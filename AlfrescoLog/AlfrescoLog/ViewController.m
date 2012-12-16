//
//  ViewController.m
//  AlfrescoLog
//
//  Created by Gavin Cornwell on 13/11/2012.
//  Copyright (c) 2012 Gavin Cornwell. All rights reserved.
//

#import "ViewController.h"
#import "AlfrescoLog.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // test some log levels
    AlfrescoLog *logger = [AlfrescoLog sharedInstance];
    NSLog(@"Log level is currently: %@", [logger stringForLogLevel:logger.logLevel]);
    
    // info message, should appear
    [logger logInfo:@"This should be an INFO level message"];
    
    // debug message, should not appear
    [logger logDebug:@"Debug message should NOT appear as level is set at INFO"];
    
    // set the log level to debug and log again
    logger.logLevel = AlfrescoLogLevelDebug;
    NSLog(@"Log level is currently: %@", [logger stringForLogLevel:logger.logLevel]);
    
    // debug message, should appear this time
    [logger logDebug:@"Debug message should appear now as level is set at DEBUG"];
    [logger logInfo:@"INFO messages should also appear still"];
    
    // set the log level to debug and log again
    logger.logLevel = AlfrescoLogLevelTrace;
    NSLog(@"Log level is currently: %@", [logger stringForLogLevel:logger.logLevel]);
    [logger logTrace:@"Trace message should appear now as level is set at TRACE"];
    [logger logDebug:@"Debug messages should also appear still"];
    [logger logInfo:@"Info messages should also appear still"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
