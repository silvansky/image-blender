//
//  MaxBlueMethod.swift
//  image-blender
//
//  Created by Valentine on 02.06.17.
//  Copyright © 2017 Silvansky. All rights reserved.
//

import Foundation
import Cocoa

class MaxBlueMethod: MinMaxMethod {
	var firstImageRep: NSBitmapImageRep!

	func compare(currentColor: NSColor, nextColor: NSColor) -> Bool {
		return currentColor.blueComponent < nextColor.blueComponent
	}
}
