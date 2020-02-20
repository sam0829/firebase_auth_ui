#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'firebase_auth_ui'
  s.version          = '0.0.1'
  s.summary          = 'A flutter plugin for Firebase Auth UI'
  s.description      = <<-DESC
A flutter plugin for Firebase Auth UI
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.static_framework = true
  s.dependency 'Flutter'
  s.dependency 'FirebaseUI/Auth'
  s.dependency 'Firebase'
  s.dependency 'Firebase/Core'
  s.dependency 'FirebaseUI/Email'
  s.dependency 'FirebaseUI/Facebook'
  s.dependency 'FirebaseUI/Google'
  s.dependency 'FirebaseUI/OAuth'
  s.dependency 'FirebaseUI/Phone'
  s.dependency 'FBSDKCoreKit'

  s.ios.deployment_target = '9.0'
  s.resource_bundle = {
    'firebase_auth_ui' => ['Classes/**/*.{xib,png,lproj}']
  }
end

