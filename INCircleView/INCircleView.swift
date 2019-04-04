//
//  INCircleView.swift
//  INCircleView
//
//  Created by Igor Nakonetsnoi on 05/01/2019.
//  Copyright © 2019 Igor Nakonetsnoi. All rights reserved.
//

import UIKit
import os.log

@IBDesignable open class INCircleView: UIView {
	// MARK: - Open properties
	// MARK: IBInspectables
	/**
	Controls the start point of the circle. Valid values are 0 to 1, capped. Default is 0 which is at the bottom. Affected by isClockwise.
	*/
	@IBInspectable var startValue: CGFloat {
		set {
			_startValue = min(1.0, max(0.0, newValue))
			reloadLayers()
			reloadDashNumber()
		}
		get {
			return _startValue
		}
	}

	/**
	Controls the end point of the circle. Valid values are 0 to 1, capped. Deault is 1 which is at the bottom. Affected by isClockwise.
	*/
	@IBInspectable var endValue: CGFloat {
		set {
			_endValue = min(1.0, max(0.0, newValue))
			reloadLayers()
			reloadDashNumber()
		}
		get {
			return _endValue
		}
	}

	/**
	Set cap location, 0 to 1, capped. Default is 0. Affected by isClockwise.
	*/
	@IBInspectable var capLocation: CGFloat {
		set {
			_capLocation = min(1.0, max(0.0, newValue))
			reloadLayers()
		}
		get {
			return _capLocation
		}
	}

	/**
	Set cap size, 0 to 1, capped. capSize starts from the capLocation so if size is 0.1 and location is 0.8 the cap will start at 0.8 and end at 0.81. Default is 0.
	*/
	@IBInspectable var capSize: CGFloat {
		set(newValue) {
			_capSize = min(1.0, max(0.0, newValue))
			reloadLayers()
		}
		get {
			return _capSize
		}
	}

	/**
	Set the offset of the fill, 0 to 1, capped.
	*/
	@IBInspectable var fillOffset: CGFloat {
		set {
			_fillOffset =  min(1.0, max(0.0, newValue))
			reloadLayers()
		}
		get {
			return _fillOffset
		}
	}

	/**
	The color of the empty circle background. Defaults to clear.
	*/
	@IBInspectable var emptyColor: UIColor = UIColor.clear {
		didSet {
			emptyLayer.strokeColor = emptyColor.cgColor
		}
	}

	/**
	The color shown for the cap. Defaults to clear.
	*/
	@IBInspectable var capColor: UIColor = UIColor.clear {
		didSet {
			capLayer.strokeColor = capColor.cgColor
		}
	}

	/**
	The background color. Defaults to clear.
	*/
	@IBInspectable var emptyBackgroundColor: UIColor = UIColor.clear {
		didSet {
			emptyBackgroundLayer.fillColor = emptyBackgroundColor.cgColor
		}
	}

	/**
	The line width of the circle view. Defaults to 5.
	*/
	@IBInspectable var lineWidth: CGFloat = 5 {
		didSet {
			for layer in filledLayers {
				layer.lineWidth = lineWidth
			}
			emptyLayer.lineWidth = lineWidth
			capLayer.lineWidth = lineWidth
			layer.layoutSublayers()
			updateRadius(radius)
			reloadLayers()
		}
	}

	/**
	Defaults to the size of the container view.
	*/
	@IBInspectable var radius: CGFloat {
		set {
			updateRadius(newValue)
		}
		get {
			return _radius
		}
	}

	/**
	Defaults to false.
	*/
	@IBInspectable var isClockwise: Bool =  true {
		didSet {
			reloadLayers()
		}
	}

	/**
	Sets corner style for the fill layers. Defaults to false.
	*/
	@IBInspectable var roundedCorners: Bool = false {
		didSet {
			reloadLayers()
		}
	}

	/**
	Sets the lineDashPattern to have a number of equaly sized dashes. Adjusted to the size of the circle according to the start/end values
	*/
	@IBInspectable var dashNumber: Int = 0 {
		// TODO: Fix an issue where the line width affects the size/spacing of dashes.
		didSet {
			reloadDashNumber()
		}
	}

