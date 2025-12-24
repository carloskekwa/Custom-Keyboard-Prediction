#import <XCTest/XCTest.h>
#import <CoreMedia/CoreMedia.h>
#import "PredictionKeyboardManager.h"
#import "PredictionConstants.h"

@interface PredictionKeyboardTests : XCTestCase
@property (nonatomic, strong) PredictionKeyboardManager *predictor;
@end

@implementation PredictionKeyboardTests

- (void)setUp {
    [super setUp];
    // Initialize predictor for each test
    self.predictor = [[PredictionKeyboardManager alloc] init];
    
    // Clear the extraction flag for testing
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.prediction.keyboard.database.loaded"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)tearDown {
    [super tearDown];
    self.predictor = nil;
}

#pragma mark - Database Extraction Tests

/// Test first-time database extraction
- (void)testDatabaseExtractionFirstTime {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Database extraction on first use"];
    
    CFTimeInterval startTime = CACurrentMediaTime();
    
    [self.predictor initializePredictionDatabase:^(BOOL success, NSError *error) {
        CFTimeInterval extractionTime = CACurrentMediaTime() - startTime;
        
        XCTAssertTrue(success, @"Database extraction should succeed. Error: %@", error.localizedDescription);
        XCTAssertNil(error, @"There should be no error during extraction");
        
        NSLog(@"[Test] First-time extraction completed in %.2f seconds", extractionTime);
        
        // Verify database was marked as loaded
        BOOL isLoaded = [[NSUserDefaults standardUserDefaults] boolForKey:@"com.prediction.keyboard.database.loaded"];
        XCTAssertTrue(isLoaded, @"Database should be marked as loaded in NSUserDefaults");
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Timeout waiting for database extraction: %@", error.localizedDescription);
        }
    }];
}

