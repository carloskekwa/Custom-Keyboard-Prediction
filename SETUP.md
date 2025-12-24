# Setup Instructions for Development

## For Library Developers

This is a CocoaPods library package. To use it in your own project:

### Option 1: Use in Your Existing App

Add to your app's Podfile:

```ruby
pod 'PredictionKeyboard', :path => '../PredictionKeyboardClean'
```

Then run:
```bash
pod install
```

### Option 2: Create Example App (Recommended for Testing)

1. **Create a new Xcode project**:
   ```bash
   # Use Xcode GUI or from command line
   # Create: iOS > App > Single View App named "PredictionKeyboardExample"
   ```

2. **Create Podfile in project root**:
   ```bash
   cd PredictionKeyboardExample
   pod init
   ```

3. **Edit Podfile**:
   ```ruby
   platform :ios, '12.0'
   
   target 'PredictionKeyboardExample' do
     use_frameworks!
     
     # Local development pod
     pod 'PredictionKeyboard', :path => '../PredictionKeyboardClean'
     
     # Dependencies
     pod 'Realm'
   end
   ```

4. **Install pods**:
   ```bash
   pod install
   ```

5. **Use the library**:
   ```objc
   #import <PredictionKeyboard/PredictionKeyboard.h>
   
   PredictionKeyboardManager *manager = [[PredictionKeyboardManager alloc] init];
   [manager initializePredictionDatabase:^(BOOL success, NSError *error) {
       [manager getPrediction:@"hello wor" completion:^(NSArray *suggestions, UIColor *color) {
           NSLog(@"Suggestions: %@", suggestions);
       }];
   }];
   ```

## Quick Troubleshooting

### "Could not automatically select an Xcode project"

**Cause**: Podfile references a target that doesn't exist in the project

**Solution**: 
- Ensure your Xcode project exists at the path specified in Podfile
- Or use the correct project path:
  ```ruby
  project 'path/to/YourProject.xcodeproj'
  ```

### Realm Issues After pod install

**Cause**: Duplicate Realm linking or wrong configuration

**Solution**:
```bash
rm -rf Pods Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/*
pod install
```

### Building Fails with "Module not found"

**Solution**: Ensure `use_frameworks!` is in your Podfile for modern Swift/Objc-C mixing

## Next Steps

1. Copy the Example/ directory to your test app (or use ExampleViewController.m as reference)
2. Update your main app to use the predictor
3. Test predictions locally
4. Publish to CocoaPods when ready (see README.md)
