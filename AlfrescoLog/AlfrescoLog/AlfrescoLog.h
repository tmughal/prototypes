//
//  AlfrescoLog.h
//  AlfrescoLog
//
//  Created by Gavin Cornwell on 13/11/2012.
//  Copyright (c) 2012 Gavin Cornwell. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#   define log(fmt, ...) NSLog((@"%s " fmt), __PRETTY_FUNCTION__, ##__VA_ARGS__);
#else
#   define log(...)
#endif

@interface AlfrescoLog : NSObject

// TODO: Can we define a string value for each option within the enum?

typedef enum
{
    AlfrescoLogLevelOff = 0,
    AlfrescoLogLevelError,
    AlfrescoLogLevelWarning,
    AlfrescoLogLevelInfo,
    AlfrescoLogLevelDebug,
    AlfrescoLogLevelTrace
} AlfrescoLogLevel;

@property (nonatomic, assign) AlfrescoLogLevel logLevel;

/**
 * Returns the shared singleton
 */
+ (AlfrescoLog *)sharedInstance;

- (id)initWithLogLevel:(AlfrescoLogLevel)logLevel;

- (NSString *)stringForLogLevel:(AlfrescoLogLevel)logLevel;

- (void)logErrorFromError:(NSError *)error;

- (void)logErrorFromString:(NSString *)errorMsg;

- (void)logWarning:(NSString *)warningMsg;

- (void)logInfo:(NSString *)infoMsg;

- (void)logDebug:(NSString *)debugMsg;

- (void)logTrace:(NSString *)traceMsg;

@end
