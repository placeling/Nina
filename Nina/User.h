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

@interface User : NSObject {
    NSString *userId;
    NSString *city;
    NSString *iconURLString;
    NSString *username;
    NSString *description;
    NSString *email;
    NSString *url;
    
    NSArray *location;
    
    NSMutableDictionary *auths;
    
    Photo *profilePic;
    NSInteger placeCount;
    NSInteger followingCount;
    NSInteger followerCount;
    bool following;
    bool follows_you;
    
    bool modified;    
}

+(RKObjectMapping*)getObjectMapping;

@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *iconURLString;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSArray *location;
@property (nonatomic, retain) NSMutableDictionary *auths;

@property (nonatomic, retain) Photo *profilePic;
@property (nonatomic, assign) NSInteger placeCount;
@property (nonatomic, assign) NSInteger followingCount;
@property (nonatomic, assign) NSInteger followerCount;

@property (nonatomic, assign) bool following;
@property (nonatomic, assign) bool follows_you;
@property (nonatomic, assign) bool modified;

- (id) initFromJsonDict:(NSDictionary *)jsonDict;
- (void) updateFromJsonDict:(NSDictionary *)jsonDict;

-(NSDictionary*) facebook;
-(NSString*) userThumbUrl;

@end