Pod::Spec.new do |s|
    
    s.name         = "XQSystemImagePicker"      #SDK名称
    s.version      = "0.0.1"#版本号
    s.homepage     = "https://github.com/SyKingW/XQSystemImagePicker"  #工程主页地址
    s.summary      = "对系统图片选择器的封装"  #项目的简单描述
    s.license      = "MIT"  #协议类型
    s.author       = { "王兴乾" => "1034439685@qq.com" } #作者及联系方式
    s.ios.deployment_target  = "10.0" #平台及版本
    s.source       = { :git => "https://github.com/SyKingW/XQSystemImagePicker.git" ,:tag => "#{s.version}"}   #工程地址及版本号
    s.requires_arc = true   #是否必须arc
    
    s.dependency 'SVProgressHUD'
    s.dependency 'XQAlert'

	s.source_files = 'SDK/**/*.{swift}'
  # s.resources = 'SDK/**/*.{strings}'

  s.frameworks = "PhotosUI"
  s.frameworks = "MobileCoreServices"
  
    
end






