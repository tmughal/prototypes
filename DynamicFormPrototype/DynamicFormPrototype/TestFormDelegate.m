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
    // personal info group
    FormFieldGroup *infoGroup = [[FormFieldGroup alloc] init];
    infoGroup.name = @"personalinfo";
    infoGroup.label = @"Personal Info";
    infoGroup.fieldNames = @[@"firstname", @"lastname", @"age", @"dob", @"married"];
    
    // user details group
    FormFieldGroup *userGroup = [[FormFieldGroup alloc] init];
    userGroup.name = @"userinfo";
    userGroup.label = @"User Info";
    userGroup.fieldNames = @[@"username", @"password"];
    
    // contact details group
    //FormFieldGroup *contactGroup = [[FormFieldGroup alloc] init];
    // address1, town, county, postcode, telephone, skype, twitter
    
    return @[infoGroup, userGroup];
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
        field.defaultValue = @"First";
    }
    else if ([fieldName isEqualToString:@"lastname"])
    {
        field = [FormField new];
        field.name = @"lastname";
        field.label = @"Last Name";
        field.type = @"string";
        field.originalValue = @"Cornwell";
        field.value = @"Cornwell";
        field.defaultValue = @"Last";
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
    else if ([fieldName isEqualToString:@"age"])
    {
        field = [FormField new];
        field.name = @"age";
        field.label = @"Age";
        field.type = @"int";
        field.originalValue = @39;
        field.value = @39;
    }
    else if ([fieldName isEqualToString:@"dob"])
    {
        field = [FormField new];
        field.name = @"dob";
        field.label = @"Date Of Birth";
        field.type = @"date";
        field.originalValue = [NSDate date];
        field.value = [NSDate date];
    }
    else if ([fieldName isEqualToString:@"username"])
    {
        field = [FormField new];
        field.name = @"username";
        field.label = @"Username";
        field.type = @"string";
        field.originalValue = @"gcornwell";
        field.value = @"gcornwell";
        field.required = YES;
    }
    else if ([fieldName isEqualToString:@"password"])
    {
        field = [FormField new];
        field.name = @"password";
        field.label = @"Password";
        field.type = @"string";
        field.secret = YES;
        field.originalValue = @"password";
        field.value = @"password";
    }
    
    return field;
}

#pragma mark - FormPersistenceDelegate

- (void)didEndEditingOfFormFields:(NSArray *)formFields
{
    for (FormField *field in formFields)
    {
        NSLog(@"Value of field %@ is %@", field.name, field.value);
    }
    
    for (FormField *field in formFields)
    {
        if (![field.value isEqual:field.originalValue])
        {
            NSLog(@"field %@ was changed", field.name);
        }
    }
}

@end
