//
//  TooltipSide.swift
//  rythmic
//
//  Created by Antoni Silvestrovic on 24/10/2020.
//  Copyright © 2020 Quassum Manus. All rights reserved.
//

import SwiftUI

public enum TooltipSide: Int {
    case leading = 2
    case center = -1
    case trailing = 6
    case top = 4
    case bottom = 0

    case leadingTop = 3
    case leadingBottom = 1
    case trailingTop = 5
    case trailingBottom = 7

	internal var arrowRotation: Double {
		let amount: Double

		switch self {
		case .top, .leadingTop, .trailingTop:
			amount = 4

		case .bottom, .leadingBottom, .trailingBottom:
			amount = 0

		default:
			amount = Double(rawValue)
		}

		return amount * .pi / 4
	}

	internal var arrowBackgroundOffsetX: CGFloat {
		switch self {
		case .bottom, .center, .top:
			return 0
		case .leading, .leadingTop, .leadingBottom:
			return 0
		case .trailing, .trailingTop, .trailingBottom:
			return 1
		}
	}

	internal var arrowBackgroundOffsetY: CGFloat {
		switch self {
		case .leading, .center, .trailing:
			return 0
		case .top, .trailingTop, .leadingTop:
			return -1
		case .bottom, .leadingBottom, .trailingBottom:
			return 1
		}
	}
}
