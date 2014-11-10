/*******************************************************************************
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
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AlfrescobatchProcessor.h"
#import "AlfrescoUnitOfWork.h"

// Unit of work implementation for retrieving the HTML of a web site

@interface RetrieveHomePageUnitOfWork : AlfrescoUnitOfWork
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
    NSLog(@"Retrieving homepage for: %@", self.url);
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:self.url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error)
        {
            NSLog(@"Failed to retrieve homepage for: %@", self.url);
            
            [self completeWorkWithResult:error];
        }
        else
        {
            NSLog(@"Successfully retrieved homepage for: %@", self.url);
            
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self completeWorkWithResult:responseString];
        }
    }] resume];
}

@end


// Unit of work implementation that sleeps the current thread twice. The key is used to represent the time to sleep in seconds.

@interface SleepingUnitOfWork : AlfrescoUnitOfWork
@end

@implementation SleepingUnitOfWork

- (void)startWork
{
    NSLog(@"Sleeping for %@ seconds the first time", self.key);
    
    [NSThread sleepForTimeInterval:[self.key doubleValue]];
    
    NSLog(@"Finished sleeping for %@ seconds the first time", self.key);
    
    if (self.cancelled)
    {
        [self cancelWork];
    }
    else
    {
        NSLog(@"Sleeping for %@ seconds the second time", self.key);
        
        [NSThread sleepForTimeInterval:[self.key doubleValue]];
        
        NSLog(@"Finished sleeping for %@ seconds the second time", self.key);
        
        [self completeWorkWithResult:@(YES)];
    }
}

@end

// Tests

@interface AlfrescoBatchProcessorTest : XCTestCase

@end

@implementation AlfrescoBatchProcessorTest

- (void)testHomepageRetrieval
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Batch processor result expectation"];
    
    AlfrescoBatchProcessor *bp = [[AlfrescoBatchProcessor alloc] initWithCompletionBlock:^(NSDictionary *dictionary, NSDictionary *errors) {
        [expectation fulfill];
        
        // check results
        XCTAssertNotNil(dictionary, @"Expected the dictionary to be returned");
        XCTAssertTrue(dictionary.count == 3, @"Expected the dictionary to contain 3 results");
        XCTAssertTrue(errors.count == 1, @"Expected there to be 1 error");
    }];
    
    RetrieveHomePageUnitOfWork *google = [[RetrieveHomePageUnitOfWork alloc] initWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    RetrieveHomePageUnitOfWork *apple = [[RetrieveHomePageUnitOfWork alloc] initWithURL:[NSURL URLWithString:@"http://www.apple.com"]];
    RetrieveHomePageUnitOfWork *microsoft = [[RetrieveHomePageUnitOfWork alloc] initWithURL:[NSURL URLWithString:@"http://www.microsoft.com"]];
    RetrieveHomePageUnitOfWork *localhost = [[RetrieveHomePageUnitOfWork alloc] initWithURL:[NSURL URLWithString:@"http://www.localhost.com"]];
    
    // add the work
    [bp addUnitOfWork:google];
    [bp addUnitOfWork:apple];
    [bp addUnitOfWork:microsoft];
    [bp addUnitOfWork:localhost];
    
    // start the processor
    [bp start];
    
    XCTAssertFalse(bp.cancelled, @"Expected the cancelled flag to be false");
    XCTAssertTrue(bp.inProgress, @"Expected the inProgress flag to be true");
    
    // wait for the future result
    [self waitForExpectationsWithTimeout:60.0 handler:nil];
}

-(void)testCancellation
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Batch processor result expectation"];
    
    AlfrescoBatchProcessor *bp = [[AlfrescoBatchProcessor alloc] initWithCompletionBlock:^(NSDictionary *dictionary, NSDictionary *errors) {
        [expectation fulfill];
        
        // check results
        XCTAssertTrue(dictionary.count == 0, @"Expected the dictionary to contain 0 results but there were: %lu", (unsigned long)dictionary.count);
        XCTAssertTrue(errors.count == 2, @"Expected there to be 2 errors but there were: %lu", (unsigned long)errors.count);
    }];
    
    SleepingUnitOfWork *sleepFor3Seconds = [[SleepingUnitOfWork alloc] initWithKey:@"3"];
    SleepingUnitOfWork *sleepFor5Seconds = [[SleepingUnitOfWork alloc] initWithKey:@"5"];
    
    // add the work
    [bp addUnitOfWork:sleepFor3Seconds];
    [bp addUnitOfWork:sleepFor5Seconds];
    
    // start the processor
    [bp start];
    
    XCTAssertFalse(bp.cancelled, @"Expected the cancelled flag to be false");
    XCTAssertTrue(bp.inProgress, @"Expected the inProgress flag to be true");
    
    // cancel the processor
    [bp cancel];
    
    XCTAssertTrue(bp.cancelled, @"Expected the cancelled flag to be true");
    XCTAssertFalse(bp.inProgress, @"Expected the inProgress flag to be false");
    
    // wait for the future result
    [self waitForExpectationsWithTimeout:60.0 handler:nil];
}

@end
