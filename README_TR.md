<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSAppTemplates/master/.github/brand/banner-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSAppTemplates/master/.github/brand/banner-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSAppTemplates/master/.github/brand/banner-tr-light.svg" alt="iOSAppTemplates: iOS 18 için 21 SwiftUI uygulama şablonu; her biri kendi adınızla kopyalayabileceğiniz testli bir Swift paketi."></picture></p>

<p align="center"><a href="README.md">English</a> · <a href="README_TR.md">Türkçe</a></p>

# iOSAppTemplates'e taşındı

Bu proje artık [iOSAppTemplates](https://github.com/muhittincamdali/iOSAppTemplates) içinde yaşıyor.
Bu depo arşivlendi ve salt okunur.

Clean Architecture şablonu yeniden yazıldı ve orada
[`Templates/CleanArchitectureApp`](https://github.com/muhittincamdali/iOSAppTemplates/tree/master/Templates/CleanArchitectureApp)
olarak birleştirildi: Domain, Data ve Presentation hedeflerine ayrılmış, HTTP katmanı, çevrimdışı
önbelleği ve testleri olan, iOS 18 için bir SwiftUI uygulaması. Bu depodaki kodun yerini alır;
bu yüzden API ve modül adları farklıdır. Eski kaynaklar başvuru için bu deponun geçmişinde durur.

- Şablon: [Templates/CleanArchitectureApp](https://github.com/muhittincamdali/iOSAppTemplates/tree/master/Templates/CleanArchitectureApp)
- Rehber: [Working with the Clean Architecture Template](https://github.com/muhittincamdali/iOSAppTemplates/blob/master/Sources/TemplateScaffold/TemplateScaffold.docc/WorkingWithTheCleanArchitectureTemplate.md) (İngilizce)
- Sürümler: [iOSAppTemplates sürümleri](https://github.com/muhittincamdali/iOSAppTemplates/releases)

## Kurulum

iOSAppTemplates klonunda `create-ios-app` aracıyla şablondan proje oluşturun:

```sh
git clone https://github.com/muhittincamdali/iOSAppTemplates.git
cd iOSAppTemplates
swift run create-ios-app new MyApp --template clean-architecture --output ~/Developer
```

İskele mantığı ayrıca bir Swift paketi kütüphanesi olarak da kullanılabilir (macOS 14 veya üzeri):

```swift
.package(url: "https://github.com/muhittincamdali/iOSAppTemplates.git", from: "3.0.0")
```

## Lisans

MIT, bkz. [LICENSE](LICENSE).
