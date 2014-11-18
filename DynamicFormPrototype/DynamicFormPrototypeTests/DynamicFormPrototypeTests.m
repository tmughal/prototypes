//
//  DynamicFormPrototypeTests.m
//  DynamicFormPrototypeTests
//
//  Created by Gavin Cornwell on 09/04/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AlfrescoFormMandatoryConstraint.h"
#import "AlfrescoFormNumberRangeConstraint.h"
#import "AlfrescoFormListOfValuesConstraint.h"
#import "AlfrescoFormMinimumLengthConstraint.h"
#import "AlfrescoFormMaximumLengthConstraint.h"
#import "AlfrescoFormRegexConstraint.h"

@interface DynamicFormPrototypeTests : XCTestCase

@end

@implementation DynamicFormPrototypeTests

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

- (void)testMandatoryConstraints
{
    AlfrescoFormMandatoryConstraint *mandatory = [AlfrescoFormMandatoryConstraint new];
    
    // check default properties
    XCTAssertTrue([mandatory.identifier isEqualToString:kAlfrescoFormConstraintMandatory],
                  @"Expected mandatory constraint identifier to be 'mandatory' but it was %@", mandatory.identifier);
    XCTAssertTrue([mandatory.errorMessage isEqualToString:@"A value is required"],
                  @"Expected mandatory constraint errorMessage to be 'A value is required' but it was %@", mandatory.errorMessage);
    
    // check basic evaluations
    XCTAssertTrue([mandatory evaluate:@"Testing"], @"Expected a string of 'Testing' to be valid");
    XCTAssertTrue([mandatory evaluate:@(50)], @"Expected an NSNumber representing 50 to be valid");
    XCTAssertFalse([mandatory evaluate:@""], @"Expected an empty string be invalid");
    XCTAssertFalse([mandatory evaluate:nil], @"Expected nil to be invalid");
}

- (void)testNumberRangeConstraints
{
    // create a range constraint from 1 to 10
    AlfrescoFormNumberRangeConstraint *numberRange = [[AlfrescoFormNumberRangeConstraint alloc] initWithMinimum:[NSNumber numberWithInt:1]
                                                                                                maximum:[NSNumber numberWithInt:10]];
    
    // check default properties
    XCTAssertTrue([numberRange.identifier isEqualToString:kAlfrescoFormConstraintNumberRange],
                  @"Expected number range constraint identifier to be 'numberRange' but it was %@", numberRange.identifier);
    XCTAssertTrue([numberRange.errorMessage isEqualToString:@"The value must be between 1 and 10"],
                  @"Expected number range constraint errorMessage to be 'The value must be between 1 and 10' but it was: %@", numberRange.errorMessage);
    
    // check valid values
    XCTAssertTrue([numberRange evaluate:@(1)], @"Expected 1 to be valid");
    XCTAssertTrue([numberRange evaluate:@(5)], @"Expected 5 to be valid");
    XCTAssertTrue([numberRange evaluate:@(10)], @"Expected 10 to be valid");
    
    // check invalid values
    XCTAssertFalse([numberRange evaluate:@(0)], @"Expected 0 to be invalid");
    XCTAssertFalse([numberRange evaluate:@(11)], @"Expected 11 to be invalid");
    
    // create a range constraint from 0.0 to 1.0
    numberRange = [[AlfrescoFormNumberRangeConstraint alloc] initWithMinimum:[NSNumber numberWithInt:0]
                                                                     maximum:[NSNumber numberWithInt:1]];
    // check valid values
    XCTAssertTrue([numberRange evaluate:@(0)], @"Expected 0 to be valid");
    XCTAssertTrue([numberRange evaluate:@(0.5)], @"Expected 0.5 to be valid");
    XCTAssertTrue([numberRange evaluate:@(1)], @"Expected 1 to be valid");
    
    // check invalid values
    XCTAssertFalse([numberRange evaluate:@(-1)], @"Expected -1 to be invalid");
    XCTAssertFalse([numberRange evaluate:@(1.1)], @"Expected 1.1 to be invalid");
    XCTAssertFalse([numberRange evaluate:@(2)], @"Expected 2 to be invalid");
}

- (void)testListOfValuesConstraint
{
    // create constraint with list of 3 choices
    NSArray *choices = @[@"choice1", @"choice2", @"choice3"];
    AlfrescoFormListOfValuesConstraint *listOfValues = [[AlfrescoFormListOfValuesConstraint alloc] initWithValues:choices labels:choices];

    // check default properties
    XCTAssertTrue([listOfValues.identifier isEqualToString:kAlfrescoFormConstraintListOfValues],
                  @"Expected list of values constraint identifier to be 'listOfValues' but it was %@", listOfValues.identifier);
    XCTAssertTrue([listOfValues.errorMessage hasPrefix:@"The value must match one of the following values:"],
                  @"Expected list of values constraint errorMessage to start with 'The value must match one of the following values:' but it started with: %@", listOfValues.errorMessage);
    
    // check valid values
    XCTAssertTrue([listOfValues evaluate:@"choice1"], @"Expected choice1 to be a valid value");
    XCTAssertTrue([listOfValues evaluate:@"choice2"], @"Expected choice2 to be a valid value");
    XCTAssertTrue([listOfValues evaluate:@"choice3"], @"Expected choice3 to be a valid value");
    
    // check invalid values
    XCTAssertFalse([listOfValues evaluate:@"choice4"], @"Expected choice4 to be an invalid value");
    XCTAssertFalse([listOfValues evaluate:nil], @"Expected choice4 to be an invalid value");
}

