//
//  AlfrescoListOfValuesViewController.h
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 16/05/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlfrescoListOfValuesViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIPickerView *picker;

- (instancetype)initWithListOfValues:(NSArray *)values;

@end
