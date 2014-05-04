//
//  DictionaryFormDelegate.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 04/05/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "DictionaryFormDelegate.h"

@interface DictionaryFormDelegate ()
@property (nonatomic, strong) NSDictionary *fields;
@end

@implementation DictionaryFormDelegate

#pragma mark - Initialisation

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        [self processDictionary];
    }
    
    return self;
}

- (void)processDictionary
{
    // TODO: process the dictionary
}

#pragma mark - FormDataSourceDelegate

- (NSArray *)groupsForForm
{
    return nil;
}

// Returns the FormField object representing the field with the given name.
- (FormField *)fieldWithName:(NSString *)fieldName
{
    return nil;
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
