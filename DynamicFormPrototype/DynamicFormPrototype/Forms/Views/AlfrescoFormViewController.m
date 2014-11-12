//
//  AlfrescoFormViewController.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 12/11/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "AlfrescoFormViewController.h"
#import "AlfrescoFormFieldGroup.h"
#import "AlfrescoFormCell.h"
#import "AlfrescoFormDateCell.h"
#import "AlfrescoFormListOfValuesCell.h"
#import "AlfrescoFormListOfValuesConstraint.h"

@interface AlfrescoFormViewController ()
@property (nonatomic, strong, readwrite) AlfrescoForm *form;
@property (nonatomic, strong) NSMutableDictionary *cells;
@end

@implementation AlfrescoFormViewController

#pragma mark - Initialisation

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(evaluateDoneButtonState)
                                                 name:kAlfrescoFormFieldChangedNotification
                                               object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // determine whether to attempt to load the form asynchronously
    if ([self.dataSource respondsToSelector:@selector(formViewController:loadFormWithCompletionBlock:)])
    {
        [self.dataSource formViewController:self loadFormWithCompletionBlock:^(AlfrescoForm *form, NSError *error) {
            if (form)
            {
                self.form = form;
                [self configureForm];
                [self.tableView reloadData];
            }
            else
            {
                // create an error alert
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Form Load Failed"
                                                                          message:[error localizedDescription]
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil, nil];
                
                // show error alert on the main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [errorAlert show];
                });
            }
        }];
    }
    else if ([self.dataSource respondsToSelector:@selector(formForFormViewController:)])
    {
        self.form = [self.dataSource formForFormViewController:self];
        [self configureForm];
    }
}

- (void)configureForm
{
    // Add done button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonClicked:)];
    
    // set form title
    self.title = self.form.title;
    
    self.cells = [NSMutableDictionary dictionary];
    
    for (AlfrescoFormFieldGroup *group in self.form.groups)
    {
        for (AlfrescoFormField *field in group.fields)
        {
            AlfrescoFormCell *formCell = nil;
            
            if (field.type == AlfrescoFormFieldTypeString || field.type == AlfrescoFormFieldTypeNumber ||
                field.type == AlfrescoFormFieldTypeEmail || field.type == AlfrescoFormFieldTypeURL)
            {
                AlfrescoFormConstraint *constraint = [field constraintWithIdentifier:kAlfrescoFormConstraintListOfValues];
                if (constraint != nil)
                {
                    formCell = [[AlfrescoFormListOfValuesCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                }
                else
                {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AlfrescoFormTextCell" owner:self options:nil];
                    formCell = [nib lastObject];
                }
            }
            else if (field.type == AlfrescoFormFieldTypeBoolean)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AlfrescoFormBooleanCell" owner:self options:nil];
                formCell = [nib lastObject];
            }
            else if (field.type == AlfrescoFormFieldTypeDate || field.type == AlfrescoFormFieldTypeDateTime)
            {
                formCell = [[AlfrescoFormDateCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            }
            else if (field.type == AlfrescoFormFieldTypeCustom)
            {
                // temporarily create a basic cell to show the label and value
                formCell = [[AlfrescoFormCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                formCell.label = ((UITableViewCell*)formCell).textLabel;
                ((UITableViewCell*)formCell).detailTextLabel.text = [field.value description];
            }
            else
            {
                // throw exeception if we can't handle the field
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:[NSString stringWithFormat:@"%@ field has an unrecognised type", field.identifier] userInfo:nil];
            }
            
            // finish common configuration of the cell and store it
            formCell.field = field;
            self.cells[field.identifier] = formCell;
        }
    }
    
    // set the state of the done button
    [self evaluateDoneButtonState];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

#pragma mark - Form view data source

- (AlfrescoForm *)formForFormViewController:(AlfrescoFormViewController *)formViewController
{
    // return an empty form by default
    return [AlfrescoForm new];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.form)
    {
        // Return the number of sections, will equal the number of groups
        return self.form.groups.count;
    }
    else
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.form)
    {
        // Return the number of rows in the section, will be the number of fields in the group.
        AlfrescoFormFieldGroup *group = self.form.groups[section];
        return group.fields.count;
    }
    else
    {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.form)
    {
        return [self formCellForIndexPath:indexPath];
    }
    else
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.text = @"Loading Form...";
        return cell;
    }
}

#pragma mark - Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.form)
    {
        AlfrescoFormFieldGroup *group = self.form.groups[section];
        return group.label;
    }
    else
    {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (self.form)
    {
        AlfrescoFormFieldGroup *group = self.form.groups[section];
        return group.summary;
    }
    else
    {
        return nil;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.form)
    {
        AlfrescoFormCell *formCell = [self formCellForIndexPath:indexPath];
        
        if (formCell.isSelectable)
        {
            return indexPath;
        }
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlfrescoFormCell *formCell = [self formCellForIndexPath:indexPath];
    [formCell didSelectCellWithNavigationController:self.navigationController];
}

#pragma mark - Event handlers

- (void)doneButtonClicked:(id)sender
{
    BOOL allowEditingToEnd = YES;
    
    // TODO: implement the outcomes
    
    if ([self.delegate respondsToSelector:@selector(formViewController:willEndEditingWithOutcome:)])
    {
        allowEditingToEnd = [self.delegate formViewController:self willEndEditingWithOutcome:nil];
    }
    
    if (allowEditingToEnd && [self.delegate respondsToSelector:@selector(formViewController:didEndEditingWithOutcome:)])
    {
        [self.delegate formViewController:self didEndEditingWithOutcome:nil];
    }
}

- (void)evaluateDoneButtonState
{
    BOOL isFormValid = self.form.valid;
    
    // if form is not valid disable the done button
    self.navigationItem.rightBarButtonItem.enabled = isFormValid;
}

#pragma mark - Helper methods

- (AlfrescoFormCell *)formCellForIndexPath:(NSIndexPath *)indexPath
{
    AlfrescoFormFieldGroup *group = self.form.groups[indexPath.section];
    AlfrescoFormField *field = group.fields[indexPath.row];
    return self.cells[field.identifier];
}

@end
