//
//  BlendMethod.swift
//  image-blender
//
//  Created by Valentine on 02.06.17.
//  Copyright © 2017 Silvansky. All rights reserved.
//

import Foundation
import Cocoa

protocol BlendMethod {
	var firstImageRep: NSBitmapImageRep! { get set }

	func processNextFrame(frame: NSBitmapImageRep, x: Int, y: Int)

	func shouldRemoveFirstImage() -> Bool

	func resultingImage() -> NSBitmapImageRep
}

extension BlendMethod {
	static func blendMethod(m: Method) -> BlendMethod? {
		var blendMethod: BlendMethod? = nil

		switch m {
		case .Min:
			blendMethod = MinBrightnessMethod()
		case .Max:
			blendMethod = MaxBrightnessMethod()
		case .MinRed:
			blendMethod = MinRedMethod()
		case .MaxRed:
			blendMethod = MaxRedMethod()
		case .MinGreen:
			blendMethod = MinGreenMethod()
		case .MaxGreen:
			blendMethod = MaxGreenMethod()
		case .MinBlue:
			blendMethod = MinBlueMethod()
		case .MaxBlue:
			blendMethod = MaxBlueMethod()
		case .MinHue:
			blendMethod = MinHueMethod()
		case .MaxHue:
			blendMethod = MaxHueMethod()
		case .MinSaturation:
			blendMethod = MinSaturationMethod()
		case .MaxSaturation:
			blendMethod = MaxSaturationMethod()
		case .Mean:
			blendMethod = MeanMethod()
		}
		return blendMethod
	}
}
