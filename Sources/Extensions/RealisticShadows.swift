//
//  RealisticShadows.swift
//  Prototype-Orb
//
//  Created by Siddhant Mehta on 2024-11-06.
//
import SwiftUI

struct RealisticShadowModifier: ViewModifier {
    let colors: [Color]
    let radius: CGFloat
    var spread: CGFloat = 1.0  // Multiplier for halo spread (0.5 to 2.5)

    func body(content: Content) -> some View {
        content
            .background {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .blur(radius: radius * 0.75 * spread)
                    .opacity(0.5)
                    .offset(y: radius * 0.5)
                    .scaleEffect(1.0 + (spread - 1.0) * 0.3)
            }
            .background {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .blur(radius: radius * 3 * spread)
                    .opacity(0.3 * min(spread, 1.5))
                    .offset(y: radius * 0.75)
                    .scaleEffect(1.0 + (spread - 1.0) * 0.5)
            }
    }
}
