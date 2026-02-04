Pod::Spec.new do |s|
  s.name             = 'iOSCleanArchitectureTemplate'
  s.version          = '1.0.0'
  s.summary          = 'Clean Architecture template for iOS with MVVM and dependency injection.'
  s.description      = <<-DESC
    iOSCleanArchitectureTemplate provides a production-ready Clean Architecture
    template for iOS. Features include MVVM pattern, dependency injection,
    use cases, repositories, and comprehensive test coverage examples.
  DESC

  s.homepage         = 'https://github.com/muhittincamdali/ios-clean-architecture-template'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Muhittin Camdali' => 'contact@muhittincamdali.com' }
  s.source           = { :git => 'https://github.com/muhittincamdali/ios-clean-architecture-template.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'

  s.swift_versions = ['5.9', '5.10', '6.0']
  s.source_files = 'Sources/**/*.swift'
  s.frameworks = 'Foundation', 'SwiftUI', 'Combine'
end
