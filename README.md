# PredictionKeyboard

[![CocoaPods Version](https://img.shields.io/cocoapods/v/PredictionKeyboard.svg?style=flat)](https://cocoapods.org/pods/PredictionKeyboard)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform iOS](https://img.shields.io/badge/platform-iOS%2012.0+-blue.svg)](https://developer.apple.com/ios/)
[![Swift 5.0+](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org)

**PredictionKeyboard** is a high-performance, intelligent next-word prediction framework for iOS custom keyboards. Built on [Realm](https://realm.io) for fast, persistent prediction scoring, it provides context-aware word suggestions and completions to enhance typing experiences in custom keyboard extensions.

---

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Swift Package Manager](#swift-package-manager-recommended)
  - [CocoaPods](#cocoapods)
- [Quick Start](#quick-start)
  - [Import the Framework](#1-import-the-framework)
  - [Main App Setup](#2-main-app---download--initialize-database)
  - [Keyboard Extension Setup](#3-keyboard-extension---use-predictions)
- [App Group Configuration](#app-group-configuration)
- [API Reference](#api-reference)
- [Architecture](#architecture)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)
- [License](#license)

---

## Features

| Feature | Description |
|---------|-------------|
| **Fast Prediction Engine** | Powered by Realm database for instant lookups and scoring |
| **Context-Aware Suggestions** | N-gram based predictions (1-gram to 3-gram) for intelligent next-word suggestions |
| **Word Completion** | Real-time autocorrect and word completion as users type |
| **Emoji Suggestions** | Automatic emoji suggestions for 225+ common words (e.g., "cool" → 😎) |
| **Pre-trained Database** | Includes a 600MB+ prediction database with millions of word sequences |
| **High Accuracy** | ~85% accuracy in real-world typing scenarios |
| **Optimized Performance** | <10ms average query time, concurrent prediction queue for non-blocking UI |
| **Privacy-First** | All predictions run locally on-device, no network requests |
| **Easy Integration** | Simple API for custom keyboard implementations |

---

## Requirements

| Requirement | Minimum Version |
|-------------|-----------------|
| iOS | 12.0+ |
| Xcode | 12.0+ |
| Swift | 5.0+ |
| Languages | Swift or Objective-C |

---

## Installation

PredictionKeyboard supports both **Swift Package Manager** and **CocoaPods**.

### Swift Package Manager (Recommended)

SPM is the recommended way to integrate PredictionKeyboard. Realm is bundled inside the framework, so you don't need to add any additional dependencies.

#### Option 1: Using Xcode UI

1. Open your project in Xcode
2. Go to **File → Add Package Dependencies...**
3. Enter the repository URL:
   ```
   https://github.com/carloskekwa/Custom-Keyboard-Prediction
   ```
4. Select version **1.0.37** or choose "Up to Next Major Version"
5. Click **Add Package**
6. Select both your **main app target** AND your **keyboard extension target**
7. Click **Add Package**

#### Option 2: Using Package.swift

Add PredictionKeyboard to your `Package.swift` dependencies:

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "YourApp",
    platforms: [
        .iOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/carloskekwa/Custom-Keyboard-Prediction", from: "1.0.37")
    ],
    targets: [
        .target(
            name: "YourApp",
            dependencies: ["PredictionKeyboard"]
        ),
        .target(
            name: "YourKeyboardExtension",
            dependencies: ["PredictionKeyboard"]
        )
    ]
)
```

#### Option 3: Adding to Existing Xcode Project

1. Select your project in the Project Navigator
2. Select your project (not target) in the editor
3. Go to **Package Dependencies** tab
4. Click the **+** button
5. Enter: `https://github.com/carloskekwa/Custom-Keyboard-Prediction`
6. Set the version rule to **"Up to Next Major Version"** from **1.0.37**
7. Click **Add Package**

> **Important:** Make sure to add the package to BOTH your main app target AND your keyboard extension target for the shared database to work.

---

### CocoaPods

Create or update your `Podfile`:

```ruby
platform :ios, '12.0'

target 'YourAppName' do
  use_frameworks!
  pod 'PredictionKeyboard', '~> 1.0'
end

target 'YourKeyboardExtension' do
  use_frameworks!
  pod 'PredictionKeyboard', '~> 1.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CODE_SIGN_IDENTITY'] = ''
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    end
  end

  # Required for Xcode 16+
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

Then run:

```bash
pod install
```

---

## Quick Start

### 1. Import the Framework

**Swift:**
```swift
import PredictionKeyboard
```

**Objective-C:**
```objc
@import PredictionKeyboard;
// Or use:
#import <PredictionKeyboard/PredictionKeyboard.h>
#import <PredictionKeyboard/PredictionKeyboardManager.h>
```

### 2. Main App - Download & Initialize Database

The database must be downloaded in your **main app** (not the keyboard extension). Here's a complete example:

**Swift (ViewController.swift):**
```swift
import UIKit
import PredictionKeyboard

class ViewController: UIViewController {

    private var predictionManager: PredictionKeyboardManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize with app group (for keyboard extension sharing)
        // IMPORTANT: Replace with YOUR unique app group identifier
        predictionManager = PredictionKeyboardManager(appGroup: "group.com.yourcompany.yourapp")

        // Check if database is already downloaded
        if predictionManager.isDatabaseDownloaded() {
            print("Database already exists, initializing...")
            initializeDatabase()
        } else {
            print("Database not found, starting download...")
            downloadDatabase()
        }
    }

    private func downloadDatabase() {
        // Show download UI with progress bar
        predictionManager.downloadDatabase(withUI: self) { [weak self] success, error in
            if success {
                print("Download completed successfully!")
                self?.initializeDatabase()
            } else {
                print("Download failed: \(error?.localizedDescription ?? "Unknown error")")
                self?.showErrorAlert(error: error)
            }
        }
    }

    private func initializeDatabase() {
        predictionManager.initializePredictionDatabase { [weak self] success, error in
            if success {
                print("Database ready to use!")
                self?.testPredictions()
            } else {
                print("Database initialization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func testPredictions() {
        // Test next-word prediction (note the trailing space)
        predictionManager.getPrediction("how are ") { suggestions, textColor in
            print("Next-word predictions: \(suggestions)")
            // suggestions = ["you", "they", "we"]
        }

        // Test word completion (no trailing space)
        predictionManager.getPrediction("hel") { suggestions, textColor in
            print("Word completions: \(suggestions)")
            // suggestions = ["hello", "help", "held"]
        }
    }

    private func showErrorAlert(error: Error?) {
        let alert = UIAlertController(
            title: "Download Failed",
            message: error?.localizedDescription ?? "Unknown error",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.downloadDatabase()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
```

**Objective-C (ViewController.m):**
```objc
#import "ViewController.h"
@import PredictionKeyboard;

@interface ViewController ()
@property (nonatomic, strong) PredictionKeyboardManager *predictionManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Initialize with app group (for keyboard extension)
    // IMPORTANT: Replace with YOUR unique app group identifier
    self.predictionManager = [[PredictionKeyboardManager alloc] initWithAppGroup:@"group.com.yourcompany.yourapp"];

    if ([self.predictionManager isDatabaseDownloaded]) {
        NSLog(@"Database already exists, initializing...");
        [self initializeDatabase];
    } else {
        NSLog(@"Database not found, starting download...");
        [self downloadDatabase];
    }
}

- (void)downloadDatabase {
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

### 3. Keyboard Extension - Use Predictions

**Swift (KeyboardViewController.swift):**
```swift
import UIKit
import PredictionKeyboard

class KeyboardViewController: UIInputViewController {

    private var predictionManager: PredictionKeyboardManager!
    private var suggestionBar: UIStackView!
    private var suggestionButtons: [UIButton] = []
    private var databaseInitialized = false

    // MARK: - Initialization

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupPredictionManager()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPredictionManager()
    }

    private func setupPredictionManager() {
        // IMPORTANT: Replace with YOUR unique app group identifier (same as main app)
        predictionManager = PredictionKeyboardManager(appGroup: "group.com.yourcompany.yourapp")

        // Initialize database in background
        predictionManager.initializePredictionDatabase { [weak self] success, error in
            if success {
                self?.databaseInitialized = true
                print("[Keyboard] Prediction database ready!")
            } else {
                print("[Keyboard] Database initialization failed: \(error?.localizedDescription ?? "")")
            }
        }
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSuggestionBar()
        setupNextKeyboardButton()
    }

    private func setupSuggestionBar() {
        // Create 3 suggestion buttons
        for i in 0..<3 {
            let button = UIButton(type: .system)
            button.titleLabel?.font = .systemFont(ofSize: 16)
            button.tag = i
            button.addTarget(self, action: #selector(suggestionTapped(_:)), for: .touchUpInside)
            suggestionButtons.append(button)
        }

        suggestionBar = UIStackView(arrangedSubviews: suggestionButtons)
        suggestionBar.axis = .horizontal
        suggestionBar.distribution = .fillEqually
        suggestionBar.alignment = .center
        suggestionBar.spacing = 8
        suggestionBar.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(suggestionBar)

        NSLayoutConstraint.activate([
            suggestionBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
            suggestionBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            suggestionBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            suggestionBar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupNextKeyboardButton() {
        // Add next keyboard button (required for custom keyboards)
        let nextKeyboardButton = UIButton(type: .system)
        nextKeyboardButton.setTitle("🌐", for: .normal)
        nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)

        view.addSubview(nextKeyboardButton)

        NSLayoutConstraint.activate([
            nextKeyboardButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            nextKeyboardButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
    }

    // MARK: - Suggestion Handling

    @objc private func suggestionTapped(_ sender: UIButton) {
        guard var suggestion = sender.titleLabel?.text, !suggestion.isEmpty else { return }

        // Remove quotes if present (word completion mode)
        if suggestion.hasPrefix("\"") && suggestion.hasSuffix("\"") {
            suggestion = String(suggestion.dropFirst().dropLast())
        }

        // Delete current partial word
        let currentText = textDocumentProxy.documentContextBeforeInput ?? ""
        if !currentText.hasSuffix(" ") && !currentText.isEmpty {
            while let context = textDocumentProxy.documentContextBeforeInput,
                  !context.isEmpty && !context.hasSuffix(" ") {
                textDocumentProxy.deleteBackward()
            }
        }

        // Insert the suggestion with a space
        textDocumentProxy.insertText(suggestion + " ")
    }

    private func updateSuggestions(_ suggestions: [String], color: UIColor) {
        for (index, button) in suggestionButtons.enumerated() {
            if index < suggestions.count && !suggestions[index].isEmpty {
                button.setTitle(suggestions[index], for: .normal)
                button.setTitleColor(color, for: .normal)
                button.isHidden = false
            } else {
                button.setTitle("", for: .normal)
                button.isHidden = true
            }
        }
    }

    // MARK: - UIInputViewController Overrides

    override func textDidChange(_ textInput: UITextInput?) {
        guard databaseInitialized else { return }

        let currentText = textDocumentProxy.documentContextBeforeInput ?? ""

        predictionManager.getPrediction(currentText) { [weak self] suggestions, textColor in
            self?.updateSuggestions(suggestions, color: textColor)
        }
    }
}
```

**Objective-C (KeyboardViewController.m):**
```objc
#import "KeyboardViewController.h"
@import PredictionKeyboard;

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
    if (self) { [self setupPredictionManager]; }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) { [self setupPredictionManager]; }
    return self;
}

- (void)setupPredictionManager {
    // IMPORTANT: Replace with YOUR unique app group identifier (same as main app)
    self.predictionManager = [[PredictionKeyboardManager alloc] initWithAppGroup:@"group.com.yourcompany.yourapp"];
    self.databaseInitialized = NO;

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
    [self setupSuggestionBar];
    [self setupNextKeyboardButton];
}

- (void)setupSuggestionBar {
    NSMutableArray *buttons = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        button.tag = i;
        [button addTarget:self action:@selector(suggestionTapped:) forControlEvents:UIControlEventTouchUpInside];
        [buttons addObject:button];
    }
    self.suggestionButtons = [buttons copy];

    self.suggestionBar = [[UIStackView alloc] initWithArrangedSubviews:self.suggestionButtons];
    self.suggestionBar.axis = UILayoutConstraintAxisHorizontal;
    self.suggestionBar.distribution = UIStackViewDistributionFillEqually;
    self.suggestionBar.alignment = UIStackViewAlignmentCenter;
    self.suggestionBar.spacing = 8;
    self.suggestionBar.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:self.suggestionBar];

    [self.suggestionBar.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:4].active = YES;
    [self.suggestionBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:8].active = YES;
    [self.suggestionBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-8].active = YES;
    [self.suggestionBar.heightAnchor constraintEqualToConstant:44].active = YES;
}

- (void)setupNextKeyboardButton {
    self.nextKeyboardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.nextKeyboardButton setTitle:@"🌐" forState:UIControlStateNormal];
    self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.nextKeyboardButton addTarget:self action:@selector(handleInputModeListFromView:withEvent:) forControlEvents:UIControlEventAllTouchEvents];

    [self.view addSubview:self.nextKeyboardButton];

    [self.nextKeyboardButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:8].active = YES;
    [self.nextKeyboardButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-8].active = YES;
}

#pragma mark - Suggestion Handling

- (void)suggestionTapped:(UIButton *)sender {
    NSString *suggestion = sender.titleLabel.text;
    if (suggestion.length == 0) return;

    // Remove quotes if present
    if ([suggestion hasPrefix:@"\""] && [suggestion hasSuffix:@"\""]) {
        suggestion = [suggestion substringWithRange:NSMakeRange(1, suggestion.length - 2)];
    }

    // Delete current partial word
    NSString *currentText = self.textDocumentProxy.documentContextBeforeInput ?: @"";
    if (![currentText hasSuffix:@" "] && currentText.length > 0) {
        while (self.textDocumentProxy.documentContextBeforeInput.length > 0 &&
               ![self.textDocumentProxy.documentContextBeforeInput hasSuffix:@" "]) {
            [self.textDocumentProxy deleteBackward];
        }
    }

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

- (void)textDidChange:(id<UITextInput>)textInput {
    if (!self.databaseInitialized) return;

    NSString *currentText = self.textDocumentProxy.documentContextBeforeInput ?: @"";

    [self.predictionManager getPrediction:currentText completion:^(NSArray<NSString *> *suggestions, UIColor *suggestionColor) {
        [self updateSuggestions:suggestions withColor:suggestionColor];
    }];
}

@end
```

---

## App Group Configuration

> **CRITICAL:** You MUST create your own unique App Group identifier and use it consistently in both your main app and keyboard extension. Using someone else's App Group ID will cause the prediction database to be inaccessible from your keyboard extension.

### Step 1: Create an App Group in Xcode

1. Select your **app target** in Xcode
2. Go to **Signing & Capabilities**
3. Click **+ Capability** and add **App Groups**
4. Click **+** and create a new group (e.g., `group.com.yourcompany.yourapp`)
5. **Repeat for your keyboard extension target** with the same App Group ID

### Step 2: Add Entitlements

Create or update your `.entitlements` file for **both** targets:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.yourcompany.yourapp</string>
    </array>
</dict>
</plist>
```

### Step 3: Configure Keyboard Extension Info.plist

Your keyboard extension must have `RequestsOpenAccess` set to `true`:

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionAttributes</key>
    <dict>
        <key>RequestsOpenAccess</key>
        <true/>
        <key>PrimaryLanguage</key>
        <string>en-US</string>
    </dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.keyboard-service</string>
    <key>NSExtensionPrincipalClass</key>
    <string>KeyboardViewController</string>
</dict>
```

> **Note:** Users must enable "Allow Full Access" in **Settings → General → Keyboard → Keyboards → [Your Keyboard]** for the shared container to work.

---

## API Reference

### `PredictionKeyboardManager`

#### Initialization

```objc
/// Initialize without app group (single app use only)
- (instancetype)init;

/// Initialize with app group for keyboard extension support
/// @param appGroupID The app group identifier (e.g., "group.com.company.app")
- (instancetype)initWithAppGroup:(nullable NSString *)appGroupID;
```

#### Core Methods

| Method | Description |
|--------|-------------|
| `isDatabaseDownloaded` | Returns `YES` if the prediction database exists and is valid |
| `downloadDatabaseWithUI:completion:` | Shows a download progress UI and downloads the database |
| `initializePredictionDatabase:` | Loads and configures the prediction database |
| `getPrediction:completion:` | Gets word predictions for the given input text |

#### Method Signatures

```objc
/// Check if the prediction database is already downloaded
- (BOOL)isDatabaseDownloaded;

/// Show download UI and download the database from remote server
/// @param viewController The view controller to display the download progress on
/// @param completion Called when download completes or fails
- (void)downloadDatabaseWithUI:(UIViewController *)viewController
                    completion:(nullable void(^)(BOOL success, NSError *_Nullable error))completion;

/// Load and configure the prediction database
/// @param completion Called when database is ready
- (void)initializePredictionDatabase:(nullable void(^)(BOOL success, NSError *_Nullable error))completion;

/// Get word predictions for the given input
/// @param syntax The text input (e.g., "how are you " or "hel")
/// @param completion Returns suggestions array and display color
/// - Trailing space: next-word predictions (blue color)
/// - No trailing space: word completion (black color)
- (void)getPrediction:(NSString *)syntax
           completion:(void(^)(NSArray<NSString *> *suggestions, UIColor *textColor))completion;
```

#### Threading

All methods are **thread-safe**. Completion handlers are always dispatched to the **main thread**, so you can safely update UI directly.

---

## Architecture

### How Prediction Works

PredictionKeyboard uses a two-phase prediction strategy:

```
┌─────────────────────────────────────────────────────────────────┐
│                        User Input                                │
│                    "how are you "                                │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
        ┌─────────────────────────────┐
        │   Ends with space?          │
        └─────────────────────────────┘
                │           │
           YES  │           │  NO
                ▼           ▼
    ┌───────────────┐   ┌───────────────┐
    │  NEXT-WORD    │   │    WORD       │
    │  PREDICTION   │   │  COMPLETION   │
    │  (N-gram)     │   │  (Prefix)     │
    └───────────────┘   └───────────────┘
           │                    │
           ▼                    ▼
    ┌───────────────┐   ┌───────────────┐
    │ ["doing",     │   │ ["you",       │
    │  "feeling",   │   │  "young",     │
    │  "today"]     │   │  "your"]      │
    │  (Blue)       │   │  (Black)      │
    └───────────────┘   └───────────────┘
```

#### 1. Next-Word Prediction (text ends with space)
- Analyzes the last 1-3 words for context
- Queries n-gram database (trigrams → bigrams → unigrams)
- Returns scored predictions based on language patterns
- Suggestions appear in **blue**

#### 2. Word Completion (while typing)
- Extracts the current incomplete word
- Performs prefix matching against word database
- Returns autocomplete suggestions sorted by frequency
- Suggestions appear in **black**

### Emoji Suggestions

When typing words that have associated emojis, the emoji appears in the third suggestion slot:

| You Type | Suggestions |
|----------|-------------|
| cool | `["cool", "cooler", "😎"]` |
| love | `["love", "lovely", "💘"]` |
| fire | `["fire", "fired", "🔥"]` |
| happy | `["happy", "happily", "☺"]` |
| cat | `["cat", "catch", "🐱"]` |

**225+ words supported** including emotions, animals, objects, and more.

---

## Troubleshooting

### Common Issues

#### "Module 'PredictionKeyboard' not found"

**Cause:** Package not properly linked to target.

**Solution:**
1. In Xcode, select your target
2. Go to **General → Frameworks, Libraries, and Embedded Content**
3. Ensure `PredictionKeyboard` is listed
4. If not, click **+** and add it

#### Database not shared between app and keyboard

**Cause:** App Group not configured correctly.

**Solution:**
1. Verify the **same App Group ID** is used in both targets
2. Check both `.entitlements` files have the App Group
3. In Xcode, verify App Groups capability is enabled for both targets
4. Ensure user has enabled "Allow Full Access" for the keyboard

#### "Database initialization failed"

**Cause:** Database not downloaded or corrupted.

**Solution:**
1. Call `isDatabaseDownloaded` to check database status
2. If `NO`, call `downloadDatabaseWithUI:completion:` from main app
3. Ensure the device has internet connection for download

#### Predictions not appearing in keyboard

**Cause:** Database not initialized before calling `getPrediction:`.

**Solution:**
1. Ensure `initializePredictionDatabase:` completes successfully
2. Check `databaseInitialized` flag before getting predictions
3. Verify keyboard has "Allow Full Access" enabled

#### Build errors with CocoaPods

**Solution:** Add the post_install script from the [CocoaPods section](#cocoapods) to disable code signing and script sandboxing.

#### Sandbox error: "Script phase '[CP] Copy XCFrameworks' blocked by sandboxing" (Xcode 16+)

**Cause:** Xcode 16 enables user script sandboxing by default, which blocks CocoaPods script phases.

**Solution:** Add this to your `Podfile` inside `post_install`:

```ruby
post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      end
    end
  end
end
```

Or manually in Xcode:
1. Select your project
2. Go to **Build Settings**
3. Search for "User Script Sandboxing"
4. Set **ENABLE_USER_SCRIPT_SANDBOXING** to **No** for all targets

---

## FAQ

**Q: How large is the prediction database?**
> The database is approximately 600MB and includes millions of word sequences for accurate predictions.

**Q: Does this send data to a server?**
> No. All predictions run completely on-device. Your typing data never leaves the device.

**Q: What languages are supported?**
> Currently optimized for English. Multi-language support is planned for future releases.

**Q: Why does the keyboard need "Allow Full Access"?**
> This is required to access the shared App Group container where the prediction database is stored.

**Q: Can I use this without a keyboard extension?**
> Yes! You can use PredictionKeyboard in any app for text prediction. Just skip the App Group configuration.

---

## Performance

| Metric | Value |
|--------|-------|
| Prediction Accuracy | ~85% in real-world typing |
| Average Query Time | <10ms |
| Memory Usage | ~50MB during active use |
| Framework Size | ~3MB (excluding database) |
| Database Size | ~600MB |

---

## License

PredictionKeyboard is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

---

## Author

**Carlos Kekwa**
- Email: carlos.kekwa@gmail.com
- GitHub: [@carloskekwa](https://github.com/carloskekwa)

---

## Links

- [GitHub Repository](https://github.com/carloskekwa/Custom-Keyboard-Prediction)
- [CocoaPods Page](https://cocoapods.org/pods/PredictionKeyboard)
- [Report Issues](https://github.com/carloskekwa/Custom-Keyboard-Prediction/issues)
