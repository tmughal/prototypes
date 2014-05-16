//
//  AlfrescoListOfValuesViewController.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 16/05/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "AlfrescoListOfValuesViewController.h"

@interface AlfrescoListOfValuesViewController ()
@property (nonatomic, strong) NSArray *listOfValues;
@end

@implementation AlfrescoListOfValuesViewController

- (instancetype)initWithListOfValues:(NSArray *)values
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self)
    {
        self.listOfValues = values;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // provide Done button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(pickerDone:)];
}

- (void)pickerDone:(id)sender
{
//    if ([self.delegate respondsToSelector:@selector(datePicker:didSelectDate:)])
//    {
//        [self.delegate datePicker:self didSelectDate:self.datePicker.date];
//    }
    NSLog(@"pickerDone");
}

@end
