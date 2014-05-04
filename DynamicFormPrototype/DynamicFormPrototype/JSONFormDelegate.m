//
//  JSONFormDelegate.m
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 25/04/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import "JSONFormDelegate.h"
#import "FormField.h"
#import "FormFieldGroup.h"

@interface JSONFormDelegate ()
@property (nonatomic, strong) NSArray *json;
@property (nonatomic, strong) NSArray *groups;
@property (nonatomic, strong) NSMutableDictionary *fields;
@end

@implementation JSONFormDelegate

#pragma mark - Initialisation

- (instancetype)initWithJSONString:(NSString *)jsonString
{
    self = [super init];
    if (self)
    {
        // parse the JSON
        NSError *serialisationError = nil;
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        id jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&serialisationError];
        
        if (!serialisationError)
        {
            _json = jsonArray;
        }
        
        // process the JSON
        [self processJSON];
    }
    return self;
}

- (void)processJSON
{
    // Expecting JSON with format...
    /*
    [{
        "name": "firstname",
        "type": "string",
        "title": "First Name",
        "default": "",
        "value": "Gavin",
        "group": "Profile",
    }]
    */
    
    if (self.json)
    {
        self.fields = [NSMutableDictionary dictionary];
        NSMutableDictionary *groupDictionary = [NSMutableDictionary dictionary];
        
        for (NSDictionary *property in self.json)
        {
            NSString *name = property[@"name"];
            NSString *group = property[@"group"];
            
            FormField *field = [FormField new];
            field.name = name;
            field.label = property[@"title"];
            field.defaultValue = property[@"default"];
            field.originalValue = property[@"value"];
            field.value = property[@"value"];
            field.type = [property[@"type"] lowercaseString];
            
            self.fields[name] = field;
            
            FormFieldGroup *fieldGroup = groupDictionary[group];
            if (fieldGroup)
            {
                fieldGroup.fieldNames = [fieldGroup.fieldNames arrayByAddingObject:name];
            }
            else
            {
                fieldGroup = [FormFieldGroup new];
                fieldGroup.name = group;
                if (group.length == 0)
                {
                    fieldGroup.label = @"Default";
                }
                else
                {
                    fieldGroup.label = group;
                }
                fieldGroup.fieldNames = @[name];
                groupDictionary[group] = fieldGroup;
            }
        }
        
        self.groups = [groupDictionary allValues];
    }
    else
    {
        self.groups = [NSArray array];
        self.fields = [NSMutableDictionary dictionary];
    }
}

#pragma mark - FormDataSourceDelegate

- (NSArray *)groupsForForm
{
    return self.groups;
}

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
