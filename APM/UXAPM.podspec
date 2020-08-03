Pod::Spec.new do |s|

  s.name         = "UXAPM"
  s.version      = "0.0.1"
  s.summary      = "UXAPM"

  s.description  = <<-DESC
                   UXAPM framework
                   DESC

  s.homepage    = "http://git.xin.com/ios_publib/UXAP"

  s.license     = {:type => 'MIT'}

  s.author      = { "Xie Lei" => "xielei@xin.com" }

  s.platform     = :ios, "9.0"

  s.source       = { :git => "http://git.xin.com/ios_publib/UXAPM.git", :tag => "#{s.version}" }

  s.source_files  = "Classes", "Classes/**/*.{h,m}"

  s.exclude_files = "Classes/Exclude"

  s.public_header_files = 'Classes/UXAPMAgent.h','Classes/UXAPMConfig.h'

  # s.vendored_frameworks = 'src/*.framework'
  
  s.pod_target_xcconfig = { "HEADER_SEARCH_PATHS" =>"$(SRCROOT)/../CollectionViewDemo/** $(SRCROOT)/../F100BaiduMapKit.framework/**"}

end
