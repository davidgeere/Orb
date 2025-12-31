//
//  OrbConfiguration.swift
//  Orb
//
//  Created by Siddhant Mehta on 2024-11-08.
//  Modified to support dynamic audio-reactive updates
//

import SwiftUI

/// Configuration for the Orb view that supports dynamic audio-reactive updates
@Observable
public final class OrbConfiguration {
    // MARK: - Computed Colors Based on State
    
    public var glowColor: Color
    public var backgroundColors: [Color]
    public var particleColor: Color
    
    // MARK: - Feature Toggles
    
    public var showBackground: Bool
    public var showWavyBlobs: Bool
    public var showParticles: Bool
    public var showGlowEffects: Bool
    public var showShadow: Bool
    
    // MARK: - Dynamic Properties
    
    public var coreGlowIntensity: Double
    public var speed: Double
    public var haloSpread: Double  // Controls outer glow/shadow spread (0.5 to 2.0)
    public var particleErraticness: Double  // How erratic particle movement is (0 to 1)
    
    // MARK: - Initialization
    
    public init(
        backgroundColors: [Color] = [.white, Color(white: 0.85), Color(red: 1.0, green: 0.9, blue: 0.6)],
        glowColor: Color = .white,
        particleColor: Color = .white,
        coreGlowIntensity: Double = 0.5,
        showBackground: Bool = true,
        showWavyBlobs: Bool = true,
        showParticles: Bool = true,
        showGlowEffects: Bool = true,
        showShadow: Bool = true,
        speed: Double = 30,
        haloSpread: Double = 1.0,
        particleErraticness: Double = 0.3
    ) {
        self.backgroundColors = backgroundColors
        self.glowColor = glowColor
        self.particleColor = particleColor
        self.showBackground = showBackground
        self.showWavyBlobs = showWavyBlobs
        self.showParticles = showParticles
        self.showGlowEffects = showGlowEffects
        self.showShadow = showShadow
        self.coreGlowIntensity = coreGlowIntensity
        self.speed = speed
        self.haloSpread = haloSpread
        self.particleErraticness = particleErraticness
    }
    
    // MARK: - Audio-Reactive Update
    
    /// Updates the orb configuration based on audio input/output states
    /// - Parameters:
    ///   - inputActive: Whether input source is active
    ///   - outputActive: Whether output source is active
    ///   - inputLevel: Input level (0-100)
    ///   - inputHigh: Input high frequency (0-100)
    ///   - inputMid: Input mid frequency (0-100)
    ///   - inputLow: Input low frequency (0-100)
    ///   - outputLevel: Output level (0-100)
    ///   - outputHigh: Output high frequency (0-100)
    ///   - outputMid: Output mid frequency (0-100)
    ///   - outputLow: Output low frequency (0-100)
    public func update(
        inputActive: Bool,
        outputActive: Bool,
        inputLevel: Float,
        inputHigh: Float,
        inputMid: Float,
        inputLow: Float,
        outputLevel: Float,
        outputHigh: Float,
        outputMid: Float,
        outputLow: Float
    ) {
        // Normalize values to 0-1
        let inLevel = Double(inputLevel) / 100.0
        let inHigh = Double(inputHigh) / 100.0
        let inMid = Double(inputMid) / 100.0
        let inLow = Double(inputLow) / 100.0
        
        let outLevel = Double(outputLevel) / 100.0
        let outHigh = Double(outputHigh) / 100.0
        let outMid = Double(outputMid) / 100.0
        let outLow = Double(outputLow) / 100.0
        
        // Determine state and compute blended values
        let isIdle = !inputActive && !outputActive
        let isBoth = inputActive && outputActive
        
        // Compute effective values based on active sources
        let effectiveLevel: Double
        let effectiveHigh: Double
        let effectiveMid: Double
        let effectiveLow: Double
        
        if isIdle {
            effectiveLevel = 0.2
            effectiveHigh = 0.15
            effectiveMid = 0.2
            effectiveLow = 0.15
        } else if isBoth {
            effectiveLevel = max(inLevel, outLevel)
            effectiveHigh = max(inHigh, outHigh)
            effectiveMid = max(inMid, outMid)
            effectiveLow = max(inLow, outLow)
        } else if inputActive {
            effectiveLevel = inLevel
            effectiveHigh = inHigh
            effectiveMid = inMid
            effectiveLow = inLow
        } else {
            effectiveLevel = outLevel
            effectiveHigh = outHigh
            effectiveMid = outMid
            effectiveLow = outLow
        }
        
        // Update colors based on state
        updateColors(
            inputActive: inputActive,
            outputActive: outputActive,
            inputStrength: inLevel,
            outputStrength: outLevel
        )
        
        // Level → Core glow intensity (0.3 to 1.5)
        coreGlowIntensity = 0.3 + effectiveLevel * 1.2
        
        // High → Speed (20 to 120)
        speed = 20 + effectiveHigh * 100
        
        // Total level → Halo spread (0.8 to 2.5)
        let totalLevel = (effectiveLevel + effectiveHigh + effectiveMid + effectiveLow) / 4.0
        haloSpread = 0.8 + totalLevel * 1.7
        
        // High + Mid → Particle erraticness (0.1 to 1.0)
        particleErraticness = 0.1 + (effectiveHigh * 0.5 + effectiveMid * 0.4)
        
        // Adjust features based on activity
        showParticles = effectiveLow > 0.2 || !isIdle
        showWavyBlobs = effectiveMid > 0.1 || !isIdle
    }
    
