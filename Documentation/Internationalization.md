# 🌍 Internationalization Guide

<div align="center">

**🌍 Dünya standartlarında çoklu dil desteği rehberi**

[📚 Getting Started](GettingStarted.md) • [🏗️ Architecture](Architecture.md) • [🎨 Design System](DesignSystem.md)

</div>

---

## 🎯 Internationalization Overview

Bu proje, dünya standartlarında çoklu dil desteği sağlar:

- **🌍 50+ Dil Desteği** - Dünya çapında erişilebilirlik
- **📱 RTL Desteği** - Arapça, İbranice, Farsça
- **🎨 Kültürel Uyumluluk** - Yerel tasarım standartları
- **📅 Tarih/Saat Formatları** - Yerel formatlar
- **💰 Para Birimi** - Yerel para birimleri
- **📏 Ölçü Birimleri** - Metrik/İmperial sistemler

---

## 🌍 Desteklenen Diller

### 📊 Dil Listesi

```swift
// Supported Languages
enum SupportedLanguage: String, CaseIterable {
    // Western Languages
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case portuguese = "pt"
    case dutch = "nl"
    case swedish = "sv"
    case norwegian = "no"
    case danish = "da"
    
    // Eastern European Languages
    case russian = "ru"
    case polish = "pl"
    case czech = "cs"
    case hungarian = "hu"
    case romanian = "ro"
    case bulgarian = "bg"
    case croatian = "hr"
    case serbian = "sr"
    case slovak = "sk"
    case slovenian = "sl"
    
    // Asian Languages
    case chineseSimplified = "zh-Hans"
    case chineseTraditional = "zh-Hant"
    case japanese = "ja"
    case korean = "ko"
    case thai = "th"
    case vietnamese = "vi"
    case indonesian = "id"
    case malay = "ms"
    case filipino = "fil"
    
    // Middle Eastern Languages
    case arabic = "ar"
    case hebrew = "he"
    case persian = "fa"
    case turkish = "tr"
    case urdu = "ur"
    
    // Indian Languages
    case hindi = "hi"
    case bengali = "bn"
    case tamil = "ta"
    case telugu = "te"
    case marathi = "mr"
    case gujarati = "gu"
    case kannada = "kn"
    case malayalam = "ml"
    case punjabi = "pa"
    
    // African Languages
    case swahili = "sw"
    case amharic = "am"
    case yoruba = "yo"
    case igbo = "ig"
    case hausa = "ha"
    
    // Other Languages
    case greek = "el"
    case finnish = "fi"
    case icelandic = "is"
    case latvian = "lv"
    case lithuanian = "lt"
    case estonian = "et"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .italian: return "Italiano"
        case .portuguese: return "Português"
        case .dutch: return "Nederlands"
        case .swedish: return "Svenska"
        case .norwegian: return "Norsk"
        case .danish: return "Dansk"
        case .russian: return "Русский"
        case .polish: return "Polski"
        case .czech: return "Čeština"
        case .hungarian: return "Magyar"
        case .romanian: return "Română"
        case .bulgarian: return "Български"
        case .croatian: return "Hrvatski"
        case .serbian: return "Српски"
        case .slovak: return "Slovenčina"
        case .slovenian: return "Slovenščina"
        case .chineseSimplified: return "简体中文"
        case .chineseTraditional: return "繁體中文"
        case .japanese: return "日本語"
        case .korean: return "한국어"
        case .thai: return "ไทย"
        case .vietnamese: return "Tiếng Việt"
        case .indonesian: return "Bahasa Indonesia"
        case .malay: return "Bahasa Melayu"
        case .filipino: return "Filipino"
        case .arabic: return "العربية"
        case .hebrew: return "עברית"
        case .persian: return "فارسی"
        case .turkish: return "Türkçe"
        case .urdu: return "اردو"
        case .hindi: return "हिन्दी"
        case .bengali: return "বাংলা"
        case .tamil: return "தமிழ்"
        case .telugu: return "తెలుగు"
        case .marathi: return "मराठी"
        case .gujarati: return "ગુજરાતી"
        case .kannada: return "ಕನ್ನಡ"
        case .malayalam: return "മലയാളം"
        case .punjabi: return "ਪੰਜਾਬੀ"
        case .swahili: return "Kiswahili"
        case .amharic: return "አማርኛ"
        case .yoruba: return "Yorùbá"
        case .igbo: return "Igbo"
        case .hausa: return "Hausa"
        case .greek: return "Ελληνικά"
        case .finnish: return "Suomi"
        case .icelandic: return "Íslenska"
        case .latvian: return "Latviešu"
        case .lithuanian: return "Lietuvių"
        case .estonian: return "Eesti"
        }
    }
    
    var isRTL: Bool {
        switch self {
        case .arabic, .hebrew, .persian, .urdu:
            return true
        default:
            return false
        }
    }
}
```

