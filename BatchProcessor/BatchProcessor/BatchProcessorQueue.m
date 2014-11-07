//
//  BatchProcessorQueue.m
//  BatchProcessor
//
//  Created by Gavin Cornwell on 24/10/2014.
//  Copyright (c) 2014 Alfresco. All rights reserved.
//

#import "BatchProcessorQueue.h"

@interface BatchProcessorQueue ()
@property (nonatomic, copy) BatchCompletionBlock completionBlock;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableArray *unitsOfWork;
@property (nonatomic, strong) NSMutableDictionary *results;
@property (nonatomic, strong) NSMutableDictionary *errors;
@end

@implementation BatchProcessorQueue

- (instancetype)initWithCompletionBlock:(BatchCompletionBlock)completionBlock
{
    self = [super init];
    
    if (self)
    {
        self.completionBlock = completionBlock;
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
        self.queue.name = @"Batch Processor Queue";
        self.unitsOfWork = [NSMutableArray array];
        self.results = [NSMutableDictionary dictionary];
        self.errors = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)addUnitOfWork:(UnitOfWork *)work;
{
    assert(work.key);
    
    __weak UnitOfWork *weakUnitOfWork = work;
    work.completionBlock = ^void () {
        [self storeUnitOfWorkResult:weakUnitOfWork];
    };
    
    [self.unitsOfWork addObject:work];
}

- (void)storeUnitOfWorkResult:(UnitOfWork *)work
{
    id result = work.result;
    NSString *key = work.key;
    
    // TODO: add some locking around the errors and results dictionaries?
    //       in theory each unit of work has a unique key so we may be ok!?
    //       should we enforce that when the units of work are added?
    
    if ([result isKindOfClass:[NSError class]])
    {
        self.errors[key] = result;
        
        NSLog(@"Stored error for key '%@' on thread %@", key, [NSThread currentThread]);
    }
    else
    {
        self.results[key] = result;
        
        NSLog(@"Stored result for key '%@' on thread %@", key, [NSThread currentThread]);
    }
    
    if (self.queue.operationCount == 0)
    {
        NSLog(@"Calling completion block on thread %@", [NSThread currentThread]);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completionBlock(self.results, self.errors);
        });
    }
    else
    {
        NSLog(@"There are %lu units of work executing (thread %@)", (unsigned long)self.queue.operationCount, [NSThread currentThread]);
    }
}

- (void)start
{
    NSLog(@"Launching units of work on thread %@", [NSThread currentThread]);
    
    for (UnitOfWork *unitOfWork in self.unitsOfWork)
    {
        [self.queue addOperation:unitOfWork];
    }

    // remove the units of work from the array
    [self.unitsOfWork removeAllObjects];
    self.unitsOfWork = nil;
    
    // TODO: set status flags
    
    NSLog(@"Launched units of work on thread %@", [NSThread currentThread]);
}


@end
