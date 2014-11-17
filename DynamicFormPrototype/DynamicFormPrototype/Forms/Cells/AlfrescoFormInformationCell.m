//
//  AlfrescoFormInformationCell.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 17/11/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "AlfrescoFormInformationCell.h"

@implementation AlfrescoFormInformationCell

- (instancetype)init
{
    return [self initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
}

- (void)configureCell
{
    // as we're using the built-in style for information cells, link up the labels
    self.label = self.textLabel;
    
    [super configureCell];
    
    [self configureCellValue];
    
    // set font for value
    self.detailTextLabel.font = [UIFont systemFontOfSize:14];
}

- (void)configureCellValue
{
    if (self.field.value != nil)
    {
        self.detailTextLabel.text = self.field.value;
    }
}

@end
