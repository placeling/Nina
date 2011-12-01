//
//  FriendFindController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-11-22.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NinaHelper.h"
#import <UIKit/UIKit.h>

@interface FriendFindController : UIViewController<ASIHTTPRequestDelegate,UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray *searchUsers; 
    NSMutableArray *suggestedUsers; 
    NSMutableArray *members;
    NSMutableArray *recentSearches;
    
    UITableView *_tableView;
    UISearchBar *_searchBar;
}

@property (nonatomic, retain) NSMutableArray *searchUsers; 
@property (nonatomic, retain) NSMutableArray *suggestedUsers; 
@property (nonatomic, retain) NSMutableArray *members; 
@property (nonatomic, retain) NSMutableArray *recentSearches;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
