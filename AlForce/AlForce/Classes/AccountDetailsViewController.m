//
//  AccountDetailsViewController.m
//  Alforce
//
//  Created by Gavin Cornwell on 04/06/2014.
//  Copyright (c) 2014 Alfresco. All rights reserved.
//

#import "AccountDetailsViewController.h"

#import "SFRestAPI.h"
#import "SFRestRequest.h"
#import "AlfrescoSDK.h"

@interface Attachment : NSObject <QLPreviewItem>

@property (nonatomic, strong) AlfrescoDocument *document;
@property (nonatomic, strong) AlfrescoContentFile *file;

@end

@implementation Attachment

@dynamic previewItemTitle;
@dynamic previewItemURL;

- (NSURL *)previewItemURL
{
    return self.file.fileUrl;
}

- (NSString *)previewItemTitle
{
    return self.document.name;
}
@end

@interface AccountDetailsViewController ()
@property (nonatomic, strong) NSString *accountId;
@property (nonatomic, strong) NSDictionary *account;
@property (nonatomic, strong) NSArray *attachments;
@property (nonatomic, strong) AlfrescoOAuthData *oauthData;
@property (nonatomic, strong) AlfrescoCloudSession *session;
@property (nonatomic, strong) Attachment *attachment;
@end

@implementation AccountDetailsViewController

- (instancetype)initWithAccountId:(NSString *)accountId oauthData:(AlfrescoOAuthData *)oauthData
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.accountId = accountId;
        self.oauthData = oauthData;
        self.account = [NSDictionary dictionary];
        self.attachments = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // retrieve the account details
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForRetrieveWithObjectType:@"Account" objectId:self.accountId
                                                                                fieldList:@"Id, Name, Type, Phone, AccountNumber, Website, Industry, Rating"];
    //SFRestRequest *request = [[SFRestAPI sharedInstance] requestForDescribeWithObjectType:@"Account"];
    [[SFRestAPI sharedInstance] send:request delegate:self];
    
    // also request the Alfresco documents attached to the account
    [self loadAlfrescoAttachments];
}

#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    
    // create a dictionary representing the account from the response object
    self.account = [NSDictionary dictionaryWithDictionary:jsonResponse];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    });
}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    AlfrescoLogDebug(@"request:didFailLoadWithError: %@", error);
    //add your failed error handling here
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    AlfrescoLogDebug(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    AlfrescoLogDebug(@"requestDidTimeout: %@", request);
    //add your failed error handling here
}

#pragma mark - Alfresco attachments

- (void)loadAlfrescoAttachments
{
    [AlfrescoCloudSession connectWithOAuthData:self.oauthData completionBlock:^(id<AlfrescoSession> session, NSError *sessionError) {
        if (session != nil)
        {
            self.session = session;
            AlfrescoSearchService *searchService = [[AlfrescoSearchService alloc] initWithSession:session];
            NSString *query = [NSString stringWithFormat:@"SELECT * FROM crm:accountRelated WHERE crm:accountId = '%@'", self.accountId];
            AlfrescoLogDebug(@"Searching for attachments...");
            
            [searchService searchWithStatement:query language:AlfrescoSearchLanguageCMIS completionBlock:^(NSArray *array, NSError *searchError) {
                if (array != nil)
                {
                    AlfrescoLogDebug(@"Found %lu attachements", (unsigned long)array.count);
                    
                    self.attachments = array;
//                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationBottom];
                    [self.tableView reloadData];
                }
                else
                {
                    AlfrescoLogDebug(@"Failed to create Alfresco in the Cloud session: %@", searchError);
                }
            }];
        }
        else
        {
            AlfrescoLogDebug(@"Failed to create Alfresco in the Cloud session: %@", sessionError);
        }
    }];
}

#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
    {
        return 7;
    }
    else
    {
        if (self.attachments == nil)
        {
            return 1;
        }
        else
        {
            if (self.attachments.count > 0)
            {
                return self.attachments.count;
            }
            else
            {
                return 1;
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
 
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = self.account[@"Name"];
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = @"Account Number";
            if (![self.account[@"AccountNumber"] isKindOfClass:[NSNull class]])
            {
                cell.detailTextLabel.text = self.account[@"AccountNumber"];
            }
        }
        else if (indexPath.row == 2)
        {
            cell.textLabel.text = @"Type";
            if (![self.account[@"Type"] isKindOfClass:[NSNull class]])
            {
                cell.detailTextLabel.text = self.account[@"Type"];
            }
        }
        else if (indexPath.row == 3)
        {
            cell.textLabel.text = @"Industry";
            if (![self.account[@"Industry"] isKindOfClass:[NSNull class]])
            {
                cell.detailTextLabel.text = self.account[@"Industry"];
            }
        }
        else if (indexPath.row == 4)
        {
            cell.textLabel.text = @"Phone";
            if (![self.account[@"Phone"] isKindOfClass:[NSNull class]])
            {
                cell.detailTextLabel.text = self.account[@"Phone"];
            }
        }
        else if (indexPath.row == 5)
        {
            cell.textLabel.text = @"Rating";
            if (![self.account[@"Rating"] isKindOfClass:[NSNull class]])
            {
                cell.detailTextLabel.text = self.account[@"Rating"];
            }
        }
        else if (indexPath.row == 6)
        {
            cell.textLabel.text = @"Website";
            if (![self.account[@"Website"] isKindOfClass:[NSNull class]])
            {
                cell.detailTextLabel.text = self.account[@"Website"];
            }
        }
    }
    else
    {
        if (self.attachments == nil)
        {
            cell.textLabel.text = @"Loading...";
        }
        else
        {
            if (self.attachments.count == 0)
            {
                cell.textLabel.text = @"No Files";
            }
            else
            {
                AlfrescoDocument *document = (AlfrescoDocument *)self.attachments[indexPath.row];
                
                UIImage *image = [UIImage imageNamed:@"small_document.png"];
                cell.imageView.image = image;
                
                cell.textLabel.text = document.name;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
    }

    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return nil;
    }
    else
    {
        if (self.attachments.count > 0)
        {
            return indexPath;
        }
        else
        {
            return nil;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlfrescoDocument *document = (AlfrescoDocument *)self.attachments[indexPath.row];
    AlfrescoLogDebug(@"selected attachment %@", document.name);
    
    AccountDetailsViewController *weakSelf = self;
    AlfrescoDocumentFolderService *docFolderService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.session];
    [docFolderService retrieveContentOfDocument:document completionBlock:^(AlfrescoContentFile *contentFile, NSError *error) {
        if (contentFile != nil)
        {
            [weakSelf displayAttachment:contentFile document:document];
        }
        else
        {
            AlfrescoLogDebug(@"Failed to retrieve content for attachment: %@", error);
        }
    } progressBlock:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Account Details";
    }
    else
    {
        return @"Files";
    }
}

#pragma mark - Quick look methods

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}

- (id <QLPreviewItem>) previewController: (QLPreviewController *) controller previewItemAtIndex: (NSInteger) index;
{
    return self.attachment;
}

- (void)displayAttachment:(AlfrescoContentFile *)file document:(AlfrescoDocument *)document
{
    self.attachment = [Attachment new];
    self.attachment.file = file;
    self.attachment.document = document;
    
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    previewController.dataSource = self;
    previewController.delegate = self;
    [[self navigationController] pushViewController:previewController animated:YES];
}

@end
