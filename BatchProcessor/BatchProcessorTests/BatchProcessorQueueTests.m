//
//  BatchProcessorQueueTests.m
//  BatchProcessor
//
//  Created by Gavin Cornwell on 24/10/2014.
//  Copyright (c) 2014 Alfresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BatchProcessorQueue.h"
#import "ConcurrentUnitOfWork.h"
#import "NonConcurrentUnitOfWork.h"

// NOTE: swap the superclass between NonConcurrentUnitOfWork and ConcurrentUnitOfWork

//@interface RetrieveHomePageUnitOfWork : NonConcurrentUnitOfWork
@interface RetrieveHomePageUnitOfWork : ConcurrentUnitOfWork
@property (nonatomic, strong) NSURL *url;
- (instancetype)initWithURL:(NSURL *)url;
@end

@implementation RetrieveHomePageUnitOfWork

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super initWithKey:[url absoluteString]];
    
    if (self)
    {
        self.url = url;
    }
    
    return self;
}

- (void)startWork
{
    NSLog(@"Retrieving homepage for %@ on thread %@", self.url, [NSThread currentThread]);
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:self.url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error)
        {
            [self completeWorkWithResult:nil error:error];
        }
        else
        {
            NSLog(@"Retrieved homepage for %@ on thread %@", self.url, [NSThread currentThread]);
            
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self completeWorkWithResult:responseString error:nil];
        }
    }] resume];
}

@end



@interface BatchProcessorQueueTests : XCTestCase

@end

@implementation BatchProcessorQueueTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testQueue
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Future result expectation"];
    
    NSLog(@"Running test on thread %@", [NSThread currentThread]);
    
    BatchProcessorQueue *bpq = [[BatchProcessorQueue alloc] initWithCompletionBlock:^(NSDictionary *dictionary, NSDictionary *errors) {
        [expectation fulfill];
        NSLog(@"Recieved completion notification on thread %@", [NSThread currentThread]);
        //        NSLog(@"result is: %@", dictionary);
        XCTAssertNotNil(dictionary, @"Expected the dictionary to be returned");
        XCTAssertTrue(dictionary.count == 3, @"Expected the dictionary to contain 3 results");
        XCTAssertTrue(errors.count == 1, @"Expected there to be 1 error");
    }];
    
    RetrieveHomePageUnitOfWork *google = [[RetrieveHomePageUnitOfWork alloc] initWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    RetrieveHomePageUnitOfWork *apple = [[RetrieveHomePageUnitOfWork alloc] initWithURL:[NSURL URLWithString:@"http://www.apple.com"]];
    RetrieveHomePageUnitOfWork *microsoft = [[RetrieveHomePageUnitOfWork alloc] initWithURL:[NSURL URLWithString:@"http://www.microsoft.com"]];
    RetrieveHomePageUnitOfWork *localhost = [[RetrieveHomePageUnitOfWork alloc] initWithURL:[NSURL URLWithString:@"http://www.localhost.com"]];
    
    // add the work
    [bpq addUnitOfWork:google];
    [bpq addUnitOfWork:apple];
    [bpq addUnitOfWork:microsoft];
    [bpq addUnitOfWork:localhost];
    
    // start the processor
    [bpq start];
    
    // wait for the future result
    [self waitForExpectationsWithTimeout:120.0 handler:nil];
}

@end
