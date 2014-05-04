//
//  DictionaryFormDelegate.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 04/05/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "DictionaryFormDelegate.h"
#import "FormField.h"
#import "FormFieldGroup.h"

@interface DictionaryFormDelegate ()
@property (nonatomic, strong) NSArray *groups;
@property (nonatomic, strong) NSMutableDictionary *fields;
@end

@implementation DictionaryFormDelegate

#pragma mark - Initialisation

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        [self processDictionary:dictionary];
    }
    
    return self;
}

- (void)processDictionary:(NSDictionary *)dictionary
{
    self.fields = [NSMutableDictionary dictionary];
    
    FormFieldGroup *group = [FormFieldGroup new];
    group.name = @"profile";
    group.label = @"Profile";
    group.fieldNames = [dictionary allKeys];
    self.groups = @[group];
    
    for (NSString *keyName in group.fieldNames)
    {
        FormField *field = [FormField new];
        field.name = keyName;
        field.label = keyName;
        field.value = dictionary[keyName];
        field.originalValue = dictionary[keyName];
        
        if ([field.value isKindOfClass:[NSString class]])
        {
            field.type = @"string";
        }
        else if ([field.value isKindOfClass:[NSNumber class]])
        {
            field.type = @"boolean";
        }
        
        self.fields[keyName] = field;
    }
}

#pragma mark - FormDataSourceDelegate

- (NSArray *)groupsForForm
{
    return self.groups;
}

// Returns the FormField object representing the field with the given name.
- (FormField *)fieldWithName:(NSString *)fieldName
{
    return self.fields[fieldName];
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
