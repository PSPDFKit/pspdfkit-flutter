# frozen_string_literal: true

#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint nutrient_flutter_ios.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = "nutrient_flutter_ios"
  s.version          = "2.0.0"
  s.summary          = "iOS implementation of the nutrient_flutter plugin."
  s.description      = <<~DESC
    iOS implementation of the nutrient_flutter plugin.
  DESC
  s.homepage         = "https://nutrient.io"
  s.license          = { file: "../LICENSE" }
  s.author           = { "Nutrient" => "support@nutrient.io" }
  s.source           = { path: "." }
  s.source_files = "Classes/**/*"
  # The Objective-C sources are compiled by the native-assets hook (hook/build.dart)
  # into nutrient_flutter_ios_ffi.dylib, which Dart binds to. Compiling them here
  # too gave the app two copies of their classes and static state.
  s.exclude_files = "Classes/**/*.{m,mm}"
  s.public_header_files = "Classes/**/*.h"
  s.dependency "Flutter"
  # Must match the pins in `nutrient_flutter.podspec`. An unpinned or mismatched
  # version causes the Swift files here (which `import PSPDFKit`/`PSPDFKitUI`)
  # to fail to compile, producing a framework with an empty Swift module.
  s.dependency "PSPDFKit"
  s.dependency "Instant"
  s.platform = :ios, "17.0"
  s.weak_frameworks = ["PencilKit"]

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { "DEFINES_MODULE" => "YES", "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "i386" }
  s.swift_version = "5.0"
end
