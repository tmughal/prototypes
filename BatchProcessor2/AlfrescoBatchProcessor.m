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

@interface AlfrescoBatchProcessor ()
@property (nonatomic, assign, readwrite) BOOL inProgress;
@property (nonatomic, assign, readwrite) BOOL cancelled;

@property (nonatomic, copy) AlfrescoBatchProcessorCompletionBlock completionBlock;
@property (nonatomic, strong) NSMutableDictionary *results;
@property (nonatomic, strong) NSMutableDictionary *errors;
@property (nonatomic, strong) NSMutableArray *unitsOfWork;
@property (nonatomic, strong) NSOperationQueue *queue;
@end


@implementation AlfrescoBatchProcessor

- (instancetype)initWithCompletionBlock:(AlfrescoBatchProcessorCompletionBlock)completionBlock
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
        
        // initialise internal queue
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.name = @"Batch Processor Queue";
//        self.queue.maxConcurrentOperationCount = 1;
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
    
    // remove the units of work from the array
    [self.unitsOfWork removeAllObjects];
    self.unitsOfWork = nil;
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
    // TODO: we may need add some locks in this method as NSMutableDictionary is not thread-safe,
    //       there is also a chance that more than one thread can finish at the same time and
    //       end up calling the batch processor completion block more than once!
    
    id result = work.result;
    NSString *key = work.key;
    
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
    
    if (self.queue.operationCount == 0)
    {
        NSLog(@"All units of work have completed, calling completion block");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completionBlock(self.results, self.errors);
        });
    }
    else
    {
        NSLog(@"There are %lu units of work in progress", (unsigned long)self.queue.operationCount);
    }
}

@end
