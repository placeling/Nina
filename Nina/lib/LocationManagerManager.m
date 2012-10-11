//
//  LocationManagerManager.m
//  Nina
//
//  Created by Ian MacKinnon on 11-08-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationManagerManager.h"


static CLLocationManager *sharedLocationManager = nil;

@implementation LocationManagerManager

#pragma mark Singleton Methods
+ (id)sharedCLLocationManager {
    @synchronized(self) {
        if(sharedLocationManager == nil)
            sharedLocationManager = [[CLLocationManager allocWithZone:NULL] init];
    }
    return sharedLocationManager;
}
+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedCLLocationManager] retain];
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (id)retain {
    return self;
}
- (unsigned)retainCount {
    return UINT_MAX; //denotes an object that cannot be released
}
- (oneway void)release {
    // never release
}
- (id)autorelease {
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
    [sharedLocationManager release];
    [super dealloc];
}
@end
