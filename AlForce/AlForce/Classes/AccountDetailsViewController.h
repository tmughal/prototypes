//
//  AccountDetailsViewController.h
//  Alforce
//
//  Created by Gavin Cornwell on 04/06/2014.
//  Copyright (c) 2014 Alfresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import "SFRestAPI.h"
#import "AlfrescoOAuthData.h"

@interface AccountDetailsViewController : UITableViewController <SFRestDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate>

- (instancetype)initWithAccountId:(NSString *)accountId oauthData:(AlfrescoOAuthData *)oauthData;

@end
