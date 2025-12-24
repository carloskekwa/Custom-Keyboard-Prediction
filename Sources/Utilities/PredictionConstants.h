//
//  PredictionConstants.h
//  PredictionKeyboard
//
//  Created by Carlos Kekwa on 2024.
//  Copyright © 2024 Carlos Kekwa. All rights reserved.
//

#ifndef PredictionConstants_h
#define PredictionConstants_h

// Realm database configuration
#define REALM_DB_NAME @"Library/Caches/predictiondb.realm"
#define REALM_SCHEMA_VERSION 10

// UserDefaults keys
#define WORD_PREDICTION_LOAD_KEY @"predict.words.load.key"

// Prediction scoring
#define INITIAL_SCORE_TO_PREDICTION 50
#define ADD_SCORE_TO_PREDICTION 10
#define MIN_PREDICTION_SCORE 25

// Limits
#define MAX_SUGGESTIONS 3
#define MIN_SCORE_FOR_NGRAM 50

#endif /* PredictionConstants_h */
