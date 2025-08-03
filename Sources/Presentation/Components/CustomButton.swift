import SwiftUI

/**
 * Custom Button Component - Presentation Layer
 * 
 * Professional reusable SwiftUI button component with advanced features:
 * - Multiple button styles
 * - Loading states
 * - Disabled states
 * - Custom animations
 * - Accessibility support
 * - Haptic feedback
 * - Icon support
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - Custom Button
struct CustomButton: View {
    
    // MARK: - Properties
    let title: String
    let action: () -> Void
    let style: ButtonStyle
    let isLoading: Bool
    let isDisabled: Bool
    let icon: String?
    let iconPosition: IconPosition
    let size: ButtonSize
    let hapticFeedback: HapticFeedback
    
    // MARK: - Animation Properties
    @State private var isPressed = false
    @State private var isAnimating = false
    
    // MARK: - Initialization
    init(
        title: String,
        style: ButtonStyle = .primary,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        icon: String? = nil,
        iconPosition: IconPosition = .leading,
        size: ButtonSize = .medium,
        hapticFeedback: HapticFeedback = .light,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.icon = icon
        self.iconPosition = iconPosition
        self.size = size
        self.hapticFeedback = hapticFeedback
        self.action = action
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: performAction) {
            HStack(spacing: spacing) {
                // Leading Icon
                if let icon = icon, iconPosition == .leading {
                    iconView(icon)
                }
                
                // Title
                if !isLoading {
                    Text(title)
                        .font(font)
                        .fontWeight(fontWeight)
                        .foregroundColor(textColor)
                        .lineLimit(1)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .scaleEffect(0.8)
                }
                
                // Trailing Icon
                if let icon = icon, iconPosition == .trailing {
                    iconView(icon)
                }
            }
            .frame(maxWidth: maxWidth, minHeight: minHeight)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(background)
            .overlay(overlay)
            .cornerRadius(cornerRadius)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isDisabled ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .animation(.easeInOut(duration: 0.2), value: isLoading)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled || isLoading)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(accessibilityTraits)
    }
    
    // MARK: - Private Methods
    private func performAction() {
        hapticFeedback.trigger()
        
        withAnimation(.easeInOut(duration: 0.1)) {
            isPressed = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
            action()
        }
    }
    
    @ViewBuilder
    private func iconView(_ icon: String) -> some View {
        Image(systemName: icon)
            .font(iconFont)
            .foregroundColor(iconColor)
            .frame(width: iconSize, height: iconSize)
    }
}

// MARK: - Button Style
enum ButtonStyle {
    case primary
    case secondary
    case outline
    case ghost
    case danger
    case success
    case warning
    case info
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return .blue
        case .secondary:
            return .gray
        case .outline:
            return .clear
        case .ghost:
            return .clear
        case .danger:
            return .red
        case .success:
            return .green
        case .warning:
            return .orange
        case .info:
            return .cyan
        }
    }
    
    var textColor: Color {
        switch self {
        case .primary, .danger, .success, .warning, .info:
            return .white
        case .secondary:
            return .white
        case .outline, .ghost:
            return .blue
        }
    }
    
    var borderColor: Color {
        switch self {
        case .outline:
            return .blue
        case .ghost:
            return .clear
        default:
            return .clear
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .outline:
            return 1.0
        default:
            return 0.0
        }
    }
}

// MARK: - Icon Position
enum IconPosition {
    case leading
    case trailing
}

// MARK: - Button Size
enum ButtonSize {
    case small
    case medium
    case large
    case extraLarge
    
    var font: Font {
        switch self {
        case .small:
            return .caption
        case .medium:
            return .body
        case .large:
            return .title3
        case .extraLarge:
            return .title2
        }
    }
    
    var fontWeight: Font.Weight {
        switch self {
        case .small:
            return .medium
        case .medium:
            return .semibold
        case .large:
            return .bold
        case .extraLarge:
            return .bold
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small:
            return 12
        case .medium:
            return 16
        case .large:
            return 20
        case .extraLarge:
            return 24
        }
    }
    
    var verticalPadding: CGFloat {
        switch self {
        case .small:
            return 8
        case .medium:
            return 12
        case .large:
            return 16
        case .extraLarge:
            return 20
        }
    }
    
    var minHeight: CGFloat {
        switch self {
        case .small:
            return 32
        case .medium:
            return 44
        case .large:
            return 52
        case .extraLarge:
            return 60
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .small:
            return 12
        case .medium:
            return 16
        case .large:
            return 20
        case .extraLarge:
            return 24
        }
    }
}

// MARK: - Haptic Feedback
enum HapticFeedback {
    case none
    case light
    case medium
    case heavy
    case soft
    case rigid
    
    func trigger() {
        switch self {
        case .none:
            break
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .soft:
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        case .rigid:
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
    }
}

// MARK: - Custom Button Extensions
extension CustomButton {
    
    // MARK: - Computed Properties
    private var spacing: CGFloat {
        return icon != nil ? 8 : 0
    }
    
    private var font: Font {
        return size.font
    }
    
    private var fontWeight: Font.Weight {
        return size.fontWeight
    }
    
    private var textColor: Color {
        return style.textColor
    }
    
    private var iconFont: Font {
        switch size {
        case .small:
            return .caption
        case .medium:
            return .body
        case .large:
            return .title3
        case .extraLarge:
            return .title2
        }
    }
    
    private var iconColor: Color {
        return textColor
    }
    
    private var iconSize: CGFloat {
        return size.iconSize
    }
    
    private var horizontalPadding: CGFloat {
        return size.horizontalPadding
    }
    
    private var verticalPadding: CGFloat {
        return size.verticalPadding
    }
    
    private var minHeight: CGFloat {
        return size.minHeight
    }
    
    private var maxWidth: CGFloat? {
        return nil // Allow flexible width
    }
    
    private var background: some View {
        Group {
            if style == .outline || style == .ghost {
                Color.clear
            } else {
                style.backgroundColor
            }
        }
    }
    
    private var overlay: some View {
        Group {
            if style == .outline {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            } else {
                EmptyView()
            }
        }
    }
    
    private var cornerRadius: CGFloat {
        switch size {
        case .small:
            return 6
        case .medium:
            return 8
        case .large:
            return 10
        case .extraLarge:
            return 12
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary, .danger, .success, .warning, .info:
            return .black.opacity(0.2)
        default:
            return .clear
        }
    }
    
    private var shadowRadius: CGFloat {
        switch size {
        case .small:
            return 2
        case .medium:
            return 4
        case .large:
            return 6
        case .extraLarge:
            return 8
        }
    }
    
    private var shadowOffset: CGFloat {
        switch size {
        case .small:
            return 1
        case .medium:
            return 2
        case .large:
            return 3
        case .extraLarge:
            return 4
        }
    }
    
    // MARK: - Accessibility
    private var accessibilityLabel: String {
        return title
    }
    
    private var accessibilityHint: String {
        if isLoading {
            return "Loading"
        } else if isDisabled {
            return "Button is disabled"
        } else {
            return "Double tap to activate"
        }
    }
    
    private var accessibilityTraits: AccessibilityTraits {
        var traits: AccessibilityTraits = .isButton
        
        if isLoading {
            traits.insert(.isBusy)
        }
        
        if isDisabled {
            traits.insert(.notEnabled)
        }
        
        return traits
    }
}

// MARK: - Button Variants
extension CustomButton {
    
    // MARK: - Primary Button
    static func primary(
        title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        icon: String? = nil,
        iconPosition: IconPosition = .leading,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) -> CustomButton {
        return CustomButton(
            title: title,
            style: .primary,
            isLoading: isLoading,
            isDisabled: isDisabled,
            icon: icon,
            iconPosition: iconPosition,
            size: size,
            action: action
        )
    }
    
    // MARK: - Secondary Button
    static func secondary(
        title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        icon: String? = nil,
        iconPosition: IconPosition = .leading,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) -> CustomButton {
        return CustomButton(
            title: title,
            style: .secondary,
            isLoading: isLoading,
            isDisabled: isDisabled,
            icon: icon,
            iconPosition: iconPosition,
            size: size,
            action: action
        )
    }
    
    // MARK: - Outline Button
    static func outline(
        title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        icon: String? = nil,
        iconPosition: IconPosition = .leading,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) -> CustomButton {
        return CustomButton(
            title: title,
            style: .outline,
            isLoading: isLoading,
            isDisabled: isDisabled,
            icon: icon,
            iconPosition: iconPosition,
            size: size,
            action: action
        )
    }
    
    // MARK: - Danger Button
    static func danger(
        title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        icon: String? = nil,
        iconPosition: IconPosition = .leading,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) -> CustomButton {
        return CustomButton(
            title: title,
            style: .danger,
            isLoading: isLoading,
            isDisabled: isDisabled,
            icon: icon,
            iconPosition: iconPosition,
            size: size,
            action: action
        )
    }
    
    // MARK: - Success Button
    static func success(
        title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        icon: String? = nil,
        iconPosition: IconPosition = .leading,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) -> CustomButton {
        return CustomButton(
            title: title,
            style: .success,
            isLoading: isLoading,
            isDisabled: isDisabled,
            icon: icon,
            iconPosition: iconPosition,
            size: size,
            action: action
        )
    }
}

// MARK: - Button Group
struct ButtonGroup: View {
    let buttons: [CustomButton]
    let axis: Axis
    let spacing: CGFloat
    
    init(
        axis: Axis = .horizontal,
        spacing: CGFloat = 12,
        @ViewBuilder content: () -> [CustomButton]
    ) {
        self.buttons = content()
        self.axis = axis
        self.spacing = spacing
    }
    
    var body: some View {
        Group {
            if axis == .horizontal {
                HStack(spacing: spacing) {
                    ForEach(Array(buttons.enumerated()), id: \.offset) { _, button in
                        button
                    }
                }
            } else {
                VStack(spacing: spacing) {
                    ForEach(Array(buttons.enumerated()), id: \.offset) { _, button in
                        button
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Primary Buttons
            HStack(spacing: 12) {
                CustomButton.primary(title: "Primary")
                CustomButton.primary(title: "Loading", isLoading: true)
                CustomButton.primary(title: "Disabled", isDisabled: true)
            }
            
            // Secondary Buttons
            HStack(spacing: 12) {
                CustomButton.secondary(title: "Secondary")
                CustomButton.secondary(title: "Icon", icon: "star.fill")
                CustomButton.secondary(title: "Trailing", icon: "arrow.right", iconPosition: .trailing)
            }
            
            // Outline Buttons
            HStack(spacing: 12) {
                CustomButton.outline(title: "Outline")
                CustomButton.outline(title: "Icon", icon: "heart.fill")
            }
            
            // Danger and Success
            HStack(spacing: 12) {
                CustomButton.danger(title: "Delete")
                CustomButton.success(title: "Save")
            }
            
            // Different Sizes
            VStack(spacing: 12) {
                CustomButton.primary(title: "Small", size: .small)
                CustomButton.primary(title: "Medium", size: .medium)
                CustomButton.primary(title: "Large", size: .large)
                CustomButton.primary(title: "Extra Large", size: .extraLarge)
            }
            
            // Button Group
            ButtonGroup {
                CustomButton.primary(title: "Save")
                CustomButton.outline(title: "Cancel")
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
