//
//  ExampleViewController.m
//  PredictionKeyboardExample
//
//  Example usage of PredictionKeyboard library
//

#import "ExampleViewController.h"
#import <PredictionKeyboard/PredictionKeyboard.h>

@interface ExampleViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *inputField;
@property (nonatomic, strong) UIStackView *suggestionsStack;
@property (nonatomic, strong) PredictionKeyboardManager *predictor;
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation ExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Prediction Keyboard Example";
    
    [self setupUI];
    [self setupPredictor];
}

- (void)setupUI {
    // Status label
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = @"Initializing...";
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.statusLabel];
    
    // Input field
    self.inputField = [[UITextField alloc] init];
    self.inputField.borderStyle = UITextBorderStyleRoundedRect;
    self.inputField.placeholder = @"Type here for predictions...";
    self.inputField.delegate = self;
    self.inputField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.inputField];
    
    // Suggestions stack
    self.suggestionsStack = [[UIStackView alloc] init];
    self.suggestionsStack.axis = UILayoutConstraintAxisVertical;
    self.suggestionsStack.spacing = 8;
    self.suggestionsStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.suggestionsStack];
    
    // Layout
    [NSLayoutConstraint activateConstraints:@[
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        [self.inputField.topAnchor constraintEqualToAnchor:self.statusLabel.bottomAnchor constant:20],
        [self.inputField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.inputField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.inputField.heightAnchor constraintEqualToConstant:44],
        
        [self.suggestionsStack.topAnchor constraintEqualToAnchor:self.inputField.bottomAnchor constant:20],
        [self.suggestionsStack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.suggestionsStack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
    ]];
}

- (void)setupPredictor {
    // Initialize predictor without app group (single app mode)
    self.predictor = [[PredictionKeyboardManager alloc] init];
    
    // Initialize prediction database
    [self.predictor initializePredictionDatabase:^(BOOL success, NSError *error) {
        if (success) {
            self.statusLabel.text = @"✓ Ready for predictions";
            self.statusLabel.textColor = [UIColor greenColor];
        } else {
            self.statusLabel.text = [NSString stringWithFormat:@"✗ Error: %@", error.localizedDescription];
            self.statusLabel.textColor = [UIColor redColor];
        }
    }];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChangeSelection:(UITextField *)textField {
    NSString *input = textField.text;
    
    [self.predictor getPrediction:input completion:^(NSArray<NSString *> *suggestions, UIColor *textColor) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.suggestionsStack.arrangedSubviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            if (suggestions.count == 0) {
                UILabel *emptyLabel = [[UILabel alloc] init];
                emptyLabel.text = @"No suggestions";
                emptyLabel.textColor = [UIColor lightGrayColor];
                [self.suggestionsStack addArrangedSubview:emptyLabel];
            } else {
                for (NSString *suggestion in suggestions) {
                    UIButton *suggestionButton = [UIButton buttonWithType:UIButtonTypeSystem];
                    [suggestionButton setTitle:suggestion forState:UIControlStateNormal];
                    [suggestionButton setTitleColor:textColor forState:UIControlStateNormal];
                    [suggestionButton addTarget:self action:@selector(suggestionTapped:) forControlEvents:UIControlEventTouchUpInside];
                    
                    suggestionButton.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:1.0 alpha:1.0];
                    suggestionButton.layer.cornerRadius = 6;
                    suggestionButton.contentEdgeInsets = UIEdgeInsetsMake(8, 12, 8, 12);
                    
                    [self.suggestionsStack addArrangedSubview:suggestionButton];
                }
            }
        });
    }];
}

- (void)suggestionTapped:(UIButton *)button {
    self.inputField.text = [self.inputField.text stringByAppendingString:button.titleLabel.text];
}

@end
