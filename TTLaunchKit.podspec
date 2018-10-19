#
# Be sure to run `pod lib lint TTLaunchKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTLaunchKit'
  s.version          = '1.0.0'
  s.summary          = '开机视频动画解决方案+启动屏广告解决方案+启动屏过度到广告'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/claudeli@yeah.net/TTLaunchKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'claudeli@yeah.net' => 'claudeli@yeah.net' }
  s.source           = { :git => 'https://github.com/claudeli@yeah.net/TTLaunchKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'TTLaunchKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'TTLaunchKit' => ['TTLaunchKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
    s.dependency 'TTNetworking'
    s.dependency 'CLTools'
    s.dependency 'YYKit'
end
