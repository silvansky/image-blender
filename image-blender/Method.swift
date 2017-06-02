//
//  Method.swift
//  image-blender
//
//  Created by Valentine on 02.06.17.
//  Copyright © 2017 Silvansky. All rights reserved.
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

	case MaxHue = "maxhue"
	case MaxSaturation = "maxsaturation"

	case MinHue = "minhue"
	case MinSaturation = "minsaturation"

	func blendMethod() -> BlendMethod {
		return MaxBrightnessMethod()
	}
}
