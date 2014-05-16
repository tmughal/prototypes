//
//  ExamplesViewController.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 15/05/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "ExamplesViewController.h"
#import "JSONEntryViewController.h"

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
    usernameField.required = YES;
    usernameField.placeholderText = requiredString;
    
    AlfrescoFormField *passwordField = [[AlfrescoFormField alloc] initWithIdentifier:@"password" type:AlfrescoFormFieldTypeString value:nil label:@"Password"];
    passwordField.secret = YES;
    passwordField.placeholderText = requiredString;
    
    AlfrescoFormField *serverField = [[AlfrescoFormField alloc] initWithIdentifier:@"server" type:AlfrescoFormFieldTypeString value:nil label:@"Server Address"];
    serverField.required = YES;
    serverField.placeholderText = requiredString;
    
    AlfrescoFormField *descriptionField = [[AlfrescoFormField alloc] initWithIdentifier:@"description" type:AlfrescoFormFieldTypeString value:nil label:@"Description"];
    descriptionField.placeholderText = @"Alfresco Server";
    
    AlfrescoFormField *httpsField = [[AlfrescoFormField alloc] initWithIdentifier:@"https" type:AlfrescoFormFieldTypeBoolean value:@(YES) label:@"HTTPS"];
    
    // settings fields
    AlfrescoFormField *syncField = [[AlfrescoFormField alloc] initWithIdentifier:@"sync" type:AlfrescoFormFieldTypeBoolean value:@(NO) label:@"Sync Favorite Content"];
    
    // advanced fields
    AlfrescoFormField *portField = [[AlfrescoFormField alloc] initWithIdentifier:@"port" type:AlfrescoFormFieldTypeNumber value:@443 label:@"Port"];
    portField.required = YES;
    
    AlfrescoFormField *serviceDocField = [[AlfrescoFormField alloc] initWithIdentifier:@"serviceDocument" type:AlfrescoFormFieldTypeString value:@"/alfresco" label:@"Service Document"];
    serverField.required = YES;
    
    // TODO: change this to a custom picker, use date field for now to show picker interaction
    AlfrescoFormField *clientCertField = [[AlfrescoFormField alloc] initWithIdentifier:@"clientCertificate" type:AlfrescoFormFieldTypeDate value:[NSDate date] label:@"Client Certificate"];
    
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
    AlfrescoFormField *definitionField = [[AlfrescoFormField alloc] initWithIdentifier:@"definition" type:AlfrescoFormFieldTypeString value:nil label:@"Definition"];
    // TODO: Add set of values to pick from
    
    AlfrescoFormField *nameField = [[AlfrescoFormField alloc] initWithIdentifier:@"name" type:AlfrescoFormFieldTypeString value:nil label:@"Name"];
    nameField.required = YES;
    
    AlfrescoFormField *descriptionField = [[AlfrescoFormField alloc] initWithIdentifier:@"description" type:AlfrescoFormFieldTypeString value:nil label:@"Description"];
    
    AlfrescoFormFieldGroup *group = [[AlfrescoFormFieldGroup alloc] initWithIdentifier:@"default"
                                                                                       fields:@[definitionField, nameField, descriptionField]
                                                                                        label:nil];
    
    return [[AlfrescoForm alloc] initWithGroups:@[group] title:@"Add Test"];
}

- (AlfrescoForm *)buildBenchmarkPropertiesForm
{
    // TODO: enable reset button on all fields via control parameter
    // TODO: test the placeholder vs. default value behaviour to get desired effect for benchmark app
    // TODO: add support for email, url, float fields
    // TODO: make use of the field summary property
    
    // test fields
    AlfrescoFormField *nameField = [[AlfrescoFormField alloc] initWithIdentifier:@"name" type:AlfrescoFormFieldTypeString value:nil label:@"Name"];
    
    // mongo fields
    AlfrescoFormField *serverField = [[AlfrescoFormField alloc] initWithIdentifier:@"server" type:AlfrescoFormFieldTypeString value:nil label:@"Server"];
    serverField.placeholderText = @"e.g. localhost";

    
    AlfrescoFormFieldGroup *testGroup = [[AlfrescoFormFieldGroup alloc] initWithIdentifier:@"testProperties"
                                                                                fields:@[nameField]
                                                                                 label:@"Test Settings"];
    
    AlfrescoFormFieldGroup *mongoGroup = [[AlfrescoFormFieldGroup alloc] initWithIdentifier:@"mongoProperties"
                                                                                    fields:@[serverField]
                                                                                     label:@"Mongo Settings"];
    
    return [[AlfrescoForm alloc] initWithGroups:@[testGroup, mongoGroup] title:@"Run Properties"];
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
        if (![field.value isEqual:field.originalValue])
        {
            NSLog(@"field %@ was changed", field.identifier);
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
