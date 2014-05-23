//
//  ExamplesViewController.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 15/05/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "ExamplesViewController.h"
#import "JSONEntryViewController.h"
#import "AlfrescoListOfValuesPickerViewController.h"
#import "AlfrescoFormListOfValuesConstraint.h"
#import "AlfrescoFormMandatoryConstraint.h"

@interface ExamplesViewController ()

@end

@implementation ExamplesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Dynamic Form Examples";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ExampleIdentifier = @"ExampleLink";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ExampleIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ExampleIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"New Account";
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"Add Benchmark Test";
    }
    else if (indexPath.row == 2)
    {
        cell.textLabel.text = @"Start Activiti Task";
    }
    else if (indexPath.row == 3)
    {
        cell.textLabel.text = @"Edit Benchmark Properties";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = nil;
    
    if (indexPath.row == 0)
    {
        viewController = [[AlfrescoFormViewController alloc] initWithForm:[self buildNewAccountForm]];
        ((AlfrescoFormViewController *)viewController).delegate = self;
    }
    else if (indexPath.row == 1)
    {
        viewController = [[AlfrescoFormViewController alloc] initWithForm:[self buildBenchmarkTestForm]];
        ((AlfrescoFormViewController *)viewController).delegate = self;
    }
    else if (indexPath.row == 2)
    {
        viewController = [[JSONEntryViewController alloc] initWithNibName:@"JSONEntryViewController" bundle:nil];
    }
    else if (indexPath.row == 3)
    {
        viewController = [[AlfrescoFormViewController alloc] initWithForm:[self buildBenchmarkPropertiesForm]];
        ((AlfrescoFormViewController *)viewController).delegate = self;
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (AlfrescoForm *)buildNewAccountForm
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

- (AlfrescoForm *)buildBenchmarkTestForm
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

- (AlfrescoForm *)buildBenchmarkPropertiesForm
{
    // TODO: enable reset button on all fields via control parameter
    // TODO: test the placeholder vs. default value behaviour to get desired effect for benchmark app
    // TODO: make use of the field summary property
    
    // general fields
    AlfrescoFormField *processUsernameField = [[AlfrescoFormField alloc] initWithIdentifier:@"processusername" type:AlfrescoFormFieldTypeString value:nil label:@"Process User"];
    processUsernameField.placeholderText = @"admin";
    
    AlfrescoFormField *processPasswordField = [[AlfrescoFormField alloc] initWithIdentifier:@"processpwd" type:AlfrescoFormFieldTypeString value:@"*****" label:@"Process Password"];
    processPasswordField.secret = YES;
    processPasswordField.placeholderText = @"*****";
    
    AlfrescoFormField *processEmailField = [[AlfrescoFormField alloc] initWithIdentifier:@"processemail" type:AlfrescoFormFieldTypeEmail value:nil label:@"Process Email"];
    processEmailField.placeholderText = @"bm@alfresco.com";
    
    AlfrescoFormField *processCountField = [[AlfrescoFormField alloc] initWithIdentifier:@"processcount" type:AlfrescoFormFieldTypeNumber value:nil label:@"Process Count"];
    processCountField.placeholderText = @"200";
    
    AlfrescoFormField *processDelayField = [[AlfrescoFormField alloc] initWithIdentifier:@"processdelay" type:AlfrescoFormFieldTypeNumber value:nil label:@"Process Delay"];
    processDelayField.placeholderText = @"10";
    // TODO: make this a decimal field
    
    // mongo DB fields
    AlfrescoFormField *mongoUsernameField = [[AlfrescoFormField alloc] initWithIdentifier:@"mongousername" type:AlfrescoFormFieldTypeString value:nil label:@"mongo.test.username"];
    mongoUsernameField.placeholderText = @"mongo";
    
    AlfrescoFormField *mongoPasswordField = [[AlfrescoFormField alloc] initWithIdentifier:@"mongopwd" type:AlfrescoFormFieldTypeString value:@"*****" label:@"mongo.test.password"];
    mongoPasswordField.placeholderText = @"*****";
    mongoPasswordField.secret = YES;
    
    AlfrescoFormField *mongoDBField = [[AlfrescoFormField alloc] initWithIdentifier:@"mongodb" type:AlfrescoFormFieldTypeString value:nil label:@"mongo.test.database"];
    mongoDBField.placeholderText = @"bm20-data";
    
    AlfrescoFormField *mongoHostField = [[AlfrescoFormField alloc] initWithIdentifier:@"mongohost" type:AlfrescoFormFieldTypeURL value:nil label:@"mongo.test.host"];
    [mongoHostField addConstraint:[AlfrescoFormMandatoryConstraint new]];
    mongoHostField.placeholderText = @"http://localhost:27127";

    // http fields
    AlfrescoFormField *httpTimeoutField = [[AlfrescoFormField alloc] initWithIdentifier:@"httptimeout" type:AlfrescoFormFieldTypeNumber value:nil label:@"http.connection.timeoutMs"];
    httpTimeoutField.placeholderText = @"10000";
    
    AlfrescoFormField *httpMaxField = [[AlfrescoFormField alloc] initWithIdentifier:@"httpmax" type:AlfrescoFormFieldTypeNumber value:nil label:@"http.connection.max"];
    httpMaxField.placeholderText = @"${events.thread.count}";
    
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

- (void)formViewController:(AlfrescoFormViewController *)viewController didEndEditingOfForm:(AlfrescoForm *)form
{
    NSLog(@"ExamplesViewController::didEndEditingOfForm");
    
    for (AlfrescoFormField *field in form.fields)
    {
        NSLog(@"Value of field %@ is %@", field.identifier, field.value);
    }
    
    for (AlfrescoFormField *field in form.fields)
    {
        if (field.value == nil && field.originalValue == nil)
        {
            continue;
        }
        
        if (![[field.value description] isEqualToString:[field.originalValue description]])
        {
            NSLog(@"field %@ was changed", field.identifier);
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
