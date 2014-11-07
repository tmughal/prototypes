//
//  BatchProcessorOptions.h
//  BatchProcessor
//
//  Created by Gavin Cornwell on 05/11/2014.
//  Copyright (c) 2014 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BatchProcessorOptions : NSObject

@property (nonatomic, strong) NSNumber *maxConcurrentUnitsOfWork;
@property (nonatomic, strong) NSNumber *unitOfWorkTimeout;
@property (nonatomic, strong) NSNumber *delayBetweenUnitsOfWork;
@property (nonatomic, strong) NSString *priority;  // essentially a mapping onto NSOperationQueuePriority

@end
