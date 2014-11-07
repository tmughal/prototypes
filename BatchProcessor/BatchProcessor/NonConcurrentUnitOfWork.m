//
//  NonConcurrentUnitOfWork.m
//  BatchProcessor
//
//  Created by Gavin Cornwell on 05/11/2014.
//  Copyright (c) 2014 Alfresco. All rights reserved.
//

#import "NonConcurrentUnitOfWork.h"

@implementation NonConcurrentUnitOfWork

- (void)main
{
    @autoreleasepool
    {
        // check we haven't been cancelled while waiting to start
        if (self.isCancelled)
        {
            return;
        }
        
        NSLog(@"Work starting for key '%@' on thread %@", self.key, [NSThread currentThread]);
        
        // start the unit of work
        [self startWork];
        
        // TODO: add a timeout so we don't wait forever!
        
        // TODO: this indicates that we should be flagging ourselves as an asynchronous operation,
        //       which means we need to handle the internal ready/executing/finished flags ourselves,
        //       override the start methods and ensure we send KVO flags for the properties.
        
        // wait until the work is complete, it's OK to block as we're an NSOperation
        // and will therefore be running in our own thread
        while (!self.workCompleted)
        {
            // do nothing, until workCompleted is called
        }
    }
}

@end
