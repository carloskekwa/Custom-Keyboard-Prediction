//
//  PredictionKeyboardManager.h
//  PredictionKeyboard
//
//  Created by Carlos Kekwa on 2024.
//  Copyright © 2024 Carlos Kekwa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Main API for next-word prediction
@interface PredictionKeyboardManager : NSObject

/// Initialize with app group for keyboard extension support
/// @param appGroupID The app group identifier (e.g., "group.com.company.keyboard")
- (instancetype)initWithAppGroup:(NSString *)appGroupID;

/// Initialize without app group (single app use)
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/// Load and configure the prediction database
/// @param completion Called when database is ready; success=YES if loaded successfully
- (void)initializePredictionDatabase:(nullable void(^)(BOOL success, NSError *_Nullable error))completion;

/// Get word predictions for the given syntax/input
/// @param syntax The text input to predict from (e.g., "how are you" or "how are yo")
/// @param completion Block called with suggestions array and display color
/// - If syntax ends with space: returns next-word predictions
/// - If syntax has no space: returns word completion/autocorrection
- (void)getPrediction:(NSString *)syntax 
           completion:(void(^)(NSArray <NSString *> *suggestions, UIColor *textColor))completion;

@end

NS_ASSUME_NONNULL_END
