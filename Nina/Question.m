//
//  Question.m
//  Nina
//
//  Created by Ian MacKinnon on 12-08-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Question.h"

@implementation Question

@synthesize title, description, cityName, countryCode, questionId;    
@synthesize lat, lng, score, createdAt, user, answers;

+(RKObjectMapping*)getObjectMapping{
    RKObjectMapping* questionMapping = [RKObjectMapping mappingForClass:[Question class]];
    [questionMapping mapKeyPathsToAttributes:
     @"id", @"questionId",
     @"title", @"title",
     @"description", @"description",
     @"city_name", @"cityName",
     @"country_code", @"countryCode",    
     
     @"lat", @"lat",
     @"lng", @"lng",
     @"score", @"score",
     @"created_at", @"createdAt",
     nil];
    
    [questionMapping mapKeyPath:@"user" toRelationship:@"user" withMapping:[User getObjectMapping]];
    
    [questionMapping mapKeyPath:@"answers" toRelationship:@"answers" withMapping:[Answer getObjectMapping]];
    
    return questionMapping;
}

- (void) dealloc{
    [questionId release];
    [title release];
    [description release];
    [cityName release];
    [countryCode release];        
    [lat release];
    [lng release];
    
    [score release];
    
    [createdAt release];
    
    [user release];
    
    [answers release];
    
    [super dealloc];
}




@end
