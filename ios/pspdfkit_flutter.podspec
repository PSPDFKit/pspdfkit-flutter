#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'pspdfkit_flutter'
  s.version          = '0.0.1'
  s.summary          = 'PSPDFKit flutter plugin.'
  s.description      = <<-DESC
PSPDFKit flutter plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'PSPDFKit'
  s.swift_version = '5.0'
  s.ios.deployment_target = '12.0'
end