---

## 📱 Localization Manager

### 🔧 Localization Manager

```swift
// Localization Manager
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: SupportedLanguage = .english
    @Published var currentLocale: Locale = Locale(identifier: "en")
    
    private let userDefaults = UserDefaults.standard
    private let languageKey = "selected_language"
    private let localeKey = "selected_locale"
    
    private init() {
        loadSavedLanguage()
    }
    
    func setLanguage(_ language: SupportedLanguage) {
        currentLanguage = language
        currentLocale = Locale(identifier: language.rawValue)
        
        // Save to UserDefaults
        userDefaults.set(language.rawValue, forKey: languageKey)
        userDefaults.set(language.rawValue, forKey: localeKey)
        
        // Update app language
        updateAppLanguage()
        
        // Post notification
        NotificationCenter.default.post(
            name: .languageChanged,
            object: language
        )
    }
    
    private func loadSavedLanguage() {
        if let savedLanguage = userDefaults.string(forKey: languageKey),
           let language = SupportedLanguage(rawValue: savedLanguage) {
            currentLanguage = language
            currentLocale = Locale(identifier: language.rawValue)
        } else {
            // Use system language
            let systemLanguage = Locale.current.languageCode ?? "en"
            currentLanguage = SupportedLanguage(rawValue: systemLanguage) ?? .english
            currentLocale = Locale.current
        }
    }
    
    private func updateAppLanguage() {
        // Update bundle
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return
        }
        
        // Update current bundle
        UserDefaults.standard.set([currentLanguage.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}

// Notification extension
extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}
```

---

## 📝 String Localization

### 📝 Localized Strings

```swift
// Localized String Manager
class LocalizedStringManager {
    static let shared = LocalizedStringManager()
    
    private let bundle: Bundle
    private let localizationManager = LocalizationManager.shared
    
    init() {
        self.bundle = Bundle.main
    }
    
    func localizedString(for key: String, comment: String = "") -> String {
        return NSLocalizedString(key, bundle: bundle, comment: comment)
    }
    
    func localizedString(for key: String, arguments: CVarArg..., comment: String = "") -> String {
        let format = NSLocalizedString(key, bundle: bundle, comment: comment)
        return String(format: format, arguments: arguments)
    }
}

// String extension
extension String {
    var localized: String {
        return LocalizedStringManager.shared.localizedString(for: self)
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return LocalizedStringManager.shared.localizedString(for: self, arguments: arguments)
    }
}

// Usage examples
struct LocalizedStrings {
    // Common strings
    static let ok = "common.ok".localized
    static let cancel = "common.cancel".localized
    static let save = "common.save".localized
    static let delete = "common.delete".localized
    static let edit = "common.edit".localized
    static let done = "common.done".localized
    static let loading = "common.loading".localized
    static let error = "common.error".localized
    static let success = "common.success".localized
    
    // User related strings
    static let userProfile = "user.profile".localized
    static let userName = "user.name".localized
    static let userEmail = "user.email".localized
    static let userSettings = "user.settings".localized
    
    // Error messages
    static let networkError = "error.network".localized
    static let serverError = "error.server".localized
    static let invalidInput = "error.invalid_input".localized
    
    // Dynamic strings
    static func welcomeMessage(name: String) -> String {
        return "welcome.message".localized(with: name)
    }
    
    static func itemsCount(_ count: Int) -> String {
        return "items.count".localized(with: count)
    }
}
```

### 📝 Localization Files

```strings
// Localizable.strings (English)
"common.ok" = "OK";
"common.cancel" = "Cancel";
"common.save" = "Save";
"common.delete" = "Delete";
"common.edit" = "Edit";
"common.done" = "Done";
"common.loading" = "Loading...";
"common.error" = "Error";
"common.success" = "Success";

"user.profile" = "User Profile";
"user.name" = "Name";
"user.email" = "Email";
"user.settings" = "Settings";

"error.network" = "Network error occurred";
"error.server" = "Server error occurred";
"error.invalid_input" = "Invalid input";

"welcome.message" = "Welcome, %@!";
"items.count" = "%d items";
```

