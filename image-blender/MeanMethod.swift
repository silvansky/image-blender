//
//  MeanMethod.swift
//  image-blender
//
//  Created by Valentine on 02.06.17.
//  Copyright © 2017 Silvansky. All rights reserved.
//

import Foundation
import Cocoa

class MeanMethod: BlendMethod {
	var firstImageRep: NSBitmapImageRep!

	private var outputWidth = 0
	private var outputHeight = 0

	lazy var accumalitiveImage: [[AccumulativeColor]]! = nil

	func processNextFrame(frame: NSBitmapImageRep, x: Int, y: Int) {
		if accumalitiveImage == nil {
			outputWidth = firstImageRep.pixelsWide
			outputHeight = firstImageRep.pixelsHigh

			accumalitiveImage = Array(repeating: Array(repeating: AccumulativeColor(red: 0, green: 0, blue: 0), count: outputHeight), count: outputWidth)
		}
		let nextColor = frame.colorAt(x: x, y: y)!
		accumalitiveImage[x][y].append(AccumulativeColor(c: nextColor))
	}

	func shouldRemoveFirstImage() -> Bool {
		return false
	}

	func resultingImage() -> NSBitmapImageRep {
		for x in 0...outputWidth-1 {
			for y in 0...outputHeight-1 {
				accumalitiveImage[x][y].divide(imageFiles.count)
				firstImageRep.setColor(accumalitiveImage[x][y].color(), atX: x, y: y)
			}
		}

		return firstImageRep
	}
}
