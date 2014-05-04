//
//  FormPersistenceDelegate.h
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 24/04/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FormPersistenceDelegate <NSObject>

// Informs the delegate the user pressed the Save button
- (void)didEndEditingOfFormFields:(NSArray *)formFields;

@optional

// Determines whether the form fields can be persisted and thus whether the Save button is enabled.
// This method provides a mechanism to perform further validation, over and above the constraints
- (BOOL)canPersistFormFields:(NSArray *)formFields;

@end
