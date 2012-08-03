//
//  Activity.m
//  Nina
//
//  Created by Ian MacKinnon on 12-08-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Activity.h"

@implementation Activity


@synthesize actor1,actor2,activityType,subjectTitle,subjectId,username1,username2;
@synthesize updatedAt, thumb1;


+(RKObjectMapping*)getObjectMapping{
    RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[Activity class]];
    [userMapping mapKeyPathsToAttributes:
     @"activity_type", @"activityType",
     @"subject_title", @"subjectTitle",
     @"subject", @"subjectId",
     @"username1", @"username1",
     @"username2", @"username2",
     @"updated_at", @"updatedAt",
     @"thumb1", @"thumb1",
     nil];
    
    //[userMapping mapKeyPath:@"actor1" toRelationship:@"actor1" withMapping:[User getObjectMapping]];
    //[userMapping mapKeyPath:@"actor2" toRelationship:@"actor2" withMapping:[User getObjectMapping]];
    
    return userMapping;
}



- (void)dealloc{     
    [actor1 release];
    [actor2 release];
    [activityType release];
    [subjectTitle release];
    
    [subjectId release];
    
    [username1 release];
    [username2 release];
    
    [updatedAt release];
    [thumb1 release];
    
    [super dealloc];
}


@end
