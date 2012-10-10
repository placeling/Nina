//
//  Authentication.m
//  Nina
//
//  Created by Ian MacKinnon on 12-02-10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Authentication.h"


@implementation Authentication

@synthesize provider, uid, token, expiry, secret;

+(RKObjectMapping*)getObjectMapping{
    RKObjectMapping* authMapping = [RKObjectMapping mappingForClass:[Authentication class]];
    [authMapping mapKeyPathsToAttributes:
     @"provider", @"provider",
     @"uid", @"uid",
     @"token", @"token",
     @"expiry", @"expiry",
     @"secret", @"secret",
     nil];
        
    return authMapping;
}


- (void)dealloc{    
    [provider release];
    [uid release];
    [token release];
    [secret release];
    [expiry release];
    
    [super dealloc];
}

@end
