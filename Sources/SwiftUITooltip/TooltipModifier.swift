//
//  Tooltip.swift
//  rythmic
//
//  Created by Antoni Silvestrovic on 19/10/2020.
//  Copyright © 2020 Quassum Manus. All rights reserved.
//

import SwiftUI

struct TooltipModifier<TooltipContent: View>: ViewModifier {
    // MARK: - Uninitialised properties
	@Binding var isPresented: Bool
    var config: TooltipConfig
    var content: TooltipContent

    // MARK: - Initialisers

	init(isPresented: Binding<Bool>, config: TooltipConfig, @ViewBuilder content: @escaping () -> TooltipContent) {
		self._isPresented = isPresented
		self.config = config
        self.content = content()
    }

    // MARK: - Local state

    @State private var contentWidth: CGFloat = 10
    @State private var contentHeight: CGFloat = 10
    
    @State var animationOffset: CGFloat = 0

    // MARK: - Computed properties

    var actualArrowHeight: CGFloat { config.showArrow ? config.arrowHeight : 0 }

    var arrowOffsetX: CGFloat {
        switch config.side {
        case .bottom, .center, .top:
            return 0

        case .leading:
            return (contentWidth / 2 + config.arrowHeight / 2)

        case .leadingTop, .leadingBottom:
            return (contentWidth / 2
                - config.borderRadius / 2
                - config.borderWidth / 2
				- config.arrowWidth)

        case .trailing:
            return -(contentWidth / 2 + config.arrowHeight / 2)

        case .trailingTop, .trailingBottom:
            return -(contentWidth / 2
                - config.borderRadius / 2
                - config.borderWidth / 2
				- config.arrowWidth)
        }
    }

    var arrowOffsetY: CGFloat {
        switch config.side {
        case .leading, .center, .trailing:
            return 0

        case .top:
            return (contentHeight / 2 + config.arrowHeight / 2)

        case .trailingTop, .leadingTop:
            return (contentHeight / 2
                + config.arrowHeight / 2
                - config.borderRadius / 2
                - config.borderWidth / 2
				+ 1)

        case .bottom:
            return -(contentHeight / 2 + config.arrowHeight / 2)

        case .leadingBottom, .trailingBottom:
            return -(contentHeight / 2
                + config.arrowHeight / 2
                - config.borderRadius / 2
                - config.borderWidth / 2)
        }
    }


    // MARK: - Helper functions

    private func offsetHorizontal(_ g: GeometryProxy) -> CGFloat {
		let offset: CGFloat

        switch config.side {
        case .leading:
			offset = -(contentWidth + config.marginX + actualArrowHeight + animationOffset)

		case .leadingTop, .leadingBottom:
			offset = -(contentWidth + config.marginX + actualArrowHeight + animationOffset)

        case .trailing, .trailingTop, .trailingBottom:
			offset = g.size.width + config.marginX + actualArrowHeight + animationOffset

        case .top, .center, .bottom:
            offset = (g.size.width - contentWidth) / 2
        }


		return offset
    }

    private func offsetVertical(_ g: GeometryProxy) -> CGFloat {
        switch config.side {
        case .top, .trailingTop, .leadingTop:
            return -(contentHeight + config.marginY + actualArrowHeight + animationOffset)
        case .bottom, .leadingBottom, .trailingBottom:
            return g.size.height + config.marginY + actualArrowHeight + animationOffset
        case .leading, .center, .trailing:
            return (g.size.height - contentHeight) / 2
        }
    }
    
    // MARK: - Animation stuff
    
    private func dispatchAnimation() {
		guard config.enableAnimation else { return }

		DispatchQueue.main.asyncAfter(deadline: .now() + config.animationTime) {
			self.animationOffset = config.animationOffset
			
			DispatchQueue.main.asyncAfter(deadline: .now() + config.animationTime*0.1) {
				self.animationOffset = 0
				self.dispatchAnimation()
			}
		}
    }

    // MARK: - TooltipModifier Body Properties

    private var sizeMeasurer: some View {
        GeometryReader { g in
            Text("")
                .onAppear {
                    self.contentWidth = g.size.width
                    self.contentHeight = g.size.height
                }
        }
    }