```strings
// Localizable.strings (Spanish)
"common.ok" = "Aceptar";
"common.cancel" = "Cancelar";
"common.save" = "Guardar";
"common.delete" = "Eliminar";
"common.edit" = "Editar";
"common.done" = "Hecho";
"common.loading" = "Cargando...";
"common.error" = "Error";
"common.success" = "Éxito";

"user.profile" = "Perfil de Usuario";
"user.name" = "Nombre";
"user.email" = "Correo Electrónico";
"user.settings" = "Configuración";

"error.network" = "Error de red ocurrió";
"error.server" = "Error del servidor ocurrió";
"error.invalid_input" = "Entrada inválida";

"welcome.message" = "¡Bienvenido, %@!";
"items.count" = "%d elementos";
```

```strings
// Localizable.strings (Arabic)
"common.ok" = "موافق";
"common.cancel" = "إلغاء";
"common.save" = "حفظ";
"common.delete" = "حذف";
"common.edit" = "تعديل";
"common.done" = "تم";
"common.loading" = "جاري التحميل...";
"common.error" = "خطأ";
"common.success" = "نجح";

"user.profile" = "ملف المستخدم";
"user.name" = "الاسم";
"user.email" = "البريد الإلكتروني";
"user.settings" = "الإعدادات";

"error.network" = "حدث خطأ في الشبكة";
"error.server" = "حدث خطأ في الخادم";
"error.invalid_input" = "إدخال غير صحيح";

"welcome.message" = "مرحباً، %@!";
"items.count" = "%d عنصر";
```

---

## 🎨 RTL Support

### 🎨 RTL Layout Manager

```swift
// RTL Layout Manager
class RTLLayoutManager {
    static let shared = RTLLayoutManager()
    
    private let localizationManager = LocalizationManager.shared
    
    var isRTL: Bool {
        return localizationManager.currentLanguage.isRTL
    }
    
    var layoutDirection: UIUserInterfaceLayoutDirection {
        return isRTL ? .rightToLeft : .leftToRight
    }
    
    func configureForRTL() {
        // Configure app for RTL
        if isRTL {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
    }
}

// SwiftUI RTL Support
struct RTLView<Content: View>: View {
    let content: Content
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .environment(\.layoutDirection, localizationManager.currentLanguage.isRTL ? .rightToLeft : .leftToRight)
    }
}

// UIKit RTL Support
extension UIView {
    func configureForRTL() {
        if RTLLayoutManager.shared.isRTL {
            semanticContentAttribute = .forceRightToLeft
        } else {
            semanticContentAttribute = .forceLeftToRight
        }
    }
}
```

---

## 📅 Date and Time Localization

### 📅 Date Formatter

```swift
// Localized Date Formatter
class LocalizedDateFormatter {
    static let shared = LocalizedDateFormatter()
    
    private let localizationManager = LocalizationManager.shared
    
    func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.locale = localizationManager.currentLocale
        formatter.dateStyle = style
        return formatter.string(from: date)
    }
    
    func formatTime(_ date: Date, style: DateFormatter.Style = .short) -> String {
        let formatter = DateFormatter()
        formatter.locale = localizationManager.currentLocale
        formatter.timeStyle = style
        return formatter.string(from: date)
    }
    
    func formatDateTime(_ date: Date, dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .short) -> String {
        let formatter = DateFormatter()
        formatter.locale = localizationManager.currentLocale
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: date)
    }
    
    func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = localizationManager.currentLocale
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// Date extension
extension Date {
    var localizedDate: String {
        return LocalizedDateFormatter.shared.formatDate(self)
    }
    
    var localizedTime: String {
        return LocalizedDateFormatter.shared.formatTime(self)
    }
    
    var localizedDateTime: String {
        return LocalizedDateFormatter.shared.formatDateTime(self)
    }
    
    var localizedRelativeDate: String {
        return LocalizedDateFormatter.shared.formatRelativeDate(self)
    }
}
```

---

## 💰 Currency Localization

### 💰 Currency Formatter