/// Test that extraction is skipped on subsequent calls
- (void)testDatabaseExtractionCached {
    XCTestExpectation *firstExpectation = [self expectationWithDescription:@"First database extraction"];
    
    // First extraction
    [self.predictor initializePredictionDatabase:^(BOOL success, NSError *error) {
        XCTAssertTrue(success, @"First extraction should succeed");
        
        [firstExpectation fulfill];
        
        // Second initialization with new manager instance
        XCTestExpectation *secondExpectation = [self expectationWithDescription:@"Cached database access"];
        
        CFTimeInterval startTime = CACurrentMediaTime();
        PredictionKeyboardManager *predictor2 = [[PredictionKeyboardManager alloc] init];
        
        [predictor2 initializePredictionDatabase:^(BOOL success, NSError *error) {
            CFTimeInterval cachedAccessTime = CACurrentMediaTime() - startTime;
            
            XCTAssertTrue(success, @"Cached access should succeed");
            XCTAssertNil(error, @"No error for cached database");
            
            NSLog(@"[Test] Cached database access completed in %.4f seconds", cachedAccessTime);
            
            // Cached access should be much faster (< 1 second)
            XCTAssertLessThan(cachedAccessTime, 1.0, @"Cached access should be fast (< 1 second)");
            
            [secondExpectation fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
            if (error) {
                XCTFail(@"Timeout waiting for cached access: %@", error.localizedDescription);
            }
        }];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Timeout waiting for first extraction: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - Prediction Performance Tests

/// Test next-word prediction performance
- (void)testNextWordPredictionPerformance {
    XCTestExpectation *initExpectation = [self expectationWithDescription:@"Initialize database"];
    
    [self.predictor initializePredictionDatabase:^(BOOL success, NSError *error) {
        XCTAssertTrue(success, @"Database should initialize successfully");
        
        [initExpectation fulfill];
        
        // Test next-word prediction performance
        XCTestExpectation *predictionExpectation = [self expectationWithDescription:@"Next-word prediction"];
        
        CFTimeInterval startTime = CACurrentMediaTime();
        NSString *input = @"the quick brown ";
        
        [self.predictor getPrediction:input completion:^(NSArray<NSString *> *suggestions, UIColor *textColor) {
            CFTimeInterval predictionTime = CACurrentMediaTime() - startTime;
            
            XCTAssertNotNil(suggestions, @"Suggestions should not be nil");
            XCTAssertLessThanOrEqual(suggestions.count, MAX_SUGGESTIONS, 
                                    @"Suggestions should not exceed MAX_SUGGESTIONS");
            XCTAssertEqual(textColor, [UIColor blueColor], @"Next-word prediction should use blue color");
            
            NSLog(@"[Test] Next-word prediction for '%@' completed in %.4f seconds", input, predictionTime);
            NSLog(@"[Test] Suggestions: %@", suggestions);
            NSLog(@"[Test] Prediction time: %.4f ms", predictionTime * 1000);
            
            // Prediction should be fast (< 100ms)
            XCTAssertLessThan(predictionTime, 0.1, @"Prediction should be fast (< 100ms)");
            
            [predictionExpectation fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
            if (error) {
                XCTFail(@"Timeout waiting for prediction: %@", error.localizedDescription);
            }
        }];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

/// Test word completion prediction performance
- (void)testWordCompletionPredictionPerformance {
    XCTestExpectation *initExpectation = [self expectationWithDescription:@"Initialize database"];
    
    [self.predictor initializePredictionDatabase:^(BOOL success, NSError *error) {
        XCTAssertTrue(success, @"Database should initialize successfully");
        
        [initExpectation fulfill];
        
        // Test word completion prediction performance
        XCTestExpectation *predictionExpectation = [self expectationWithDescription:@"Word completion prediction"];
        
        CFTimeInterval startTime = CACurrentMediaTime();
        NSString *input = @"hello wor";
        
        [self.predictor getPrediction:input completion:^(NSArray<NSString *> *suggestions, UIColor *textColor) {
            CFTimeInterval predictionTime = CACurrentMediaTime() - startTime;
            
            XCTAssertNotNil(suggestions, @"Suggestions should not be nil");
            XCTAssertLessThanOrEqual(suggestions.count, MAX_SUGGESTIONS, 
                                    @"Suggestions should not exceed MAX_SUGGESTIONS");
            XCTAssertEqual(textColor, [UIColor blackColor], @"Word completion should use black color");
            
            NSLog(@"[Test] Word completion for '%@' completed in %.4f seconds", input, predictionTime);
            NSLog(@"[Test] Suggestions: %@", suggestions);
            NSLog(@"[Test] Prediction time: %.4f ms", predictionTime * 1000);
            
            // Prediction should be fast (< 100ms)
            XCTAssertLessThan(predictionTime, 0.1, @"Prediction should be fast (< 100ms)");
            
            [predictionExpectation fulfill];
        }];
        
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
            if (error) {
                XCTFail(@"Timeout waiting for prediction: %@", error.localizedDescription);
            }
        }];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

/// Test multiple rapid predictions for sustained performance
- (void)testMultiplePredictionsBurstPerformance {
    XCTestExpectation *initExpectation = [self expectationWithDescription:@"Initialize database"];
    
    [self.predictor initializePredictionDatabase:^(BOOL success, NSError *error) {
        XCTAssertTrue(success, @"Database should initialize successfully");
        
        [initExpectation fulfill];
        
        XCTestExpectation *burstExpectation = [self expectationWithDescription:@"Burst predictions"];
        
        NSArray<NSString *> *testInputs = @[
            @"the ",
            @"hello ",
            @"the quick ",
            @"wor",
            @"pre",
            @"tec"
        ];
        
        __block NSInteger completedCount = 0;
        __block CFTimeInterval totalTime = 0;
        NSMutableArray<NSNumber *> *timings = [NSMutableArray array];
        
        for (NSString *input in testInputs) {
            CFTimeInterval startTime = CACurrentMediaTime();
            
            [self.predictor getPrediction:input completion:^(NSArray<NSString *> *suggestions, UIColor *textColor) {
                CFTimeInterval predictionTime = CACurrentMediaTime() - startTime;
                
                [timings addObject:@(predictionTime)];
                totalTime += predictionTime;
                completedCount++;
                
                NSLog(@"[Test] Prediction %ld: '%@' in %.4f ms, suggestions: %@", 
                      (long)completedCount, input, predictionTime * 1000, suggestions);
                
                if (completedCount == testInputs.count) {
                    CFTimeInterval avgTime = totalTime / testInputs.count;
                    CFTimeInterval maxTime = [[timings valueForKey:@"doubleValue"] componentsJoinedByString:@","].doubleValue;
                    
                    NSLog(@"[Test] Burst Performance Summary:");
                    NSLog(@"[Test]   Total predictions: %ld", (long)testInputs.count);
                    NSLog(@"[Test]   Average time: %.4f ms", avgTime * 1000);
                    NSLog(@"[Test]   Total time: %.4f ms", totalTime * 1000);
                    
                    [burstExpectation fulfill];
                }
            }];
        }
        
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
            if (error) {
                XCTFail(@"Timeout waiting for burst predictions: %@", error.localizedDescription);
            }
        }];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

@end
