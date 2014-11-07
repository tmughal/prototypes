//
//  BatchProcessorQueue.h
//  BatchProcessor
//
//  Created by Gavin Cornwell on 24/10/2014.
//  Copyright (c) 2014 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BatchProcessor.h"
#import "UnitOfWork.h"

@interface BatchProcessorQueue : BatchProcessor

- (void)addUnitOfWork:(UnitOfWork *)work;

@end
