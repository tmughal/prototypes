//
//  ActivitiTaskFormViewController.h
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 12/11/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "AlfrescoFormViewController.h"

@interface ActivitiTaskFormViewController : AlfrescoFormViewController

- (instancetype)initWithTaskId:(NSNumber *)taskId username:(NSString *)username password:(NSString *)password appURL:(NSURL *)url;

@end
