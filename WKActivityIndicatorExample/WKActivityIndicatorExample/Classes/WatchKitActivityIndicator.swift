//
//  WatchKitActivityIndicator.swift
//  WatchKitActivityIndicator
//
//  Created by Andy Drizen on 03/01/2015.
//  Copyright (c) 2015 Andy Drizen. All rights reserved.
//

//
//  Rewritten by Joris Vervuurt on 07/01/15, based on the initial code by Andy Drizen.
//	Website: https://www.joris-vervuurt.com
//
//	+ Added comments and pragma marks.
//	+ Added lots of customization options; from color to speed-related variables.
//	+ @IBDesignable and @IBInspectable properties: the activity indicator can now be used and customized within Interface Builder.
//

import UIKit

/// Interface Builder-designable implementation of the WatchKit activity indicator for iOS.
@IBDesignable class WatchKitActivityIndicator: UIView {
	
	// MARK: - Type Aliases
	
	/// The definition of a generic completion closure (no parameters and no return value).
	typealias CompletionClosure = () -> Void
	
	// MARK: - Properties
	
	/// The number of balls to draw.
	@IBInspectable var ballCount: Int = 6
	
	/// The margin around each ball.
	@IBInspectable var ballMargin: CGFloat = 2.0
	
	/// The color of the activity indicator.
	@IBInspectable var color: UIColor = UIColor.whiteColor()
	
	/// The initial speed of the activity indicator.
	@IBInspectable var initialSpeed: CGFloat = 3.0
	
	/// The speed increment rate of the activity indicator.
	@IBInspectable var speedIncrementRate: CGFloat = 2.0
	
	/// The maximum speed of the activity indicator.
	@IBInspectable var maximumSpeed: CGFloat = 5.0
	
	/// The growth rate of the activity indicator (used for scaling each ball).
	@IBInspectable var growthRate: CGFloat = 0.08
	
	// MARK: - Private Fields
	
	/// The display link used for drawing the activity indicator at the refresh rate of the display.
	private var displayLink: CADisplayLink!
	
	/// The current speed of the activity indicator.
	private var speed: CGFloat!
	
	/// The current angle offset of the activity indicator.
	private var angleOffset: CGFloat!
	
	/// An array containing alpha values for all balls.
	private var alphaValues: [CGFloat]!
	
	/// An array containing scale values for all balls.
	private var scaleValues: [CGFloat]!
	
	/// A value that indicates whether the activity indicator is animating.
	private var isAnimating: Bool = false
	
	/// A value that indicates whether the activity indicator should stop animating.
	private var shouldStopAnimating: Bool = false
	
	/// The completion closure to call when the activity indicator has stopped animating.
	private var stopAnimatingCompletionClosure: CompletionClosure?
	
	// MARK: - Initializers
	
	/**
		Common initializer.
	*/
	private func commonInit() {
		// If the background is set to Default (nil), set it to a clear color.
		self.backgroundColor = self.backgroundColor ?? UIColor.clearColor()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.commonInit()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		self.commonInit()
	}
	
	// MARK: - Functions
	
	/**
		Starts animating the activity indicator.
	*/
	func startAnimating() {
		if !self.isAnimating {
			self.reset()
			
			self.displayLink = CADisplayLink(target: self, selector: "prepareForNextFrame")
			self.displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
			
			self.isAnimating = true
		}
	}
	
	/**
		Stops animating the activity indicator.
	*/
	func stopAnimating(#completion: CompletionClosure?) {
		if self.isAnimating {
			self.stopAnimatingCompletionClosure = completion
			self.shouldStopAnimating = true
		}
	}
	