    // MARK: - Color Updates
    
    private func updateColors(
        inputActive: Bool,
        outputActive: Bool,
        inputStrength: Double,
        outputStrength: Double
    ) {
        // Define color palettes
        let idleColors: [Color] = [
            Color(red: 0.95, green: 0.95, blue: 0.98),  // Cool white
            Color(red: 0.85, green: 0.85, blue: 0.9),   // Silver
            Color(red: 1.0, green: 0.92, blue: 0.7)     // Warm gold
        ]
        
        let inputColors: [Color] = [
            Color(red: 0.3, green: 0.9, blue: 1.0),     // Cyan
            Color(red: 0.2, green: 0.6, blue: 0.95),    // Blue
            Color(red: 0.4, green: 0.8, blue: 0.85)     // Teal
        ]
        
        let outputColors: [Color] = [
            Color(red: 1.0, green: 0.45, blue: 0.7),    // Pink
            Color(red: 1.0, green: 0.5, blue: 0.4),     // Coral
            Color(red: 1.0, green: 0.7, blue: 0.5)      // Orange/Peach
        ]
        
        let bothColors: [Color] = [
            Color(red: 0.3, green: 0.85, blue: 0.95),   // Cyan
            Color(red: 0.7, green: 0.5, blue: 0.9),     // Purple
            Color(red: 1.0, green: 0.5, blue: 0.65),    // Pink
            Color(red: 1.0, green: 0.85, blue: 0.5)     // Gold
        ]
        
        let isIdle = !inputActive && !outputActive
        let isBoth = inputActive && outputActive
        
        if isIdle {
            backgroundColors = idleColors
            glowColor = Color(red: 1.0, green: 0.98, blue: 0.9)
            particleColor = Color(red: 1.0, green: 0.95, blue: 0.8)
        } else if isBoth {
            // Blend based on relative strengths
            backgroundColors = bothColors
            
            // Glow color shifts based on which is stronger
            let totalStrength = inputStrength + outputStrength
            let inputRatio = totalStrength > 0 ? inputStrength / totalStrength : 0.5
            
            // Interpolate between cyan and pink for glow
            glowColor = Color(
                red: 0.3 + 0.7 * (1 - inputRatio),
                green: 0.7 - 0.2 * (1 - inputRatio),
                blue: 0.95 - 0.25 * (1 - inputRatio)
            )
            particleColor = .white
        } else if inputActive {
            backgroundColors = inputColors
            glowColor = Color(red: 0.4, green: 0.9, blue: 1.0)
            particleColor = Color(red: 0.6, green: 0.95, blue: 1.0)
        } else {
            backgroundColors = outputColors
            glowColor = Color(red: 1.0, green: 0.5, blue: 0.7)
            particleColor = Color(red: 1.0, green: 0.7, blue: 0.8)
        }
    }
}
