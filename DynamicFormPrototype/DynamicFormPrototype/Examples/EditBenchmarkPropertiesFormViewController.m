//
//  EditBenchmarkPropertiesFormViewController.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 12/11/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "EditBenchmarkPropertiesFormViewController.h"
#import "AlfrescoFormMandatoryConstraint.h"

@implementation EditBenchmarkPropertiesFormViewController

#pragma mark - Form view data source

- (AlfrescoForm *)formForFormViewController:(AlfrescoFormViewController *)formViewController
{
    NSDictionary *commonControlParameters = @{kAlfrescoFormControlParameterAllowReset: @YES,
                                              kAlfrescoFormControlParameterShowBorder: @YES,
                                              kAlfrescoFormControlParameterTextAlignment: @"right"};
    
    // general fields
    AlfrescoFormField *processUsernameField = [[AlfrescoFormField alloc] initWithIdentifier:@"processusername" type:AlfrescoFormFieldTypeString value:@"user" label:@"Process User"];
    processUsernameField.placeholderText = @"admin";
    processUsernameField.controlParameters = commonControlParameters;
    
    AlfrescoFormField *processPasswordField = [[AlfrescoFormField alloc] initWithIdentifier:@"processpwd" type:AlfrescoFormFieldTypeString value:@"*****" label:@"Process Password"];
    processPasswordField.placeholderText = @"*****";
    processPasswordField.controlParameters = @{kAlfrescoFormControlParameterAllowReset: @YES,
                                               kAlfrescoFormControlParameterShowBorder: @YES,
                                               kAlfrescoFormControlParameterSecret: @YES,
                                               kAlfrescoFormControlParameterTextAlignment: @"right"};
    
    AlfrescoFormField *processEmailField = [[AlfrescoFormField alloc] initWithIdentifier:@"processemail" type:AlfrescoFormFieldTypeEmail value:nil label:@"Process Email"];
    processEmailField.placeholderText = @"bm@alfresco.com";
    processEmailField.controlParameters = commonControlParameters;
    
    AlfrescoFormField *processCountField = [[AlfrescoFormField alloc] initWithIdentifier:@"processcount" type:AlfrescoFormFieldTypeNumber value:nil label:@"Process Count"];
    processCountField.placeholderText = @"200";
    processCountField.controlParameters = commonControlParameters;
    
    AlfrescoFormField *processDelayField = [[AlfrescoFormField alloc] initWithIdentifier:@"processdelay" type:AlfrescoFormFieldTypeNumber value:nil label:@"Process Delay"];
    processDelayField.placeholderText = @"0.5";
    processDelayField.controlParameters = @{kAlfrescoFormControlParameterAllowDecimals: @YES,
                                            kAlfrescoFormControlParameterAllowReset: @YES,
                                            kAlfrescoFormControlParameterShowBorder: @YES,
                                            kAlfrescoFormControlParameterTextAlignment: @"right"};
    
    // mongo DB fields
    AlfrescoFormField *mongoUsernameField = [[AlfrescoFormField alloc] initWithIdentifier:@"mongousername" type:AlfrescoFormFieldTypeString value:nil label:@"mongo.test.username"];
    mongoUsernameField.placeholderText = @"mongo";
    mongoUsernameField.controlParameters = commonControlParameters;
    
    AlfrescoFormField *mongoPasswordField = [[AlfrescoFormField alloc] initWithIdentifier:@"mongopwd" type:AlfrescoFormFieldTypeString value:@"*****" label:@"mongo.test.password"];
    mongoPasswordField.placeholderText = @"*****";
    mongoPasswordField.controlParameters = commonControlParameters;
    mongoPasswordField.controlParameters = @{kAlfrescoFormControlParameterAllowReset: @YES,
                                             kAlfrescoFormControlParameterShowBorder: @YES,
                                             kAlfrescoFormControlParameterSecret: @YES,
                                             kAlfrescoFormControlParameterTextAlignment: @"right"};
    
    AlfrescoFormField *mongoDBField = [[AlfrescoFormField alloc] initWithIdentifier:@"mongodb" type:AlfrescoFormFieldTypeString value:nil label:@"mongo.test.database"];
    mongoDBField.placeholderText = @"bm20-data";
    mongoDBField.controlParameters = commonControlParameters;
    
    AlfrescoFormField *mongoHostField = [[AlfrescoFormField alloc] initWithIdentifier:@"mongohost" type:AlfrescoFormFieldTypeURL value:nil label:@"mongo.test.host"];
    [mongoHostField addConstraint:[AlfrescoFormMandatoryConstraint new]];
    mongoHostField.placeholderText = @"http://localhost:27127";
    mongoHostField.controlParameters = commonControlParameters;
    
    // http fields
    AlfrescoFormField *httpTimeoutField = [[AlfrescoFormField alloc] initWithIdentifier:@"httptimeout" type:AlfrescoFormFieldTypeNumber value:nil label:@"http.connection.timeoutMs"];
    httpTimeoutField.placeholderText = @"10000";
    httpTimeoutField.controlParameters = commonControlParameters;
    
    AlfrescoFormField *httpMaxField = [[AlfrescoFormField alloc] initWithIdentifier:@"httpmax" type:AlfrescoFormFieldTypeNumber value:nil label:@"http.connection.max"];
    httpMaxField.placeholderText = @"${events.thread.count}";
    httpMaxField.controlParameters = commonControlParameters;
    
    // scheduling fields
    double seconds = [[NSDate date] timeIntervalSince1970] - 86400;
    NSDate *pastDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    AlfrescoFormField *startOnField = [[AlfrescoFormField alloc] initWithIdentifier:@"starton" type:AlfrescoFormFieldTypeDate value:pastDate label:@"Start On"];
    AlfrescoFormField *dueByField = [[AlfrescoFormField alloc] initWithIdentifier:@"dueby" type:AlfrescoFormFieldTypeDateTime value:[NSDate date] label:@"Due By"];
    
    // groups
    AlfrescoFormFieldGroup *generalGroup = [[AlfrescoFormFieldGroup alloc] initWithIdentifier:@"general"
                                                                                       fields:@[processUsernameField, processPasswordField, processEmailField, processCountField, processDelayField]
                                                                                        label:@"General"];
    
    AlfrescoFormFieldGroup *mongoGroup = [[AlfrescoFormFieldGroup alloc] initWithIdentifier:@"mongoProperties"
                                                                                     fields:@[mongoUsernameField, mongoPasswordField, mongoDBField, mongoHostField]
                                                                                      label:@"MongoDB Connection"];
    
    AlfrescoFormFieldGroup *httpGroup = [[AlfrescoFormFieldGroup alloc] initWithIdentifier:@"http"
                                                                                    fields:@[httpTimeoutField, httpMaxField]
                                                                                     label:@"Http Connections"];
    
    AlfrescoFormFieldGroup *schedulingGroup = [[AlfrescoFormFieldGroup alloc] initWithIdentifier:@"scheduling"
                                                                                          fields:@[startOnField, dueByField]
                                                                                           label:@"Scheduling"];
    
    return [[AlfrescoForm alloc] initWithGroups:@[generalGroup, mongoGroup, httpGroup, schedulingGroup] title:@"Edit Properties"];
}

#pragma mark - Form view delegate

- (void)formViewController:(AlfrescoFormViewController *)formViewController didEndEditingWithOutcome:(NSString *)outcome
{
    NSLog(@"Finished editing form: %@", formViewController.form);
    
    for (AlfrescoFormField *field in formViewController.form.fields)
    {
        NSLog(@"%@ = %@", field.identifier, field.value);
    }
}

@end
