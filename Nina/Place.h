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
    BOOL dirty;
    
    NSString *name;
    NSString *pid;
    User *user;
    UIImage *icon;
    NSString *googlePlacesUrl;
    
    NSString *address;
    NSString *city;
    NSString *place_id;
    NSArray *usersBookmarking;
    NSArray *tags;
    
    CLLocation* location;
    
    NSString *phone;
    
    NSArray *categories;
    NSInteger perspectiveCount;
    NSInteger followingPerspectiveCount;
    
    BOOL bookmarked;
    
    
    NSMutableArray *homePerspectives;
    NSMutableArray *followingPerspectives;
    NSMutableArray *everyonePerspectives;
    
}
@property (nonatomic, assign) BOOL dirty;
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
@property (nonatomic, retain) NSArray *usersBookmarking;
@property (nonatomic, retain) NSArray *tags;

@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, assign) BOOL bookmarked;

@property (nonatomic, assign) NSMutableArray *homePerspectives;
@property (nonatomic, assign) NSMutableArray *followingPerspectives;
@property (nonatomic, assign) NSMutableArray *everyonePerspectives;

- (id) initFromJsonDict:(NSDictionary *)jsonDict;

-(NSString*) usersBookmarkingString;

-(NSString*) distance;

@end
