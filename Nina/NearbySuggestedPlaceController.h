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
#import <RestKit/RestKit.h>

@interface NearbySuggestedPlaceController : UIViewController<UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate, LoginControllerDelegate, RKObjectLoaderDelegate>{
    
    IBOutlet UISearchBar *_searchBar;
    IBOutlet UITableView *placesTableView;
    
    BOOL followingLoaded;
    BOOL popularLoaded;
    BOOL locationEnabled;
    
    NSString *searchTerm;
    NSString *category;
    
    //NSMutableArray  *myPlaces;
    NSMutableArray  *followingPlaces;
    NSMutableArray  *popularPlaces;
}

@property(nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property(nonatomic,retain) IBOutlet UITableView *placesTableView;

@property(nonatomic, assign) BOOL followingLoaded;
@property(nonatomic, assign) BOOL popularLoaded;

@property(nonatomic,assign) BOOL locationEnabled;
@property(nonatomic,retain) NSString *searchTerm;
@property(nonatomic,retain) NSString *category;


@end