- (void)testMinimumLengthConstraint
{
    // create a min length constraint of 3
    AlfrescoFormMinimumLengthConstraint *minLength = [[AlfrescoFormMinimumLengthConstraint alloc] initWithMinimumLength:[NSNumber numberWithInt:3]];
    
    // check default properties
    XCTAssertTrue([minLength.identifier isEqualToString:kAlfrescoFormConstraintMinimumLength],
                  @"Expected minimum length constraint identifier to be 'minimumLength' but it was %@",
                  minLength.identifier);
    XCTAssertTrue([minLength.errorMessage isEqualToString:@"The value must have a length of at least 3"],
                  @"Expected minumum length constraint errorMessage to be 'The value must have a length of at least 3' but it was: %@",
                  minLength.errorMessage);
    
    // check valid values
    XCTAssertTrue([minLength evaluate:@"Hello"], @"Expected 'Hello' to be valid");
    XCTAssertTrue([minLength evaluate:@"abcdefghijklmnopqrstuvwxyz"], @"Expected 'abcdefghijklmnopqrstuvwxyz' to be valid");
    XCTAssertTrue([minLength evaluate:@"Yes"], @"Expected 'Yes' to be valid");
    XCTAssertTrue([minLength evaluate:@(12345)], @"Expected 12345 to be valid");
    
    // check invalid values
    XCTAssertFalse([minLength evaluate:@"No"], @"Expected 'No' to be invalid");
    XCTAssertFalse([minLength evaluate:@""], @"Expected empty string to be invalid");
    XCTAssertFalse([minLength evaluate:nil], @"Expected nil to be invalid");
    XCTAssertFalse([minLength evaluate:@(12)], @"Expected 12 to be invalid");
}

- (void)testMaximumLengthConstraint
{
    // create a max length constraint of 10
    AlfrescoFormMaximumLengthConstraint *maxLength = [[AlfrescoFormMaximumLengthConstraint alloc] initWithMaximumLength:[NSNumber numberWithInt:10]];
    
    // check default properties
    XCTAssertTrue([maxLength.identifier isEqualToString:kAlfrescoFormConstraintMaximumLength],
                  @"Expected maximum length constraint identifier to be 'maximumLength' but it was %@",
                  maxLength.identifier);
    XCTAssertTrue([maxLength.errorMessage isEqualToString:@"The value must not have a length that exceeds 10"],
                  @"Expected maximum length constraint errorMessage to be 'The value must not have a length that exceeds 10' but it was: %@",
                  maxLength.errorMessage);
    
    // check valid values
    XCTAssertTrue([maxLength evaluate:@"Hello"], @"Expected 'Hello' to be valid");
    XCTAssertTrue([maxLength evaluate:@"0123456789"], @"Expected '0123456789' to be valid");
    XCTAssertTrue([maxLength evaluate:nil], @"Expected nil to be valid");
    XCTAssertTrue([maxLength evaluate:@(12345)], @"Expected 12345 to be valid");
    
    // check invalid values
    XCTAssertFalse([maxLength evaluate:@"abcdefghijklmnopqrstuvwxyz"], @"Expected 'abcdefghijklmnopqrstuvwxyz' to be invalid");
    XCTAssertFalse([maxLength evaluate:@(12345678909876)], @"Expected 12345678909876 to be valid");
}

- (void)testRegexConstraint
{
    // create a letters only regex constraint
    NSRegularExpression *expression = [[NSRegularExpression alloc] initWithPattern:@"^[A-Za-z]+$" options:NSRegularExpressionCaseInsensitive error:nil];
    AlfrescoFormRegexConstraint *regex = [[AlfrescoFormRegexConstraint alloc] initWithRegex:expression];
    
    // check default properties
    XCTAssertTrue([regex.identifier isEqualToString:kAlfrescoFormConstraintRegex],
                  @"Expected regex constraint identifier to be 'regex' but it was %@", regex.identifier);
    XCTAssertTrue([regex.errorMessage isEqualToString:@"The value must match the pattern ^[A-Za-z]+$"],
                  @"Expected regex constraint errorMessage to be 'The value of this field must match the pattern ^[A-Za-z]+$' but it was: %@",
                  regex.errorMessage);
    
    // change the error message
    regex.errorMessage = @"The value of this field can only contain letters";
    
    // check new error message
    XCTAssertTrue([regex.errorMessage isEqualToString:@"The value of this field can only contain letters"],
                  @"Expected regex constraint errorMessage to be 'The value of this field can only contain letters' but it was: %@",
                  regex.errorMessage);
    
    // check valid values
    XCTAssertTrue([regex evaluate:@"Hello"], @"Expected 'Hello' to be valid");
    XCTAssertTrue([regex evaluate:@"abcdefghijklmnopqrstuvwxyz"], @"Expected 'abcdefghijklmnopqrstuvwxyz' to be valid");
    
    // check invalid values
    XCTAssertFalse([regex evaluate:@"123"], @"Expected '123' to be invalid");
    XCTAssertFalse([regex evaluate:@"l3tt3r5"], @"Expected 'l3tt3r5' to be invalid");
    XCTAssertFalse([regex evaluate:@"This is a sentence."], @"Expected 'This is a sentence.' to be invalid");
    XCTAssertFalse([regex evaluate:@""], @"Expected empty string to be invalid");
    XCTAssertFalse([regex evaluate:nil], @"Expected nil to be invalid");
}

@end
