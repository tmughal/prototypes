//
//  NewAccountFormViewController.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 12/11/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "NewAccountFormViewController.h"
#import "AlfrescoFormMandatoryConstraint.h"

@implementation NewAccountFormViewController

#pragma mark - Form view data source

- (AlfrescoForm *)formForFormView:(AlfrescoFormView *)formView
{
    NSString *requiredString = @"Required";
    NSString *syncSummaryString = @"Select to sync favorited content to your device. A warning will be displayed before syncing content over 20MB";
    
    // account details fields
    AlfrescoFormField *usernameField = [[AlfrescoFormField alloc] initWithIdentifier:@"username" type:AlfrescoFormFieldTypeString value:nil label:@"Username"];
    [usernameField addConstraint:[AlfrescoFormMandatoryConstraint new]];
    usernameField.placeholderText = requiredString;
    
    AlfrescoFormField *passwordField = [[AlfrescoFormField alloc] initWithIdentifier:@"password" type:AlfrescoFormFieldTypeString value:nil label:@"Password"];
    [passwordField addConstraint:[AlfrescoFormMandatoryConstraint new]];
    passwordField.secret = YES;
    passwordField.placeholderText = requiredString;
    
    AlfrescoFormField *serverField = [[AlfrescoFormField alloc] initWithIdentifier:@"server" type:AlfrescoFormFieldTypeString value:nil label:@"Server Address"];
    [serverField addConstraint:[AlfrescoFormMandatoryConstraint new]];
    serverField.placeholderText = requiredString;
    
    AlfrescoFormField *descriptionField = [[AlfrescoFormField alloc] initWithIdentifier:@"description" type:AlfrescoFormFieldTypeString value:nil label:@"Description"];
    descriptionField.placeholderText = @"Alfresco Server";
    
    AlfrescoFormField *httpsField = [[AlfrescoFormField alloc] initWithIdentifier:@"https" type:AlfrescoFormFieldTypeBoolean value:@(YES) label:@"HTTPS"];
    
    // settings fields
    AlfrescoFormField *syncField = [[AlfrescoFormField alloc] initWithIdentifier:@"sync" type:AlfrescoFormFieldTypeBoolean value:@(NO) label:@"Sync Favorite Content"];
    
    // advanced fields
    AlfrescoFormField *portField = [[AlfrescoFormField alloc] initWithIdentifier:@"port" type:AlfrescoFormFieldTypeNumber value:@443 label:@"Port"];
    [portField addConstraint:[AlfrescoFormMandatoryConstraint new]];
    
    AlfrescoFormField *serviceDocField = [[AlfrescoFormField alloc] initWithIdentifier:@"serviceDocument" type:AlfrescoFormFieldTypeString value:@"/alfresco" label:@"Service Document"];
    [serverField addConstraint:[AlfrescoFormMandatoryConstraint new]];
    
    AlfrescoFormField *clientCertField = [[AlfrescoFormField alloc] initWithIdentifier:@"clientCertificate" type:AlfrescoFormFieldTypeCustom value:@"Custom Field" label:@"Client Certificate"];
    
    // account details group
    AlfrescoFormFieldGroup *accountGroup = [[AlfrescoFormFieldGroup alloc] initWithIdentifier:@"accountdetails"
                                                                                       fields:@[usernameField, passwordField, serverField, descriptionField, httpsField]
                                                                                        label:@"Account Details"];
    
    // settings group
    AlfrescoFormFieldGroup *settingsGroup = [[AlfrescoFormFieldGroup alloc] initWithIdentifier:@"settings"
                                                                                        fields:@[syncField]
                                                                                         label:@"Settings"
                                                                                       summary:syncSummaryString];
    
    // advanced group
    AlfrescoFormFieldGroup *advancedGroup = [[AlfrescoFormFieldGroup alloc] initWithIdentifier:@"advanced"
                                                                                        fields:@[portField, serviceDocField, clientCertField]
                                                                                         label:@"Advanced"];
    
    // create form
    return [[AlfrescoForm alloc] initWithGroups:@[accountGroup, settingsGroup, advancedGroup] title:@"New Account"];
}

#pragma mark - Form view delegate

- (void)formView:(AlfrescoFormView *)formView didEndEditingOfForm:(AlfrescoForm *)form withOutcome:(NSString *)outcome
{
    NSLog(@"Finished editing form: %@", form);
    
    for (AlfrescoFormField *field in form.fields)
    {
        NSLog(@"%@ = %@", field.identifier, field.value);
    }
}

- (BOOL)formView:(AlfrescoFormView *)formView canPersistForm:(AlfrescoForm *)form
{
    NSLog(@"Checking whether form can be persisted");
    
    return YES;
}

@end
