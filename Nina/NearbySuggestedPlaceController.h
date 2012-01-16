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

@interface NearbySuggestedPlaceController : SuggestedPlaceController<UITableViewDelegate,UITableViewDataSource>{
    
    UITableView *placesTableView;
}

@property(nonatomic, retain) IBOutlet UITableView *placesTableView;

-(IBAction)reloadList;


@end
