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

@synthesize thumb_image, iphone_image, main_image, perspective;

@dynamic thumbUrl,iphoneUrl,mainUrl, photoId, mine;


- (void) updateFromJsonDict:(NSDictionary *)jsonDict{
    self.photoId = [jsonDict objectForKey:@"id"];
    
    self.iphoneUrl = [jsonDict objectForKeyNotNull:@"iphone_url"];
    self.mainUrl = [jsonDict objectForKeyNotNull:@"main_url"];
    self.thumbUrl = [jsonDict objectForKeyNotNull:@"thumb_url"];
}

+(RKManagedObjectMapping*)getObjectMapping{
    RKManagedObjectMapping* photoMapping = [RKManagedObjectMapping mappingForClass:[Photo class]];
    [photoMapping mapKeyPathsToAttributes:
        @"id", @"photoId",
        @"thumb_url", @"thumbUrl",
        @"main_url", @"mainUrl",
     nil];
    photoMapping.primaryKeyAttribute = @"photoId";
    return photoMapping;
}

- (void)dealloc
{
    [thumb_image release];
    [iphone_image release];
    [main_image release];
    
    [thumbUrl release];
    [iphoneUrl release];
    [mainUrl release];
    [photoId release];
    
    [super dealloc];
}

@end
