//
//  MemberRecord.h
//  placeling2
//
//  Created by Lindsay Watt on 11-06-10.
//  Copyright 2011 Placeling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo.h"
#import <RestKit/RestKit.h>
#import "Authentication.h"

@class Perspective;

@interface User : NSObject {
    NSString *userId;
    NSString *city;
    NSString *username;
    NSString *fullname; //transient, from server, for displaying with facebook friends
    
    NSString *userDescription;
    NSString *email;
    NSString *url;
    
    NSArray *location;
    
    NSMutableArray *auths;
    
    NSMutableArray *perspectives;
    
    Photo *profilePic;
    NSNumber *placeCount;
    NSNumber *followingCount;
    NSNumber *followerCount;
    NSNumber *following;
    NSNumber *follows_you;
     
    NSTimeInterval timestamp;
    BOOL blocked;
}

+(RKObjectMapping*)getObjectMapping;

@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *userDescription;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSArray *location;
@property (nonatomic, retain) NSMutableArray *auths;
@property (nonatomic, retain) NSMutableArray *perspectives;

@property (nonatomic, retain) Photo *profilePic;
@property (nonatomic, retain) NSNumber *placeCount;
@property (nonatomic, retain) NSNumber *followingCount;
@property (nonatomic, retain) NSNumber *followerCount;

@property (nonatomic, retain) NSNumber *following;
@property (nonatomic, retain) NSNumber *follows_you;
@property (nonatomic, retain) NSString *fullname;
@property (nonatomic, assign) BOOL blocked;
@property (nonatomic, assign) NSTimeInterval timestamp;

- (void) updateFromJsonDict:(NSDictionary *)jsonDict;

-(NSDictionary*) facebook;
-(NSString*) userThumbUrl;

@end