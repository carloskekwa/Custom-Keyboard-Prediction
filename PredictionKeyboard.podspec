Pod::Spec.new do |s|
  s.name             = 'PredictionKeyboard'
  s.version          = '1.0.0'
  s.summary          = 'Next word prediction for iOS custom keyboards'
  s.description      = <<-DESC
    PredictionKeyboard provides intelligent next-word prediction for custom iOS keyboards.
    Built on Realm for fast, persistent prediction scoring across user input contexts.
  DESC

  s.homepage         = 'https://github.com/carloskekwa/Custom-Keyboard-Prediction'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Carlos Kekwa' => 'carlos.kekwa@gmail.com' }
  s.ios.deployment_target = '13.0'
  
  # Source as CocoaPods source spec (not pre-built binary)
  s.source           = { :git => 'https://github.com/carloskekwa/Custom-Keyboard-Prediction.git', :tag => s.version.to_s }
  
  # Core dependencies
  s.dependency 'Realm', '~> 10.0'

  # Source files: include all .h/.m files from Sources folder
  s.source_files     = 'Sources/**/*.{h,m,mm,c,cpp}'
  
  # Public headers: expose main API and models
  s.public_header_files = [
    'Sources/Public/PredictionKeyboard.h',
    'Sources/Public/PredictionKeyboardManager.h',
    'Sources/Public/PredictionModels.h',
    'Sources/Models/PredictionTable.h',
    'Sources/Models/PredictionWord.h',
    'Sources/Utilities/PredictionConstants.h'
  ]
  
  # Bundled prediction database resource
  s.resources        = 'Resources/predictiondb.realm'
  
  # Compiler flags for ARC and other optimizations
  s.compiler_flags   = '-fmodules -fcxx-modules'
  s.requires_arc     = true
end
