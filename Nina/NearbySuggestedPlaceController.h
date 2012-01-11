//
//  NearbySuggestedPlaceController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-10-03.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NinaHelper.h"
#import "SuggestedPlaceController.h"

@interface NearbySuggestedPlaceController : SuggestedPlaceController<UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate>{
    
    IBOutlet UISearchBar *_searchBar;
    IBOutlet UITableView *placesTableView;
}

@property(nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property(nonatomic,retain) IBOutlet UITableView *placesTableView;

@end
