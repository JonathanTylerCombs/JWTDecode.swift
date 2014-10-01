<<<<<<< HEAD
Pod::Spec.new do |s|
  s.name             = 'JWTDecode'
  s.version          = '3.1.0'
  s.summary          = 'A JWT decoder for iOS, macOS, tvOS, and watchOS'
  s.description      = <<-DESC
                        Easily decode a JWT and access the claims it contains. 
                        > This library doesn't validate the JWT. Any well-formed JWT can be decoded from Base64URL.
                        DESC
  s.homepage         = 'https://github.com/auth0/JWTDecode.swift'
  s.license          = 'MIT'
  s.author           = { 'Auth0' => 'support@auth0.com', 'Rita Zerrizuela' => 'rita.zerrizuela@auth0.com' }
  s.source           = { :git => 'https://github.com/auth0/JWTDecode.swift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/auth0'

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '11.0'
  s.tvos.deployment_target = '13.0'
  s.watchos.deployment_target = '7.0'

  s.source_files = 'JWTDecode/*.swift'
  s.swift_versions = ['5.7', '5.8']
=======
#
# Be sure to run `pod lib lint JWTDecode.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "JWTDecode"
  s.version          = "0.1.0"
  s.summary          = "A short description of JWTDecode."
  s.description      = <<-DESC
                       An optional longer description of JWTDecode

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/<GITHUB_USERNAME>/JWTDecode"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Hernan Zalazar" => "hernanzalazar@gmail.com" }
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/JWTDecode.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'JWTDecode' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
>>>>>>> 7e714cf (Initial commit)
end
