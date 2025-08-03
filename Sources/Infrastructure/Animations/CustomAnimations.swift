import SwiftUI

/**
 * Custom Animations - Infrastructure Layer
 * 
 * This file defines premium custom animations for the iOS Clean Architecture Template.
 * It provides smooth, performant animations that enhance user experience.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - Animation Constants
struct AnimationConstants {
    static let fast: Double = 0.2
    static let normal: Double = 0.3
    static let slow: Double = 0.5
    static let verySlow: Double = 0.8
    
    static let springResponse: Double = 0.6
    static let springDampingFraction: Double = 0.8
    static let springStiffness: Double = 100
    static let springDamping: Double = 10
}

// MARK: - Basic Animations
extension Animation {
    /// Fast animation for quick interactions
    static let fast = Animation.easeInOut(duration: AnimationConstants.fast)
    
    /// Normal animation for standard interactions
    static let normal = Animation.easeInOut(duration: AnimationConstants.normal)
    
    /// Slow animation for important transitions
    static let slow = Animation.easeInOut(duration: AnimationConstants.slow)
    
    /// Very slow animation for dramatic effects
    static let verySlow = Animation.easeInOut(duration: AnimationConstants.verySlow)
}

// MARK: - Spring Animations
extension Animation {
    /// Smooth spring animation
    static let smoothSpring = Animation.spring(
        response: AnimationConstants.springResponse,
        dampingFraction: AnimationConstants.springDampingFraction
    )
    
    /// Bouncy spring animation
    static let bouncySpring = Animation.interpolatingSpring(
        stiffness: AnimationConstants.springStiffness,
        damping: AnimationConstants.springDamping
    )
    
    /// Gentle spring animation
    static let gentleSpring = Animation.spring(
        response: 0.8,
        dampingFraction: 0.9
    )
}

// MARK: - Custom Animations
extension Animation {
    /// Pulse animation for attention-grabbing elements
    static let pulse = Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
    
    /// Shake animation for error states
    static let shake = Animation.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)
    
    /// Bounce animation for successful actions
    static let bounce = Animation.interpolatingSpring(stiffness: 200, damping: 5)
    
    /// Slide in from top animation
    static let slideInFromTop = Animation.easeOut(duration: 0.4)
    
    /// Slide in from bottom animation
    static let slideInFromBottom = Animation.easeOut(duration: 0.4)
    
    /// Slide in from leading animation
    static let slideInFromLeading = Animation.easeOut(duration: 0.4)
    
    /// Slide in from trailing animation
    static let slideInFromTrailing = Animation.easeOut(duration: 0.4)
    
    /// Fade in animation
    static let fadeIn = Animation.easeIn(duration: 0.3)
    
    /// Fade out animation
    static let fadeOut = Animation.easeOut(duration: 0.3)
    
    /// Scale up animation
    static let scaleUp = Animation.spring(response: 0.4, dampingFraction: 0.8)
    
    /// Scale down animation
    static let scaleDown = Animation.easeInOut(duration: 0.2)
}

// MARK: - Animation Modifiers
struct AnimatedViewModifier: ViewModifier {
    let animation: Animation
    let delay: Double
    
    init(animation: Animation = .normal, delay: Double = 0) {
        self.animation = animation
        self.delay = delay
    }
    
    func body(content: Content) -> some View {
        content
            .animation(animation.delay(delay), value: true)
    }
}

struct PulseAnimationModifier: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.1 : 1.0)
            .animation(.pulse, value: isPulsing)
            .onAppear {
                isPulsing = true
            }
    }
}

struct ShakeAnimationModifier: ViewModifier {
    @State private var isShaking = false
    
    func body(content: Content) -> some View {
        content
            .offset(x: isShaking ? 10 : 0)
            .animation(.shake, value: isShaking)
            .onAppear {
                isShaking = true
            }
    }
}

struct BounceAnimationModifier: ViewModifier {
    @State private var isBouncing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isBouncing ? 1.2 : 1.0)
            .animation(.bounce, value: isBouncing)
            .onAppear {
                isBouncing = true
            }
    }
}

// MARK: - View Extensions
extension View {
    /// Apply custom animation
    func customAnimation(_ animation: Animation = .normal, delay: Double = 0) -> some View {
        modifier(AnimatedViewModifier(animation: animation, delay: delay))
    }
    
    /// Apply pulse animation
    func pulseAnimation() -> some View {
        modifier(PulseAnimationModifier())
    }
    
    /// Apply shake animation
    func shakeAnimation() -> some View {
        modifier(ShakeAnimationModifier())
    }
    
    /// Apply bounce animation
    func bounceAnimation() -> some View {
        modifier(BounceAnimationModifier())
    }
    
    /// Slide in from top
    func slideInFromTop() -> some View {
        self
            .offset(y: -UIScreen.main.bounds.height)
            .animation(.slideInFromTop, value: true)
    }
    
    /// Slide in from bottom
    func slideInFromBottom() -> some View {
        self
            .offset(y: UIScreen.main.bounds.height)
            .animation(.slideInFromBottom, value: true)
    }
    
    /// Fade in
    func fadeIn() -> some View {
        self
            .opacity(0)
            .animation(.fadeIn, value: true)
    }
    
    /// Scale up
    func scaleUp() -> some View {
        self
            .scaleEffect(0)
            .animation(.scaleUp, value: true)
    }
}

// MARK: - Staggered Animation
struct StaggeredAnimationModifier: ViewModifier {
    let delay: Double
    let animation: Animation
    
    init(delay: Double, animation: Animation = .normal) {
        self.delay = delay
        self.animation = animation
    }
    
    func body(content: Content) -> some View {
        content
            .animation(animation.delay(delay), value: true)
    }
}

extension View {
    /// Apply staggered animation
    func staggeredAnimation(delay: Double, animation: Animation = .normal) -> some View {
        modifier(StaggeredAnimationModifier(delay: delay, animation: animation))
    }
}

// MARK: - Loading Animation
struct LoadingAnimationModifier: ViewModifier {
    @State private var isRotating = false
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isRotating)
            .onAppear {
                isRotating = true
            }
    }
}

extension View {
    /// Apply loading animation
    func loadingAnimation() -> some View {
        modifier(LoadingAnimationModifier())
    }
}

// MARK: - Success Animation
struct SuccessAnimationModifier: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.2 : 1.0)
            .animation(.bounce, value: isAnimating)
            .onAppear {
                isAnimating = true
            }
    }
}

extension View {
    /// Apply success animation
    func successAnimation() -> some View {
        modifier(SuccessAnimationModifier())
    }
}

// MARK: - Error Animation
struct ErrorAnimationModifier: ViewModifier {
    @State private var isShaking = false
    
    func body(content: Content) -> some View {
        content
            .offset(x: isShaking ? 10 : 0)
            .animation(.shake, value: isShaking)
            .onAppear {
                isShaking = true
            }
    }
}

extension View {
    /// Apply error animation
    func errorAnimation() -> some View {
        modifier(ErrorAnimationModifier())
    }
}
