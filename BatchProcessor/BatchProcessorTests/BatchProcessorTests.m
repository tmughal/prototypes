//
//  BatchProcessorTests.m
//  BatchProcessorTests
//
//  Created by Gavin Cornwell on 16/10/2014.
//  Copyright (c) 2014 Alfresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BatchProcessor.h"

@interface BatchProcessorTests : XCTestCase

@end

@implementation BatchProcessorTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSeparateUnitsOfWork
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Future result expectation"];
    
    BatchProcessor *bp = [[BatchProcessor alloc] initWithCompletionBlock:^(NSDictionary *dictionary, NSDictionary *errors) {
        [expectation fulfill];
//        NSLog(@"result is: %@", dictionary);
        XCTAssertNotNil(dictionary, @"Expected the dictionary to be returned");
        XCTAssertTrue(dictionary.count == 3, @"Expected the dictionary to contain 3 results");
        XCTAssertTrue(errors.count == 1, @"Expected there to be 1 error");
    }];
    
    __weak BatchProcessor *weakBp = bp;
    [bp addUnitOfWork:^{
        [self retrieveHomePageOfSite:[NSURL URLWithString:@"http://www.google.com"] completionBlock:^(NSString *homePageHtml, NSError *error) {
            [weakBp storeUnitOfWorkResult:(error ? error : homePageHtml) withKey:@"google"];
        }];
    }];
    
    [bp addUnitOfWork:^{
        [self retrieveHomePageOfSite:[NSURL URLWithString:@"http://www.apple.com"] completionBlock:^(NSString *homePageHtml, NSError *error) {
            [weakBp storeUnitOfWorkResult:(error ? error : homePageHtml) withKey:@"apple"];
        }];
    }];
    
    [bp addUnitOfWork:^{
        [self retrieveHomePageOfSite:[NSURL URLWithString:@"http://www.microsoft.com"] completionBlock:^(NSString *homePageHtml, NSError *error) {
            [weakBp storeUnitOfWorkResult:(error ? error : homePageHtml) withKey:@"microsoft"];
        }];
    }];
    
    [bp addUnitOfWork:^{
        [self retrieveHomePageOfSite:[NSURL URLWithString:@"http://localhost"] completionBlock:^(NSString *homePageHtml, NSError *error) {
            [weakBp storeUnitOfWorkResult:(error ? error : homePageHtml) withKey:@"localhost"];
        }];
    }];
    
    // start the processor
    [bp start];
    
    // wait for the future result
    [self waitForExpectationsWithTimeout:35.0 handler:nil];
}

- (void)testParameterisedUnitOfWork
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Future result expectation"];
    
    BatchProcessor *bp = [[BatchProcessor alloc] initWithCompletionBlock:^(NSDictionary *dictionary, NSDictionary *errors) {
        [expectation fulfill];
//        NSLog(@"result is: %@", dictionary);
        XCTAssertNotNil(dictionary, @"Expected the dictionary to be returned");
        XCTAssertTrue(dictionary.count == 3, @"Expected the dictionary to contain 3 results but there were %lu", (unsigned long)dictionary.count);
        XCTAssertTrue(errors.count == 1, @"Expected there to be 1 error but there were %lu", (unsigned long)errors.count);
    }];
    
    NSArray *homePages = @[@"http://www.google.com", @"http://www.apple.com", @"http://www.microsoft.com", @"http://localhost"];
    
    __weak BatchProcessor *weakBp = bp;
    [bp addParameterisedUnitOfWork:^(id parameter) {
        NSURL *url = [NSURL URLWithString:parameter];
        [self retrieveHomePageOfSite:url completionBlock:^(NSString *homePageHtml, NSError *error) {
            [weakBp storeUnitOfWorkResult:(error ? error : homePageHtml) withKey:parameter];
        }];
    } forParameters:homePages];
    
    // start the processor
    [bp start];
    
    // wait for the future result
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)retrieveHomePageOfSite:(NSURL *)url completionBlock:(void (^)(NSString *homePageHtml, NSError *error))completionBlock
{
    NSLog(@"Retrieving homepage for %@ on thread %@", url, [NSThread currentThread]);
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
        }
        else
        {
            NSLog(@"Retrieved homepage for %@ on thread %@", url, [NSThread currentThread]);
            
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            completionBlock(responseString, nil);
        }
    }] resume];
}

@end
