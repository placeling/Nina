//
//  FriendFindController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-11-22.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NinaHelper.h"
#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface FriendFindController : UIViewController<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, RKObjectLoaderDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate>{
    NSMutableArray *searchUsers; 
    NSMutableArray *suggestedUsers; 
    NSMutableArray *recentSearches;
    
    BOOL showSearchResults;
    bool loading;
    UITableView *_tableView;
    UISearchBar *_searchBar;
}

@property (nonatomic, retain) NSMutableArray *searchUsers; 
@property (nonatomic, retain) NSMutableArray *suggestedUsers; 
@property (nonatomic, retain) NSMutableArray *recentSearches;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
