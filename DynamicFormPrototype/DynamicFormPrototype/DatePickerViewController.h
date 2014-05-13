//
//  DatePickerViewController.h
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 13/05/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormField.h"

@class DatePickerViewController;

@protocol DatePickerDelegate <NSObject>
- (void)datePicker:(DatePickerViewController *)datePicker didSelectDate:(NSDate *)date forField:(FormField *)field;
@end


@interface DatePickerViewController : UIViewController

@property (nonatomic, weak) id<DatePickerDelegate> delegate;

- (instancetype)initWithFormField:(FormField *)field;

@end
