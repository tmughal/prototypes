//
//  ExamplesViewController.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 15/05/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "ExamplesViewController.h"
#import "AlfrescoFormViewController.h"
#import "NewAccountFormViewController.h"
#import "AddBenchmarkTestFormViewController.h"
#import "EditBenchmarkPropertiesFormViewController.h"
#import "RetrieveActivitiTaskFormViewController.h"
#import "AdvancedFormViewController.h"

@implementation ExamplesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Dynamic Form Examples";
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
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ExampleIdentifier = @"ExampleLink";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ExampleIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ExampleIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"New Account";
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"Add Benchmark Test";
    }
    else if (indexPath.row == 2)
    {
        cell.textLabel.text = @"Edit Benchmark Properties";
    }
    else if (indexPath.row == 3)
    {
        cell.textLabel.text = @"Activiti Task";
    }
    else if (indexPath.row == 4)
    {
        cell.textLabel.text = @"Advanced";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = nil;
    
    if (indexPath.row == 0)
    {
        viewController = [NewAccountFormViewController new];
    }
    else if (indexPath.row == 1)
    {
        viewController = [AddBenchmarkTestFormViewController new];
    }
    else if (indexPath.row == 2)
    {
        viewController = [EditBenchmarkPropertiesFormViewController new];
    }
    else if (indexPath.row == 3)
    {
        viewController = [RetrieveActivitiTaskFormViewController new];
    }
    else if (indexPath.row == 4)
    {
        viewController = [AdvancedFormViewController new];
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
