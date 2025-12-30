Pod::Spec.new do |s|
  s.name             = 'PredictionKeyboard'
  s.version          = '1.0.32'
  s.summary          = 'Intelligent next-word prediction for iOS keyboards'
  
  s.description      = <<-DESC
PredictionKeyboard provides fast, accurate next-word prediction and word completion 
for custom iOS keyboards. Built on a 600MB Realm database with millions of n-grams 
for context-aware suggestions. Database is downloaded on first launch.
                       DESC

  s.homepage         = 'https://github.com/carloskekwa/Custom-Keyboard-Prediction'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Carlos Kekwa' => 'carlos_kek@hotmail.com' }
  s.source           = { :http => 'https://youtakeadvantage.s3.eu-central-1.amazonaws.com/PredictionKeyboard.zip' }

  s.ios.deployment_target = '12.0'
  s.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4', '5.5']
  
  s.vendored_frameworks = 'PredictionKeyboard.xcframework'
  s.preserve_paths = 'Resources'
  
  s.frameworks = 'Foundation', 'UIKit', 'Security'
  s.libraries = 'c++', 'compression', 'z'
  
  s.dependency 'Realm', '~> 10.0'
  s.dependency 'RealmSwift', '~> 10.0'
  
  s.requires_arc = true
  
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }
end
