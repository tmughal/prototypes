//
//  ActivitiTaskFormRequestDelegate.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 24/06/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "ActivitiTaskFormRequestDelegate.h"
#import "AlfrescoFormMandatoryConstraint.h"
#import "AlfrescoFormListOfValuesConstraint.h"
#import "ActivitiTaskFormDelegate.h"

@interface ActivitiTaskFormRequestDelegate ()
@property (nonatomic, strong) ActivitiTaskFormDelegate *formDelegate;
@end

@implementation ActivitiTaskFormRequestDelegate

// Informs the delegate the user pressed the "Done" button
- (void)formViewController:(AlfrescoFormViewController *)viewController didEndEditingOfForm:(AlfrescoForm *)form
{
    NSString *username = [form fieldWithIdentifier:@"username"].value;
    NSString *password = [form fieldWithIdentifier:@"password"].value;
    NSString *appUrl = [form fieldWithIdentifier:@"appUrl"].value;
    NSNumber *taskId = [form fieldWithIdentifier:@"taskId"].value;
    
    NSString *appAuthUrl = [appUrl stringByAppendingString:@"/authentication"];
    
    // use username/password to build body
    NSString *body = [NSString stringWithFormat:@"j_username=%@&j_password=%@&_spring_security_remember_me=true", [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *authRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:appAuthUrl]];
    authRequest.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    authRequest.HTTPMethod = @"POST";
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:authRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *authError) {
        
        long statusCode = (long)((NSHTTPURLResponse*)response).statusCode;
        NSLog(@"status code = %ld", statusCode);
        
        if (data != nil && statusCode != 401)
        {
            NSDictionary *headers = ((NSHTTPURLResponse*)response).allHeaderFields;
            NSString *cookie = headers[@"Set-Cookie"];
            NSLog(@"cookie = %@", cookie);
            
            // request the form JSON
            NSString *taskFormUrl = [appUrl stringByAppendingFormat:@"/rest/task-forms/%@", taskId];
            
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
            [config setHTTPAdditionalHeaders:@{@"Cookie": cookie}];
            NSURLSession *authenticatedSession = [NSURLSession sessionWithConfiguration:config];
            [[authenticatedSession dataTaskWithURL:[NSURL URLWithString:taskFormUrl]
                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *formError) {
                
                if (data != nil)
                {
                    // parse JSON into Form objects
                    NSError *parseError = nil;
                    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                    
                    if (parseError == nil)
                    {
                        AlfrescoForm *form = [self parseFormFromJSON:json];
                    
                        // create form view controller
                        AlfrescoFormViewController *formController = [[AlfrescoFormViewController alloc] initWithForm:form];
                        self.formDelegate = [ActivitiTaskFormDelegate new];
                        self.formDelegate.cookie = cookie;
                        self.formDelegate.taskUrl = taskFormUrl;
                        formController.delegate = self.formDelegate;
                        
                        // push view controller on main thread
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [viewController.navigationController pushViewController:formController animated:YES];
                        });
                    }
                    else
                    {
                        UIAlertView *parseErrorAlert = [[UIAlertView alloc] initWithTitle:@"JSON Parse Failed"
                                                                            message:[parseError localizedDescription]
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil, nil];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [parseErrorAlert show];
                        });
                    }
                }
                else
                {
                    UIAlertView *formErrorAlert = [[UIAlertView alloc] initWithTitle:@"Form Retrieval Failed"
                                                                        message:[formError localizedDescription]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil, nil];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [formErrorAlert show];
                    });
                }
            }] resume];
        }
        else
        {
            UIAlertView *authErrorAlert = [[UIAlertView alloc] initWithTitle:@"Authentication Failed"
                                                                message:[authError localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];

            dispatch_async(dispatch_get_main_queue(), ^{
                [authErrorAlert show];
            });
        }
    }] resume];
}

- (AlfrescoForm *)parseFormFromJSON:(NSDictionary *)json
{
    NSString *currentGroupId = @"default";
    NSString *currentGroupTitle = nil;
    NSMutableArray *currentGroupFields = [NSMutableArray array];
    NSMutableArray *groups = [NSMutableArray array];
    
    NSArray *fields = json[@"fields"];
    for (NSDictionary *field in fields)
    {
        NSString *type = field[@"type"];
        if ([type isEqualToString:@"group"])
        {
            // create current group and reset holding objects
            if (currentGroupFields.count > 0)
            {
                AlfrescoFormFieldGroup *fieldGroup = [[AlfrescoFormFieldGroup alloc] initWithIdentifier:currentGroupId fields:currentGroupFields label:currentGroupTitle];
                [groups addObject:fieldGroup];
                
                // get next group details
                currentGroupFields = [NSMutableArray array];
                currentGroupId = field[@"id"];
                currentGroupTitle = field[@"name"];
            }
        }
        else
        {
            AlfrescoFormField *formField = [self fieldFromDictionary:field];
            [currentGroupFields addObject:formField];
        }
    }
    
    // add the last group of fields
    if (currentGroupFields.count > 0)
    {
        AlfrescoFormFieldGroup *fieldGroup = [[AlfrescoFormFieldGroup alloc] initWithIdentifier:currentGroupId fields:currentGroupFields label:currentGroupTitle];
        [groups addObject:fieldGroup];
    }
    
    AlfrescoForm *form = [[AlfrescoForm alloc] initWithGroups:groups title:@"Task Form"];
    return form;
}

- (AlfrescoFormField *)fieldFromDictionary:(NSDictionary *)fieldDictionary
{
    NSString *identifier = fieldDictionary[@"id"];
    NSString *name = fieldDictionary[@"name"];
    NSString *type = fieldDictionary[@"type"];
    BOOL required = [fieldDictionary[@"required"] boolValue];
    id value = fieldDictionary[@"value"];
    id options = fieldDictionary[@"options"];
    
    AlfrescoFormFieldType fieldType = AlfrescoFormFieldTypeUnknown;
    if ([type isEqualToString:@"text"] || [type isEqualToString:@"multi-line-text"] ||
        [type isEqualToString:@"dropdown"] || [type isEqualToString:@"radio-buttons"])
    {
        fieldType = AlfrescoFormFieldTypeString;
    }
    else if ([type isEqualToString:@"integer"])
    {
        fieldType = AlfrescoFormFieldTypeNumber;
    }
    
    AlfrescoFormField *field = [[AlfrescoFormField alloc] initWithIdentifier:identifier type:fieldType value:value label:name];
    
    if (required)
    {
        [field addConstraint:[AlfrescoFormMandatoryConstraint new]];
    }
    
    if ([options isKindOfClass:[NSArray class]])
    {
        NSMutableArray *values = [NSMutableArray array];
        for (NSDictionary *constraint in options)
        {
            [values addObject:constraint[@"name"]];
        }
        
        AlfrescoFormListOfValuesConstraint *constraint = [[AlfrescoFormListOfValuesConstraint alloc] initWithValues:values labels:values];
        [field addConstraint:constraint];
    }
    
    return field;
}

@end
