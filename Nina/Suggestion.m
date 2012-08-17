//
//  Suggestion.m
//  Nina
//
//  Created by Ian MacKinnon on 12-08-15.
//
//

#import "Suggestion.h"

@implementation Suggestion

@synthesize createdAt,message,sender,receiver,place;

+(RKObjectMapping*)getObjectMapping{
    RKObjectMapping* suggestionMapping = [RKObjectMapping mappingForClass:[Suggestion class]];
    [suggestionMapping mapKeyPathsToAttributes:
     @"message", @"message",
     @"created_at", @"createdAt",
     nil];
    
    [suggestionMapping mapKeyPath:@"sender" toRelationship:@"sender" withMapping:[User getObjectMapping]];
    [suggestionMapping mapKeyPath:@"receiver" toRelationship:@"receiver" withMapping:[User getObjectMapping]];
    [suggestionMapping mapKeyPath:@"place" toRelationship:@"place" withMapping:[Place getObjectMapping]];
    
    return suggestionMapping;
}

-(NSString*)getUserId{
    return receiver.userId;
}

-(NSString*)getPlace_id{
    return self.place.pid;
}


-(void) dealloc{    
    [createdAt release];
    [message release];
    [sender release];
    [receiver release];
    [place release];
    
    [super dealloc];
}


@end
