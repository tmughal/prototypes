//
//  AdvancedFormViewController.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 13/11/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "AdvancedFormViewController.h"
#import "AlfrescoFormMandatoryConstraint.h"

@implementation AdvancedFormViewController

#pragma mark - Form view data source

- (AlfrescoForm *)formForFormViewController:(AlfrescoFormViewController *)formViewController
{
    AlfrescoFormField *nameField = [[AlfrescoFormField alloc] initWithIdentifier:@"name" type:AlfrescoFormFieldTypeString value:nil label:@"Name"];
    [nameField addConstraint:[AlfrescoFormMandatoryConstraint new]];
    nameField.placeholderText = @"Test Name";
    
    AlfrescoFormField *descriptionField = [[AlfrescoFormField alloc] initWithIdentifier:@"description" type:AlfrescoFormFieldTypeString value:nil label:@"Description"];
    descriptionField.placeholderText = @"Test Description";
    
    AlfrescoFormFieldGroup *group = [[AlfrescoFormFieldGroup alloc] initWithIdentifier:@"default"
                                                                                fields:@[nameField, descriptionField]
                                                                                 label:nil];
    
    return [[AlfrescoForm alloc] initWithGroups:@[group] title:@"Advanced" outcomes:@[@"Reject", @"Accept"]];
}

#pragma mark - Form view delegate

- (void)formViewController:(AlfrescoFormViewController *)formViewController didEndEditingWithOutcome:(NSString *)outcome
{
    NSLog(@"Finished editing form with outcome: %@", outcome);
}

@end
