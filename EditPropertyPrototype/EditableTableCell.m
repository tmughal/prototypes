//
//  EditableTableCell.m
//  EditPropertyPrototype
//
//  Created by Gavin Cornwell on 08/11/2013.
//  Copyright (c) 2013 Gavin Cornwell. All rights reserved.
//

#import "EditableTableCell.h"

@implementation EditableTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        
        self.propertyValueTextField.hidden = YES;
        self.propertyValueLabel.hidden = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)toggleEditingMode
{
    BOOL isInEditMode = self.propertyValueLabel.hidden;
    
    if (isInEditMode)
    {
        self.propertyValueTextField.hidden = YES;
        self.propertyValueLabel.hidden = NO;
    }
    else
    {
        self.propertyValueTextField.hidden = NO;
        self.propertyValueLabel.hidden = YES;
    }
}

@end
