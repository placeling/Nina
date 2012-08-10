//
//  PlacemarkComment.m
//  Nina
//
//  Created by Ian MacKinnon on 12-08-09.
//
//

#import "PlacemarkComment.h"


@implementation PlacemarkComment

@synthesize commentId, comment, createdAt, user;

+(RKObjectMapping*)getObjectMapping{
    RKObjectMapping* commentMapping = [RKObjectMapping mappingForClass:[PlacemarkComment class]];
    [commentMapping mapKeyPathsToAttributes:
     @"id", @"commentId",
     @"comment", @"comment",
     @"created_at", @"createdAt",
     nil];
    
    [commentMapping mapKeyPath:@"user" toRelationship:@"user" withMapping:[User getObjectMapping]];
    
    return commentMapping;
}



- (void) dealloc{
    [commentId release];
    [comment release];
    [createdAt release];
    [user release];
    
    [super dealloc];
}




@end
