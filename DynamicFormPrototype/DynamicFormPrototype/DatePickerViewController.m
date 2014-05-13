//
//  DatePickerViewController.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 13/05/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "DatePickerViewController.h"

@interface DatePickerViewController ()
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) FormField *field;
@end

@implementation DatePickerViewController

- (instancetype)initWithFormField:(FormField *)field
{
    self = [super init];
    if (self)
    {
        self.field = field;
        self.datePicker = [[UIDatePicker alloc] init];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        self.datePicker.date = self.field.value;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // add the date picker to view
    [self.view addSubview:self.datePicker];
    
    // provide done button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(datePickerDone:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Today"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(showAndSelectToday:)];
}

- (void)showAndSelectToday:(id)sender
{
    [self.datePicker setDate:[NSDate date] animated:YES];
}

- (void)datePickerDone:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(datePicker:didSelectDate:forField:)])
    {
        [self.delegate datePicker:self didSelectDate:self.datePicker.date forField:self.field];
    }
}

@end
