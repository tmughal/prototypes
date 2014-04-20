//
//  EditableTableCell.h
//  EditPropertyPrototype
//
//  Created by Gavin Cornwell on 08/11/2013.
//  Copyright (c) 2013 Gavin Cornwell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditableTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *propertyNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *propertyValueLabel;
@property (nonatomic, weak) IBOutlet UITextField *propertyValueTextField;

-(void)toggleEditingMode;

@end
