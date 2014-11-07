//
//  UnitOfWorkOperation.m
//  BatchProcessor
//
//  Created by Gavin Cornwell on 24/10/2014.
//  Copyright (c) 2014 Alfresco. All rights reserved.
//

#import "UnitOfWork.h"

@interface UnitOfWork ()
@property (nonatomic, strong, readwrite) NSString *key;
@property (nonatomic, strong, readwrite) id result;
@property (nonatomic, assign, readwrite) BOOL successful;
@property (nonatomic, assign, readwrite) BOOL workCompleted;
@end

@implementation UnitOfWork

- (instancetype)initWithKey:(NSString *)key
{
    self = [super init];
    
    if (self)
    {
        self.key = key;
        self.successful = NO;
        self.workCompleted = NO;
    }
    
    return self;
}

- (void)startWork
{
    @throw ([NSException exceptionWithName:@"Missing method implementation"
                                    reason:@"UnitOfWork subclass must override the startWork method"
                                  userInfo:nil]);
}

- (void)completeWorkWithResult:(id)result error:(NSError *)error
{
    // we're successful if there is no error
    self.successful = (!error);

    // store the result object if successful otherwise store the error
    self.result = (self.successful) ? result : error;

    // indicate we're done
    self.workCompleted = YES;
    
    NSLog(@"UnitOfWork - Work completed for key '%@' on thread %@", self.key, [NSThread currentThread]);
}

@end
