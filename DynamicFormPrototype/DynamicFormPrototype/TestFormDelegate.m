//
//  TestFormDelegate.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 25/04/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "TestFormDelegate.h"
#import "FormFieldGroup.h"
#import "FormField.h"

@implementation TestFormDelegate

#pragma mark - FormDataSourceDelegate

- (NSArray *)groupsForForm
{
    FormFieldGroup *infoGroup = [[FormFieldGroup alloc] init];
    infoGroup.name = @"personalinfo";
    infoGroup.label = @"Personal Info";
    infoGroup.fieldNames = @[@"firstname", @"lastname", @"married"];
    return @[infoGroup];
}

// Returns the FormField object representing the field with the given name.
- (FormField *)fieldWithName:(NSString *)fieldName
{
    FormField *field = nil;
    
    if ([fieldName isEqualToString:@"firstname"])
    {
        field = [FormField new];
        field.name = @"firstname";
        field.label = @"First Name";
        field.type = @"string";
        field.originalValue = @"Gavin";
        field.value = @"Gavin";
    }
    else if ([fieldName isEqualToString:@"lastname"])
    {
        field = [FormField new];
        field.name = @"lastname";
        field.label = @"Last Name";
        field.type = @"string";
        field.originalValue = @"Cornwell";
        field.value = @"Cornwell";
    }
    else if ([fieldName isEqualToString:@"married"])
    {
        field = [FormField new];
        field.name = @"married";
        field.label = @"Married";
        field.type = @"boolean";
        field.originalValue = @(YES);
        field.value = @(YES);
    }
    
    return field;
}

#pragma mark - FormPersistenceDelegate

- (void)didEndEditingOfFormFields:(NSArray *)formFields
{
    for (FormField *field in formFields)
    {
        NSLog(@"Value of field %@ is %@", field.name, field.value);
        if (![field.value isEqual:field.originalValue])
        {
            NSLog(@"field was changed!");
        }
    }
}

@end
