/*
 ******************************************************************************
 * Copyright (C) 2005-2014 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Mobile SDK.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *****************************************************************************
 */

#import <Foundation/Foundation.h>
#import "AlfrescoUnitOfWork.h"

typedef void (^AlfrescoBatchProcessorCompletionBlock)(NSDictionary *results, NSDictionary *errors);

@interface AlfrescoBatchProcessorOptions : NSObject
@property (nonatomic, assign) NSInteger maxConcurrentUnitsOfWork;
@end

@interface AlfrescoBatchProcessor : NSObject

@property (nonatomic, assign, readonly) BOOL inProgress;
@property (nonatomic, assign, readonly) BOOL cancelled;
@property (nonatomic, strong, readonly) NSArray *queuedUnitOfWorkKeys;

- (instancetype)initWithCompletionBlock:(AlfrescoBatchProcessorCompletionBlock)completionBlock;

- (instancetype)initWithOptions:(AlfrescoBatchProcessorOptions *)options
                completionBlock:(AlfrescoBatchProcessorCompletionBlock)completionBlock;

- (void)addUnitOfWork:(AlfrescoUnitOfWork *)work;

- (void)start;

- (void)cancel;

@end
