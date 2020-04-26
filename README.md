# Custom-Keyboard-Prediction for Keyboard extension in iOS (Work on Real Device Only)


**Work on Real Device Only !!!!!!!!!!!!!**


## Description 

PredictionForKeybpard is the best iOS Library that make Next Word Prediction easy for Custom iOS Keyboard. 
Since Apple does not support and does not provide any API for that, we decided to make a library that does that. Just Enjoy and buy me a coffee one day!

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

Custom-Keyboard-Prediction is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

         pod 'PredictionForKeyboard'
         pod install
         
##  App Groups

[Enable App Groups](https://medium.com/ios-os-x-development/shared-user-defaults-in-ios-3f15cd2c9409).
Let the groups name be 'group.com.code.testingpredictionframework'. Otherwise the library will crash.

![alt text](https://firebasestorage.googleapis.com/v0/b/full-keyboard.appspot.com/o/Screen%20Shot%202018-12-30%20at%208.33.41%20PM.png?alt=media&token=fba9f7fe-92c4-4a1b-b6c6-fb9d8d447051)

## Copy Bundle Resources

Add Bundle Resource (+)

![alt_text](https://firebasestorage.googleapis.com/v0/b/full-keyboard.appspot.com/o/Screen%20Shot%202020-04-25%20at%2011.29.45%20PM.png?alt=media&token=a0f53711-25b3-4507-bfb4-dfa0b5881d22)

![alt_text](https://firebasestorage.googleapis.com/v0/b/full-keyboard.appspot.com/o/Screen%20Shot%202020-04-25%20at%2011.29.51%20PM.png?alt=media&token=7dcabed5-d632-4063-b5d2-c90ee49be138)

![alt_text](https://firebasestorage.googleapis.com/v0/b/full-keyboard.appspot.com/o/Screen%20Shot%202020-04-25%20at%2011.29.55%20PM.png?alt=media&token=5b79760f-681e-4085-94a3-b559881a789b)

![alt_text](https://firebasestorage.googleapis.com/v0/b/full-keyboard.appspot.com/o/1.png?alt=media&token=555e37d8-2a62-46cd-8335-10bbf33dcf7a)

![alt_text](https://firebasestorage.googleapis.com/v0/b/full-keyboard.appspot.com/o/2.png?alt=media&token=e8d1da24-6af7-414b-8833-1be55cda83ea)

![alt_text](https://firebasestorage.googleapis.com/v0/b/full-keyboard.appspot.com/o/Screen%20Shot%202020-04-25%20at%2011.30.13%20PM.png?alt=media&token=9c54af00-e45d-4191-bdc4-38440d7ad911)

![alt_text](https://firebasestorage.googleapis.com/v0/b/full-keyboard.appspot.com/o/Screen%20Shot%202020-04-25%20at%2011.30.24%20PM.png?alt=media&token=93ea1e6b-9bd7-49b7-97e5-f02846be28ae)

![alt_text](https://firebasestorage.googleapis.com/v0/b/full-keyboard.appspot.com/o/Screen%20Shot%202020-04-25%20at%2011.53.37%20PM.png?alt=media&token=fbac48b2-3afc-4976-82ea-0b4a0c43c132)

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
