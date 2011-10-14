//
//  photo.m
//  placeling2
//
//  Created by Lindsay Watt on 11-06-27.
//  Copyright 2011 Placeling. All rights reserved.
//

#import "Photo.h"
#import "NSDictionary+Utility.h"


@implementation Photo

@synthesize thumb_image, iphone_image, main_image;

@synthesize thumb_url,iphone_url,main_url, photo_id;

- (id) initFromJsonDict:(NSDictionary *)jsonDict{
    if(self = [super init]){
        [self updateFromJsonDict:jsonDict];
	}
	return self;
}

- (void) updateFromJsonDict:(NSDictionary *)jsonDict{
    self.photo_id = [jsonDict objectForKey:@"_id"];
    
    self.iphone_url = [jsonDict objectForKeyNotNull:@"iphone_url"];
    self.main_url = [jsonDict objectForKeyNotNull:@"main_url"];
    self.thumb_url = [jsonDict objectForKeyNotNull:@"thumb_url"];
}

- (void)dealloc
{
    [thumb_image release];
    [iphone_image release];
    [main_image release];
    
    [thumb_url release];
    [iphone_url release];
    [main_url release];
    [photo_id release];
    
    [super dealloc];
}

@end
