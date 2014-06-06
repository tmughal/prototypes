/*
 Copyright (c) 2011, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "RootViewController.h"

#import "SFRestAPI.h"
#import "SFRestRequest.h"
#import "AccountDetailsViewController.h"
#import "AlfrescoSDK.h"

@interface RootViewController ()
@property (nonatomic, strong) AlfrescoOAuthData *oauthData;
@property (nonatomic, strong) NSArray *hotAccounts;
@property (nonatomic, strong) NSArray *warmAccounts;
@property (nonatomic, strong) NSArray *coldAccounts;
@property (nonatomic, strong) NSArray *noRatingAccounts;
@end

@implementation RootViewController

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Alforce One";
    
    //Here we use a query that should work on either Force.com or Database.com
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:@"SELECT Name, Id, Rating FROM Account LIMIT 10"];
    [[SFRestAPI sharedInstance] send:request delegate:self];
    
    self.hotAccounts = @[];
    self.warmAccounts = @[];
    self.coldAccounts = @[];
    self.noRatingAccounts = @[];
}

#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse
{
    NSArray *records = [jsonResponse objectForKey:@"records"];
    AlfrescoLogDebug(@"request:didLoadResponse: #records: %lu", (unsigned long)records.count);
    
    NSMutableArray *tempHotAccounts = [NSMutableArray array];
    NSMutableArray *tempWarmAccounts = [NSMutableArray array];
    NSMutableArray *tempColdAccounts = [NSMutableArray array];
    NSMutableArray *tempNoRatingAccounts = [NSMutableArray array];
    
    // sort the accounts according to rating
    for (NSDictionary *record in records)
    {
        id rating = record[@"Rating"];
        if ([rating isKindOfClass:[NSNull class]])
        {
            [tempNoRatingAccounts addObject:record];
        }
        else
        {
            if ([rating isEqualToString:@"Hot"])
            {
                [tempHotAccounts addObject:record];
            }
            else if ([rating isEqualToString:@"Warm"])
            {
                [tempWarmAccounts addObject:record];
            }
            else
            {
                [tempColdAccounts addObject:record];
            }
        }
    }
    
    self.hotAccounts = tempHotAccounts;
    self.warmAccounts = tempWarmAccounts;
    self.coldAccounts = tempColdAccounts;
    self.noRatingAccounts = tempNoRatingAccounts;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error
{
    AlfrescoLogDebug(@"request:didFailLoadWithError: %@", error);
    //add your failed error handling here
}

- (void)requestDidCancelLoad:(SFRestRequest *)request
{
    AlfrescoLogDebug(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
}

- (void)requestDidTimeout:(SFRestRequest *)request
{
    AlfrescoLogDebug(@"requestDidTimeout: %@", request);
    //add your failed error handling here
}

#pragma mark - AlfrescoOAuthLoginDelegate

- (void)oauthLoginDidFailWithError:(NSError *)error
{
    AlfrescoLogDebug(@"Failed to authenticate to Alfresco in the Cloud: %@", error);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.hotAccounts.count;
    }
    else if (section == 1)
    {
        return self.warmAccounts.count;
    }
    else if (section == 2)
    {
        return self.coldAccounts.count;
    }
    else
    {
        return self.noRatingAccounts.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Hot Accounts";
    }
    else if (section == 1)
    {
        return @"Warm Accounts";
    }
    else if (section == 2)
    {
        return @"Cold Accounts";
    }
    else
    {
        return @"No Rating";
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *CellIdentifier = @"CellIdentifier";

   // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    UIImage *image = [UIImage imageNamed:@"account.png"];
    cell.imageView.image = image;
    
	// Configure the cell to show the data.
    NSDictionary *obj = nil;
    if (indexPath.section == 0)
    {
        obj = [self.hotAccounts objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1)
    {
        obj = [self.warmAccounts objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 2)
    {
        obj = [self.coldAccounts objectAtIndex:indexPath.row];
    }
    else
    {
        obj = [self.noRatingAccounts objectAtIndex:indexPath.row];
    }
	
	cell.textLabel.text = [obj objectForKey:@"Name"];

	//this adds the arrow to the right hand side.
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *obj = nil;
    if (indexPath.section == 0)
    {
        obj = [self.hotAccounts objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1)
    {
        obj = [self.warmAccounts objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 2)
    {
        obj = [self.coldAccounts objectAtIndex:indexPath.row];
    }
    else
    {
        obj = [self.noRatingAccounts objectAtIndex:indexPath.row];
    }
    NSString *selectedAccountId = obj[@"Id"];
    AlfrescoLogDebug(@"selected account %@", selectedAccountId);
    
    if (self.oauthData == nil)
    {
        AlfrescoOAuthLoginViewController *loginVC = [[AlfrescoOAuthLoginViewController alloc] initWithAPIKey:ALFRESCO_CLOUD_OAUTH_KEY secretKey:ALFRESCO_CLOUD_OAUTH_SECRET completionBlock:^(AlfrescoOAuthData *oauthData, NSError *error) {
            
            // remove the oauth login controller, regardless of result
            [[self navigationController] popViewControllerAnimated:NO];
            
            if (oauthData != nil)
            {
                self.oauthData = oauthData;
            
                // push the account details view controller
                AccountDetailsViewController *detailsVC = [[AccountDetailsViewController alloc] initWithAccountId:selectedAccountId oauthData:self.oauthData];
                [[self navigationController] pushViewController:detailsVC animated:YES];
            }
            else
            {
                AlfrescoLogDebug(@"Failed to authenticate to Alfresco in the Cloud: %@", error);
            }
        }];
        
        [[self navigationController] pushViewController:loginVC animated:YES];
    }
    else
    {
        AccountDetailsViewController *detailsVC = [[AccountDetailsViewController alloc] initWithAccountId:selectedAccountId oauthData:self.oauthData];
        [[self navigationController] pushViewController:detailsVC animated:YES];
    }
}

@end
