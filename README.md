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
         pod install
         
##  App Groups

[Enable App Groups](https://medium.com/ios-os-x-development/shared-user-defaults-in-ios-3f15cd2c9409): group.com.code.testingpredictionframework



## Implementation

 Mainly you will use this Library in a Custom Keyboard Prediction. 
 So to do that :


Import the Framework this way.

        #import <PredictionForKeyboard/predictWord.h>

 Wherever u want to predict. init
First time initialization may take up to one minute.
        
        @implementation
        predictWord *predict; 
        -(void)viewDidLoad{
         predictWord *predict = [[predictWord alloc] init];
        [predict initRealmWords:^(BOOL success) { 

        }];
        }


 Array of next word prediction after initRealmWords Finish

        [predict getPrediction:@"how are you " completion:^(NSArray *suggestions, UIColor *textColor) {
            NSLog(@"%@:",suggestions); 
        }];


Array of word List Prediction 

          [predict getPrediction:@"how are you" completion:^(NSArray *suggestions, UIColor *textColor) {
            NSLog(@"%@:",suggestions); 
         }];

No space on the right will give u word prediction and with a space will give the next word prediction.
Just Give it any syntaxe and it will find the Prediction for it. The Array returned is mainly an array with many words ranked from the highest to the lowest.

## Author

carlos kekwa, carlos_kek@hotmail.com

## License

PredoctionForKeybpard is available under the MIT license. See the LICENSE file for more info.
