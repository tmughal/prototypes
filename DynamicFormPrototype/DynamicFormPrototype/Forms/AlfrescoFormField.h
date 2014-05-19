//
//  AlfrescoFormField.h
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 14/05/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AlfrescoFormFieldType)
{
    AlfrescoFormFieldTypeString = 0,
    AlfrescoFormFieldTypeBoolean,
    AlfrescoFormFieldTypeNumber,
    AlfrescoFormFieldTypeDate,
    AlfrescoFormFieldTypeDateTime,
    AlfrescoFormFieldTypeEmail,
    AlfrescoFormFieldTypeURL,
    AlfrescoFormFieldTypeCustom
};

@interface AlfrescoFormField : NSObject

@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, assign, readonly) AlfrescoFormFieldType type;
@property (nonatomic, strong, readonly) id originalValue;
@property (nonatomic, strong, readonly) NSArray *constraints;

@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *placeholderText;
@property (nonatomic, strong) id value;
@property (nonatomic, assign) BOOL required;
@property (nonatomic, assign) BOOL secret;

- (instancetype)initWithIdentifier:(NSString *)identifier type:(AlfrescoFormFieldType)type value:(id)value label:(NSString *)label;

- (void)addConstraint:(id)constraint;

+ (NSString *)stringForFieldType:(AlfrescoFormFieldType)type;
+ (AlfrescoFormFieldType)enumForTypeString:(NSString *)typeString;

@end
