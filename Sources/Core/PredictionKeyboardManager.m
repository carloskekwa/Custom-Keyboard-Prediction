//
//  PredictionKeyboardManager.m
//  PredictionKeyboard
//
//  Created by Carlos Kekwa on 2024.
//  Copyright © 2024 Carlos Kekwa. All rights reserved.
//

#import "PredictionKeyboardManager.h"
#import <Realm/Realm.h>
#import <CoreMedia/CoreMedia.h>
#import "PredictionTable.h"
#import "PredictionWord.h"
#import "PredictionConstants.h"

// Database extraction flag - used to extract database only once on first use
static NSString * const kPredictionDatabaseLoadedKey = @"com.prediction.keyboard.database.loaded";

@interface PredictionKeyboardManager ()
@property (nonatomic, strong) NSString *appGroupID;
@property (nonatomic, strong) dispatch_queue_t predictionQueue;
@end

@implementation PredictionKeyboardManager

- (instancetype)initWithAppGroup:(NSString *)appGroupID {
    self = [super init];
    if (self) {
        _appGroupID = [appGroupID copy];
        _predictionQueue = dispatch_queue_create("com.predictionkeyboard.prediction", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _appGroupID = nil;
        _predictionQueue = dispatch_queue_create("com.predictionkeyboard.prediction", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)initializePredictionDatabase:(nullable void(^)(BOOL success, NSError *_Nullable error))completion {
    // Check if database was already extracted on first use
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kPredictionDatabaseLoadedKey]) {
        [self configureRealmAndNotify:completion];
        return;
    }
    
    // Extract database on background thread only on first use
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @autoreleasepool {
            NSError *extractError = nil;
            BOOL success = [self extractDatabaseIfNeeded:&extractError];
            
            if (success) {
                // Mark database as loaded
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPredictionDatabaseLoadedKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            if (!success && extractError) {
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(NO, extractError);
                    });
                }
                return;
            }
            
            // Configure Realm after extraction
            [self configureRealmAndNotify:completion];
        }
    });
}

/// Configure Realm and run verification queries
- (void)configureRealmAndNotify:(nullable void(^)(BOOL success, NSError *_Nullable error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            NSError *error = nil;
            
            // Determine Realm file path
            NSURL *realmPath = [self realmPathWithError:&error];
            if (!realmPath || error) {
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(NO, error);
                    });
                }
                return;
            }
            
            // Configure Realm
            RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
            config.fileURL = realmPath;
            config.schemaVersion = REALM_SCHEMA_VERSION;
            config.readOnly = NO;
            config.objectClasses = @[[PredictionTable class], [PredictionWord class]];
            config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
                // Automatic migration
            };
            
            // Test opening Realm
            RLMRealm *realm = [RLMRealm realmWithConfiguration:config error:&error];
            if (!error && realm) {
                [RLMRealmConfiguration setDefaultConfiguration:config];
            }
            
            RLMResults<PredictionTable *> *allPredictions = [PredictionTable allObjectsInRealm:realm];
            NSLog(@"[PredictionKeyboard] PredictionTable total count: %lu", (unsigned long)allPredictions.count);
            
            // Query a specific example
            RLMResults<PredictionTable *> *testQuery = [PredictionTable objectsInRealm:realm where:@"predKey BEGINSWITH 'the'"];
            NSLog(@"[PredictionKeyboard] PredictionTable entries starting with 'the': %lu", (unsigned long)testQuery.count);
            
            if (testQuery.count > 0) {
                PredictionTable *firstResult = testQuery.firstObject;
                NSLog(@"[PredictionKeyboard] Sample result - Key: '%@', Value: '%@', Score: %ld",
                     firstResult.predKey, firstResult.predValue, (long)firstResult.Score);
            } else {
                NSLog(@"[PredictionKeyboard] No results found - database might be empty");
                
                // Check if there are ANY objects in the Realm
                NSLog(@"[PredictionKeyboard] Checking all object types in Realm...");
                for (RLMObjectSchema *objectSchema in realm.schema.objectSchema) {
                    NSLog(@"  - %@", objectSchema.className);
                }
            }
            
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(!error, error);
                });
            }
        }
    });
}

