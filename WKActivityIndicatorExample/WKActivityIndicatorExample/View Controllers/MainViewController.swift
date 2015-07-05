//
//  MainViewController.swift
//  WKActivityIndicatorExample
//
//  Created by Joris Vervuurt on 04-07-15.
//  Copyright (c) 2015 Joris Vervuurt Software. All rights reserved.
//

import UIKit

/// View Controller for the Main view.
class MainViewController: UIViewController {

	// MARK: - IBOutlets
	
	@IBOutlet weak var activityIndicator: WatchKitActivityIndicator!
	
	// MARK: - Functions
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
	
	// MARK: - IBActions
	
	@IBAction func startAnimatingButtonPressed(sender: UIButton) {
		self.activityIndicator.startAnimating()
	}
	
	@IBAction func stopAnimatingButtonPressed(sender: UIButton) {
		self.activityIndicator.stopAnimating(completion: { () in
			println("WatchKitActivityIndicator has stopped animating.")
		})
	}
	
}
