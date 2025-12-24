# PredictionKeyboard - Integration Guide

## Project Structure

```
PredictionKeyboardClean/
├── Sources/
│   ├── Public/                          # Public API headers
│   │   ├── PredictionKeyboard.h         # Main umbrella header
│   │   ├── PredictionKeyboardManager.h  # Manager API
│   │   ├── PredictionModels.h           # Model headers
│   │   └── PredictionConstants.h        # Constants
│   ├── Models/                          # Realm models
│   │   ├── PredictionTable.h/.m         # N-gram predictions
│   │   └── PredictionWord.h/.m          # Word frequency
│   ├── Core/                            # Implementation
│   │   └── PredictionKeyboardManager.m  # Manager implementation
│   └── Utilities/                       # Helpers
│       └── PredictionConstants.h        # Shared constants
├── Resources/
│   └── predictiondb.realm              # Bundled prediction database
├── Tests/                              # Unit tests (optional)
├── PredictionKeyboard.podspec          # CocoaPods specification
├── README.md                           # Full documentation
├── Podfile                             # Example dependencies
├── LICENSE                             # MIT License
└── .gitignore                          # Git ignore rules
```

## Key Changes from Original

### Architecture Improvements
1. **Organized Source Layout**: Clear separation of public API, models, core logic, utilities
2. **Clean Headers**: Model classes properly documented with NS_ASSUME_NONNULL
3. **Single Realm Dependency**: No duplicate Realm linkage via proper podspec configuration
4. **Better Manager API**: `PredictionKeyboardManager` instead of raw `predictWord` class

### API Simplification
```objc
// Before: Complex init with app group
predictWord *predict = [[predictWord alloc] initWith:@"group.com.company.keyboard"];

// After: Clean manager initialization
PredictionKeyboardManager *manager = [[PredictionKeyboardManager alloc] initWithAppGroup:@"group.com.company.keyboard"];
```

### Bug Fixes
1. **Duplicate Realm Linkage**: Now properly declared as dependency in podspec
2. **Model Registration**: Both `PredictionTable` and `PredictionWord` registered with Realm schema
3. **App Group Support**: Proper container URL handling for keyboard extensions
4. **Error Handling**: Better error reporting in initialization

## Implementation Details

### Core Algorithm

The prediction engine uses contextual n-gram analysis:

1. **Next Word Prediction** (when text ends with space):
   - Extract last 1-3 words as context
   - Query `PredictionTable` for stored predictions
   - Fall back to shorter context if needed
   - Return top 3 scored predictions

2. **Word Completion** (when text has no trailing space):
   - Extract last word
   - Query `PredictionWord` with prefix matching
   - Fuzzy match with wildcard queries
   - Return ranked completions

### Data Scoring

- **Initial Score**: 50 (when pattern first seen)
- **Score Increment**: +10 (each time pattern reused)
- **Min Query Score**: 25 (for completions), 50 (for n-grams)
- **Max Suggestions**: 3

## Migration from Old Project

If you have existing prediction data in the old project:

1. **Export Realm Data**:
   ```bash
   # From old project, export the predictiondb.realm file
   cp PredictionForKeyboard/Versions/Resources/predictiondb.realm \
      PredictionKeyboardClean/Resources/predictiondb.realm
   ```

2. **Update Podfile**:
   ```ruby
   pod 'PredictionKeyboard', :git => 'https://github.com/carloskekwa/PredictionKeyboard.git'
   ```

3. **Update Usage**:
   - Old: `#import <PredictionForKeyboard/predictWord.h>`
   - New: `#import <PredictionKeyboard/PredictionKeyboard.h>`

## Development Workflow

### Add to Your App

1. Add to Podfile:
   ```ruby
   pod 'PredictionKeyboard'
   pod install
   ```

2. In your view controller:
   ```objc
   #import <PredictionKeyboard/PredictionKeyboard.h>
   
   @property (nonatomic, strong) PredictionKeyboardManager *predictor;
   
   - (void)viewDidLoad {
       [super viewDidLoad];
       self.predictor = [[PredictionKeyboardManager alloc] initWithAppGroup:nil];
       [self.predictor initializePredictionDatabase:^(BOOL success, NSError *error) {
           if (success) NSLog(@"Ready for predictions");
       }];
   }
   ```

3. Get predictions:
   ```objc
   [self.predictor getPrediction:@"hello wor" completion:^(NSArray *suggestions, UIColor *color) {
       NSLog(@"Suggestions: %@", suggestions);
   }];
   ```

### In Keyboard Extension

1. Set up App Group container in main app:
   ```objc
   // In AppDelegate.m
   NSString *appGroupID = @"group.com.company.keyboard";
   NSURL *realmPath = [[[NSFileManager defaultManager] 
       containerURLForSecurityApplicationGroupIdentifier:appGroupID]
       URLByAppendingPathComponent:@"Library/Caches/predictiondb.realm"];
   
   RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
   config.fileURL = realmPath;
   [RLMRealmConfiguration setDefaultConfiguration:config];
   ```

2. In keyboard extension:
   ```objc
   #import <PredictionKeyboard/PredictionKeyboard.h>
   
   @property (nonatomic, strong) PredictionKeyboardManager *predictor;
   
   - (void)viewDidLoad {
       [super viewDidLoad];
       self.predictor = [[PredictionKeyboardManager alloc] 
           initWithAppGroup:@"group.com.company.keyboard"];
   }
   ```

## Publishing to CocoaPods

1. Create GitHub repository
2. Update podspec with git URL
3. Tag release: `git tag 1.0.0`
4. Push tags: `git push origin --tags`
5. Register pod: `pod trunk push PredictionKeyboard.podspec`

## Dependencies

- **Realm** (~> 10.0): Persistent database
- **MBProgressHUD** (~> 1.2): Loading indicators
- **Minimum iOS**: 12.0

## License

MIT - See LICENSE file
