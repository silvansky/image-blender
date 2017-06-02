//
//  AccumulativeColor.swift
//  image-blender
//
//  Created by Valentine on 02.06.17.
//  Copyright © 2017 Silvansky. All rights reserved.
//

import Foundation
import Cocoa

struct AccumulativeColor {
	var red: CGFloat
	var green: CGFloat
	var blue: CGFloat

	init(red: CGFloat, green: CGFloat, blue: CGFloat) {
		self.red = red
		self.green = green
		self.blue = blue
	}

	init(c: NSColor) {
		self.red = c.redComponent
		self.green = c.greenComponent
		self.blue = c.blueComponent
	}

	mutating func append(_ c: AccumulativeColor) {
		self.red += c.red
		self.green += c.green
		self.blue += c.blue
	}

	mutating func divide(_ i: Int) {
		let c = CGFloat(i)
		self.red /= c
		self.green /= c
		self.blue /= c
	}

	func color() -> NSColor {
		return NSColor(calibratedRed: red, green: green, blue: blue, alpha: 1)
	}
}
