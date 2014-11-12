//
//  AlfrescoFormViewController.h
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 12/11/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlfrescoFormView.h"

// NOTE: This extends UITableViewController for now but in the future to support more than
//       one column this will extend UIViewController and the appropriate view controller
//       implementation will be determined internally.

@interface AlfrescoFormViewController : UITableViewController <AlfrescoFormViewDelegate, AlfrescoFormViewDataSource>

@property (nonatomic, strong, readonly) AlfrescoFormView *formView;
@property (nonatomic, assign) BOOL loadFormAsynchronously;

@end
