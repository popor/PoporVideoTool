#
# Be sure to run `pod lib lint PoporVideoTool.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PoporVideoTool'
  s.version          = '1.0'
  s.summary          = '视频压缩 video compress, wechat, 类似微信视频压缩的清晰度和速度.'

  s.homepage         = 'https://github.com/popor/PoporVideoTool'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'popor' => '908891024@qq.com' }
  s.source           = { :git => 'https://github.com/popor/PoporVideoTool.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target  = '8.0' # minimum SDK with autolayout
  s.osx.deployment_target  = '10.15' # minimum SDK with autolayout
  s.tvos.deployment_target = '9.0' # minimum SDK with autolayout

  s.ios.frameworks         = 'Foundation'
  s.tvos.frameworks        = 'Foundation'
  s.osx.frameworks         = 'AppKit'
  
  s.source_files = 'PoporVideoTool/Classes/**/*'
  
end
