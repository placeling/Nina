//
//  Advertisement.m
//  Nina
//
//  Created by Ian MacKinnon on 12-01-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Advertisement.h"

@implementation Advertisement

@synthesize adType, targetUrl, imageUrl, height, width;

+(RKObjectMapping*)getObjectMapping{
    RKObjectMapping* adMapping = [RKObjectMapping mappingForClass:[Advertisement class]];
    [adMapping mapKeyPathsToAttributes:

     @"ad_type", @"adType",
     @"target_url", @"targetUrl",
     @"image_url", @"imageUrl",
     @"height", @"height",
     @"width", @"width",
     nil];
    
    return adMapping;
}

@end
