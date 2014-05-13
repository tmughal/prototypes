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
#import "FormField.h"
#import "FormFieldGroup.h"
#import "DatePickerViewController.h"

@interface DynamicFormViewController ()
@property (nonatomic, strong) id<FormDataSourceDelegate> dataSourceDelegate;
@property (nonatomic, strong) id<FormPersistenceDelegate> persistenceDelegate;
@property (nonatomic, strong) NSArray *groups;
@property (nonatomic, strong) NSMutableArray *fields;
@property (nonatomic, strong) NSMutableDictionary *cells;
@end

@implementation DynamicFormViewController

#pragma mark - Initialisation

- (instancetype)initWithFormDataSource:(id<FormDataSourceDelegate>)dataSource
                   persistenceDelegate:(id<FormPersistenceDelegate>)persistenceDelegate
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.dataSourceDelegate = dataSource;
        self.persistenceDelegate = persistenceDelegate;
        self.groups = [dataSource groupsForForm];
        self.fields = [NSMutableArray array];
        self.cells = [NSMutableDictionary dictionary];
        
        for (FormFieldGroup *group in self.groups)
        {
            for (NSString *fieldName in group.fieldNames)
            {
                // retrieve the field
                FormField *field = [self.dataSourceDelegate fieldWithName:fieldName];
                
                // we must find a field, throw excpetion if we don't
                if (field == nil)
                {
                    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                                   reason:[NSString stringWithFormat:@"Failed to find field named: %@", fieldName] userInfo:nil];
                }
                
                // configure and store the cell and field
                [self configureCellForField:field];
            }
        }
    }
    return self;
}

- (void)configureCellForField:(FormField *)field
{
    if ([field.type isEqualToString:@"string"])
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TextFieldCell" owner:self options:nil];
        TextFieldCellTableViewCell *cell = [nib lastObject];
        
        cell.textField.text = field.value;
        cell.textField.tag = self.fields.count;
        cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        [cell.textField addTarget:self action:@selector(stringFieldEdited:) forControlEvents:UIControlEventEditingDidEnd];
        
        if (field.required)
        {
            cell.label.text = [NSString stringWithFormat:@"%@*", field.label];
        }
        else
        {
            cell.label.text = field.label;
        }
        
        if (field.secret)
        {
            cell.textField.secureTextEntry = YES;
        }
        
        if (field.defaultValue != nil)
        {
            cell.textField.placeholder = field.defaultValue;
        }
        
        self.cells[field.name] = cell;
        [self.fields addObject:field];
    }
    else if ([field.type isEqualToString:@"int"])
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TextFieldCell" owner:self options:nil];
        TextFieldCellTableViewCell *cell = [nib lastObject];
        
        cell.label.text = field.label;
        cell.textField.text = [field.value stringValue];
        cell.textField.tag = self.fields.count;
        cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        
        [cell.textField addTarget:self action:@selector(numberFieldEdited:) forControlEvents:UIControlEventEditingDidEnd];
        [cell.textField setKeyboardType:UIKeyboardTypeNumberPad];
        
        if (field.secret)
        {
            cell.textField.secureTextEntry = YES;
        }
        
        if (field.defaultValue != nil)
        {
            cell.textField.placeholder = field.defaultValue;
        }
        
        self.cells[field.name] = cell;
        [self.fields addObject:field];
    }
    else if ([field.type isEqualToString:@"boolean"])
    {
        BOOL on = [field.value boolValue];
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BooleanFormField" owner:self options:nil];
        BooleanFormField *cell = [nib lastObject];
        
        cell.label.text = field.label;
        cell.switchControl.tag = self.fields.count;
        cell.switchControl.on = on;
        [cell.switchControl addTarget:self action:@selector(booleanFieldEdited:) forControlEvents:UIControlEventValueChanged];
        
        self.cells[field.name] = cell;
        [self.fields addObject:field];
    }
    else if ([field.type isEqualToString:@"date"])
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        
        cell.textLabel.text = field.label;
        
        NSDate *date = field.value;
        if (date != nil)
        {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            cell.detailTextLabel.text = [dateFormatter stringFromDate:date];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        self.cells[field.name] = cell;
        [self.fields addObject:field];
    }
    else
    {
        // throw exeception if we can't handle the field
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"Unrecognised field type: %@", field.type] userInfo:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(saveButtonClicked:)];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections, will equal the number of groups
    return self.groups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section, will be the number of fields in the group.
    FormFieldGroup *group = self.groups[section];
    return group.fieldNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // retrieve the cell for the field
    return self.cells[[self fieldNameForIndexPath:indexPath]];
}

#pragma mark - Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    FormFieldGroup *group = self.groups[section];
    return group.label;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FormField *field = self.fields[indexPath.row];
    if ([field.type isEqualToString:@"date"])
    {
        return indexPath;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FormField *field = self.fields[indexPath.row];
    DatePickerViewController *datePickerVC = [[DatePickerViewController alloc] initWithFormField:field];
    datePickerVC.delegate = self;
    
    [self.navigationController pushViewController:datePickerVC animated:YES];
}

#pragma mark - Event handlers

- (void)saveButtonClicked:(id)sender
{
    [self.persistenceDelegate didEndEditingOfFormFields:self.fields];
}

- (void)stringFieldEdited:(id)sender
{
    UITextField *tf = (UITextField *)sender;
    FormField *field = self.fields[tf.tag];
    if (tf.text.length == 0)
    {
        field.value = nil;
    }
    else
    {
        field.value = tf.text;
    }
    
    NSLog(@"string field edited, tag %ld changed to %@", (long)tf.tag, tf.text);
    
    [self evaluateSaveButtonState];
}

- (void)numberFieldEdited:(id)sender
{
    UITextField *tf = (UITextField *)sender;
    FormField *field = self.fields[tf.tag];
    
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    field.value = [numberFormatter numberFromString:tf.text];
    
    NSLog(@"number field edited, tag %ld changed to %@", (long)tf.tag, tf.text);
    
    [self evaluateSaveButtonState];
}

- (void)booleanFieldEdited:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    FormField *field = self.fields[s.tag];
    field.value = [NSNumber numberWithBool:s.on];
    
    NSLog(@"boolean field edited, tag %ld change to %@", (long)s.tag, s.on ? @"YES" :@"NO");
    
    [self evaluateSaveButtonState];
}

- (void)datePicker:(DatePickerViewController *)datePicker didSelectDate:(NSDate *)date forField:(FormField *)field
{
    field.value = date;
    
    NSLog(@"date field edited, changed to %@", field.value);
    
    [self.navigationController popViewControllerAnimated:YES];
    
    // update the cell to display new date
    UITableViewCell *cell = self.cells[field.name];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:field.value];
    
    [self evaluateSaveButtonState];
}

#pragma mark - Internal helper methods

- (NSString *)fieldNameForIndexPath:(NSIndexPath *)indexPath
{
    FormFieldGroup *group = self.groups[indexPath.section];
    NSString *fieldName = group.fieldNames[indexPath.row];
    return fieldName;
}

- (void)evaluateSaveButtonState
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    for (FormField *field in self.fields)
    {
        if (field.required && field.value == nil)
        {
            self.navigationItem.rightBarButtonItem.enabled = NO;
            break;
        }
    }
}

@end
