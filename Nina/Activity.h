//
//  Activity.h
//  Nina
//
//  Created by Ian MacKinnon on 12-08-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "User.h"

@interface Activity : NSObject {
    User *actor1;
    User *actor2;
    NSString *activityType;
    NSString *subjectTitle;
    
    NSString *subjectId;

    NSString *username1;
    NSString *username2;
    
    NSString *thumb1;
    NSDate *updatedAt;

}


+(RKObjectMapping*)getObjectMapping;

@property (nonatomic, retain) User *actor1;
@property (nonatomic, retain) User *actor2;
@property (nonatomic, retain) NSString *username1;
@property (nonatomic, retain) NSString *username2;
@property (nonatomic, retain) NSString *activityType;
@property (nonatomic, retain) NSString *subjectTitle;
@property (nonatomic, retain) NSString *subjectId;
@property (nonatomic, retain) NSString *thumb1;
@property (nonatomic, retain) NSDate *updatedAt;

@end
