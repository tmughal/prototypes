//
//  FormFieldGroup.h
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 24/04/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormFieldGroup : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSArray *fieldNames; // should this be FormField objects?

@end
