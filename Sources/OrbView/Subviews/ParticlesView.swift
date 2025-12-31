//
//  Particles.swift
//  Prototype-Orb
//
//  Created by Siddhant Mehta on 2024-11-06.
//
import SwiftUI
import SpriteKit

class ParticleScene: SKScene {
    let color: UIColor
    let speedRange: ClosedRange<Double>
    let sizeRange: ClosedRange<CGFloat>
    let particleCount: Int
    let opacityRange: ClosedRange<Double>
    let erraticness: Double  // 0 to 1, how random/erratic the movement is
    
    init(
        size: CGSize,
        color: UIColor,
        speedRange: ClosedRange<Double>,
        sizeRange: ClosedRange<CGFloat>,
        particleCount: Int,
        opacityRange: ClosedRange<Double>,
        erraticness: Double = 0.3
    ) {
        self.color = color
        self.speedRange = speedRange
        self.sizeRange = sizeRange
        self.particleCount = particleCount
        self.opacityRange = opacityRange
        self.erraticness = erraticness
        super.init(size: size)
        
        backgroundColor = .clear
        setupParticleEmitter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupParticleEmitter() {
        let emitter = SKEmitterNode()
        
        // Create a white particle texture
        emitter.particleTexture = createParticleTexture()
        
        // Update color properties
        emitter.particleColorSequence = nil
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0
        
        // Basic emitter properties - speed increases with erraticness
        let baseSpeed = CGFloat(speedRange.lowerBound)
        let speedBoost = CGFloat(erraticness) * 30
        emitter.particleSpeed = baseSpeed + speedBoost
        emitter.particleSpeedRange = CGFloat(speedRange.upperBound - speedRange.lowerBound) * (1 + CGFloat(erraticness))
        emitter.particleScale = sizeRange.lowerBound
        emitter.particleScaleRange = sizeRange.upperBound - sizeRange.lowerBound
        
        // Alpha and fade properties
        emitter.particleAlpha = 0 // Start invisible
        emitter.particleAlphaSpeed = CGFloat(opacityRange.upperBound) / 0.5 // Fade in over 0.5 seconds
        emitter.particleAlphaRange = CGFloat(opacityRange.upperBound - opacityRange.lowerBound)
        
        // Create alpha sequence for fade in/out
        let alphaSequence = SKKeyframeSequence(keyframeValues: [
            0,                              // Start invisible
            Double.random(in: opacityRange),        // Fade in to max opacity
            Double.random(in: opacityRange),        // Stay at max opacity
            Double.random(in: opacityRange)         // Fade to min opacity
        ], times: [
            0,      // At start
            0.2,    // Reach max at 20% of lifetime
            0.8,    // Stay at max until 80% of lifetime
            1.0     // Fade to min by end
        ])
        emitter.particleAlphaSequence = alphaSequence
        
        // Create scale sequence for grow/shrink animation
        let scaleSequence = SKKeyframeSequence(keyframeValues: [
            sizeRange.lowerBound * 0.7,    // Start at half min size
            sizeRange.upperBound * 0.9,    // Grow to max size
            sizeRange.upperBound,          // Stay at max
            sizeRange.lowerBound * 0.8     // Shrink back to half min size
        ], times: [
            0,      // At start
            0.4,    // Reach max at 20% of lifetime
            0.7,    // Stay at max until 80% of lifetime
            1.0     // Shrink by end
        ])
        emitter.particleScaleSequence = scaleSequence
        
        emitter.particleBlendMode = .add
        
        // Particles spawn from ALL over the orb area
        emitter.position = CGPoint(x: size.width/2, y: size.height/2)
        emitter.particlePositionRange = CGVector(dx: size.width * 0.9, dy: size.height * 0.9)
        
        // Particle birth and lifetime
        emitter.particleBirthRate = CGFloat(particleCount) / 2.0
        emitter.numParticlesToEmit = 0
        emitter.particleLifetime = 2.5
        emitter.particleLifetimeRange = 1.5
        
        // FULL 360 degree emission - particles go in ALL directions
        emitter.emissionAngle = 0  // Doesn't matter when range is full circle
        emitter.emissionAngleRange = CGFloat.pi * 2  // Full 360 degrees always
        
        // Random acceleration for chaotic movement
        // Higher erraticness = stronger random forces
        let accelStrength = 10 + CGFloat(erraticness) * 50
        emitter.xAcceleration = CGFloat.random(in: -accelStrength...accelStrength)
        emitter.yAcceleration = CGFloat.random(in: -accelStrength...accelStrength)
        
        // Add rotation for more visual interest
        emitter.particleRotation = 0
        emitter.particleRotationRange = CGFloat.pi * 2
        emitter.particleRotationSpeed = CGFloat.random(in: -2...2) * CGFloat(erraticness + 0.3)
        
        addChild(emitter)
    }
    
    private func createParticleTexture() -> SKTexture {
        let size = CGSize(width: 8, height: 8)  // Smaller size for better performance
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Simple filled white circle
            UIColor.white.setFill()
            let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size))
            circlePath.fill()
        }
        
        return SKTexture(image: image)
    }
}

struct ParticlesView: View {
    let color: Color
    let speedRange: ClosedRange<Double>
    let sizeRange: ClosedRange<CGFloat>
    let particleCount: Int
    let opacityRange: ClosedRange<Double>
    var erraticness: Double = 0.3
    
    var scene: SKScene {
        let scene = ParticleScene(
            size: CGSize(width: 300, height: 300), // Use fixed size
            color: UIColor(color),
            speedRange: speedRange,
            sizeRange: sizeRange,
            particleCount: particleCount,
            opacityRange: opacityRange,
            erraticness: erraticness
        )
        scene.scaleMode = .aspectFit
        return scene
    }
    
    var body: some View {
        GeometryReader { geometry in
            SpriteView(scene: scene, options: [.allowsTransparency])
                .frame(width: geometry.size.width, height: geometry.size.height)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ParticlesView(
        color: .green,
        speedRange: 30...60,
        sizeRange: 0.2...1,
        particleCount: 100,
        opacityRange: 0.5...1
    )
    .background(.black)
}
