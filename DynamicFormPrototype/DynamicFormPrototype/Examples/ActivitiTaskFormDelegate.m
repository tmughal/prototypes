//
//  ActivitiTaskFormDelegate.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 25/06/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "ActivitiTaskFormDelegate.h"

@implementation ActivitiTaskFormDelegate

// Informs the delegate the user pressed the "Done" button
- (void)formViewController:(AlfrescoFormViewController *)viewController didEndEditingOfForm:(AlfrescoForm *)form
{
    NSLog(@"Persisting task form...");
    
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    for (AlfrescoFormField *field in form.fields)
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
        NSLog(@"POSTING %@ to %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding], self.taskUrl);
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        [config setHTTPAdditionalHeaders:@{@"Cookie": self.cookie, @"Content-Type": @"application/json"}];
        NSURLSession *authenticatedSession = [NSURLSession sessionWithConfiguration:config];
        NSMutableURLRequest *saveRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.taskUrl]];
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
                    [viewController.navigationController popToRootViewControllerAnimated:YES];
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

@end
