//
//  RetrieveActivitiTaskFormViewController.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 12/11/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "RetrieveActivitiTaskFormViewController.h"
#import "AlfrescoFormMandatoryConstraint.h"
#import "ActivitiTaskFormViewController.h"

@implementation RetrieveActivitiTaskFormViewController

#pragma mark - Form view data source

- (AlfrescoForm *)formForFormView:(AlfrescoFormView *)formView
{
    AlfrescoFormField *usernameField = [[AlfrescoFormField alloc] initWithIdentifier:@"username" type:AlfrescoFormFieldTypeString value:@"admin@app.activiti.com" label:@"Username"];
    [usernameField addConstraint:[AlfrescoFormMandatoryConstraint new]];
    
    AlfrescoFormField *passwordField = [[AlfrescoFormField alloc] initWithIdentifier:@"password" type:AlfrescoFormFieldTypeString value:@"cherok33" label:@"Password"];
    passwordField.secret = YES;
    [passwordField addConstraint:[AlfrescoFormMandatoryConstraint new]];
    
    AlfrescoFormField *appUrlField = [[AlfrescoFormField alloc] initWithIdentifier:@"appUrl" type:AlfrescoFormFieldTypeURL value:@"http://localhost:7777/rest/app" label:@"URL"];
    [appUrlField addConstraint:[AlfrescoFormMandatoryConstraint new]];
    
    AlfrescoFormField *taskIdField = [[AlfrescoFormField alloc] initWithIdentifier:@"taskId" type:AlfrescoFormFieldTypeNumber value:nil label:@"Task ID"];
    [taskIdField addConstraint:[AlfrescoFormMandatoryConstraint new]];
    
    AlfrescoFormFieldGroup *group = [[AlfrescoFormFieldGroup alloc] initWithIdentifier:@"default"
                                                                                fields:@[usernameField, passwordField, appUrlField, taskIdField]
                                                                                 label:nil];
    
    return [[AlfrescoForm alloc] initWithGroups:@[group] title:@"Task Details"];
}

#pragma mark - Form view delegate

- (void)formView:(AlfrescoFormView *)formView didEndEditingOfForm:(AlfrescoForm *)form withOutcome:(NSString *)outcome
{
    NSString *username = [form fieldWithIdentifier:@"username"].value;
    NSString *password = [form fieldWithIdentifier:@"password"].value;
    NSString *appUrl = [form fieldWithIdentifier:@"appUrl"].value;
    NSNumber *taskId = [form fieldWithIdentifier:@"taskId"].value;
    
    ActivitiTaskFormViewController *taskFormVC = [[ActivitiTaskFormViewController alloc] initWithTaskId:taskId
                                                                                               username:username
                                                                                               password:password
                                                                                                 appURL:[NSURL URLWithString:appUrl]];
    taskFormVC.loadFormAsynchronously = YES;
    
    // push view controller
    [self.navigationController pushViewController:taskFormVC animated:YES];
}


@end
