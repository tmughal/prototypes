/*
 ******************************************************************************
 * Copyright (C) 2005-2014 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Mobile SDK.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *****************************************************************************
 */

#import "AlfrescoBatchProcessor.h"

@implementation AlfrescoBatchProcessorOptions
@end

@interface AlfrescoBatchProcessor ()
@property (nonatomic, assign, readwrite) BOOL inProgress;
@property (nonatomic, assign, readwrite) BOOL cancelled;

@property (nonatomic, copy) AlfrescoBatchProcessorCompletionBlock completionBlock;
@property (nonatomic, strong) NSMutableDictionary *results;
@property (nonatomic, strong) NSMutableDictionary *errors;
@property (nonatomic, strong) NSMutableArray *unitsOfWork;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSLock *mutexLock;
@end


@implementation AlfrescoBatchProcessor

- (instancetype)initWithCompletionBlock:(AlfrescoBatchProcessorCompletionBlock)completionBlock
{
    return [self initWithCompletionBlock:completionBlock options:nil];
}

- (instancetype)initWithCompletionBlock:(AlfrescoBatchProcessorCompletionBlock)completionBlock
                                options:(AlfrescoBatchProcessorOptions *)options
{
    self = [super init];
    
    if (self)
    {
        self.inProgress = NO;
        self.cancelled = NO;
        
        self.completionBlock = completionBlock;
        self.results = [NSMutableDictionary dictionary];
        self.errors = [NSMutableDictionary dictionary];
        self.unitsOfWork = [NSMutableArray array];
        self.mutexLock = [[NSLock alloc] init];
        
        // initialise internal queue
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.name = @"Batch Processor Queue";
        if (options && options.maxConcurrentUnitsOfWork)
        {
            self.queue.maxConcurrentOperationCount = options.maxConcurrentUnitsOfWork;
        }
    }
    
    return self;
}

- (void)addUnitOfWork:(AlfrescoUnitOfWork *)work;
{
    assert(work.key);
    
    __weak AlfrescoUnitOfWork *weakUnitOfWork = work;
    work.completionBlock = ^void () {
        [self storeUnitOfWorkResult:weakUnitOfWork];
    };
    
    [self.unitsOfWork addObject:work];
}

- (void)start
{
    self.inProgress = YES;
    
    for (AlfrescoUnitOfWork *unitOfWork in self.unitsOfWork)
    {
        [self.queue addOperation:unitOfWork];
    }
    
    NSLog(@"Launched %lu units of work", (unsigned long)self.unitsOfWork.count);
}

- (void)cancel
{
    self.cancelled = YES;
    [self.queue cancelAllOperations];
    self.inProgress = NO;
    
    NSLog(@"Cancelled all units of work");
}

#pragma mark Internal methods

- (void)storeUnitOfWorkResult:(AlfrescoUnitOfWork *)work
{
    id result = work.result;
    NSString *key = work.key;
    
    // take out a lock so the dictionaries are only updated by one thread at a time,
    // likewise for the checking and calling of the completion block.
    [self.mutexLock lock];
    
    if ([result isKindOfClass:[NSError class]])
    {
        self.errors[key] = result;
        
        NSLog(@"Stored error for key: %@", key);
    }
    else
    {
        self.results[key] = result;
        
        NSLog(@"Stored result for key: %@", key);
    }
    
    // remove the unit of work from the internal array
    [self.unitsOfWork removeObject:work];
    
    if (self.unitsOfWork.count == 0)
    {
        self.inProgress = NO;
        
        NSLog(@"All units of work have completed");
        
        if (self.completionBlock != NULL)
        {
            NSLog(@"Calling completion block on main thread");
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completionBlock(self.results, self.errors);
            });
        }
    }
    else
    {
        NSLog(@"There are %lu units of work in progress", (unsigned long)self.unitsOfWork.count);
    }
    
    // remove the lock
    [self.mutexLock unlock];
}

@end
