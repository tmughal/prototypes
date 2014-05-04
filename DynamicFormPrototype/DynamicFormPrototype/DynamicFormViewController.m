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

@interface DynamicFormViewController ()
@property (nonatomic, strong) id<FormDataSourceDelegate> dataSourceDelegate;
@property (nonatomic, strong) id<FormPersistenceDelegate> persistenceDelegate;
@property (nonatomic, strong) NSArray *groups;
@property (nonatomic, strong) NSMutableArray *fields;
@end

@implementation DynamicFormViewController

- (instancetype)initWithFormDataSource:(id<FormDataSourceDelegate>)dataSource
                   persistenceDelegate:(id<FormPersistenceDelegate>)persistenceDelegate
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        self.dataSourceDelegate = dataSource;
        self.persistenceDelegate = persistenceDelegate;
        self.groups = [dataSource groupsForForm];
        self.fields = [NSMutableArray array];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    FormFieldGroup *group = self.groups[section];
    return group.label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // create the appropriate kind of cell for the field
    FormFieldGroup *group = self.groups[indexPath.section];
    FormField *field = [self.dataSourceDelegate fieldWithName:group.fieldNames[indexPath.row]];
    
    if ([field.type isEqualToString:@"string"])
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TextFieldCell" owner:self options:nil];
        TextFieldCellTableViewCell *cell = [nib lastObject];
        
        cell.label.text = field.label;
        cell.textField.text = field.originalValue;
        cell.textField.tag = self.fields.count;
        [cell.textField addTarget:self action:@selector(textFieldEdited:) forControlEvents:UIControlEventEditingDidEnd];
        
        [self.fields addObject:field];
        return cell;
    }
    else if ([field.type isEqualToString:@"boolean"])
    {
        BOOL on = [field.originalValue boolValue];
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BooleanFormField" owner:self options:nil];
        BooleanFormField *cell = [nib lastObject];
        
        cell.label.text = field.label;
        cell.switchControl.on = on;
        cell.switchControl.tag = self.fields.count;
        [cell.switchControl addTarget:self action:@selector(booleanFieldEdited:) forControlEvents:UIControlEventValueChanged];
        
        [self.fields addObject:field];
        return cell;
    }
    
    // TODO: handle the nil case above by throwing exception with meaningful message
    return nil;
}

#pragma mark - Event handlers

- (void)saveButtonClicked:(id)sender
{
    [self.persistenceDelegate didEndEditingOfFormFields:self.fields];
}

- (void)textFieldEdited:(id)sender
{
    UITextField *tf = (UITextField *)sender;
    FormField *field = self.fields[tf.tag];
    field.value = tf.text;
    
    NSLog(@"text field edited, tag %d changed to %@", tf.tag, tf.text);
}

- (void)booleanFieldEdited:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    FormField *field = self.fields[s.tag];
    field.value = [NSNumber numberWithBool:s.on];
    
    NSLog(@"boolean field edited, tag %d change to %hhd", s.tag, s.on);
}

@end
