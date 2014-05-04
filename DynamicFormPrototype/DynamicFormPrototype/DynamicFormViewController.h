//
//  DynamicFormViewController.h
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 09/04/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormDataSourceDelegate.h"
#import "FormPersistenceDelegate.h"

@interface DynamicFormViewController : UITableViewController

- (instancetype)initWithFormDataSource:(id<FormDataSourceDelegate>)dataSource
                   persistenceDelegate:(id<FormPersistenceDelegate>)persistenceDelegate;

@end
