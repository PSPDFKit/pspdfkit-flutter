# frozen_string_literal: true

#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name                  = "pspdfkit_flutter"
  s.version               = "3.12.0"
  s.homepage              = "https://PSPDFKit.com"
  s.documentation_url     = "https://pspdfkit.com/guides/flutter"
  s.license               = { type: "Commercial", file: "../LICENSE" }
  s.author                = { "PSPDFKit GmbH" => "support@pspdfkit.com" }
  s.summary               = "Flutter PDF Library by PSPDFKit"
  s.description           = <<-DESC
                            A high-performance viewer, extensive annotation and document editing tools, digital signatures, and more.
  DESC
  s.source                = { path: "." }
  s.source_files          = "Classes/**/*.{h,m,swift}"
  s.public_header_files   = "Classes/**/*.h"
  s.dependency("Flutter")
  s.dependency("PSPDFKit", "13.8.0")
  s.dependency("Instant", "13.8.0")
  s.swift_version         = "5.0"
  s.platform              = :ios, "15.0"
  s.version               = "3.12.0"
  s.pod_target_xcconfig = { "DEFINES_MODULE" => "YES", "SWIFT_INSTALL_OBJC_HEADER" => "NO" }
end
