//
//  BatchProcessor.m
//
//  Created by Gavin Cornwell on 02/10/2014.
//  Copyright (c) 2014 Alfresco. All rights reserved.
//

#import "BatchProcessor.h"

@interface BatchProcessor ()
@property (nonatomic, copy) BatchCompletionBlock completionBlock;
@property (nonatomic, strong) NSMutableDictionary *results;
@property (nonatomic, strong) NSMutableDictionary *errors;
@property (nonatomic, strong) NSMutableArray *unitsOfWork;
@property (nonatomic, copy) ParameterisedUnitOfWorkBlock parameterisedWork;
@property (nonatomic, strong) NSArray *parameters;
@property (nonatomic, assign) unsigned long numberOfExpectedResults;
@end

@implementation BatchProcessor

- (instancetype)initWithCompletionBlock:(BatchCompletionBlock)completionBlock
{
    self = [super init];
    
    if (self)
    {
        self.completionBlock = completionBlock;
        self.results = [NSMutableDictionary dictionary];
        self.errors = [NSMutableDictionary dictionary];
        self.unitsOfWork = [NSMutableArray array];
    }
    
    return self;
}

- (instancetype)initWithCompletionBlock:(BatchCompletionBlock)completionBlock options:(BatchProcessorOptions *)options
{
    return [self initWithCompletionBlock:completionBlock];
}

- (void)addUnitOfWork:(void (^)())work
{
    [self.unitsOfWork addObject:work];
}

- (void)addParameterisedUnitOfWork:(ParameterisedUnitOfWorkBlock)work forParameters:(NSArray *)parameters
{
    self.parameterisedWork = work;
    self.parameters = parameters;
}

- (void)storeUnitOfWorkResult:(id)result withKey:(NSString *)key
{
    if ([result isKindOfClass:[NSError class]])
    {
        self.errors[key] = result;
        
        NSLog(@"Stored error: %@ on thread %@", result, [NSThread currentThread]);
    }
    else
    {
        self.results[key] = result;
        
        NSLog(@"Stored result with key '%@' on thread %@", key, [NSThread currentThread]);
    }
    
    // if this was the last expected result return the results
    self.numberOfExpectedResults--;
    
    if (self.numberOfExpectedResults == 0)
    {
        NSLog(@"Calling completion block on thread %@", [NSThread currentThread]);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completionBlock(self.results, self.errors);
        });
    }
}

- (void)start
{
    // TODO: launch the units of work on a background thread
    
    // call each unit of work
    if (self.parameterisedWork)
    {
        // set the number of expected results
        self.numberOfExpectedResults = self.parameters.count;
        
        NSLog(@"Launching parameterised units of work on thread %@", [NSThread currentThread]);
        
        for (id parameter in self.parameters)
        {
            self.parameterisedWork(parameter);
        }
        
        NSLog(@"Finished launching parameterised units of work on thread %@", [NSThread currentThread]);
    }
    else
    {
        // set the number of expected results
        self.numberOfExpectedResults = self.unitsOfWork.count;
        
        NSLog(@"Launching units of work on thread %@", [NSThread currentThread]);
        for (UnitOfWorkBlock work in self.unitsOfWork)
        {
            work();
        }
        NSLog(@"Finished launching units of work on thread %@", [NSThread currentThread]);
    }
}

- (void)cancel
{
    // TODO
}

@end
