# 🎨 Design System

<div align="center">

**🎨 Dünya standartlarında Design System rehberi**

[📚 Getting Started](GettingStarted.md) • [🏗️ Architecture](Architecture.md) • [🔌 API Reference](API.md)

</div>

---

## 🎯 Design System Overview

Bu proje, dünya standartlarında bir Design System kullanarak tutarlı ve premium bir kullanıcı deneyimi sağlar.

### 🎨 Tasarım Prensipleri

- **🎯 Tutarlılık** - Tüm bileşenler tutarlı tasarım dili
- **♿ Erişilebilirlik** - WCAG 2.1 AA standartları
- **📱 Responsive** - Tüm ekran boyutlarına uyum
- **🌙 Dark/Light Mode** - Otomatik tema desteği
- **⚡ Performans** - Optimize edilmiş animasyonlar
- **🎭 Mikro-etkileşimler** - Kullanıcı deneyimini artıran detaylar

---

## 🎨 Renk Paleti

### 🌈 Ana Renkler

```swift
// Apple Blue - Premium Renk Paleti
extension Color {
    // Primary Colors
    static let primaryBlue = Color(red: 0/255, green: 122/255, blue: 255/255)
    static let primaryBlueLight = Color(red: 0/255, green: 122/255, blue: 255/255, opacity: 0.8)
    static let primaryBlueDark = Color(red: 0/255, green: 122/255, blue: 255/255, opacity: 1.2)
    
    // Secondary Colors
    static let secondaryBlue = Color(red: 0/255, green: 122/255, blue: 255/255, opacity: 0.6)
    static let secondaryBlueLight = Color(red: 0/255, green: 122/255, blue: 255/255, opacity: 0.4)
    
    // Accent Colors
    static let accentGreen = Color(red: 52/255, green: 199/255, blue: 89/255)
    static let accentOrange = Color(red: 255/255, green: 149/255, blue: 0/255)
    static let accentRed = Color(red: 255/255, green: 59/255, blue: 48/255)
    static let accentPurple = Color(red: 175/255, green: 82/255, blue: 222/255)
    
    // Neutral Colors
    static let background = Color(red: 248/255, green: 248/255, blue: 248/255)
    static let surface = Color.white
    static let text = Color(red: 28/255, green: 28/255, blue: 30/255)
    static let textSecondary = Color(red: 99/255, green: 99/255, blue: 102/255)
    static let border = Color(red: 229/255, green: 229/255, blue: 234/255)
}
```

### 🌙 Dark Mode Renkleri

```swift
// Dark Mode Color Palette
extension Color {
    // Dark Mode Primary
    static let darkPrimaryBlue = Color(red: 10/255, green: 132/255, blue: 255/255)
    static let darkPrimaryBlueLight = Color(red: 10/255, green: 132/255, blue: 255/255, opacity: 0.8)
    
    // Dark Mode Background
    static let darkBackground = Color(red: 0/255, green: 0/255, blue: 0/255)
    static let darkSurface = Color(red: 28/255, green: 28/255, blue: 30/255)
    static let darkSurfaceSecondary = Color(red: 44/255, green: 44/255, blue: 46/255)
    
    // Dark Mode Text
    static let darkText = Color.white
    static let darkTextSecondary = Color(red: 174/255, green: 174/255, blue: 178/255)
    static let darkBorder = Color(red: 44/255, green: 44/255, blue: 46/255)
}
```

### 🎨 Renk Kullanım Kuralları

```swift
// Color Usage Guidelines
struct ColorGuidelines {
    // Primary Actions
    static let primaryButton = Color.primaryBlue
    static let primaryButtonPressed = Color.primaryBlueDark
    
    // Secondary Actions
    static let secondaryButton = Color.secondaryBlue
    static let secondaryButtonPressed = Color.secondaryBlueLight
    
    // Success States
    static let success = Color.accentGreen
    static let successBackground = Color.accentGreen.opacity(0.1)
    
    // Warning States
    static let warning = Color.accentOrange
    static let warningBackground = Color.accentOrange.opacity(0.1)
    
    // Error States
    static let error = Color.accentRed
    static let errorBackground = Color.accentRed.opacity(0.1)
    
    // Information States
    static let info = Color.accentPurple
    static let infoBackground = Color.accentPurple.opacity(0.1)
}
```

---

## 📝 Tipografi

### 🔤 Font Ailesi

