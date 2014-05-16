//
//  AlfrescoFormTextCell.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 09/04/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "AlfrescoFormTextCell.h"

@implementation AlfrescoFormTextCell

- (void)configureCell
{
    [super configureCell];
    
    NSLog(@"configuring text cell (%@)...", self.field.identifier);
    
    // set text field value
    // TODO: deal with default values
    if (self.field.type == AlfrescoFormFieldTypeNumber)
    {
        self.textField.text = [self.field.value stringValue];
    }
    else
    {
        self.textField.text = self.field.value;
    }
    
    // setup keyboard type, if necessary
    if (self.field.type == AlfrescoFormFieldTypeNumber)
    {
        [self.textField setKeyboardType:UIKeyboardTypeNumberPad];
        
        // TODO: determine if we should show the decimal number pad
        // [self.textField setKeyboardType:UIKeyboardTypeDecimalPad];
    }
    else if (self.field.type == AlfrescoFormFieldTypeEmail)
    {
        [self.textField setKeyboardType:UIKeyboardTypeEmailAddress];
    }
    else if (self.field.type == AlfrescoFormFieldTypeURL)
    {
        [self.textField setKeyboardType:UIKeyboardTypeURL];
    }
    
    // set other text field options
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;

    if (self.field.secret)
    {
        self.textField.secureTextEntry = YES;
    }

    if (self.field.placeholderText != nil)
    {
        self.textField.placeholder = self.field.placeholderText;
    }
    
    // setup event handler
    [self.textField addTarget:self action:@selector(fieldEdited:) forControlEvents:UIControlEventEditingDidEnd];
}

- (void)fieldEdited:(id)sender
{
    if (self.textField.text.length == 0)
    {
        self.field.value = nil;
    }
    else
    {
        self.field.value = self.textField.text;
    }
    
    NSLog(@"text field (%@) edited, value changed to %@", self.field.identifier, self.field.value);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAlfrescoFormFieldChangedNotification object:self.field];
}

@end
