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

    NSString *notes;
    NSArray *tags;
    NSMutableArray *photos; // Array of Photo objects
    BOOL starred;
    NSString *dateAdded;
    BOOL visited;
    BOOL share;
}

@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Place *place;
@property (nonatomic, retain) NSString *notes;
@property (nonatomic, retain) NSArray *tags;
@property (nonatomic, retain) NSMutableArray *photos;
@property BOOL starred;
@property (nonatomic, retain) NSString *dateAdded;
@property BOOL visited;
@property BOOL share;

- (id) initFromJsonDict:(NSDictionary *)jsonDict;
- (void) updateFromJsonDict:(NSDictionary *)jsonDict;

@end
