# frozen_string_literal: true

#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name                  = "nutrient_flutter"
  s.version               = "5.0.1"
  s.homepage              = "https://nutrient.io"
  s.documentation_url     = "https://nutrient.io/guides/flutter"
  s.license               = { type: "Commercial", file: "../LICENSE" }
  s.author                = { "Nutrient" => "support@nutrient.io" }
  s.summary               = "Flutter PDF Library by Nutrient"
  s.description           = <<-DESC
                            A high-performance viewer, extensive annotation and document editing tools, digital signatures, and more.
  DESC
  s.source                = { path: "." }
  s.source_files          = "Classes/**/*.{h,m,swift}"
  s.public_header_files   = "Classes/**/*.h"
  s.dependency("Flutter")
  s.dependency("PSPDFKit")
  s.dependency("Instant")
  s.swift_version         = "5.0"
  s.platform              = :ios, "16.0"
  s.version               = "5.0.1"
  s.pod_target_xcconfig = { "DEFINES_MODULE" => "YES", "SWIFT_INSTALL_OBJC_HEADER" => "NO" }
end
