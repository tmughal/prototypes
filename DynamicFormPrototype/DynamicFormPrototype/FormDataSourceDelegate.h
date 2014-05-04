//
//  FormDataSourceDelegate.h
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 24/04/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormField.h"

@protocol FormDataSourceDelegate <NSObject>

// Returns an array of groups, in the order of display for the form.
- (NSArray *)groupsForForm;

// Returns the FormField object representing the field with the given name.
- (FormField *)fieldWithName:(NSString *)fieldName;

@end