- (void)getPrediction:(NSString *)syntax 
           completion:(void(^)(NSArray <NSString *> *suggestions, UIColor *textColor))completion {
    if (!syntax || !completion) return;
    
    dispatch_async(self.predictionQueue, ^{
        @autoreleasepool {
            NSMutableArray *suggestions = [NSMutableArray array];
            
            // Determine prediction type based on trailing space
            BOOL isNextWordPrediction = [syntax hasSuffix:@" "];
            
            if (isNextWordPrediction) {
                // Next-word prediction
                [self predictNextWord:syntax suggestions:suggestions];
            } else {
                // Word completion / autocorrection
                [self predictWordCompletion:syntax suggestions:suggestions];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIColor *color = isNextWordPrediction ? [UIColor blueColor] : [UIColor blackColor];
                completion([suggestions copy], color);
            });
        }
    });
}

#pragma mark - Private Methods

- (NSURL *)realmPathWithError:(NSError **)error {
    NSURL *baseURL;
    
    if (self.appGroupID) {
        // App Group container for keyboard extension
        baseURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:self.appGroupID];
    } else {
        // Standard app documents
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        baseURL = [NSURL fileURLWithPath:docPath];
    }
    
    if (!baseURL) {
        if (error) {
            *error = [NSError errorWithDomain:@"PredictionKeyboard" code:-1 
                                    userInfo:@{NSLocalizedDescriptionKey: @"Cannot access storage"}];
        }
        return nil;
    }
    
    // Create directory structure if it doesn't exist
    NSURL *realmURL = [baseURL URLByAppendingPathComponent:REALM_DB_NAME];
    NSURL *realmDir = [realmURL URLByDeletingLastPathComponent];
    NSError *dirError = nil;
    [[NSFileManager defaultManager] createDirectoryAtURL:realmDir withIntermediateDirectories:YES attributes:nil error:&dirError];
    
    if (dirError) {
        if (error) {
            *error = dirError;
        }
        return nil;
    }
    
    return realmURL;
}

- (void)predictNextWord:(NSString *)syntax suggestions:(NSMutableArray *)suggestions {
    // Extract last 1-3 words for context
    NSArray *contextWords = [self extractContextWords:syntax limit:3];
    
    if (contextWords.count == 0) return;
    
    @try {
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        // Try progressively smaller context windows
        for (NSInteger i = contextWords.count; i >= 1 && suggestions.count < MAX_SUGGESTIONS; i--) {
            NSString *predKey = [self joinWords:[contextWords subarrayWithRange:NSMakeRange(contextWords.count - i, i)]];
            
            RLMResults<PredictionTable *> *results = [PredictionTable objectsInRealm:realm 
                                                                          withPredicate:[NSPredicate predicateWithFormat:@"predKey == %@ AND Score > %ld", predKey, (long)MIN_SCORE_FOR_NGRAM]];
            
            RLMResults *sorted = [results sortedResultsUsingKeyPath:@"Score" ascending:NO];
            
            for (PredictionTable *pred in sorted) {
                if (suggestions.count >= MAX_SUGGESTIONS) break;
                if (![suggestions containsObject:pred.predValue]) {
                    [suggestions addObject:pred.predValue];
                }
            }
        }
    } @catch (NSException *exception) {
        // Silent catch for Realm errors
    }
}

- (void)predictWordCompletion:(NSString *)syntax suggestions:(NSMutableArray *)suggestions {
    NSString *lastWord = [self getLastWord:syntax];
    if (lastWord.length == 0) return;
    
    @try {
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"predKey BEGINSWITH[c] %@ AND predValue > %ld", lastWord, (long)MIN_PREDICTION_SCORE];
        RLMResults<PredictionWord *> *results = [PredictionWord objectsInRealm:realm withPredicate:predicate];
        RLMResults *sorted = [results sortedResultsUsingKeyPath:@"predValue" ascending:NO];
        
        for (PredictionWord *pred in sorted) {
            if (suggestions.count >= MAX_SUGGESTIONS) break;
            [suggestions addObject:pred.predKey];
        }
    } @catch (NSException *exception) {
        // Silent catch
    }
}

