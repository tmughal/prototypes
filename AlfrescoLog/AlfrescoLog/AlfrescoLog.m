//
//  AlfrescoLog.m
//  AlfrescoLog
//
//  Created by Gavin Cornwell on 13/11/2012.
//  Copyright (c) 2012 Gavin Cornwell. All rights reserved.
//

#import "AlfrescoLog.h"

@implementation AlfrescoLog

@synthesize logLevel = _logLevel;

#pragma mark - Lifecycle methods

+ (AlfrescoLog *)sharedInstance
{
    static dispatch_once_t predicate = 0;
    __strong static id sharedObject = nil;
    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

- (id)init
{
    return [self initWithLogLevel:AlfrescoLogLevelInfo];
}

- (id)initWithLogLevel:(AlfrescoLogLevel)logLevel
{
    self = [super init];
    if (self)
    {
        self.logLevel = logLevel;
    }
    return self;
}

#pragma mark - Info methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ Log level: %@", [super description], [self stringForLogLevel:self.logLevel]];
}

- (NSString *)stringForLogLevel:(AlfrescoLogLevel)logLevel
{
    NSString *result = nil;
    
    switch(logLevel)
    {
        case AlfrescoLogLevelOff:
            result = @"OFF";
            break;
        case AlfrescoLogLevelError:
            result = @"ERROR";
            break;
        case AlfrescoLogLevelWarning:
            result = @"WARN";
            break;
        case AlfrescoLogLevelInfo:
            result = @"INFO";
            break;
        case AlfrescoLogLevelDebug:
            result = @"DEBUG";
            break;
        case AlfrescoLogLevelTrace:
            result = @"TRACE";
            break;
        default:
            result = @"UNKNOWN";
    }
    
    return result;
}

#pragma mark - Logging methods

- (void)logErrorFromError:(NSError *)error
{
    NSString *callingMethod = [self methodNameFromCallStack:[[NSThread callStackSymbols] objectAtIndex:1]];
    
    if (self.logLevel != AlfrescoLogLevelOff)
    {
        // TODO: include error code
        
        [self logMessage:error.localizedDescription forLogLevel:AlfrescoLogLevelError callingMethod:callingMethod];
    }
}

- (void)logErrorFromString:(NSString *)errorMsg
{
    NSString *callingMethod = [self methodNameFromCallStack:[[NSThread callStackSymbols] objectAtIndex:1]];
    
    if (self.logLevel != AlfrescoLogLevelOff)
    {
        [self logMessage:errorMsg forLogLevel:AlfrescoLogLevelError callingMethod:callingMethod];
    }
}

- (void)logWarning:(NSString *)warningMsg
{
    NSString *callingMethod = [self methodNameFromCallStack:[[NSThread callStackSymbols] objectAtIndex:1]];
    
    if (self.logLevel >= AlfrescoLogLevelWarning)
    {
        [self logMessage:warningMsg forLogLevel:AlfrescoLogLevelWarning callingMethod:callingMethod];
    }
}

- (void)logInfo:(NSString *)infoMsg
{
    NSString *callingMethod = [self methodNameFromCallStack:[[NSThread callStackSymbols] objectAtIndex:1]];

    if (self.logLevel >= AlfrescoLogLevelInfo)
    {
        [self logMessage:infoMsg forLogLevel:AlfrescoLogLevelInfo callingMethod:callingMethod];
    }
}

- (void)logDebug:(NSString *)debugMsg
{
    NSString *callingMethod = [self methodNameFromCallStack:[[NSThread callStackSymbols] objectAtIndex:1]];
    
    if (self.logLevel >= AlfrescoLogLevelDebug)
    {
        [self logMessage:debugMsg forLogLevel:AlfrescoLogLevelDebug callingMethod:callingMethod];
    }
}

- (void)logTrace:(NSString *)traceMsg
{
    NSString *callingMethod = [self methodNameFromCallStack:[[NSThread callStackSymbols] objectAtIndex:1]];
    
    if (self.logLevel == AlfrescoLogLevelTrace)
    {
        [self logMessage:traceMsg forLogLevel:AlfrescoLogLevelTrace callingMethod:callingMethod];
    }
}

#pragma mark - Helper methods

- (void)logMessage:(NSString *)message forLogLevel:(AlfrescoLogLevel)logLevel callingMethod:(NSString *)callingMethod
{
    NSLog(@"%@ %@ %@", [self stringForLogLevel:logLevel], callingMethod, message);
}

- (NSString *)methodNameFromCallStack:(NSString *)topOfStack
{
    NSString *methodName = nil;
    
    if (topOfStack != nil)
    {
        NSRange startBracketRange = [topOfStack rangeOfString:@"[" options:NSBackwardsSearch];
        if (NSNotFound != startBracketRange.location)
        {
            NSString *start = [topOfStack substringFromIndex:startBracketRange.location];
            NSRange endBracketRange = [start rangeOfString:@"]" options:NSBackwardsSearch];
            if (NSNotFound != endBracketRange.location)
            {
                methodName = [start substringToIndex:endBracketRange.location + 1];
            }
        }
    }
    
    return methodName;
}

@end
