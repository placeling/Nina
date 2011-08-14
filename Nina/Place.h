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
    
    NSString *address;
    NSString *google_id;
    
    CLLocation* location;
    
    NSString *phone;
    
    NSArray *categories;
    NSInteger mapCount;
    BOOL bookmarked;
    
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *pid;
@property (nonatomic, retain) NSString *google_id;
@property (nonatomic, retain) User *user;

@property (nonatomic, retain) NSString *address;

@property (nonatomic, retain) CLLocation* location;
@property (nonatomic, retain) NSString *phone;

@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, assign) NSInteger mapCount;
@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, assign) BOOL bookmarked;


- (id) initFromJsonDict:(NSDictionary *)jsonDict;

@end
