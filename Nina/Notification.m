//
//  Notification.m
//  Nina
//
//  Created by Ian MacKinnon on 12-08-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Notification.h"

@implementation Notification

@synthesize actor, notificationType, subjectName, createdAt, thumb1, subjectId;


+(RKObjectMapping*)getObjectMapping{
    RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[Notification class]];
    [userMapping mapKeyPathsToAttributes:
     @"type", @"notificationType",
     @"created_at", @"createdAt",
     @"subject_name", @"subjectName",
     @"subject", @"subjectId",
     nil];
    
    [userMapping mapKeyPath:@"actor1" toRelationship:@"actor" withMapping:[User getObjectMapping]];
    
    return userMapping;
}



- (void)dealloc{    
    [actor release];
    [notificationType release];
    [subjectName release];
    [createdAt release];
    [thumb1 release];
    [subjectId release];
    
    [super dealloc];
}


@end
