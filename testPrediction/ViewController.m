//
//  ViewController.m
//  testPrediction
//
//  Created by Carlos on 4/24/20.
//  Copyright © 2020 Carlos. All rights reserved.
//

#import "ViewController.h"
    #import <PredictionForKeyboard/predictWord.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    predictWord *predict = [[predictWord alloc] init];
      [predict initRealmWords:^(BOOL success) {
          [predict getPrediction:@"hello how" completion:^(NSArray *suggestions, UIColor *textColor) {
                     NSLog(@"final word%@:",suggestions);
                 }];
      }];
}


@end