```swift
// Typography System
struct Typography {
    // Headings
    static let h1 = Font.system(size: 32, weight: .bold, design: .default)
    static let h2 = Font.system(size: 28, weight: .bold, design: .default)
    static let h3 = Font.system(size: 24, weight: .semibold, design: .default)
    static let h4 = Font.system(size: 20, weight: .semibold, design: .default)
    static let h5 = Font.system(size: 18, weight: .medium, design: .default)
    static let h6 = Font.system(size: 16, weight: .medium, design: .default)
    
    // Body Text
    static let bodyLarge = Font.system(size: 18, weight: .regular, design: .default)
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)
    
    // Captions
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let captionSmall = Font.system(size: 10, weight: .regular, design: .default)
    
    // Buttons
    static let buttonLarge = Font.system(size: 18, weight: .semibold, design: .default)
    static let button = Font.system(size: 16, weight: .semibold, design: .default)
    static let buttonSmall = Font.system(size: 14, weight: .semibold, design: .default)
}
```

### 📏 Line Height

```swift
// Line Height Guidelines
struct LineHeight {
    static let h1: CGFloat = 40
    static let h2: CGFloat = 36
    static let h3: CGFloat = 32
    static let h4: CGFloat = 28
    static let h5: CGFloat = 24
    static let h6: CGFloat = 20
    static let bodyLarge: CGFloat = 26
    static let body: CGFloat = 24
    static let bodySmall: CGFloat = 20
    static let caption: CGFloat = 16
    static let captionSmall: CGFloat = 14
}
```

---

## 📐 Spacing Sistemi

### 📏 Spacing Değerleri

```swift
// Spacing System
struct Spacing {
    // Base spacing unit
    static let base: CGFloat = 4
    
    // Spacing values
    static let xs: CGFloat = base * 1    // 4pt
    static let sm: CGFloat = base * 2    // 8pt
    static let md: CGFloat = base * 3    // 12pt
    static let lg: CGFloat = base * 4    // 16pt
    static let xl: CGFloat = base * 6    // 24pt
    static let xxl: CGFloat = base * 8   // 32pt
    static let xxxl: CGFloat = base * 12 // 48pt
    
    // Component spacing
    static let buttonPadding: CGFloat = lg
    static let cardPadding: CGFloat = xl
    static let sectionPadding: CGFloat = xxl
    static let screenPadding: CGFloat = lg
}
```

### 📐 Layout Guidelines

```swift
// Layout Guidelines
struct Layout {
    // Screen margins
    static let screenMargin: CGFloat = Spacing.lg
    
    // Component spacing
    static let componentSpacing: CGFloat = Spacing.md
    
    // Section spacing
    static let sectionSpacing: CGFloat = Spacing.xl
    
    // Card spacing
    static let cardSpacing: CGFloat = Spacing.lg
    
    // Button spacing
    static let buttonSpacing: CGFloat = Spacing.sm
}
```

---

## 🎭 Animasyonlar

### ⚡ Temel Animasyonlar

```swift
// Animation System
struct Animations {
    // Duration
    static let fast: Double = 0.15
    static let normal: Double = 0.3
    static let slow: Double = 0.5
    
    // Easing
    static let easeInOut = Animation.easeInOut(duration: normal)
    static let easeOut = Animation.easeOut(duration: normal)
    static let easeIn = Animation.easeIn(duration: normal)
    
    // Spring animations
    static let spring = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let springBouncy = Animation.interpolatingSpring(stiffness: 100, damping: 10)
    static let springSmooth = Animation.interpolatingSpring(stiffness: 50, damping: 15)
    
    // Custom animations
    static let fadeIn = Animation.easeInOut(duration: fast)
    static let fadeOut = Animation.easeInOut(duration: fast)
    static let slideIn = Animation.easeOut(duration: normal)
    static let slideOut = Animation.easeIn(duration: normal)
    static let scaleIn = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let scaleOut = Animation.easeIn(duration: fast)
}
```

### 🎭 Mikro-etkileşimler

```swift
// Micro-interactions
struct MicroInteractions {
    // Button press
    static let buttonPress = Animation.easeInOut(duration: 0.1)
    
    // Card hover
    static let cardHover = Animation.easeInOut(duration: 0.2)
    
    // Loading spinner
    static let loading = Animation.linear(duration: 1.0).repeatForever(autoreverses: false)
    
    // Success checkmark
    static let success = Animation.spring(response: 0.3, dampingFraction: 0.6)
    
    // Error shake
    static let errorShake = Animation.easeInOut(duration: 0.1).repeatCount(3)
}
```

