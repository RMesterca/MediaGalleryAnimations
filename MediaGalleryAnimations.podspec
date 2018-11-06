#
# Be sure to run `pod lib lint MediaGalleryAnimations.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MediaGalleryAnimations'
  s.version          = '0.1.0'
  s.summary          = 'Pod for simple interactive and interruptible animations'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'MediaGalleryPanAnimations helps simplify the implementation of interactive and interruptible pan gesture animations'

  s.homepage         = 'https://github.com/RMesterca/MediaGalleryAnimations.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rmesterca' => 'ralucamesterca@gmail.com' }
  s.source           = { :git => 'https://github.com/RMesterca/MediaGalleryAnimations.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '4.0'

  s.source_files = 'MediaGalleryAnimations/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MediaGalleryAnimations' => ['MediaGalleryAnimations/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
