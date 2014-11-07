//
//  ConcurrentUnitOfWork.m
//  BatchProcessor
//
//  Created by Gavin Cornwell on 05/11/2014.
//  Copyright (c) 2014 Alfresco. All rights reserved.
//

#import "ConcurrentUnitOfWork.h"

@interface ConcurrentUnitOfWork ()
@property (nonatomic, assign, readwrite) BOOL workExecuting;
@property (nonatomic, assign, readwrite) BOOL workCompleted;
@end

@implementation ConcurrentUnitOfWork

@synthesize workCompleted;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.workExecuting = NO;
    }
    
    return self;
}

- (void)start
{
    // Always check for cancellation before launching the task.
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        self.workCompleted = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    self.workExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    NSLog(@"Work starting for key '%@' on thread %@", self.key, [NSThread currentThread]);
//    [NSThread detachNewThreadSelector:@selector(startWork) toTarget:self withObject:nil];
    [self startWork];
}

- (void)completeWorkWithResult:(id)result error:(NSError *)error
{
    NSLog(@"ConcurrentUnitOfWork - Completing work for key '%@' on thread %@", self.key, [NSThread currentThread]);
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    self.workExecuting = NO;
    [super completeWorkWithResult:result error:error];
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isAsynchronous
{
    return YES;
}

- (BOOL)isExecuting
{
    return self.workExecuting;
}

- (BOOL)isFinished
{
    return self.workCompleted;
}

@end
