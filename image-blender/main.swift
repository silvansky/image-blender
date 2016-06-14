//
//  main.swift
//  image-blender
//
//  Created by Valentine on 08.06.16.
//  Copyright © 2016 Silvansky. All rights reserved.
//

import Foundation
import Cocoa

enum Method : String {
	case Min = "min"
	case Max = "max"

	case Mean = "mean"

	case MinRed = "minred"
	case MinGreen = "mingreen"
	case MinBlue = "minblue"

	case MaxRed = "maxred"
	case MaxGreen = "maxgreen"
	case MaxBlue = "maxblue"
}

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

	mutating func append(c: AccumulativeColor) {
		self.red += c.red
		self.green += c.green
		self.blue += c.blue
	}

	mutating func divide(i: Int) {
		let c = CGFloat(i)
		self.red /= c
		self.green /= c
		self.blue /= c
	}

	func color() -> NSColor {
		return NSColor(calibratedRed: red, green: green, blue: blue, alpha: 1)
	}
}

if Process.arguments.count < 3 {
	print("Usage: \(Process.arguments[0]) input_file_list.txt output_file.png [min|max|mean|minred|mingreen|minblue|maxred|maxgreen|maxblue]")
	exit(1)
}

let inputFile = Process.arguments[1]
let outputFile = Process.arguments[2]

var method = Method.Max

if Process.arguments.count > 3 {
	let methodRawValue = Process.arguments[3]

	guard let _method = Method(rawValue: methodRawValue) else {
		print("Wrong method: \(methodRawValue)")
		exit(1)
	}

	method = _method
} else {
	print("Method is defaulted to \(method.rawValue)")
}

var imageFiles = [String]()

do {
	let imageFileList = try String(contentsOfFile: inputFile)
	imageFiles = imageFileList.componentsSeparatedByString("\n").filter({ s -> Bool in
		return !s.isEmpty
	})

	if (imageFiles.count == 0) {
		print("No input files!")
		exit(1)
	}
} catch {
	print("Failed to load file \(inputFile)")
	exit(1)
}

guard let firstImage = NSImage(contentsOfFile: imageFiles[0]) else {
	print("Can't read first image: \(imageFiles[0])")
	exit(1)
}

guard let firstImageRep = firstImage.representations[0] as? NSBitmapImageRep else {
	print("Can't use non-raster images!")
	exit(1)
}

let outputWidth = firstImageRep.pixelsWide
let outputHeight = firstImageRep.pixelsHigh

var accumalitiveImage = [[AccumulativeColor]]()

if method == .Mean {
	accumalitiveImage = Array(count: outputWidth, repeatedValue: Array(count: outputHeight, repeatedValue: AccumulativeColor(red: 0, green: 0, blue: 0)))
} else {
	imageFiles.removeFirst()
}

var imagesPool = [NSBitmapImageRep]()
let imagesPoolSize = 20

let processPool = {
	for rep in imagesPool {
		for i in 0...outputWidth-1 {
			let x = i
			for y in 0...outputHeight-1 {
				let currentColor = firstImageRep.colorAtX(x, y: y)!
				let nextColor = rep.colorAtX(x, y: y)!

				switch method {
				case .Max:
					if currentColor.brightnessComponent < nextColor.brightnessComponent {
						firstImageRep.setColor(nextColor, atX: x, y: y)
					}
				case .Min:
					if currentColor.brightnessComponent > nextColor.brightnessComponent {
						firstImageRep.setColor(nextColor, atX: x, y: y)
					}
				case .Mean:
					accumalitiveImage[x][y].append(AccumulativeColor(c: nextColor))
				case .MinRed:
					if currentColor.redComponent > nextColor.redComponent {
						firstImageRep.setColor(nextColor, atX: x, y: y)
					}
				case .MinGreen:
					if currentColor.greenComponent > nextColor.greenComponent {
						firstImageRep.setColor(nextColor, atX: x, y: y)
					}
				case .MinBlue:
					if currentColor.blueComponent > nextColor.blueComponent {
						firstImageRep.setColor(nextColor, atX: x, y: y)
					}
				case .MaxRed:
					if currentColor.redComponent < nextColor.redComponent {
						firstImageRep.setColor(nextColor, atX: x, y: y)
					}
				case .MaxGreen:
					if currentColor.greenComponent < nextColor.greenComponent {
						firstImageRep.setColor(nextColor, atX: x, y: y)
					}
				case .MaxBlue:
					if currentColor.blueComponent < nextColor.blueComponent {
						firstImageRep.setColor(nextColor, atX: x, y: y)
					}
				}
			}
		}
	}

	imagesPool.removeAll()
}

for (i, imageFileName) in imageFiles.enumerate() {
	autoreleasepool({
		guard let nextImage = NSImage(contentsOfFile: imageFileName),
			let nextImageRep = nextImage.representations[0] as? NSBitmapImageRep else {
				print("Can't read image: \(imageFileName)")
				exit(1)
		}

		if imagesPool.count >= imagesPoolSize {
			processPool()
			print("Processing: \(Int(Double(i) / Double(imageFiles.count) * 100.0))% done")
		}

		imagesPool.append(nextImageRep)
	})
}

processPool()

if method == .Mean {
	for x in 0...outputWidth-1 {
		for y in 0...outputHeight-1 {
			accumalitiveImage[x][y].divide(imageFiles.count)
			firstImageRep.setColor(accumalitiveImage[x][y].color(), atX: x, y: y)
		}
	}
}

firstImageRep.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:])!.writeToFile(outputFile, atomically: true);

print("Done! Resulting image saved to \(outputFile)")
