<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSAppTemplates/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOSAppTemplates/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOSAppTemplates/master/.github/brand/banner-light.svg" alt="iOSAppTemplates: 21 SwiftUI app templates for iOS 18, each a tested Swift package you can copy under your own name."></picture></p>

<p align="center"><a href="README.md">English</a> · <a href="README_TR.md">Türkçe</a></p>

# Moved to iOSAppTemplates

This project now lives in [iOSAppTemplates](https://github.com/muhittincamdali/iOSAppTemplates).
This repository is archived and read-only.

The Clean Architecture template was rewritten and merged there as
[`Templates/CleanArchitectureApp`](https://github.com/muhittincamdali/iOSAppTemplates/tree/master/Templates/CleanArchitectureApp):
a SwiftUI app for iOS 18 split into Domain, Data and Presentation targets, with an HTTP layer,
an offline cache and tests. It replaces the code in this repository, so APIs and module names
differ; the old sources stay here in the history for reference.

- Template: [Templates/CleanArchitectureApp](https://github.com/muhittincamdali/iOSAppTemplates/tree/master/Templates/CleanArchitectureApp)
- Guide: [Working with the Clean Architecture Template](https://github.com/muhittincamdali/iOSAppTemplates/blob/master/Sources/TemplateScaffold/TemplateScaffold.docc/WorkingWithTheCleanArchitectureTemplate.md)
- Releases: [iOSAppTemplates releases](https://github.com/muhittincamdali/iOSAppTemplates/releases)

## Install

Create a project from the template with the `create-ios-app` tool in a clone of iOSAppTemplates:

```sh
git clone https://github.com/muhittincamdali/iOSAppTemplates.git
cd iOSAppTemplates
swift run create-ios-app new MyApp --template clean-architecture --output ~/Developer
```

The scaffolding logic is also available as a Swift package library (macOS 14 or later):

```swift
.package(url: "https://github.com/muhittincamdali/iOSAppTemplates.git", from: "3.0.0")
```

## License

MIT, see [LICENSE](LICENSE).