	// MARK: - Open properties
	/**
	The dash pattern is specified as an array of NSNumber objects that specify the lengths of the painted segments and unpainted segments, respectively, of the dash pattern.
	
	For example, passing an array with the values [2,3] sets a dash pattern that alternates between a 2-user-space-unit-long painted segment and a 3-user-space-unit-long unpainted segment. Passing the values [10,5,5,5] sets the pattern to a 10-unit painted segment, a 5-unit unpainted segment, a 5-unit painted segment, and a 5-unit unpainted segment.
	
	Default is nil, a solid line.
	*/
	var lineDashPattern: [NSNumber]? {
		// TODO: Fix an issue where the second layer does not start with the correct dash pattern.
		didSet {
			for layer in filledLayers {
				layer.lineDashPattern = lineDashPattern
			}
			emptyLayer.lineDashPattern = lineDashPattern
		}
	}
	
	// MARK: - Private properties
	// MARK: IBDesignable private properties
	private var _fillOffset: CGFloat = 0
	private var _startValue: CGFloat = 0
	private var _endValue: CGFloat = 1
	private var _radius: CGFloat = 0
	private var _capLocation: CGFloat = 0
	private var _capSize: CGFloat = 0

	// MARK: Other properties
	private var shouldUpdateLayers: Bool = false

	private lazy var emptyLayer: CAShapeLayer = {
		let layer = CAShapeLayer()
		layer.lineWidth = lineWidth
		layer.strokeColor = emptyColor.cgColor
		layer.fillColor = UIColor.clear.cgColor
		layer.path = emptyCirclePath()
		layer.lineDashPattern = lineDashPattern
		return layer
	}()

	private lazy var emptyBackgroundLayer: CAShapeLayer = {
		let layer = CAShapeLayer()
		layer.path = emptyCircleBackgroundPath()
		layer.fillColor = UIColor.clear.cgColor
		return layer
	}()

	private lazy var capLayer: CAShapeLayer = {
		let layer = CAShapeLayer()
		layer.lineWidth = lineWidth
		layer.strokeColor = capColor.cgColor
		layer.fillColor = UIColor.clear.cgColor
		layer.path = indicatorCirclePath()
		return layer
	}()

	private var filledLayers = [CAShapeLayer]()
	private var fillValues = [Float]()
	private var fillColors = [UIColor]()
	private var totalFillValue: Float {
		return fillValues.reduce(0, +)
	}

	private let logCircleView = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "INCircleView")

	// MARK: - Public inits
	public override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}

	// MARK: - View lifecycle
	open override func didMoveToSuperview() {
		if radius == 0 {
			updateRadius(frame.size.width / 2)
		}
	}
}

// MARK: - Public
public extension INCircleView {
	/**
	FillColours are the color shown for the filled part(s). Defaults to clear.
	FillValues specify how much of the visible gauge is filled with the fill Color(s). Defaults to 0. Range 0 to 1, capped to those values.
	The number of objects in both arrays must match.
	*/
	func set(fillColors: [UIColor], fillValues: [Float]) {
		guard fillColors.count == fillValues.count else {
			os_log("Fill colors and fill values counts do not match.", log: logCircleView, type: .debug)
			return
		}
		
		self.fillColors = fillColors
		shouldUpdateLayers = true
		
		update(fillValues: fillValues)
	}
	
	func update(fillValues: [Float]) {
		guard fillValues.count == fillColors.count else {
			os_log("Fill values count is incorrect, internal error.", log: logCircleView, type: .debug)
			return
		}
		
		if self.fillValues.count != fillValues.count {
			createFilledLayersWith(fillValues: fillValues)
		}

		if self.fillValues != fillValues || shouldUpdateLayers {
			shouldUpdateLayers = false
			var accumulatedOffset: CGFloat = 0

			for (index, layer) in filledLayers.enumerated() {
				let fillValue = CGFloat(min(1.0, max(0.0, fillValues[index])))
				let fillColor = fillColors[index]
				layer.strokeStart = accumulatedOffset
				layer.strokeEnd = fillValue + accumulatedOffset
				layer.strokeColor = fillColor.cgColor

				accumulatedOffset += fillValue
			}
			
			self.fillValues = fillValues
			layer.layoutSublayers()
		}
	}
}

// MARK: - Pivate
private extension INCircleView {
	func setup() {
		layer.addSublayer(emptyBackgroundLayer)
		layer.addSublayer(emptyLayer)
	}
	