---

## 🧩 UI Bileşenleri

### 🔘 Buttons

```swift
// Button Components
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(Animations.buttonPress) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            Text(title)
                .font(Typography.button)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isPressed ? ColorGuidelines.primaryButtonPressed : ColorGuidelines.primaryButton)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(Animations.buttonPress) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            Text(title)
                .font(Typography.button)
                .foregroundColor(ColorGuidelines.primaryButton)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ColorGuidelines.primaryButton, lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isPressed ? ColorGuidelines.primaryButton.opacity(0.1) : Color.clear)
                        )
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
```

### 📱 Cards

```swift
// Card Component
struct CardView<Content: View>: View {
    let content: Content
    @State private var isPressed = false
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(Spacing.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surface)
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: isPressed ? 4 : 8,
                        x: 0,
                        y: isPressed ? 2 : 4
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .onTapGesture {
                withAnimation(Animations.cardHover) {
                    isPressed = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
    }
}
```

### 📝 Text Fields

```swift
// Text Field Component
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String?
    @State private var isFocused = false
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(isFocused ? ColorGuidelines.primaryButton : Color.textSecondary)
                    .frame(width: 20, height: 20)
            }
            
            TextField(placeholder, text: $text)
                .font(Typography.body)
                .foregroundColor(Color.text)
                .onTapGesture {
                    withAnimation(Animations.easeInOut) {
                        isFocused = true
                    }
                }
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isFocused ? ColorGuidelines.primaryButton : Color.border,
                            lineWidth: isFocused ? 2 : 1
                        )
                )
        )
        .onTapGesture {
            withAnimation(Animations.easeInOut) {
                isFocused = true
            }
        }
    }
}
```

### 🔄 Loading States

```swift
// Loading Components
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    ColorGuidelines.primaryButton,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 40, height: 40)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(Animations.loading, value: isAnimating)
                .onAppear {
                    isAnimating = true
                }
            
            Text("Loading...")
                .font(Typography.body)
                .foregroundColor(Color.textSecondary)
        }
    }
}

struct SkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.border)
            .opacity(isAnimating ? 0.3 : 0.7)
            .animation(
                Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}
```

---

## ♿ Erişilebilirlik

### 🎯 Accessibility Guidelines

```swift
// Accessibility Extensions
extension View {
    func accessibilityLabel(_ label: String) -> some View {
        self.accessibilityLabel(label)
    }
    
    func accessibilityHint(_ hint: String) -> some View {
        self.accessibilityHint(hint)
    }
    
    func accessibilityValue(_ value: String) -> some View {
        self.accessibilityValue(value)
    }
    
    func accessibilityTraits(_ traits: AccessibilityTraits) -> some View {
        self.accessibilityTraits(traits)
    }
}

// High Contrast Support
struct HighContrastColors {
    static let primary = Color.primaryBlue
    static let background = Color.white
    static let text = Color.black
    static let border = Color.black
}

// Dynamic Type Support
struct DynamicTypeText: View {
    let text: String
    let font: Font
    
    var body: some View {
        Text(text)
            .font(font)
            .dynamicTypeSize(.large ... .accessibility3)
    }
}
```

### 🎨 Color Contrast

```swift
// Color Contrast Guidelines
struct ColorContrast {
    // Minimum contrast ratios (WCAG AA)
    static let normalText: Double = 4.5
    static let largeText: Double = 3.0
    
    // High contrast colors
    static let highContrastPrimary = Color(red: 0/255, green: 122/255, blue: 255/255)
    static let highContrastBackground = Color.white
    static let highContrastText = Color.black
}
```

---

## 📱 Responsive Design

### 📐 Breakpoints

```swift
// Responsive Breakpoints
struct Breakpoints {
    static let phone: CGFloat = 375
    static let tablet: CGFloat = 768
    static let desktop: CGFloat = 1024
    
    static let isPhone = UIScreen.main.bounds.width <= phone
    static let isTablet = UIScreen.main.bounds.width > phone && UIScreen.main.bounds.width <= tablet
    static let isDesktop = UIScreen.main.bounds.width > tablet
}
```

### 📱 Adaptive Layout

