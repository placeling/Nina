//
//  LocationRecord.h
//  placeling2
//
//  Created by Lindsay Watt on 11-06-30.
//  Copyright 2011 Placeling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "NinaHelper.h"

@interface Place : NSObject {
    NSString *name;
    NSString *pid;
    User *user;
    UIImage *icon;
    NSString *googlePlacesUrl;
    
    NSString *address;
    NSString *city;
    NSString *place_id;
    NSArray *usersBookmarking;
    
    CLLocation* location;
    
    NSString *phone;
    
    NSArray *categories;
    NSInteger perspectiveCount;
    NSInteger followingPerspectiveCount;
    
    BOOL bookmarked;
    
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *pid;
@property (nonatomic, retain) NSString *place_id;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSString *googlePlacesUrl;

@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *city;

@property (nonatomic, retain) CLLocation* location;
@property (nonatomic, retain) NSString *phone;

@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, assign) NSInteger perspectiveCount;
@property (nonatomic, assign) NSInteger followingPerspectiveCount;
@property (nonatomic, assign) NSArray *usersBookmarking;

@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, assign) BOOL bookmarked;


- (id) initFromJsonDict:(NSDictionary *)jsonDict;

-(NSString*) usersBookmarkingString;

@end
