//
//  Notification.h
//  Nina
//
//  Created by Ian MacKinnon on 12-08-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "User.h"

@interface Notification : NSObject{
    User *actor;
    NSString *notificationType;
    NSString *subjectName;
    
    NSDate *createdAt;
    NSString *thumb1;
}

+(RKObjectMapping*)getObjectMapping;

@property (nonatomic, retain) User *actor;
@property (nonatomic, retain) NSString *notificationType;
@property (nonatomic, retain) NSString *subjectName;
@property (nonatomic, retain) NSString *thumb1;

@property (nonatomic, retain) NSDate *createdAt;

@end
