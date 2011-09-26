//
//  PlaceDetail.h
//  placeling2
//
//  Created by Lindsay Watt on 11-06-27.
//  Copyright 2011 Placeling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Place.h"

@interface Perspective : NSObject {
    User *user;
    Place *place;

    NSString *perspectiveId;
    NSString *notes;
    NSArray *tags;
    NSMutableArray *photos; // Array of Photo objects
    BOOL starred;
    NSString *dateAdded;
    NSString *lastModified;
    BOOL visited;
    BOOL share;
    BOOL mine;
    
    BOOL modified;
}

@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Place *place;
@property (nonatomic, retain) NSString *notes;
@property (nonatomic, retain) NSArray *tags;
@property (nonatomic, retain) NSMutableArray *photos;
@property (nonatomic, assign) BOOL starred;
@property (nonatomic, retain) NSString *dateAdded;
@property (nonatomic, assign) BOOL visited;
@property (nonatomic, assign) BOOL share;
@property (nonatomic, assign) BOOL modified;
@property (nonatomic, readonly) BOOL mine;
@property (nonatomic, retain) NSString* perspectiveId;
@property (nonatomic, retain) NSString *lastModified;

- (id) initFromJsonDict:(NSDictionary *)jsonDict;
- (void) updateFromJsonDict:(NSDictionary *)jsonDict;

@end
