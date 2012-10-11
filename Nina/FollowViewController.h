//
//  FollowViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-08-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NinaHelper.h"
#import "User.h"
#import "Place.h"
#import "Perspective.h"
#import <RestKit/RestKit.h>

@interface FollowViewController : UITableViewController<RKObjectLoaderDelegate>{
    User* _user;
    Place* _place;
    Perspective *_perspective;
    NSMutableArray *users;
    bool following;//false for followers, true for following 
    
    BOOL loadingMore;
    BOOL hasMore;
}

@property (nonatomic, retain) NSMutableArray *users;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Place *place;
@property (nonatomic, retain) Perspective *perspective;
@property(nonatomic,assign) bool following;

- (id)initWithUser:(User*)focusUser andFollowing:(bool)follow;
-(id) initWithPlace:(Place*)place andFollowing:(bool)follow;
-(id) initWithPerspective:(Perspective*)perspective;

@end