- (NSArray *)extractContextWords:(NSString *)text limit:(NSInteger)limit {
    NSMutableArray *words = [NSMutableArray array];
    [text enumerateSubstringsInRange:NSMakeRange(0, text.length) 
                             options:NSStringEnumerationByWords | NSStringEnumerationReverse 
                          usingBlock:^(NSString *substring, NSRange subrange, NSRange enclosingRange, BOOL *stop) {
        if (words.count < limit) {
            [words insertObject:substring atIndex:0];
        } else {
            *stop = YES;
        }
    }];
    return [words copy];
}

- (NSString *)getLastWord:(NSString *)text {
    __block NSString *lastWord = @"";
    [text enumerateSubstringsInRange:NSMakeRange(0, text.length) 
                             options:NSStringEnumerationByWords | NSStringEnumerationReverse 
                          usingBlock:^(NSString *substring, NSRange subrange, NSRange enclosingRange, BOOL *stop) {
        lastWord = [substring lowercaseString];
        *stop = YES;
    }];
    return lastWord;
}

- (NSString *)joinWords:(NSArray *)words {
    return [[words valueForKey:@"description"] componentsJoinedByString:@" "];
}

#pragma mark - Database Extraction

/// Extract bundled prediction database on first use
/// @param error Out parameter for extraction errors
/// @return YES if extraction successful or database already exists and is valid
- (BOOL)extractDatabaseIfNeeded:(NSError **)error {
    NSURL *databaseURL = [self realmPathWithError:error];
    if (!databaseURL) {
        return NO;
    }
    
    NSString *databasePath = databaseURL.path;
    NSString *documentsPath = [databasePath stringByDeletingLastPathComponent];
    
    // Check if database already exists and is valid
    if ([NSFileManager.defaultManager fileExistsAtPath:databasePath]) {
        NSError *fileError = nil;
        NSDictionary *attributes = [NSFileManager.defaultManager attributesOfItemAtPath:databasePath error:&fileError];
        long long filesize = [[attributes objectForKey:NSFileSize] longLongValue];
        
        NSLog(@"[PredictionKeyboard] Database exists with size: %lld bytes (%.2f MB)", filesize, filesize / (1024.0 * 1024.0));
        
        // Valid database already exists
        if (filesize > 10000) {
            return YES;
        }
        
        // Database is corrupted, remove it
        [NSFileManager.defaultManager removeItemAtPath:databasePath error:nil];
    }
    
    // Look for direct bundled .realm file (iOS-compatible, no unzip needed)
    NSBundle *bundle = [NSBundle bundleForClass:[self class]] ?: [NSBundle mainBundle];
    NSString *bundledRealmPath = [bundle pathForResource:@"predictiondb" ofType:@"realm"];
    
    if (bundledRealmPath) {
        NSLog(@"[PredictionKeyboard] Found bundled .realm file, copying to documents...");
        CFTimeInterval startTime = CACurrentMediaTime();
        
        NSError *copyError = nil;
        [[NSFileManager defaultManager] copyItemAtPath:bundledRealmPath toPath:databasePath error:&copyError];
        
        if (copyError) {
            NSLog(@"[PredictionKeyboard] Error copying bundled database: %@", copyError.localizedDescription);
            if (error) {
                *error = copyError;
            }
            return NO;
        }
        
        CFTimeInterval endTime = CACurrentMediaTime();
        NSLog(@"[PredictionKeyboard] Database copy completed in %.2f seconds", (endTime - startTime));
        
        // Verify copied file
        if ([NSFileManager.defaultManager fileExistsAtPath:databasePath]) {
            NSDictionary *attrs = [NSFileManager.defaultManager attributesOfItemAtPath:databasePath error:nil];
            long long size = [[attrs objectForKey:NSFileSize] longLongValue];
            NSLog(@"[PredictionKeyboard] Copied database size: %.2f MB", size / (1024.0 * 1024.0));
        }
        
        return YES;
    }
    
    // Look for packed database (zipped) - fallback for macOS only
    NSString *packedDB = [bundle pathForResource:@"predictiondb.realm" ofType:@"zip"];
    
    if (packedDB) {
        NSLog(@"[PredictionKeyboard] Found packed database, extracting...");
        CFTimeInterval startTime = CACurrentMediaTime();
        
        // Unzip the database
        BOOL unzipSuccess = [self unzipFile:packedDB toPath:documentsPath error:error];
        
        if (unzipSuccess) {
            // Remove temporary extraction files
            NSString *macosxPath = [documentsPath stringByAppendingPathComponent:@"__MACOSX"];
            [NSFileManager.defaultManager removeItemAtPath:macosxPath error:nil];
            
            CFTimeInterval endTime = CACurrentMediaTime();
            NSLog(@"[PredictionKeyboard] Database extraction completed in %.2f seconds", (endTime - startTime));
            
            // Verify extracted file
            if ([NSFileManager.defaultManager fileExistsAtPath:databasePath]) {
                NSDictionary *attrs = [NSFileManager.defaultManager attributesOfItemAtPath:databasePath error:nil];
                long long size = [[attrs objectForKey:NSFileSize] longLongValue];
                NSLog(@"[PredictionKeyboard] Extracted database size: %.2f MB", size / (1024.0 * 1024.0));
            }
            
            return YES;
        } else {
            NSLog(@"[PredictionKeyboard] Error extracting database: %@", error ? (*error).localizedDescription : @"Unknown");
            return NO;
        }
    }
    
    // No database resource found
    NSLog(@"[PredictionKeyboard] No packed or bundled database found. Database will be created on first use.");
    return YES;
}

