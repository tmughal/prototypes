//
//  AlfrescoForm.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 14/05/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "AlfrescoForm.h"

@interface AlfrescoForm ()
@property (nonatomic, strong, readwrite) NSArray *groups;
@end

@implementation AlfrescoForm

- (instancetype)initWithGroups:(NSArray *)groups title:(NSString *)title
{
    self = [super init];
    if (self)
    {
        // TODO: Assert the required parameters are not nil
        
        self.groups = groups;
        self.title = title;
    }
    
    return self;
}

- (NSArray *)fields
{
    NSMutableArray *fields = [NSMutableArray array];
    
    for (AlfrescoFormFieldGroup *group in self.groups)
    {
        [fields addObjectsFromArray:group.fields];
    }
    
    return fields;
}

- (BOOL)isValid
{
    BOOL valid = YES;
    
    // iterate round all fields and check their constraints, if they all pass the form is valid.

    for (AlfrescoFormField *field in self.fields)
    {
        // TODO: evaluate all constraints rather than just the required flag
        
        if (field.required && field.value == nil)
        {
            NSLog(@"field %@ is invalid", field.identifier);
            
            valid = NO;
            break;
        }
    }
    
    return valid;
}

@end
