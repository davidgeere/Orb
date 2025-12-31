//
//  AnimatedGradientView.swift
//  Orb
//
//  Created for dynamic, flowing gradient backgrounds
//

import SwiftUI

/// An animated gradient that flows and shifts over time using MeshGradient
struct AnimatedGradientView: View {
    let colors: [Color]
    let speed: Double
    
    @State private var time: Double = 0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            
            MeshGradient(
                width: 3,
                height: 3,
                points: meshPoints(time: elapsed * speed * 0.02),
                colors: meshColors
            )
        }
    }
    
    /// Generate animated mesh points that create flowing movement
    /// Points are constrained to stay well within bounds to prevent edge artifacts
    private func meshPoints(time: Double) -> [SIMD2<Float>] {
        // 3x3 grid of points that animate
        // Very small amplitude, only center points move
        let amp: Float = 0.04
        
        return [
            // Top row - ALL corners completely fixed
            SIMD2<Float>(0.0, 0.0),
            SIMD2<Float>(0.5, 0.0),  // Top middle stays fixed
            SIMD2<Float>(1.0, 0.0),
            
            // Middle row - only center moves, edges fixed
            SIMD2<Float>(0.0, 0.5),  // Left middle stays fixed
            SIMD2<Float>(
                0.5 + Float(sin(time * 0.8)) * amp,
                0.5 + Float(cos(time * 1.1)) * amp
            ),  // Center moves gently
            SIMD2<Float>(1.0, 0.5),  // Right middle stays fixed
            
            // Bottom row - ALL corners completely fixed
            SIMD2<Float>(0.0, 1.0),
            SIMD2<Float>(0.5, 1.0),  // Bottom middle stays fixed
            SIMD2<Float>(1.0, 1.0)
        ]
    }
    
    /// Expand colors to fill the 3x3 mesh grid
    private var meshColors: [Color] {
        // We need 9 colors for a 3x3 mesh
        // Distribute the input colors across the grid with variations
        
        guard !colors.isEmpty else {
            return Array(repeating: .black, count: 9)
        }
        
        if colors.count == 1 {
            return Array(repeating: colors[0], count: 9)
        }
        
        if colors.count == 2 {
            return [
                colors[0], colors[1], colors[0],
                colors[1], colors[0].opacity(0.9), colors[1],
                colors[0], colors[1], colors[0]
            ]
        }
        
        if colors.count == 3 {
            return [
                colors[0], colors[1], colors[2],
                colors[1], colors[0], colors[1],
                colors[2], colors[1], colors[0]
            ]
        }
        
        // 4+ colors - create a nice distribution
        return [
            colors[0], colors[1 % colors.count], colors[2 % colors.count],
            colors[1 % colors.count], colors[0], colors[2 % colors.count],
            colors[2 % colors.count], colors[3 % colors.count], colors[0]
        ]
    }
}

#Preview {
    AnimatedGradientView(
        colors: [.cyan, .blue, .purple, .pink],
        speed: 60
    )
    .ignoresSafeArea()
}

