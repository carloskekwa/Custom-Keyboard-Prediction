# Custom-Keyboard-Prediction

Example iOS app demonstrating the **PredictionKeyboard** framework - an intelligent next-word prediction system for custom keyboards with emoji suggestions.

## Overview

This repository contains a complete working example with:
- **testPrediction** - Main app that downloads and initializes the prediction database
- **testKeyboard** - Keyboard extension that uses predictions and emoji suggestions

## Quick Start

### 1. Clone and Install

```bash
git clone https://github.com/carloskekwa/Custom-Keyboard-Prediction.git
cd Custom-Keyboard-Prediction
pod install
open testPrediction.xcworkspace
```

### 2. Configure App Group

Before running, you must create your own App Group:

1. Open the project in Xcode
2. Select the **testPrediction** target > **Signing & Capabilities**
3. Add **App Groups** capability
4. Create a unique group ID (e.g., `group.com.yourcompany.yourapp`)
5. Repeat for the **testKeyboard** target with the same group ID
6. Update the group ID in both:
   - `testPrediction/ViewController.m`
   - `testKeyboard/KeyboardViewController.m`

### 3. Build and Run

1. Build and run on a physical device (keyboard extensions don't work well in simulator)
2. The main app will download the prediction database (~600MB)
3. Go to **Settings > General > Keyboard > Keyboards > Add New Keyboard**
4. Select **Test Keyboard**
5. Tap on it and enable **Allow Full Access**

## Project Structure

```
Custom-Keyboard-Prediction/
├── testPrediction/           # Main app
│   ├── ViewController.m      # Database download & initialization
│   └── Info.plist
├── testKeyboard/             # Keyboard extension
│   ├── KeyboardViewController.m  # Prediction usage
│   └── Info.plist
├── Podfile                   # CocoaPods configuration
└── README.md
```

## Code Examples

### Main App - ViewController.m

Downloads and initializes the prediction database:

```objc
#import "ViewController.h"
#import <PredictionKeyboard/PredictionKeyboard.h>
#import <PredictionKeyboard/PredictionKeyboardManager.h>

@interface ViewController ()
@property (nonatomic, strong) PredictionKeyboardManager *predictionManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Initialize with app group (for keyboard extension)
    // IMPORTANT: Replace with YOUR unique app group identifier
    self.predictionManager = [[PredictionKeyboardManager alloc] initWithAppGroup:@"group.com.yourcompany.yourapp"];

    // Check if database is already downloaded
    if ([self.predictionManager isDatabaseDownloaded]) {
        NSLog(@"Database already exists, initializing...");
        [self initializeDatabase];
    } else {
        NSLog(@"Database not found, starting download...");
        [self downloadDatabase];
    }
}

- (void)downloadDatabase {
    // Show download UI with progress bar
    [self.predictionManager downloadDatabaseWithUI:self completion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"Download completed successfully!");
            [self initializeDatabase];
        } else {
            NSLog(@"Download failed: %@", error.localizedDescription);
            [self showErrorAlert:error];
        }
    }];
}

- (void)initializeDatabase {
    [self.predictionManager initializePredictionDatabase:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"Database ready to use!");
            [self testPredictions];
        } else {
            NSLog(@"Database initialization failed: %@", error.localizedDescription);
        }
    }];
}

- (void)testPredictions {
    // Test next-word prediction (note the trailing space)
    [self.predictionManager getPrediction:@"how are " completion:^(NSArray<NSString *> *suggestions, UIColor *textColor) {
        NSLog(@"Next-word predictions: %@", suggestions);
        // suggestions = @[@"you", @"they", @"we"]
    }];

    // Test word completion (no trailing space)
    [self.predictionManager getPrediction:@"hel" completion:^(NSArray<NSString *> *suggestions, UIColor *textColor) {
        NSLog(@"Word completions: %@", suggestions);
        // suggestions = @[@"hello", @"help", @"held"]
    }];
}

- (void)showErrorAlert:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Download Failed"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self downloadDatabase];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
```

### Keyboard Extension - KeyboardViewController.m

Uses predictions in the keyboard:

```objc
#import "KeyboardViewController.h"
#import <PredictionKeyboard/PredictionKeyboard.h>
#import <PredictionKeyboard/PredictionKeyboardManager.h>

@interface KeyboardViewController ()
@property (nonatomic, strong) UIButton *nextKeyboardButton;
@property (nonatomic, strong) PredictionKeyboardManager *predictionManager;
@property (nonatomic, strong) UIStackView *suggestionBar;
@property (nonatomic, strong) NSArray<UIButton *> *suggestionButtons;
@property (nonatomic, assign) BOOL databaseInitialized;
@end

@implementation KeyboardViewController

#pragma mark - Initialization

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setupPredictionManager];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupPredictionManager];
    }
    return self;
}

- (void)setupPredictionManager {
    // Initialize prediction manager ONCE when the extension loads
    // IMPORTANT: Replace with YOUR unique app group identifier (same as main app)
    self.predictionManager = [[PredictionKeyboardManager alloc] initWithAppGroup:@"group.com.yourcompany.yourapp"];
    self.databaseInitialized = NO;

    // Initialize database in background - only once
    [self.predictionManager initializePredictionDatabase:^(BOOL success, NSError *error) {
        if (success) {
            self.databaseInitialized = YES;
            NSLog(@"[Keyboard] Prediction database ready!");
        } else {
            NSLog(@"[Keyboard] Database initialization failed: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Setup UI elements
    [self setupSuggestionBar];
    [self setupNextKeyboardButton];
}

- (void)setupNextKeyboardButton {
    self.nextKeyboardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.nextKeyboardButton setTitle:NSLocalizedString(@"Next Keyboard", @"Title for 'Next Keyboard' button") forState:UIControlStateNormal];
    [self.nextKeyboardButton sizeToFit];
    self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self.nextKeyboardButton addTarget:self action:@selector(handleInputModeListFromView:withEvent:) forControlEvents:UIControlEventAllTouchEvents];

    [self.view addSubview:self.nextKeyboardButton];

    [self.nextKeyboardButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.nextKeyboardButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
}

- (void)setupSuggestionBar {
    // Create suggestion buttons
    NSMutableArray *buttons = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        button.tag = i;
        [button addTarget:self action:@selector(suggestionTapped:) forControlEvents:UIControlEventTouchUpInside];
        [buttons addObject:button];
    }
    self.suggestionButtons = [buttons copy];

    // Create stack view for suggestions
    self.suggestionBar = [[UIStackView alloc] initWithArrangedSubviews:self.suggestionButtons];
    self.suggestionBar.axis = UILayoutConstraintAxisHorizontal;
    self.suggestionBar.distribution = UIStackViewDistributionFillEqually;
    self.suggestionBar.alignment = UIStackViewAlignmentCenter;
    self.suggestionBar.spacing = 8;
    self.suggestionBar.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:self.suggestionBar];

    // Position at top of keyboard
    [self.suggestionBar.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:4].active = YES;
    [self.suggestionBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:8].active = YES;
    [self.suggestionBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-8].active = YES;
    [self.suggestionBar.heightAnchor constraintEqualToConstant:44].active = YES;
}

#pragma mark - Suggestion Handling

- (void)suggestionTapped:(UIButton *)sender {
    NSString *suggestion = sender.titleLabel.text;
    if (suggestion.length == 0) return;

    // Remove quotes if present (for word completion mode)
    if ([suggestion hasPrefix:@"\""] && [suggestion hasSuffix:@"\""]) {
        suggestion = [suggestion substringWithRange:NSMakeRange(1, suggestion.length - 2)];
    }

    // Delete current partial word and insert suggestion
    NSString *currentText = self.textDocumentProxy.documentContextBeforeInput ?: @"";
    if (![currentText hasSuffix:@" "] && currentText.length > 0) {
        // Delete the partial word
        while (self.textDocumentProxy.documentContextBeforeInput.length > 0 &&
               ![self.textDocumentProxy.documentContextBeforeInput hasSuffix:@" "]) {
            [self.textDocumentProxy deleteBackward];
        }
    }

    // Insert the suggestion with a space
    [self.textDocumentProxy insertText:[suggestion stringByAppendingString:@" "]];
}

- (void)updateSuggestions:(NSArray<NSString *> *)suggestions withColor:(UIColor *)color {
    for (int i = 0; i < self.suggestionButtons.count; i++) {
        UIButton *button = self.suggestionButtons[i];
        if (i < suggestions.count && suggestions[i].length > 0) {
            [button setTitle:suggestions[i] forState:UIControlStateNormal];
            [button setTitleColor:color forState:UIControlStateNormal];
            button.hidden = NO;
        } else {
            [button setTitle:@"" forState:UIControlStateNormal];
            button.hidden = YES;
        }
    }
}

#pragma mark - UIInputViewController Overrides

- (void)viewWillLayoutSubviews {
    self.nextKeyboardButton.hidden = !self.needsInputModeSwitchKey;
    [super viewWillLayoutSubviews];
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // Update keyboard appearance
    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
    [self.nextKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];

    // Only get predictions if database is initialized
    if (!self.databaseInitialized) {
        return;
    }

    // Get predictions for current text
    NSString *currentText = self.textDocumentProxy.documentContextBeforeInput ?: @"";

    // Safe to call - completion returns on main thread
    [self.predictionManager getPrediction:currentText completion:^(NSArray<NSString *> *suggestions, UIColor *suggestionColor) {
        [self updateSuggestions:suggestions withColor:suggestionColor];
    }];
}

@end
```

## Installation Options

### Option 1: Swift Package Manager (Recommended)

1. Open the project in Xcode
2. Go to **File → Add Package Dependencies...**
3. Enter: `https://github.com/carloskekwa/Custom-Keyboard-Prediction`
4. Select version **1.0.42** or "Up to Next Major Version"
5. Add to both **testPrediction** and **testKeyboard** targets

### Option 2: CocoaPods

## Podfile Configuration

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '15.0'

target 'testPrediction' do
  use_frameworks!

  pod 'PredictionKeyboard'
end

target 'testKeyboard' do
  use_frameworks!
  pod 'PredictionKeyboard'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CODE_SIGN_IDENTITY'] = ''
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    end
  end

  # Disable sandbox for script phases (required for Xcode 16+)
  installer.pods_project.targets.each do |target|
    target.build_phases.each do |phase|
      if phase.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase)
        phase.always_out_of_date = "1"
      end
    end
  end

  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      end
    end
  end