```swift
// Adaptive Layout Components
struct AdaptiveStack<Content: View>: View {
    let horizontalAlignment: HorizontalAlignment
    let verticalAlignment: VerticalAlignment
    let spacing: CGFloat?
    let content: Content
    
    init(
        horizontalAlignment: HorizontalAlignment = .center,
        verticalAlignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        Group {
            if Breakpoints.isPhone {
                VStack(alignment: horizontalAlignment, spacing: spacing) {
                    content
                }
            } else {
                HStack(alignment: verticalAlignment, spacing: spacing) {
                    content
                }
            }
        }
    }
}
```

---

## 🎨 Tema Sistemi

### 🌙 Dark/Light Mode

```swift
// Theme System
class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false
    
    static let shared = ThemeManager()
    
    private init() {
        // Check system appearance
        isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
    }
    
    func toggleTheme() {
        withAnimation(Animations.easeInOut) {
            isDarkMode.toggle()
        }
    }
}

// Theme-aware colors
struct ThemeColors {
    @Environment(\.colorScheme) var colorScheme
    
    var background: Color {
        colorScheme == .dark ? Color.darkBackground : Color.background
    }
    
    var surface: Color {
        colorScheme == .dark ? Color.darkSurface : Color.surface
    }
    
    var text: Color {
        colorScheme == .dark ? Color.darkText : Color.text
    }
    
    var textSecondary: Color {
        colorScheme == .dark ? Color.darkTextSecondary : Color.textSecondary
    }
}
```

---

## 📚 Kullanım Örnekleri

### 🎯 Temel Kullanım

```swift
// Basic Usage Example
struct ContentView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var text = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Header
                    Text("Design System Demo")
                        .font(Typography.h1)
                        .foregroundColor(ThemeColors().text)
                    
                    // Card with content
                    CardView {
                        VStack(spacing: Spacing.lg) {
                            Text("Sample Card")
                                .font(Typography.h3)
                                .foregroundColor(ThemeColors().text)
                            
                            CustomTextField(
                                placeholder: "Enter text...",
                                text: $text,
                                icon: "pencil"
                            )
                            
                            HStack(spacing: Spacing.md) {
                                PrimaryButton(title: "Primary") {
                                    // Action
                                }
                                
                                SecondaryButton(title: "Secondary") {
                                    // Action
                                }
                            }
                        }
                    }
                    
                    // Loading state
                    LoadingView()
                }
                .padding(Spacing.screenPadding)
            }
            .background(ThemeColors().background)
            .navigationTitle("Design System")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
```

---

## 📋 Design System Checklist

### 🎨 Renkler
- [ ] **Primary Colors** - Ana renkler tanımlandı
- [ ] **Secondary Colors** - İkincil renkler tanımlandı
- [ ] **Accent Colors** - Vurgu renkleri tanımlandı
- [ ] **Neutral Colors** - Nötr renkler tanımlandı
- [ ] **Dark Mode** - Karanlık tema renkleri
- [ ] **High Contrast** - Yüksek kontrast desteği

### 📝 Tipografi
- [ ] **Font Hierarchy** - Font hiyerarşisi
- [ ] **Line Heights** - Satır yükseklikleri
- [ ] **Dynamic Type** - Dinamik tip desteği
- [ ] **Accessibility** - Erişilebilirlik

### 📐 Spacing
- [ ] **Spacing Scale** - Spacing ölçeği
- [ ] **Component Spacing** - Bileşen aralıkları
- [ ] **Layout Guidelines** - Layout kuralları

### 🎭 Animasyonlar
- [ ] **Duration** - Animasyon süreleri
- [ ] **Easing** - Easing fonksiyonları
- [ ] **Micro-interactions** - Mikro-etkileşimler

### 🧩 Bileşenler
- [ ] **Buttons** - Buton bileşenleri
- [ ] **Cards** - Kart bileşenleri
- [ ] **Text Fields** - Metin alanları
- [ ] **Loading States** - Yükleme durumları

### ♿ Erişilebilirlik
- [ ] **WCAG Compliance** - WCAG uyumluluğu
- [ ] **VoiceOver** - VoiceOver desteği
- [ ] **Dynamic Type** - Dinamik tip
- [ ] **High Contrast** - Yüksek kontrast

---

<div align="center">

**🎨 Dünya standartlarında Design System için teşekkürler!**

**🚀 Dünya standartlarında iOS Clean Architecture Template**

</div> 