/// Unzip a file to a destination directory using system unzip command
/// @param zipPath Path to the .zip file
/// @param destinationPath Destination directory path
/// @param error Out parameter for errors
/// @return YES if unzip was successful
- (BOOL)unzipFile:(NSString *)zipPath toPath:(NSString *)destinationPath error:(NSError **)error {
#if TARGET_OS_OSX
    @try {
        // Create destination directory if needed
        [[NSFileManager defaultManager] createDirectoryAtPath:destinationPath 
                                   withIntermediateDirectories:YES 
                                                    attributes:nil 
                                                         error:error];
        if (error && *error) {
            return NO;
        }
        
        // Use system unzip command (macOS only)
        NSTask *unzipTask = [[NSTask alloc] init];
        unzipTask.launchPath = @"/usr/bin/unzip";
        unzipTask.arguments = @[@"-q", zipPath, @"-d", destinationPath];
        
        NSPipe *errorPipe = [NSPipe pipe];
        unzipTask.standardError = errorPipe;
        
        [unzipTask launch];
        [unzipTask waitUntilExit];
        
        if (unzipTask.terminationStatus == 0) {
            NSLog(@"[PredictionKeyboard] Successfully unzipped database from %@", zipPath);
            return YES;
        } else {
            NSData *errorData = [errorPipe.fileHandleForReading readDataToEndOfFile];
            NSString *errorMessage = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
            
            if (error) {
                *error = [NSError errorWithDomain:@"PredictionKeyboard" 
                                             code:1001 
                                         userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to unzip database: %@", errorMessage]}];
            }
            return NO;
        }
    } @catch (NSException *exception) {
        if (error) {
            *error = [NSError errorWithDomain:@"PredictionKeyboard" 
                                         code:1002 
                                     userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Exception during unzip: %@", exception.reason]}];
        }
        return NO;
    }
#else
    // NSTask and system unzip are not available on iOS/tvOS; return an error to indicate
    // that extraction is unsupported on this platform. Consumers should bundle an already
    // extracted Realm file for non-macOS platforms or implement platform-appropriate extraction.
    if (error) {
        *error = [NSError errorWithDomain:@"PredictionKeyboard" code:1003 userInfo:@{NSLocalizedDescriptionKey: @"Unzip not supported on this platform"}];
    }
    return NO;
#endif
}

@end

