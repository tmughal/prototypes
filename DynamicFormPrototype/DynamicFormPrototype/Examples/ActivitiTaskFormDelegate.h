//
//  ActivitiTaskFormDelegate.h
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 25/06/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlfrescoFormViewController.h"

@interface ActivitiTaskFormDelegate : NSObject <AlfrescoFormViewControllerDelegate>

@property (nonatomic, strong) NSString *taskUrl;
@property (nonatomic, strong) NSString *cookie;

@end
