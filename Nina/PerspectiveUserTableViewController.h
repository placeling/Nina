//
//  PerspectiveUserTableViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 12-01-15.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuggestedPlaceController.h"

@interface PerspectiveUserTableViewController : UITableViewController{
    
    NSMutableArray *_places;
    NSArray *users;
    NSMutableDictionary *perspectiveTally;
    id<SuggestedFilterProtocol> delegate;
}


@property(nonatomic, retain) NSMutableArray *places;
@property(nonatomic, retain) NSArray *users;
@property(nonatomic, retain) NSMutableDictionary *perspectiveTally;
@property(nonatomic, assign) id<SuggestedFilterProtocol> delegate;

- (id)initWithPlaces:(NSMutableArray*)newPlaces;
- (void) refreshTable;
@end
