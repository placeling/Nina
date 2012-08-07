//
//  PerspectiveTagTableViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 12-05-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuggestedPlaceController.h"

@interface PerspectiveTagTableViewController : UITableViewController{
    
    NSMutableArray *_places;
    NSArray *tags;
    NSMutableDictionary *perspectiveTally;
    id<SuggestedFilterProtocol> delegate;
    NSString *filteringUser;
}


@property(nonatomic, retain) NSMutableArray *places;
@property(nonatomic, retain) NSArray *tags;
@property(nonatomic, retain) NSMutableDictionary *perspectiveTally;
@property(nonatomic, retain) NSString *filteringUser;
@property(nonatomic, assign) id<SuggestedFilterProtocol> delegate;

- (id)initWithPlaces:(NSMutableArray*)newPlaces;
- (void) refreshTable;
@end
