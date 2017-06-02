//
//  MinMaxMethod.swift
//  image-blender
//
//  Created by Valentine on 02.06.17.
//  Copyright © 2017 Silvansky. All rights reserved.
//

import Foundation
import Cocoa

protocol MinMaxMethod: BlendMethod {
	func compare(currentColor: NSColor, nextColor: NSColor) -> Bool
}

extension MinMaxMethod {
	func processNextFrame(frame: NSBitmapImageRep, x: Int, y: Int) {
		let currentColor = firstImageRep.colorAt(x: x, y: y)!
		let nextColor = frame.colorAt(x: x, y: y)!

		if compare(currentColor: currentColor, nextColor: nextColor) {
			firstImageRep.setColor(nextColor, atX: x, y: y)
		}
	}

	func shouldRemoveFirstImage() -> Bool {
		return true
	}

	func resultingImage() -> NSBitmapImageRep {
		return firstImageRep
	}
}
