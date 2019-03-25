//
//  ViewController.swift
//  INCircleView
//
//  Created by Igor Nakonetsnoi on 05/01/2019.
//  Copyright © 2019 Igor Nakonetsnoi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var circleView: INCircleView! {
		didSet {
			circleView.set(fillColors: [.green], fillValues: [0.5])
		}
	}
	
	@IBOutlet weak var circleView2: INCircleView! {
		didSet {
			circleView2.set(fillColors: [.green], fillValues: [0.7])
		}
	}

	@IBOutlet weak var circleView3: INCircleView! {
		didSet {
			circleView3.set(fillColors: [.yellow], fillValues: [0.1])
		}
	}

	@IBOutlet weak var circleView4: INCircleView! {
		didSet {
			circleView4.set(fillColors: [.blue], fillValues: [0.3])
		}
	}

	@IBOutlet weak var circleView5: INCircleView! {
		didSet {
			circleView5.set(fillColors: [.green, .red, .yellow, .blue], fillValues: [0.1, 0.3, 0.5, 0.1])
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
			DispatchQueue.main.async {
				let randomValue = Float.random(min: 0, max: 1)
				self.circleView.update(fillValues: [randomValue])
				self.circleView2.update(fillValues: [randomValue])
				self.circleView3.update(fillValues: [randomValue])
				self.circleView4.update(fillValues: [randomValue])

				let randomSmallValue = Float.random(min: 0, max: 0.5)
				self.circleView5.update(fillValues: [0.1, 0.3, randomSmallValue, 0.1])
			}
		}
	}
}

public extension Float {

	/// Returns a random floating point number between 0.0 and 1.0, inclusive.
	public static var random: Float {
		return Float(arc4random()) / 0xFFFFFFFF
	}

	/// Random float between 0 and n-1.
	///
	/// - Parameter n:  Interval max
	/// - Returns:      Returns a random float point number between 0 and n max
	public static func random(min: Float, max: Float) -> Float {
		return Float.random * (max - min) + min
	}
}
