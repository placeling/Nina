//
//  PerspectiveUserTableViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 12-01-15.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NearbySuggestedMapController.h"

@interface PerspectiveUserTableViewController : UITableViewController{
    
    NSMutableArray *_places;
    NSMutableArray *users;
    NSMutableDictionary *perspectiveTally;
    id<SuggestedMapUserFilterProtocol> delegate;
}


@property(nonatomic, retain) NSMutableArray *places;
@property(nonatomic, retain) NSMutableArray *users;
@property(nonatomic, retain) NSMutableDictionary *perspectiveTally;
@property(nonatomic, assign) id<SuggestedMapUserFilterProtocol> delegate;

- (id)initWithPlaces:(NSMutableArray*)newPlaces;

@end