end
```

## Important Notes

### App Group Configuration

> **CRITICAL:** You MUST create your own unique App Group identifier. Using someone else's App Group ID will not work. The database is stored in the shared App Group container, so both the main app and keyboard extension must use the same group ID.

### Keyboard Extension Info.plist

Your keyboard extension's `Info.plist` must have `RequestsOpenAccess` set to `true`:

```xml
<key>RequestsOpenAccess</key>
<true/>
```

### Allow Full Access

Users must enable "Allow Full Access" in **Settings > General > Keyboard > Keyboards > [Your Keyboard]** for the shared container to work.

### Database Download

- The database (~600MB) is downloaded in the **main app**, not the keyboard extension
- Keyboard extensions have limited network access and memory
- The keyboard extension only initializes and uses the pre-downloaded database

## Emoji Suggestions

Version 1.0.36+ includes automatic emoji suggestions. When typing words that have associated emojis, the emoji appears in the third suggestion slot:

| You Type | Suggestions |
|----------|-------------|
| cool | `["cool", "cooler", "😎"]` |
| love | `["love", "lovely", "💘"]` |
| fire | `["fire", "fired", "🔥"]` |
| happy | `["happy", "happily", "☺"]` |
| cat | `["cat", "catch", "🐱"]` |
| good | `["good", "goodness", "👍"]` |
| heart | `["heart", "hearts", "❤️"]` |

**225+ words supported** including:
- Emotions: happy, sad, angry, love, cool, etc.
- Animals: cat, dog, bird, fish, etc.
- Objects: car, phone, coffee, pizza, etc.
- Actions: run, swim, dance, etc.

If no emoji matches the typed word, the third slot shows a second word prediction instead.

## API Reference

### PredictionKeyboardManager

```objc
// Initialize with app group
- (instancetype)initWithAppGroup:(NSString *)appGroupID;

// Check if database exists
- (BOOL)isDatabaseDownloaded;

// Download with progress UI
- (void)downloadDatabaseWithUI:(UIViewController *)viewController
                    completion:(void(^)(BOOL success, NSError *error))completion;

// Initialize database
- (void)initializePredictionDatabase:(void(^)(BOOL success, NSError *error))completion;

// Get predictions (includes emoji in slot 3 when available)
- (void)getPrediction:(NSString *)syntax
           completion:(void(^)(NSArray<NSString *> *suggestions, UIColor *textColor))completion;
```

## License

MIT License - see [LICENSE](LICENSE) file.

## Author

Carlos Kekwa - [@carloskekwa](https://github.com/carloskekwa)