```swift
// Localized Currency Formatter
class LocalizedCurrencyFormatter {
    static let shared = LocalizedCurrencyFormatter()
    
    private let localizationManager = LocalizationManager.shared
    
    func formatCurrency(_ amount: Decimal, currencyCode: String? = nil) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = localizationManager.currentLocale
        
        if let currencyCode = currencyCode {
            formatter.currencyCode = currencyCode
        }
        
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "\(amount)"
    }
    
    func formatCurrency(_ amount: Decimal, for locale: Locale) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "\(amount)"
    }
}

// Decimal extension
extension Decimal {
    var localizedCurrency: String {
        return LocalizedCurrencyFormatter.shared.formatCurrency(self)
    }
    
    func localizedCurrency(for locale: Locale) -> String {
        return LocalizedCurrencyFormatter.shared.formatCurrency(self, for: locale)
    }
}
```

---

## 📏 Measurement Localization

### 📏 Measurement Formatter

```swift
// Localized Measurement Formatter
class LocalizedMeasurementFormatter {
    static let shared = LocalizedMeasurementFormatter()
    
    private let localizationManager = LocalizationManager.shared
    
    func formatDistance(_ distance: Measurement<UnitLength>) -> String {
        let formatter = MeasurementFormatter()
        formatter.locale = localizationManager.currentLocale
        formatter.unitOptions = .providedUnit
        return formatter.string(from: distance)
    }
    
    func formatWeight(_ weight: Measurement<UnitMass>) -> String {
        let formatter = MeasurementFormatter()
        formatter.locale = localizationManager.currentLocale
        formatter.unitOptions = .providedUnit
        return formatter.string(from: weight)
    }
    
    func formatTemperature(_ temperature: Measurement<UnitTemperature>) -> String {
        let formatter = MeasurementFormatter()
        formatter.locale = localizationManager.currentLocale
        formatter.unitOptions = .providedUnit
        return formatter.string(from: temperature)
    }
    
    func formatVolume(_ volume: Measurement<UnitVolume>) -> String {
        let formatter = MeasurementFormatter()
        formatter.locale = localizationManager.currentLocale
        formatter.unitOptions = .providedUnit
        return formatter.string(from: volume)
    }
}

// Measurement extensions
extension Measurement where UnitType == UnitLength {
    var localizedDistance: String {
        return LocalizedMeasurementFormatter.shared.formatDistance(self)
    }
}

extension Measurement where UnitType == UnitMass {
    var localizedWeight: String {
        return LocalizedMeasurementFormatter.shared.formatWeight(self)
    }
}

extension Measurement where UnitType == UnitTemperature {
    var localizedTemperature: String {
        return LocalizedMeasurementFormatter.shared.formatTemperature(self)
    }
}

extension Measurement where UnitType == UnitVolume {
    var localizedVolume: String {
        return LocalizedMeasurementFormatter.shared.formatVolume(self)
    }
}
```

---

## 🎨 Cultural Adaptations

### 🎨 Cultural Design Manager

```swift
// Cultural Design Manager
class CulturalDesignManager {
    static let shared = CulturalDesignManager()
    
    private let localizationManager = LocalizationManager.shared
    
    var colorScheme: ColorScheme {
        switch localizationManager.currentLanguage {
        case .chineseSimplified, .chineseTraditional, .japanese, .korean:
            return .redAccent
        case .arabic, .hebrew, .persian:
            return .blueAccent
        case .indianLanguages:
            return .orangeAccent
        default:
            return .default
        }
    }
    
    var fontFamily: String {
        switch localizationManager.currentLanguage {
        case .chineseSimplified, .chineseTraditional:
            return "PingFang SC"
        case .japanese:
            return "Hiragino Sans"
        case .korean:
            return "Apple SD Gothic Neo"
        case .arabic, .hebrew, .persian:
            return "Arial"
        case .thai:
            return "Thonburi"
        default:
            return "SF Pro"
        }
    }
    
    var numberFormat: NumberFormat {
        switch localizationManager.currentLanguage {
        case .german, .french, .italian, .spanish:
            return .commaDecimal
        case .arabic, .persian:
            return .arabicNumerals
        default:
            return .standard
        }
    }
}

enum ColorScheme {
    case default
    case redAccent
    case blueAccent
    case orangeAccent
}

enum NumberFormat {
    case standard
    case commaDecimal
    case arabicNumerals
}
```

---

## 📱 UI Localization

### 📱 Localized Views

