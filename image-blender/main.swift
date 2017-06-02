//
//  main.swift
//  image-blender
//
//  Created by Valentine on 08.06.16.
//  Copyright © 2016 Silvansky. All rights reserved.
//

import Foundation
import Cocoa

if CommandLine.arguments.count < 3 {
	print("Usage: \(CommandLine.arguments[0]) input_file_list.txt output_file.png [min|max|mean|minred|mingreen|minblue|maxred|maxgreen|maxblue|minhue|minsaturation|maxhue|maxsaturation] [keep]")
	exit(1)
}

let inputFile = CommandLine.arguments[1]
let outputFile = CommandLine.arguments[2]

var method = Method.Max

if CommandLine.arguments.count > 3 {
	let methodRawValue = CommandLine.arguments[3]

	guard let _method = Method(rawValue: methodRawValue) else {
		print("Wrong method: \(methodRawValue)")
		exit(1)
	}

	method = _method
} else {
	print("Method is defaulted to \(method.rawValue)")
}

var keepIntermediateImages = false

if CommandLine.arguments.count > 4 {
	if CommandLine.arguments[4] == "keep" {
		keepIntermediateImages = true
	} else {
		print("Ignoring unrecognized option \(CommandLine.arguments[4])")
	}
}

var imageFiles = [String]()

do {
	let imageFileList = try String(contentsOfFile: inputFile)
	imageFiles = imageFileList.components(separatedBy: "\n").filter({ s -> Bool in
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

var blendMethod = method.blendMethod()
blendMethod.firstImageRep = firstImageRep

let outputWidth = firstImageRep.pixelsWide
let outputHeight = firstImageRep.pixelsHigh

if blendMethod.shouldRemoveFirstImage() {
	imageFiles.removeFirst()
}

var imagesPool = [NSBitmapImageRep]()
let imagesPoolSize = 20

let processPool = {
	for rep in imagesPool {
		for i in 0...outputWidth-1 {
			let x = i
			for y in 0...outputHeight-1 {
				let currentColor = firstImageRep.colorAt(x: x, y: y)!
				let nextColor = rep.colorAt(x: x, y: y)!

				blendMethod.processNextFrame(frame: rep, x: x, y: y)
			}
		}
	}

	imagesPool.removeAll()
}

for (i, imageFileName) in imageFiles.enumerated() {
	autoreleasepool(invoking: {
		guard let nextImage = NSImage(contentsOfFile: imageFileName),
			let nextImageRep = nextImage.representations[0] as? NSBitmapImageRep else {
				print("Can't read image: \(imageFileName)")
				exit(1)
		}

		if imagesPool.count >= imagesPoolSize {
			processPool()
			print("Processing: \(Int(Double(i) / Double(imageFiles.count) * 100.0))% done")
			if keepIntermediateImages {
				let tmpOutputFile = "\(outputFile)_tmp_\(i).png"
				try? firstImageRep.representation(using: NSBitmapImageFileType.PNG, properties: [:])!.write(to: URL(fileURLWithPath: tmpOutputFile), options: [.atomic]);
			}
		}

		imagesPool.append(nextImageRep)
	})
}

processPool()

let resultingImage = blendMethod.resultingImage()

try? resultingImage.representation(using: NSBitmapImageFileType.PNG, properties: [:])!.write(to: URL(fileURLWithPath: outputFile), options: [.atomic]);

print("Done! Resulting image saved to \(outputFile)")
