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

#import "AlfrescoUnitOfWork.h"

@interface AlfrescoUnitOfWork ()
@property (nonatomic, strong, readwrite) NSString *key;
@property (nonatomic, strong, readwrite) id result;
@property (nonatomic, assign) BOOL workCompleted;
@property (nonatomic, assign) BOOL workInProgress;
@end

@implementation AlfrescoUnitOfWork

- (instancetype)initWithKey:(NSString *)key
{
    self = [super init];
    
    if (self)
    {
        self.key = key;
        self.workCompleted = NO;
        self.workInProgress = NO;
    }
    
    return self;
}

- (void)start
{
    // check for cancellation before starting
    if ([self isCancelled])
    {
        [self cancelWork];
        return;
    }
    
    // update progress state
    [self updateExecutingStateTo:YES];
    
    NSLog(@"Work starting for key: %@", self.key);
    //    [NSThread detachNewThreadSelector:@selector(startWork) toTarget:self withObject:nil];
    [self startWork];
}

- (void)cancel
{
    NSLog(@"Cancelling work for key: %@", self.key);
    [self cancelWork];
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
    return self.workInProgress;
}

- (BOOL)isFinished
{
    return self.workCompleted;
}

- (void)startWork
{
    @throw ([NSException exceptionWithName:@"Missing method implementation"
                                    reason:@"AlfrescoUnitOfWork subclass must override the startWork method"
                                  userInfo:nil]);
}

- (void)completeWorkWithResult:(id)result
{
    // store the result
    self.result = result;
    
    // indicate we're done
    [self updateExecutingStateTo:NO];
    [self updateFinishedStateTo:YES];
    
    NSLog(@"Work completed for key: %@", self.key);
}

- (void)cancelWork
{
    // create a cancelled error as the result
    self.result = [NSError errorWithDomain:@"Batch Processor"
                                      code:0
                                  userInfo:@{NSLocalizedDescriptionKey: @"Unit of work was cancelled."}];
    
    // update executing state, if necessary
    if (self.workInProgress)
    {
        [self updateExecutingStateTo:NO];
    }
    
    // update finished state
    [self updateFinishedStateTo:YES];
    
    NSLog(@"Work cancelled for key: %@", self.key);
}

# pragma mark Private methods

- (void)updateFinishedStateTo:(BOOL)state
{
    // inform any KVO listeners before change
    [self willChangeValueForKey:@"isFinished"];
    
    self.workCompleted = state;
    
    // inform any KVO listeners after change
    [self didChangeValueForKey:@"isFinished"];
}

- (void)updateExecutingStateTo:(BOOL)state
{
    // inform any KVO listeners before change
    [self willChangeValueForKey:@"isExecuting"];
    
    self.workInProgress = state;
    
    // inform any KVO listeners after change
    [self didChangeValueForKey:@"isExecuting"];
}

@end
