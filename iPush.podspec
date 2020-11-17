Pod::Spec.new do |spec|
  spec.author       = "胡式华"
  spec.name         = "iPush"
  spec.version      = "1.2.1"
  spec.summary      = "iPush SDK for iOS"
  spec.description  = "iPush 智能推送平台 SDK for iOS"
  spec.homepage     = "https://github.com/hushihua/iPush.git"
  spec.license      = { :type => "Commercial", :text => "@2019 Lema.cm" }
  spec.author       = { "Adam.Hu" => "adam.hu.2018@gmail.com" }
  spec.source       = { :git => "https://github.com/hushihua/iPush.git", :tag=>"#{spec.version}" }
  spec.source_files = "iPush.framework/Headers/*.{h}"
  spec.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }
  spec.requires_arc = true
  spec.ios.deployment_target = "10.0"
  spec.ios.vendored_frameworks = "iPush.framework"
  
  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  
end
