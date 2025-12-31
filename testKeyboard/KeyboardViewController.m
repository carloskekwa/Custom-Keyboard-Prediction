//
//  KeyboardViewController.m
//  testKeyboard
//
//  Created by Carlos Kekwa on 31/12/2025.
//  Copyright © 2025 Carlos. All rights reserved.
//

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
    // IMPORTANT: Replace with YOUR unique app group identifier
    self.predictionManager = [[PredictionKeyboardManager alloc] initWithAppGroup:@"group.code.group.k2025"];
    self.databaseInitialized = NO;

    // Initialize database in background - only once
    [self.predictionManager initializePredictionDatabase:^(BOOL success, NSError *error) {
        if (success) {
            self.databaseInitialized = YES;
            NSLog(@"[testKeyboard] Prediction database ready!");
        } else {
            NSLog(@"[testKeyboard] Database initialization failed: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - View Lifecycle

- (void)updateViewConstraints {
    [super updateViewConstraints];
    // Add custom view sizing constraints here
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Setup UI elements
    [self setupSuggestionBar];
    [self setupNextKeyboardButton];
    [self.predictionManager getPrediction:@"how are " completion:^(NSArray<NSString *> *suggestions, UIColor *suggestionColor) {
        NSLog(@"suggestions:%@", suggestions);
    }];
    [self.predictionManager getPrediction:@"helko" completion:^(NSArray<NSString *> *suggestions, UIColor *suggestionColor) {
        NSLog(@"suggestions:%@", suggestions);
    }];
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
