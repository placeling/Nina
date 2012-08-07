//
//  Answer.m
//  Nina
//
//  Created by Ian MacKinnon on 12-08-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Answer.h"

@implementation Answer

@synthesize place, answerId, upvotes, createdAt, comments;


+(RKObjectMapping*)getObjectMapping{
    RKObjectMapping* questionMapping = [RKObjectMapping mappingForClass:[Answer class]];
    [questionMapping mapKeyPathsToAttributes:
     @"id", @"answerId",
     @"upvotes", @"upvotes",
     @"created_at", @"createdAt",
     nil];
    
    [questionMapping mapKeyPath:@"place" toRelationship:@"place" withMapping:[Place getObjectMapping]];
    
    
    return questionMapping;
}



- (void) dealloc{
    [place release];
    [answerId release];
    [upvotes release];
    [createdAt release];
    [comments release];
    
    [super dealloc];
}



@end
