//
//  MemberRecord.h
//  placeling2
//
//  Created by Lindsay Watt on 11-06-10.
//  Copyright 2011 Placeling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo.h"

@interface User : NSObject {
    NSString *userId;
    NSString *city;
    NSString *iconURLString;
    NSString *username;
    NSString *description;
    
    Photo *profilePic;
    NSInteger placeCount;
    NSInteger followingCount;
    NSInteger followerCount;
    bool following;
    bool follows_you;
    
}

@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *iconURLString;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *description;

@property (nonatomic, retain) Photo *profilePic;
@property (nonatomic, assign) NSInteger placeCount;
@property (nonatomic, assign) NSInteger followingCount;
@property (nonatomic, assign) NSInteger followerCount;

@property (nonatomic, assign) bool following;
@property (nonatomic, assign) bool follows_you;

- (id) initFromJsonDict:(NSDictionary *)jsonDict;

@end