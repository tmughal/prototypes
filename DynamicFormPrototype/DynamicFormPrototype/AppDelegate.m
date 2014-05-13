//
//  AppDelegate.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 09/04/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "AppDelegate.h"
#import "DynamicFormViewController.h"
#import "TestFormDelegate.h"
#import "JSONFormDelegate.h"
#import "DictionaryFormDelegate.h"

NSString * const kJSON = @"[{\"name\": \"firstname\",\"type\": \"string\",\"title\": \"First Name\",\"default\": \"\",\"value\": \"Gavin\",\"group\": \"Profile\"},{\"name\": \"lastname\",\"type\": \"string\",\"title\": \"Last Name\",\"default\": \"\",\"value\": \"Cornwell\",\"group\": \"Profile\"},{\"name\": \"married\",\"type\": \"boolean\",\"title\": \"Married\",\"default\": \"1\",\"value\": \"1\",\"group\": \"Profile\"}]";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // hardcoded example
    TestFormDelegate *formDelegate = [TestFormDelegate new];
    
    // JSON example
//    JSONFormDelegate *formDelegate = [[JSONFormDelegate alloc] initWithJSONString:kJSON];
    
    // dictionary example
//    NSDictionary *formData = @{@"First Name": @"Gavin", @"Middle Name": @"Paul", @"Last Name": @"Cornwell", @"Married": [NSNumber numberWithBool:YES]};
//    DictionaryFormDelegate *formDelegate = [[DictionaryFormDelegate alloc] initWithDictionary:formData];
    
    DynamicFormViewController *formController = [[DynamicFormViewController alloc] initWithFormDataSource:formDelegate
                                                                                      persistenceDelegate:formDelegate];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:formController];
    self.window.rootViewController = nc;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end