//
//  JSONEntryViewController.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 16/05/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "JSONEntryViewController.h"
#import "AlfrescoFormViewController.h"

@interface JSONEntryViewController ()

@end

@implementation JSONEntryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonClicked:)];
    self.title = @"Edit JSON";
}

#pragma mark - Event handlers

- (void)doneButtonClicked:(id)sender
{
    AlfrescoForm *form = [self buildFormFromJSON];
    
    if (form != nil)
    {
        AlfrescoFormViewController *formViewController = [[AlfrescoFormViewController alloc] initWithForm:form];
        formViewController.delegate = self;
        [self.navigationController pushViewController:formViewController animated:YES];
    }
    else
    {
        UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Parse Error"
                                                               message:@"Failed to generate form from JSON."
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil, nil];
        [failureAlert show];
    }
}

#pragma mark - Helper methods

- (AlfrescoForm *)buildFormFromJSON
{
    AlfrescoForm *form = nil;
    
    // parse the JSON
    NSError *serialisationError = nil;
    NSData *jsonData = [self.textView.text dataUsingEncoding:NSUTF8StringEncoding];
    id jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&serialisationError];
    
    if (!serialisationError)
    {
        NSArray *data = jsonDictionary[@"data"];
        NSDictionary *dataObject = data[0];
        NSDictionary *jsonFormProperties = dataObject[@"formProperties"];
        
        NSMutableArray *fields = [NSMutableArray array];
        
        for (NSDictionary *jsonProperty in jsonFormProperties)
        {
            NSString *identifier = jsonProperty[@"id"];
            NSString *name = jsonProperty[@"name"];
            NSString *type = jsonProperty[@"type"];
            id value = jsonProperty[@"value"];
//            BOOL readable = [jsonProperty[@"readable"] boolValue];
//            BOOL writable = [jsonProperty[@"writable"] boolValue];
            BOOL required = [jsonProperty[@"required"] boolValue];
//            NSArray *listOfValues = jsonProperty[@"enumValues"];
            
            if ([value isKindOfClass:[NSNull class]])
            {
                value = nil;
            }
            
            AlfrescoFormField *field = [[AlfrescoFormField alloc] initWithIdentifier:identifier
                                                                                type:[AlfrescoFormField enumForTypeString:type]
                                                                               value:value label:name];
            field.required = required;
            
            [fields addObject:field];
        }
        
        AlfrescoFormFieldGroup *group = [[AlfrescoFormFieldGroup alloc] initWithIdentifier:@"default"
                                                                                    fields:fields
                                                                                     label:nil];
        form = [[AlfrescoForm alloc] initWithGroups:@[group] title:@"Start Task"];
    }
    
    return form;
}

#pragma mark - AlfrescoFormViewControllerDelegate

- (void)formViewController:(AlfrescoFormViewController *)viewController didEndEditingOfForm:(AlfrescoForm *)form
{
    NSLog(@"JSONEntryViewController::didEndEditingOfForm");
    
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
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