```swift
// Localized Text View
struct LocalizedText: View {
    let key: String
    let arguments: [CVarArg]
    
    init(_ key: String, arguments: CVarArg...) {
        self.key = key
        self.arguments = arguments
    }
    
    var body: some View {
        if arguments.isEmpty {
            Text(key.localized)
        } else {
            Text(key.localized(with: arguments))
        }
    }
}

// Localized Button
struct LocalizedButton: View {
    let key: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(key.localized)
        }
    }
}

// Localized Text Field
struct LocalizedTextField: View {
    let key: String
    @Binding var text: String
    
    var body: some View {
        TextField(key.localized, text: $text)
    }
}

// Usage example
struct LocalizedUserView: View {
    @State private var name = ""
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            LocalizedText("user.profile")
                .font(.title)
            
            LocalizedTextField("user.name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            LocalizedButton("common.save") {
                // Save action
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .environment(\.layoutDirection, localizationManager.currentLanguage.isRTL ? .rightToLeft : .leftToRight)
    }
}
```

---

## 🧪 Localization Testing

### 🧪 Localization Tests

```swift
// Localization Tests
class LocalizationTests: XCTestCase {
    func testAllLanguagesHaveStrings() {
        for language in SupportedLanguage.allCases {
            let bundle = Bundle.main
            let path = bundle.path(forResource: language.rawValue, ofType: "lproj")
            
            XCTAssertNotNil(path, "Missing localization for \(language.displayName)")
        }
    }
    
    func testStringLocalization() {
        let testCases = [
            ("common.ok", "OK"),
            ("common.cancel", "Cancel"),
            ("user.profile", "User Profile")
        ]
        
        for (key, expectedEnglish) in testCases {
            let localized = NSLocalizedString(key, bundle: Bundle.main, comment: "")
            XCTAssertNotEqual(localized, key, "Missing localization for key: \(key)")
        }
    }
    
    func testRTLSupport() {
        let rtlLanguages: [SupportedLanguage] = [.arabic, .hebrew, .persian, .urdu]
        
        for language in rtlLanguages {
            XCTAssertTrue(language.isRTL, "\(language.displayName) should be RTL")
        }
    }
    
    func testDateFormatting() {
        let date = Date()
        let formatter = LocalizedDateFormatter.shared
        
        for language in SupportedLanguage.allCases {
            LocalizationManager.shared.setLanguage(language)
            let formatted = formatter.formatDate(date)
            XCTAssertFalse(formatted.isEmpty, "Date formatting failed for \(language.displayName)")
        }
    }
    
    func testCurrencyFormatting() {
        let amount: Decimal = 1234.56
        let formatter = LocalizedCurrencyFormatter.shared
        
        for language in SupportedLanguage.allCases {
            LocalizationManager.shared.setLanguage(language)
            let formatted = formatter.formatCurrency(amount)
            XCTAssertFalse(formatted.isEmpty, "Currency formatting failed for \(language.displayName)")
        }
    }
}
```

---

## 📋 Localization Checklist

### 🌍 Language Support
- [ ] **50+ Languages** - Comprehensive language support
- [ ] **RTL Support** - Arabic, Hebrew, Persian, Urdu
- [ ] **Cultural Adaptations** - Local design patterns
- [ ] **Font Support** - Appropriate fonts for each language

### 📝 String Localization
- [ ] **All UI Strings** - Complete string localization
- [ ] **Dynamic Strings** - Parameterized strings
- [ ] **Pluralization** - Proper plural forms
- [ ] **Context Comments** - Clear context for translators

### 📅 Date/Time
- [ ] **Date Formatting** - Local date formats
- [ ] **Time Formatting** - Local time formats
- [ ] **Relative Dates** - "2 hours ago" etc.
- [ ] **Calendar Support** - Local calendars

### 💰 Currency
- [ ] **Currency Symbols** - Local currency symbols
- [ ] **Formatting** - Local number formatting
- [ ] **Exchange Rates** - Real-time rates
- [ ] **Decimal Places** - Local decimal conventions

### 📏 Measurements
- [ ] **Distance** - Metric/Imperial systems
- [ ] **Weight** - Local weight units
- [ ] **Temperature** - Celsius/Fahrenheit
- [ ] **Volume** - Local volume units

### 🎨 UI/UX
- [ ] **RTL Layout** - Right-to-left support
- [ ] **Cultural Colors** - Local color preferences
- [ ] **Typography** - Local font preferences
- [ ] **Spacing** - Local spacing conventions

### 🧪 Testing
- [ ] **String Coverage** - All strings localized
- [ ] **RTL Testing** - RTL layout testing
- [ ] **Format Testing** - Date/currency formatting
- [ ] **Cultural Testing** - Local user testing

---

<div align="center">

**🌍 Dünya standartlarında çoklu dil desteği için teşekkürler!**

**🚀 Dünya standartlarında iOS Clean Architecture Template**

</div> 