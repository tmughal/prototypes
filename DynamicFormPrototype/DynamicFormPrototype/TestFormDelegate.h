//
//  TestFormDelegate.h
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 25/04/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormDataSourceDelegate.h"
#import "FormPersistenceDelegate.h"

@interface TestFormDelegate : NSObject <FormDataSourceDelegate, FormPersistenceDelegate>

@end
