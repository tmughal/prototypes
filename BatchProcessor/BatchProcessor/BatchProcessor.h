//
//  BatchProcessor.h
//
//  Created by Gavin Cornwell on 02/10/2014.
//  Copyright (c) 2014 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BatchProcessorOptions.h"

typedef void (^UnitOfWorkBlock)();
typedef void (^ParameterisedUnitOfWorkBlock)(id parameter);
typedef void (^BatchCompletionBlock)(NSDictionary *dictionary, NSDictionary *errors);

@interface BatchProcessor : NSObject

@property (nonatomic, assign, readonly) BOOL inProgress;
@property (nonatomic, assign, readonly) BOOL complete;


- (instancetype)initWithCompletionBlock:(BatchCompletionBlock)completionBlock;

- (instancetype)initWithCompletionBlock:(BatchCompletionBlock)completionBlock options:(BatchProcessorOptions *)options;

- (void)addUnitOfWork:(UnitOfWorkBlock)work;
- (void)addParameterisedUnitOfWork:(ParameterisedUnitOfWorkBlock)work forParameters:(NSArray *)parameters;

- (void)storeUnitOfWorkResult:(id)result withKey:(NSString *)key;

- (void)start;
- (void)cancel;

@end
