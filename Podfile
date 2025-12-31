# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '15.0'

target 'testPrediction' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # PredictionKeyboard library from CocoaPods
  pod 'PredictionKeyboard', path: '../PredictionKeyboardClean', inhibit_warnings: true
  target 'testPredictionTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'testPredictionUITests' do
    # Pods for testing
  end

end

target 'testKeyboard' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # PredictionKeyboard library from CocoaPods
  pod 'PredictionKeyboard', path: '../PredictionKeyboardClean', inhibit_warnings: true

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'PredictionKeyboard'
      target.build_configurations.each do |config|
        config.build_settings['INFOPLIST_FILE'] = ''
        config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
      end
    end
  end
end