    private var arrowView: some View {
		ArrowShape()
			.rotation(Angle(radians: config.side.arrowRotation))
			.stroke(
				self.config.borderWidth == 0 ? Color.clear : self.config.borderColor,
				lineWidth: self.config.borderWidth
			)
			.background(
				ArrowShape()
					.rotation(Angle(radians: config.side.arrowRotation))
					.fill(self.config.backgroundColor)
					.offset(x: config.side.arrowBackgroundOffsetX, y: config.side.arrowBackgroundOffsetY)
			)
            .frame(
				width: self.config.arrowWidth,
				height: self.config.arrowHeight
			)
			.offset(x: self.arrowOffsetX, y: self.arrowOffsetY)

    }

    private var arrowCutoutMask: some View {
		ZStack {
            Rectangle()
                .frame(
                    width: self.contentWidth + self.config.borderWidth * 2,
                    height: self.contentHeight + self.config.borderWidth * 2
				)
                .foregroundColor(.white)

            Rectangle()
                .frame(
                    width: self.config.arrowWidth,
                    height: self.config.arrowHeight + self.config.borderWidth
				)
                .rotationEffect(Angle(radians: config.side.arrowRotation))
                .offset(
                    x: self.arrowOffsetX,
                    y: self.arrowOffsetY
				)
                .foregroundColor(.black)
        }
        .compositingGroup()
        .luminanceToAlpha()
    }

    var tooltipBody: some View {
        GeometryReader { g in
            ZStack {
                RoundedRectangle(cornerRadius: self.config.borderRadius)
					.stroke(
						self.config.borderWidth == 0 ? Color.clear : self.config.borderColor,
						lineWidth: self.config.borderWidth
					)
					.background(
						RoundedRectangle(cornerRadius: self.config.borderRadius)
							.fill(self.config.backgroundColor)
					)
                    .frame(width: self.contentWidth, height: self.contentHeight)
                    .mask(self.arrowCutoutMask)

                ZStack {
                    content
                        .padding(self.config.contentPaddingEdgeInsets)
                }
				.background(self.sizeMeasurer)
				.overlay(self.arrowView)
            }
			.offset(x: self.offsetHorizontal(g), y: self.offsetVertical(g))
			.animation(config.enableAnimation ? .easeInOut : nil)
            .onAppear {
                self.dispatchAnimation()
            }
        }
    }

    // MARK: - ViewModifier properties

    func body(content: Content) -> some View {
		Group {
			if isPresented {
				content
					.overlay(tooltipBody)
			} else {
				content
			}
		}
    }
}

struct Tooltip_Previews: PreviewProvider {
	struct PreviewView: View {
		let customConfig: TooltipConfig = {
			var copy = DefaultTooltipConfig()
			copy.enableAnimation = false
			copy.backgroundColor = Color.white
			copy.borderColor = Color.green
			copy.borderRadius = 0
			copy.side = .leadingTop
			copy.arrowWidth = 25
			copy.arrowHeight = 15
			copy.contentPaddingLeft = 0
			copy.contentPaddingRight = 0
			copy.contentPaddingTop = 0
			copy.contentPaddingBottom = 0
			copy.marginX -= 65
			return copy
		}()

		@State private var isPresented: Bool = true

		var body: some View {
			VStack(spacing: 100) {
				Text("Say something nice...")
					.tooltip(isPresented: .constant(true)) {
						Text("Something nice!")
					}

				Text("Say something nice...")
					.tooltip(isPresented: .constant(true), side: .top) {
						Text("Something!")
					}

				HStack {
					Spacer()

					Image(systemName: "heart")
						.font(.system(size: 30))
						.onTapGesture {
							withAnimation { isPresented.toggle() }
						}
						.tooltip(isPresented: $isPresented, side: .leadingTop, config: customConfig) {
							VStack {
								Text("Something nice!")
							}
							.frame(minWidth: 260, minHeight: 150)
						}
				}
			}
			.frame(maxWidth: .infinity)
			.padding()
			.background(Color.red)
		}
	}

    static var previews: some View {
		PreviewView()
			.previewDevice("iPhone 12")
    }
}
