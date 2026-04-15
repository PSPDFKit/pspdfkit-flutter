# frozen_string_literal: true

#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint nutrient_flutter_ios.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = "nutrient_flutter_ios"
  s.version          = "1.0.2"
  s.summary          = "iOS implementation of the nutrient_flutter plugin."
  s.description      = <<~DESC
    iOS implementation of the nutrient_flutter plugin.
  DESC
  s.homepage         = "https://nutrient.io"
  s.license          = { file: "../LICENSE" }
  s.author           = { "Nutrient" => "support@nutrient.io" }
  s.source           = { path: "." }
  s.source_files = "Classes/**/*"
  s.public_header_files = "Classes/**/*.h"
  s.dependency "Flutter"
  s.dependency "PSPDFKit"
  s.dependency "Instant"
  s.platform = :ios, "16.0"
  s.weak_frameworks = ["PencilKit"]

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { "DEFINES_MODULE" => "YES", "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "i386" }
  s.swift_version = "5.0"

  # NutrientIOSBindings.m trampolines and NutrientFFI.mm C functions are all
  # marked __attribute__((used)), so the linker retains them without -force_load.
  # The previous user_target_xcconfig -force_load approach caused "build input
  # file cannot be found" errors because the app target's link phase had no
  # build-order dependency on the pod's compile phase.
end
