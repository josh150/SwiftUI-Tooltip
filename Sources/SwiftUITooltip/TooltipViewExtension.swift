//
//  TooltipViewExtension.swift
//  rythmic
//
//  Created by Antoni Silvestrovic on 24/10/2020.
//  Copyright © 2020 Quassum Manus. All rights reserved.
//

import SwiftUI

public extension View {
    func tooltip<TooltipContent: View>(@ViewBuilder content: @escaping () -> TooltipContent) -> some View {
        modifier(TooltipModifier(config: DefaultTooltipConfig.shared, content: content))
    }

    func tooltip<TooltipContent: View>(config: TooltipConfig, @ViewBuilder content: @escaping () -> TooltipContent) -> some View {
        modifier(TooltipModifier(config: config, content: content))
    }

    func tooltip<TooltipContent: View>(_ side: TooltipSide, @ViewBuilder content: @escaping () -> TooltipContent) -> some View {
       modifier(TooltipModifier(config: DefaultTooltipConfig.shared.with(side: side), content: content))
    }
    
    func tooltip<TooltipContent: View>(_ side: TooltipSide, config: TooltipConfig, @ViewBuilder content: @escaping () -> TooltipContent) -> some View {
        modifier(TooltipModifier(config: config.with(side: side), content: content))
    }
}
