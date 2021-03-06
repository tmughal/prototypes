//
//  AddBenchmarkTestFormViewController.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 12/11/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "AddBenchmarkTestFormViewController.h"
#import "AlfrescoFormMandatoryConstraint.h"
#import "AlfrescoFormListOfValuesConstraint.h"

@implementation AddBenchmarkTestFormViewController

#pragma mark - Form view data source

- (AlfrescoForm *)formForFormViewController:(AlfrescoFormViewController *)formViewController
{
    AlfrescoFormField *definitionField = [[AlfrescoFormField alloc] initWithIdentifier:@"testdefinition" type:AlfrescoFormFieldTypeString value:nil label:@"Definition"];
    NSArray *values = @[@"123", @"456", @"789"];
    NSArray *labels = @[@"Sample Test Definition", @"Share Test Definition", @"Cloud Test Definition"];
    AlfrescoFormListOfValuesConstraint *constraint = [[AlfrescoFormListOfValuesConstraint alloc] initWithValues:values labels:labels];
    [definitionField addConstraint:constraint];
    [definitionField addConstraint:[AlfrescoFormMandatoryConstraint new]];
    
    AlfrescoFormField *nameField = [[AlfrescoFormField alloc] initWithIdentifier:@"name" type:AlfrescoFormFieldTypeString value:nil label:@"Name"];
    [nameField addConstraint:[AlfrescoFormMandatoryConstraint new]];
    nameField.placeholderText = @"Test Name";
    
    AlfrescoFormField *descriptionField = [[AlfrescoFormField alloc] initWithIdentifier:@"description" type:AlfrescoFormFieldTypeString value:nil label:@"Description"];
    descriptionField.placeholderText = @"Test Description";
    
    AlfrescoFormFieldGroup *group = [[AlfrescoFormFieldGroup alloc] initWithIdentifier:@"default"
                                                                                fields:@[definitionField, nameField, descriptionField]
                                                                                 label:nil];
    
    return [[AlfrescoForm alloc] initWithGroups:@[group] title:@"Add Test"];
}

#pragma mark - Form view delegate

- (BOOL)shouldShowCancelButtonForFormViewContoller:(AlfrescoFormViewController *)formViewController
{
    return YES;
}

- (void)didCancelEditingOfFormViewController:(AlfrescoFormViewController *)formViewController
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)formViewController:(AlfrescoFormViewController *)formViewController didEndEditingWithOutcome:(NSString *)outcome
{
    NSLog(@"Finished editing form: %@", formViewController.form);
    
    for (AlfrescoFormField *field in formViewController.form.fields)
    {
        NSLog(@"%@ = %@", field.identifier, field.value);
    }
}

@end
