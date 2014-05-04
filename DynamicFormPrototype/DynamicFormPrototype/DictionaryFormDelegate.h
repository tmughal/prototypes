//
//  DictionaryFormDelegate.h
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 04/05/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormDataSourceDelegate.h"
#import "FormPersistenceDelegate.h"

@interface DictionaryFormDelegate : NSObject <FormDataSourceDelegate, FormPersistenceDelegate>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
