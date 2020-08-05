#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_tim'
  s.version          = '0.2.2'
  s.summary          = 'A Flutter IM plugin.'
  s.description      = <<-DESC
A new Flutter IM plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'YYModel'
  s.dependency 'TXIMSDK_iOS'
  s.dependency 'MJExtension'


  s.ios.deployment_target = '8.0'
end

