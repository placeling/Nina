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
    
    NSString *streetAddress;
    NSString *city;
    NSString *googleId;
    NSString *google_ref;
    NSString *thumbUrl;
    NSString *highlightUrl;
    
    NSString *mapUrl;
    
    NSArray *usersBookmarking;
    NSArray *tags;
    
    NSNumber *lat;
    NSNumber *lng;
    
    NSString *phone;
    
    NSArray *categories;
    NSInteger perspectiveCount;
    NSInteger followingPerspectiveCount;
    
    BOOL bookmarked;
    BOOL highlighted;
    bool hidden;
    
    NSMutableArray *placemarks;
    NSMutableArray *homePerspectives;
    NSMutableArray *followingPerspectives;
    NSMutableArray *everyonePerspectives;
    
}

+(RKObjectMapping*)getObjectMapping;
+(RKObjectMapping*)getObjectMappingNoPerspectives;

@property (nonatomic, assign) BOOL dirty;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *pid;
@property (nonatomic, retain) NSString *googleId;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSString *googlePlacesUrl;
@property (nonatomic, retain) NSString *google_ref;
@property (nonatomic, retain) NSString *thumbUrl;
@property (nonatomic, retain) NSString *highlightUrl;
@property (nonatomic, retain) NSString *mapUrl;

@property (nonatomic, retain) NSString *streetAddress;
@property (nonatomic, retain) NSString *city;

@property (nonatomic, retain) NSNumber *lat;
@property (nonatomic, retain) NSNumber *lng;
@property (nonatomic, retain) NSString *phone;

@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, assign) NSInteger perspectiveCount;
@property (nonatomic, assign) NSInteger followingPerspectiveCount;
@property (nonatomic, retain) NSArray *usersBookmarking;
@property (nonatomic, retain) NSArray *tags;

@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, assign) BOOL bookmarked;
@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, assign) bool hidden;

@property (nonatomic, assign) NSMutableArray *homePerspectives;
@property (nonatomic, assign) NSMutableArray *followingPerspectives;
@property (nonatomic, assign) NSMutableArray *everyonePerspectives;
@property (nonatomic, retain) NSMutableArray *placemarks;

- (id) initFromJsonDict:(NSDictionary *)jsonDict;
- (void) updateFromJsonDict:(NSDictionary *)jsonDict;

-(NSString*) usersBookmarkingString;
-(NSString*) tagString;
-(NSString*) placeThumbUrl;
-(CLLocation*) location;
-(float) distance;

@end
