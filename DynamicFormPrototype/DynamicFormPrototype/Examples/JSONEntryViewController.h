//
//  JSONEntryViewController.h
//  DynamicFormPrototype
//
//  Created by Gavin Cornwell on 16/05/2014.
//  Copyright (c) 2014 Gavin Cornwell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlfrescoFormViewController.h"

@interface JSONEntryViewController : UIViewController <AlfrescoFormViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UITextView *textView;

@end
