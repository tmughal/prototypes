//
//  FormField.h
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 24/04/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormField : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *type; // TODO: make this an enum
@property (nonatomic, strong) id originalValue;
@property (nonatomic, strong) id value;
@property (nonatomic, strong) id defaultValue;
@property (nonatomic, assign) BOOL required;
@property (nonatomic, strong) NSArray *constraints; // TODO: create a FormFieldConstraint class

@end
