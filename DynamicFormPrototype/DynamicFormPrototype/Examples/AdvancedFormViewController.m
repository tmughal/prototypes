//
//  AdvancedFormViewController.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 13/11/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "AdvancedFormViewController.h"
#import "AlfrescoFormMandatoryConstraint.h"
#import "AlfrescoFormNumberRangeConstraint.h"
#import "AlfrescoFormMinimumLengthConstraint.h"
#import "AlfrescoFormMaximumLengthConstraint.h"
#import "AlfrescoFormRegexConstraint.h"

@implementation AdvancedFormViewController

#pragma mark - Form view data source

- (AlfrescoForm *)formForFormViewController:(AlfrescoFormViewController *)formViewController
{
    AlfrescoFormField *nameField = [[AlfrescoFormField alloc] initWithIdentifier:@"name" type:AlfrescoFormFieldTypeString value:nil label:@"Name"];
    [nameField addConstraint:[AlfrescoFormMandatoryConstraint new]];
    nameField.placeholderText = @"Test Name";
    
    AlfrescoFormField *descriptionField = [[AlfrescoFormField alloc] initWithIdentifier:@"description" type:AlfrescoFormFieldTypeString value:nil label:@"Description"];
    descriptionField.placeholderText = @"Test Description";
    
    // define a hidden field
    AlfrescoFormField *hiddenField = [[AlfrescoFormField alloc] initWithIdentifier:@"hidden" type:AlfrescoFormFieldTypeHidden value:@"hidden value" label:nil];
    
    // define a field with number range constraint
    AlfrescoFormField *rangeField = [[AlfrescoFormField alloc] initWithIdentifier:@"range" type:AlfrescoFormFieldTypeNumber value:nil label:@"Range 0-100"];
    [rangeField addConstraint:[[AlfrescoFormNumberRangeConstraint alloc] initWithMinimum:@(0) maximum:@(100)]];
    
    // define a field with min length constraint
    AlfrescoFormField *minField = [[AlfrescoFormField alloc] initWithIdentifier:@"min" type:AlfrescoFormFieldTypeString value:nil label:@"Min of 5"];
    [minField addConstraint:[[AlfrescoFormMinimumLengthConstraint alloc] initWithMinimumLength:@(5)]];
    
    // define a field with max length constraint
    AlfrescoFormField *maxField = [[AlfrescoFormField alloc] initWithIdentifier:@"max" type:AlfrescoFormFieldTypeString value:nil label:@"Max of 5"];
    [maxField addConstraint:[[AlfrescoFormMaximumLengthConstraint alloc] initWithMaximumLength:@(5)]];
    
    // define a field with regex constraint
    AlfrescoFormField *regexField = [[AlfrescoFormField alloc] initWithIdentifier:@"regex" type:AlfrescoFormFieldTypeString value:nil label:@"Letters"];
    NSRegularExpression *expression = [[NSRegularExpression alloc] initWithPattern:@"^[A-Za-z]+$" options:NSRegularExpressionCaseInsensitive error:nil];
    [regexField addConstraint:[[AlfrescoFormRegexConstraint alloc] initWithRegex:expression]];
    
    // define a field with multiple constraints
    AlfrescoFormField *phoneField = [[AlfrescoFormField alloc] initWithIdentifier:@"phone" type:AlfrescoFormFieldTypeString value:nil label:@"Phone No"];
    [phoneField addConstraint:[[AlfrescoFormMinimumLengthConstraint alloc] initWithMinimumLength:@(6)]];
    [phoneField addConstraint:[[AlfrescoFormMaximumLengthConstraint alloc] initWithMaximumLength:@(12)]];
    expression = [[NSRegularExpression alloc] initWithPattern:@"^[0-9 -]+$" options:NSRegularExpressionCaseInsensitive error:nil];
    [phoneField addConstraint:[[AlfrescoFormRegexConstraint alloc] initWithRegex:expression]];
    
    AlfrescoFormFieldGroup *general = [[AlfrescoFormFieldGroup alloc] initWithIdentifier:@"general"
                                                                                  fields:@[nameField, hiddenField, descriptionField]
                                                                                   label:@"General"];
    
    AlfrescoFormFieldGroup *constraints = [[AlfrescoFormFieldGroup alloc] initWithIdentifier:@"constraints"
                                                                                  fields:@[rangeField, minField, maxField, regexField, phoneField]
                                                                                   label:@"Constraints"];
    
    return [[AlfrescoForm alloc] initWithGroups:@[general, constraints] title:@"Advanced" outcomes:@[@"Reject", @"Accept"]];
}

#pragma mark - Form view delegate

- (void)formViewController:(AlfrescoFormViewController *)formViewController didEndEditingWithOutcome:(NSString *)outcome
{
    NSLog(@"Finished editing form with outcome: %@", outcome);
    
    for (AlfrescoFormField *field in formViewController.form.fields)
    {
        NSLog(@"%@ = %@", field.identifier, field.value);
    }
}

@end
