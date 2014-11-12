//
//  AlfrescoFormView.h
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 12/11/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlfrescoForm.h"

@protocol AlfrescoFormViewDataSource;
@protocol AlfrescoFormViewDelegate;

@interface AlfrescoFormView : UIView

@property (nonatomic, strong, readonly) AlfrescoForm *form;
@property (nonatomic, weak) id<AlfrescoFormViewDelegate> delegate;
@property (nonatomic, weak) id<AlfrescoFormViewDataSource> dataSource;

@end


@protocol AlfrescoFormViewDelegate <NSObject>

@optional

// Informs the delegate that the user pressed an outcome button
- (BOOL)formView:(AlfrescoFormView *)formView willEndEditingOfForm:(AlfrescoForm *)form withOutcome:(NSString *)outcome;

// Informs the delegate that the form has finished being edited
- (void)formView:(AlfrescoFormView *)formView didEndEditingOfForm:(AlfrescoForm *)form withOutcome:(NSString *)outcome;

// Informs the delegate that the user pressed the cancel button
- (BOOL)formView:(AlfrescoFormView *)formView willCancelEditingOfForm:(AlfrescoForm *)form;

// Informs the delegate that form editing has been cancelled
- (void)formView:(AlfrescoFormView *)formView didCancelEditingOfForm:(AlfrescoForm *)form;

// Determines whether the form fields can be persisted and thus whether the outcome buttons are enabled.
- (BOOL)formView:(AlfrescoFormView *)formView canPersistForm:(AlfrescoForm *)form;

// Determines whether the cancel button should be displayed
- (BOOL)shouldShowCancelButtonForFormView:(AlfrescoFormView *)formView;

@end

typedef void (^AlfrescoFormCompletionBlock)(AlfrescoForm *form, NSError *error);

@protocol AlfrescoFormViewDataSource <NSObject>

@optional

- (AlfrescoForm *)formForFormView:(AlfrescoFormView *)formView;

- (void)formView:(AlfrescoFormView *)formView loadFormWithCompletionBlock:(AlfrescoFormCompletionBlock)completionBlock;

@end


