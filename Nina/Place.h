//
//  LocationRecord.h
//  placeling2
//
//  Created by Lindsay Watt on 11-06-30.
//  Copyright 2011 Placeling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Place : NSObject {
    NSString *name;
    NSString *uid;
    User *user;
    UIImage *icon;
    
    NSString *address;
    NSString *google_id;
    
    NSNumber *lat;
    NSNumber *lng;
    
    NSString *phone;
    
    NSArray *categories;
    NSNumber *mapCount;
    
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *google_id;
@property (nonatomic, retain) User *user;

@property (nonatomic, retain) NSString *address;

@property (nonatomic, retain) NSNumber *lat;
@property (nonatomic, retain) NSNumber *lng;

@property (nonatomic, retain) NSString *phone;

@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) NSNumber *mapCount;
@property (nonatomic, retain) UIImage *icon;


- (id) initFromJsonDict:(NSDictionary *)jsonDict;

@end
