//
//  NearbySuggestedPlaceController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-10-03.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NinaHelper.h"
#import "EGORefreshTableHeaderView.h"
#import "LoginController.h"

@interface NearbySuggestedPlaceController : UIViewController<UITableViewDelegate,UITableViewDataSource, ASIHTTPRequestDelegate, UISearchBarDelegate, LoginControllerDelegate>{
    EGORefreshTableHeaderView *refreshHeaderView;
    
    IBOutlet UISearchBar *_searchBar;
    IBOutlet UIBarButtonItem *popularPlacesButton;
    IBOutlet UIBarButtonItem *topLocalsButton;
    IBOutlet UITableView *placesTableView;
    IBOutlet UIToolbar *toolbar;
    
    BOOL _reloading;
    BOOL showAll;
    BOOL dataLoaded;
    BOOL locationEnabled;
    
    NSString *searchTerm;
    NSString *category;
    
    NSMutableArray  *nearbyPlaces;
}


@property(assign,getter=isReloading) BOOL reloading;
@property(nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *popularPlacesButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *topLocalsButton;
@property(nonatomic,retain) IBOutlet UIToolbar *toolbar;
@property(nonatomic,retain) IBOutlet UITableView *placesTableView;
@property(nonatomic,assign) BOOL showAll;
@property(nonatomic,assign) BOOL dataLoaded;
@property(nonatomic,assign) BOOL locationEnabled;
@property(nonatomic,retain) NSString *searchTerm;
@property(nonatomic,retain) NSString *category;

-(IBAction)popularPlaces:(id)sender;
-(IBAction)topLocals:(id)sender;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;


@end
