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
    NSString *city;
    NSString *iconURLString;
    NSString *username;
    Photo *profilePic;
    NSNumber *placeCount;
}

@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *iconURLString;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) Photo *profilePic;
@property (nonatomic, retain) NSNumber *placeCount;

@end