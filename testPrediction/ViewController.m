//
//  ViewController.m
//  testPrediction
//
//  Created by Carlos on 4/24/20.
//  Copyright © 2020 Carlos. All rights reserved.
//

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
    self.predictionManager = [[PredictionKeyboardManager alloc] initWithAppGroup:@"group.code.group.k2025"];
    
    // Or without app group (single app)
    // self.predictionManager = [[PredictionKeyboardManager alloc] init];
    
    // Check if database is already downloaded
    if ([self.predictionManager isDatabaseDownloaded]) {
        NSLog(@"✅ Database already exists, initializing...");
        [self initializeDatabase];
    } else {
        NSLog(@"⬇️ Database not found, starting download...");
        [self downloadDatabase];
    }
}

- (void)downloadDatabase {
    // Show download UI with progress bar
    [self.predictionManager downloadDatabaseWithUI:self completion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"✅ Download completed successfully!");
            [self initializeDatabase];
        } else {
            NSLog(@"❌ Download failed: %@", error.localizedDescription);
            [self showErrorAlert:error];
        }
    }];
}

- (void)initializeDatabase {
    [self.predictionManager initializePredictionDatabase:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"✅ Database ready to use!");
            [self testPredictions];
        } else {
            NSLog(@"❌ Database initialization failed: %@", error.localizedDescription);
        }
    }];
}

- (void)testPredictions {
    // Test next-word prediction
    [self.predictionManager getPrediction:@"kifak khaye " completion:^(NSArray<NSString *> *suggestions, UIColor *textColor) {
        NSLog(@"Next-word predictions: %@", suggestions);
        // suggestions = @[@"you", @"they", @"we"]
    }];
    
    // Test word completion
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
