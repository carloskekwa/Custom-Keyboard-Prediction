//
//  PredictionWord.h
//  PredictionKeyboard
//
//  Created by Carlos Kekwa on 2024.
//  Copyright © 2024 Carlos Kekwa. All rights reserved.
//

#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

/// Realm model for tracking single-word frequency and scores
@interface PredictionWord : RLMObject

/// The word key
@property (nonatomic, strong) NSString *predKey;

/// The score/frequency value
@property (nonatomic, assign) NSInteger predValue;

@end

RLM_ARRAY_TYPE(PredictionWord)

NS_ASSUME_NONNULL_END
