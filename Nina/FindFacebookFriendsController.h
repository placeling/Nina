//
//  FindFacebookFriendsController.h
//  Nina
//
//  Created by Ian MacKinnon on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@interface FindFacebookFriendsController : UITableViewController<RKObjectLoaderDelegate>{
    bool loading;
    NSMutableArray *searchUsers; 
}

@property(nonatomic, retain) NSMutableArray *facebookFriends; 



@end
