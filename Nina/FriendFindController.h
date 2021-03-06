//
//  FriendFindController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-11-22.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NinaHelper.h"
#import "ApplicationController.h"
#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "LoginController.h"

@interface FriendFindController : ApplicationController<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, RKObjectLoaderDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, LoginControllerDelegate, UIAlertViewDelegate>{
    NSMutableArray *searchUsers; 
    NSMutableArray *suggestedUsers; 
    NSMutableArray *recentSearches;
    
    BOOL showSearchResults;
    bool loading;
    UITableView *_tableView;
    UISearchBar *_searchBar;
    UIToolbar *_toolbar;
}

@property (nonatomic, retain) NSMutableArray *searchUsers; 
@property (nonatomic, retain) NSMutableArray *suggestedUsers; 
@property (nonatomic, retain) NSMutableArray *recentSearches;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

-(IBAction)findFacebookFriends;

@end
