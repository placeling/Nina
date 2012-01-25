//
//  Advertisement.m
//  Nina
//
//  Created by Ian MacKinnon on 12-01-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Advertisement.h"

@implementation Advertisement

@synthesize adType;

+(RKObjectMapping*)getObjectMapping{
    RKObjectMapping* adMapping = [RKObjectMapping mappingForClass:[Advertisement class]];
    [adMapping mapKeyPathsToAttributes:

     @"ad_type", @"adType",
     nil];
    
    return adMapping;
}

@end
