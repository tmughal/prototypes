//
//  ActivitiTaskFormViewController.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 12/11/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "ActivitiTaskFormViewController.h"
#import "AlfrescoFormMandatoryConstraint.h"
#import "AlfrescoFormListOfValuesConstraint.h"

@interface ActivitiTaskFormViewController ()
@property (nonatomic, strong) NSNumber *taskId;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSURL *appURL;
@property (nonatomic, strong) NSString *taskFormUrl;
@property (nonatomic, strong) NSString *cookie;
@end

@implementation ActivitiTaskFormViewController

#pragma mark - Initialisation

- (instancetype)initWithTaskId:(NSNumber *)taskId username:(NSString *)username password:(NSString *)password appURL:(NSURL *)appURL
{
    self = [super init];
    
    if (self)
    {
        self.taskId = taskId;
        self.username = username;
        self.password = password;
        self.appURL = appURL;
    }
    
    return self;
}

#pragma mark - Form view data source

- (void)formViewController:(AlfrescoFormViewController *)formViewController loadFormWithCompletionBlock:(AlfrescoFormCompletionBlock)completionBlock
{
    NSString *appAuthUrl = [self.appURL.absoluteString stringByAppendingString:@"/authentication"];
    
    // use username/password to build body
    NSString *body = [NSString stringWithFormat:@"j_username=%@&j_password=%@&_spring_security_remember_me=true",
                      [self.username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                      [self.password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *authRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:appAuthUrl]];
    authRequest.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    authRequest.HTTPMethod = @"POST";
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:authRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *authError) {
        
        long statusCode = (long)((NSHTTPURLResponse*)response).statusCode;
        NSLog(@"status code = %ld", statusCode);
        
        if (authError == nil && data != nil && statusCode != 401)
        {
            NSDictionary *headers = ((NSHTTPURLResponse*)response).allHeaderFields;
            self.cookie = headers[@"Set-Cookie"];
            NSLog(@"cookie = %@", self.cookie);
            
            // request the form JSON
            self.taskFormUrl = [self.appURL.absoluteString stringByAppendingFormat:@"/rest/task-forms/%@", self.taskId];
            
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
            [config setHTTPAdditionalHeaders:@{@"Cookie": self.cookie}];
            NSURLSession *authenticatedSession = [NSURLSession sessionWithConfiguration:config];
            [[authenticatedSession dataTaskWithURL:[NSURL URLWithString:self.taskFormUrl]
                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *formError) {
                if (data != nil)
                {
                    // parse JSON into Form objects
                    NSError *parseError = nil;
                    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                     
                    if (parseError == nil)
                    {
                        AlfrescoForm *form = [self parseFormFromJSON:json];
                        completionBlock(form, nil);
                    }
                    else
                    {
                        completionBlock(nil, parseError);
                    }
                }
                else
                {
                    completionBlock(nil, formError);
                }
            }] resume];
        }
        else
        {
            completionBlock(nil, authError);
        }
    }] resume];
}

#pragma mark - Form view delegate

- (void)formViewController:(AlfrescoFormViewController *)formViewController didEndEditingWithOutcome:(NSString *)outcome
{
    NSLog(@"Persisting task form...");
    
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    for (AlfrescoFormField *field in formViewController.form.fields)
    {
        if (field.value != nil)
        {
            values[field.identifier] = field.value;
        }
    }
    
    NSDictionary *jsonDictionary = @{@"values": values};
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&parseError];
    
    if (parseError == nil)
    {
        NSLog(@"POSTING %@ to %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding], self.taskFormUrl);
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        [config setHTTPAdditionalHeaders:@{@"Cookie": self.cookie, @"Content-Type": @"application/json"}];
        NSURLSession *authenticatedSession = [NSURLSession sessionWithConfiguration:config];
        NSMutableURLRequest *saveRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.taskFormUrl]];
        saveRequest.HTTPBody = jsonData;
        saveRequest.HTTPMethod = @"POST";
        
        [[authenticatedSession dataTaskWithRequest:saveRequest
                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *saveError) {
                                     
                                     long statusCode = (long)((NSHTTPURLResponse*)response).statusCode;
                                     NSLog(@"status code = %ld", statusCode);
                                     
                                     if (data != nil && statusCode == 200)
                                     {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             // go back to examples view controller
                                             [self.navigationController popToRootViewControllerAnimated:YES];
                                         });
                                     }
                                     else
                                     {
                                         NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                         NSLog(@"error response: %@", response);
                                         
                                         UIAlertView *formErrorAlert = [[UIAlertView alloc] initWithTitle:@"Form Save Failed"
                                                                                                  message:[saveError localizedDescription]
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
        UIAlertView *parseErrorAlert = [[UIAlertView alloc] initWithTitle:@"JSON Parse Failed"
                                                                  message:[parseError localizedDescription]
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil, nil];
        
        [parseErrorAlert show];
    }
}

#pragma mark - Helper methods

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
