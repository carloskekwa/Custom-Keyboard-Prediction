//
//  PredictionTable.h
//  PredictionKeyboard
//
//  Created by Carlos Kekwa on 2024.
//  Copyright © 2024 Carlos Kekwa. All rights reserved.
//

#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

/// Realm model for storing n-gram prediction scores
/// Represents contextual word predictions with scoring for machine learning
@interface PredictionTable : RLMObject

/// The context key (n-gram: 1-3 words)
@property (nonatomic, strong) NSString *predKey;

/// The predicted word for this context
@property (nonatomic, strong) NSString *predValue;

/// Relevance score (higher = more relevant)
@property (nonatomic, assign) NSInteger Score;

@end

RLM_ARRAY_TYPE(PredictionTable)

NS_ASSUME_NONNULL_END