	/**
		Sets all variables for the next frame.
	*/
	func prepareForNextFrame() {
		if self.speed < self.maximumSpeed {
			self.speed = self.speed + (self.speedIncrementRate * self.growthRate)
			
			if self.speed > self.maximumSpeed {
				self.speed = self.maximumSpeed
			}
		}
		
		self.angleOffset = self.angleOffset - self.speed
		
		if self.shouldStopAnimating {
			if maxElement(self.alphaValues) > 0 {
				for i in 0..<self.ballCount {
					self.alphaValues[i] = max(0, self.alphaValues[i] - self.growthRate)
				}
			}
			
			if maxElement(self.alphaValues) == 0 {
				if self.stopAnimatingCompletionClosure != nil {
					self.stopAnimatingCompletionClosure!()
				}
				
				self.reset()
			}
		} else {
			let minimumAlphaValue: CGFloat = minElement(self.alphaValues)
			let minimumScaleValue: CGFloat = minElement(self.scaleValues)
			
			if minimumAlphaValue < 1 || minimumScaleValue < 1 {
				for i in 0..<self.ballCount {
					if minimumAlphaValue < 1 && self.alphaValues[i] < 1 {
						self.alphaValues[i] = min(1, self.alphaValues[i] + self.growthRate)
					}
				
					if minimumScaleValue < 1 && self.scaleValues[i] < 1 {
						self.scaleValues[i] = min(1, self.scaleValues[i] + self.growthRate)
					}
				}
			}
		}
		
		self.setNeedsDisplay()
	}
	
	#if TARGET_INTERFACE_BUILDER
		// Only override the prepareForInterfaceBuilder function when the target is Interface Builder.
	
		override func prepareForInterfaceBuilder() {
			self.layer.borderWidth = 1.0
			self.layer.borderColor = self.color.CGColor
	
			let label: UILabel = UILabel(frame: self.bounds)
			label.frame = CGRectInset(label.frame, 10.0, 10.0)
			label.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
			label.textColor = self.color
			label.textAlignment = .Center
			label.numberOfLines = 0
			label.lineBreakMode = .ByWordWrapping
			label.text = "WatchKitActivityIndicator"
			self.addSubview(label)
		}
	#else
		// Only override the drawRect function when the target is not Interface Builder.
	
		override func drawRect(rect: CGRect) {
			if self.isAnimating {
				let context: CGContext = UIGraphicsGetCurrentContext()
				
				let center: CGPoint = CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMidY(rect))
				let ballSize: CGFloat = floor(CGRectGetWidth(rect) / (CGFloat(self.ballCount) / 2)) - self.ballMargin
				let radius: Double = Double(CGRectGetWidth(rect) - ballSize) / 2
				
				for ballIndex in 0..<self.ballCount {
					let size: CGFloat = ballSize * self.scaleValues[ballIndex]
					let angle: Double = -M_PI_2 + (M_PI/180 * (Double(CGFloat(ballIndex) * (360.0 / CGFloat(self.ballCount))) + Double(self.angleOffset)))
					let x = center.x + CGFloat(sin(angle) * radius)
					let y = center.y + CGFloat(cos(angle) * radius)
					
					self.color.colorWithAlphaComponent(self.alphaValues[ballIndex]).set()
					
					CGContextAddEllipseInRect(context, CGRect(x: x - (size / 2), y: y - (size / 2), width: size, height: size))
					CGContextDrawPath(context, kCGPathFill)
				}
			}
		}
	#endif
	
	// MARK: - Private Functions
	
	/**
		Resets all variables.
	*/
	private func reset() {
		if self.isAnimating {
			if self.displayLink != nil {
				self.displayLink.invalidate()
			}
			
			self.shouldStopAnimating = false
			self.stopAnimatingCompletionClosure = nil
			
			self.isAnimating = false
		}
		
		self.speed = self.initialSpeed
		self.angleOffset = 0.0
		
		self.alphaValues = []
		self.scaleValues = []
		
		for ballIndex in 0..<self.ballCount {
			let alphaAndScaleValue: CGFloat = 0.2 - (CGFloat((self.ballCount - 1) - ballIndex) * 0.3)
			self.alphaValues.append(alphaAndScaleValue)
			self.scaleValues.append(alphaAndScaleValue)
		}
	}

}
