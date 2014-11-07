//
//  UnitOfWorkOperation.h
//  BatchProcessor
//
//  Created by Gavin Cornwell on 24/10/2014.
//  Copyright (c) 2014 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnitOfWork : NSOperation

@property (nonatomic, strong, readonly) NSString *key;
@property (nonatomic, strong, readonly) id result;
@property (nonatomic, assign, readonly) BOOL successful;

//temporary
@property (nonatomic, assign, readonly) BOOL workCompleted;

- (instancetype)initWithKey:(NSString *)key;

- (void)startWork;
- (void)completeWorkWithResult:(id)result error:(NSError *)error;

@end