	func createFilledLayersWith(fillValues: [Float]) {
		filledLayers.forEach({ $0.removeFromSuperlayer()})

		for (index, _) in fillValues.enumerated() {
			let filledLayer = CAShapeLayer()
			filledLayer.lineWidth = lineWidth
			if fillColors.count > index {
				filledLayer.strokeColor = fillColors[index].cgColor
			}else {
				filledLayer.strokeColor = UIColor.clear.cgColor
			}
			filledLayer.fillColor = UIColor.clear.cgColor
			filledLayer.path = fillCirclePath()
			filledLayer.lineDashPattern = lineDashPattern
			layer.addSublayer(filledLayer)
			filledLayers.append(filledLayer)
		}
		
		// TODO: It would be good to update this to use zPosition
		capLayer.removeFromSuperlayer()
		layer.addSublayer(capLayer)
	}

	func updateRadius(_ radius: CGFloat) {
		_radius = abs(radius) - lineWidth / 2
	}

	func reloadLayers() {
		set(fillColors: fillColors, fillValues: fillValues)
	}

	func reloadDashNumber() {
		if dashNumber == 0 { return }
		let circumference = 2 * Double.pi * Double(endValue - startValue) * Double(radius)
		let dashSize = circumference / Double(dashNumber * 2)
		lineDashPattern = [NSNumber(floatLiteral: dashSize), NSNumber(floatLiteral: dashSize)]
	}
}

// MARK: - Paths generation
private extension INCircleView {
	func convertValueToAngle( _ value: CGFloat) -> CGFloat {
		return value * CGFloat.pi * 2 + CGFloat.pi / 2
	}

	var arcCenter: CGPoint {
		return CGPoint(x: bounds.midX, y: bounds.midY)
	}
	
	var startAngle: CGFloat {
		let angle = convertValueToAngle(startValue)
		return isClockwise ? angle : CGFloat.pi - angle
	}
	
	var endAngle: CGFloat {
		let angle = convertValueToAngle(endValue)
		return isClockwise ? angle : CGFloat.pi - angle
	}
	
	func fillCirclePath() -> CGPath {
		let startAngle = self.startAngle + (isClockwise ? fillOffset : -fillOffset)
		let endAngle = self.endAngle + (isClockwise ? fillOffset : -fillOffset)
		let path = UIBezierPath(arcCenter: arcCenter,
								radius: radius,
								startAngle: startAngle,
								endAngle: endAngle,
								clockwise: isClockwise)
		return path.cgPath
	}
	
	func emptyCirclePath() -> CGPath {
		let path = UIBezierPath(arcCenter: arcCenter,
								radius: radius,
								startAngle: startAngle,
								endAngle: endAngle,
								clockwise: isClockwise)
		return path.cgPath
	}

	func emptyCircleBackgroundPath() -> CGPath {
		let path = UIBezierPath()
		path.move(to: CGPoint(x: arcCenter.x, y: arcCenter.y))
		path.addArc(withCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: isClockwise)
		path.close()
		return path.cgPath
	}

	func indicatorCirclePath() -> CGPath {
		var startAngle = convertValueToAngle(capLocation)
		var endAngle = convertValueToAngle(capLocation + capSize)

		if !isClockwise {
			startAngle = CGFloat.pi - startAngle
			endAngle = CGFloat.pi - endAngle
		}

		let path = UIBezierPath(arcCenter: arcCenter,
								radius: radius,
								startAngle: startAngle,
								endAngle: endAngle,
								clockwise: isClockwise)
		return path.cgPath
	}
}

// MARK: - CALayerDelegate
extension INCircleView {
	override open func layoutSublayers(of layer: CALayer) {
		super.layoutSublayers(of: layer)
		
		guard layer == self.layer else {
			os_log("Root layer is missing, internal error.", log: logCircleView, type: .debug)
			return
		}

		filledLayers.forEach({
			$0.path = fillCirclePath()
			if roundedCorners {
				$0.lineCap = .round
			}else {
				$0.lineCap = .butt
			}
		})
		
		emptyLayer.path = emptyCirclePath()
		emptyBackgroundLayer.path = emptyCircleBackgroundPath()
		capLayer.path = indicatorCirclePath()

		if roundedCorners {
			emptyLayer.lineCap = .round
		}else {
			emptyLayer.lineCap = .butt
		}

	}
}
