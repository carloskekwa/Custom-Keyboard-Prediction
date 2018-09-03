# Custom-Keyboard-Prediction

## Description 

PredictionForKeybpard is the best iOS Library that make Next Word Prediction easy for Custom iOS Keyboard. 
Since Apple does not support and does not provide any API for that, we decided to make a library that does that. Just Enjoy and buy me a coffee one day!

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Custom-Keyboard-Prediction is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

         pod 'PredictionForKeyboard'

## Implementation

 Mainly you will use this Library in a Custom Keyboard Prediction. 
 So to do that :
n the Container app, in the AppDelegate.m
        
         - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
         //declare a specific entry for realm 
          NSURL *realmPath = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:APP_GROUP_ID] URLByAppendingPathComponent:REALM_DB_NAME]; 
          RLMRealmConfiguration *configuration = [RLMRealmConfiguration defaultConfiguration];
          configuration.fileURL = realmPath;
          NSLog(@"Realm Path: %@", realmPath);
          [RLMRealmConfiguration setDefaultConfiguration:configuration];
    
         return YES;
        }

 And in the KeyboardviewController.m check if full Access Granted
        
         BOOL isAllowFullAccessed = [self isOpenAccessGranted];
         if (isAllowFullAccessed) {
        NSURL *realmPath = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:APP_GROUP_ID] URLByAppendingPathComponent:REALM_DB_NAME];
        RLMRealmConfiguration *configuration = [RLMRealmConfiguration defaultConfiguration];
        configuration.fileURL = realmPath;
        [RLMRealmConfiguration setDefaultConfiguration:configuration];
        NSLog(@"Realm: %@", realmPath);
         }

 You can ignore what is above if you are not using this library for a Custom Keyboard
        - (BOOL)isOpenAccessGranted {
    
         NSOperatingSystemVersion operatingSystem = [[NSProcessInfo processInfo] operatingSystemVersion];
    
         if (operatingSystem.majorVersion >= 10) {
         UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
         NSString *currentString = pasteboard.string;
        
         pasteboard.string = @"Please allow full access";
         if (pasteboard.hasStrings) {
            pasteboard.string = currentString ? currentString : @"";
            return YES;
         } else {
            pasteboard.string = currentString ? currentString : @"";
            return NO;
         }
         } else {
         return [UIPasteboard generalPasteboard];
         }
         }


         #import <PredictionForKeyboard/predictWord.h>

 Wherever u want to predict maybe in the insertText: method
        
        @implementation
        predictWord *predict; 
        -(void)viewDidLoad{
         predictWord *predict = [[predictWord alloc] init];
        }

First time initialization may take up to one minute.

        [predict initRealmWords:^(BOOL success) { 

        }];

 Array of next word prediction after initRealmWords Finish

        [predict getPrediction:@"how are you " completion:^(NSArray *suggestions, UIColor *textColor) {
            NSLog(@"%@:",suggestions); 
        }];


Array of word List Prediction 

          [predict getPrediction:@"how are you " completion:^(NSArray *suggestions, UIColor *textColor) {
            NSLog(@"%@:",suggestions); 
         }];


Just Give it any syntaxe and it will find the Prediction for it. The Array returned is mainly an array with many words ranked from the highest to the lowest.

## Author

carlos kekwa, carlos_kek@hotmail.com

## License

PredoctionForKeybpard is available under the MIT license. See the LICENSE file for more info.
