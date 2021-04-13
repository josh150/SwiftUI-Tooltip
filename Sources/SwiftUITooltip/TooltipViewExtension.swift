//
//  TooltipViewExtension.swift
//  rythmic
//
//  Created by Antoni Silvestrovic on 24/10/2020.
//  Copyright © 2020 Quassum Manus. All rights reserved.
//

import SwiftUI

public extension View {
	func tooltip<TooltipContent: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> TooltipContent) -> some View {
        modifier(TooltipModifier(isPresented: isPresented, config: DefaultTooltipConfig.shared, content: content))
    }

    func tooltip<TooltipContent: View>(isPresented: Binding<Bool>, config: TooltipConfig, @ViewBuilder content: @escaping () -> TooltipContent) -> some View {
        modifier(TooltipModifier(isPresented: isPresented, config: config, content: content))
    }

    func tooltip<TooltipContent: View>(isPresented: Binding<Bool>, side: TooltipSide, @ViewBuilder content: @escaping () -> TooltipContent) -> some View {
       modifier(TooltipModifier(isPresented: isPresented, config: DefaultTooltipConfig.shared.with(side: side), content: content))
    }
    
    func tooltip<TooltipContent: View>(isPresented: Binding<Bool>, side: TooltipSide, config: TooltipConfig, @ViewBuilder content: @escaping () -> TooltipContent) -> some View {
        modifier(TooltipModifier(isPresented: isPresented, config: config.with(side: side), content: content))
    }
}
