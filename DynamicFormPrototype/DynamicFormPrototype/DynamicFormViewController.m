//
//  DynamicFormViewController.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 09/04/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "DynamicFormViewController.h"
#import "TextFieldCellTableViewCell.h"
#import "BooleanFormField.h"

@interface DynamicFormViewController ()
@property (nonatomic, strong) NSDictionary *fieldData;
@property (nonatomic, strong) NSMutableArray *fieldValues;
@property (nonatomic, strong) NSMutableArray *fields;
@end

@implementation DynamicFormViewController

- (instancetype)initWithDictionary:(NSDictionary *)fieldData
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        self.fieldData = fieldData;
        self.fields = [NSMutableArray array];
        self.fieldValues = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(saveButtonClicked:)];
    
    for (NSString *field in [self.fieldData allKeys])
    {
        id fieldValue = self.fieldData[field];
        if ([fieldValue isKindOfClass:[NSString class]])
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TextFieldCell" owner:self options:nil];
            TextFieldCellTableViewCell *cell = [nib lastObject];
            
            cell.label.text = field;
            cell.textField.text = fieldValue;
            cell.textField.tag = self.fields.count;
            [cell.textField addTarget:self action:@selector(textFieldEdited:)
                       forControlEvents:UIControlEventEditingDidEnd];
            
            [self.fields addObject:cell];
            [self.fieldValues addObject:fieldValue];
        }
        else if ([fieldValue isKindOfClass:[NSNumber class]])
        {
            BOOL on = [fieldValue boolValue];
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BooleanFormField" owner:self options:nil];
            BooleanFormField *cell = [nib lastObject];
            
            cell.label.text = field;
            cell.switchControl.on = on;
            cell.switchControl.tag = self.fields.count;
            [cell.switchControl addTarget:self action:@selector(booleanFieldEdited:) forControlEvents:UIControlEventValueChanged];
            
            [self.fields addObject:cell];
            [self.fieldValues addObject:[NSNumber numberWithBool:on]];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.fields.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.fields[indexPath.row];
}

#pragma mark - Event handlers

- (void)saveButtonClicked:(id)sender
{
    NSLog(@"Save button clicked, currrent values");
    
    for (int x = 0; x < self.fieldValues.count; x++)
    {
        NSLog(@"%d = %@", x, self.fieldValues[x]);
    }
}

- (void)textFieldEdited:(id)sender
{
    NSLog(@"text field edited");
    
    UITextField *tf = (UITextField *)sender;
    NSLog(@"field tag %d changed to %@", tf.tag, tf.text);
    
    self.fieldValues[tf.tag] = tf.text;
}

- (void)booleanFieldEdited:(id)sender
{
    NSLog(@"boolean field edited");
    
    UISwitch *s = (UISwitch *)sender;
    NSLog(@"field tag %d change to %hhd", s.tag, s.on);
    
    self.fieldValues[s.tag] = [NSNumber numberWithBool:s.on];
}

@end
