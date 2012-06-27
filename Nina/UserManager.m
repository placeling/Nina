//
//  UserManager.m
//  Nina
//
//  Created by Ian MacKinnon on 12-05-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserManager.h"

@implementation UserManager

static User *sharedMeUser = nil;

#pragma mark Singleton Methods
+ (id)sharedMeUser {
    
    @synchronized(self) {
        if(sharedMeUser == nil)
            sharedMeUser = [[User alloc] init];
    }
    return sharedMeUser;
}

+(void) setUser:(User*)user{
    if (sharedMeUser){
        [sharedMeUser release];
    }
    sharedMeUser = [user retain];
}

+(void) updatePerspective:(Perspective*)newPerspective{
    if ( sharedMeUser){
        for ( int i =0; i < [sharedMeUser.perspectives count]; i++){
            Perspective *perspective  = [sharedMeUser.perspectives objectAtIndex:i];
            if ( [perspective.perspectiveId isEqualToString:newPerspective.perspectiveId] ){
                [sharedMeUser.perspectives removeObjectAtIndex:i];
            }
        }
        [sharedMeUser.perspectives insertObject:newPerspective atIndex:0];
        sharedMeUser.timestamp = [[NSDate date] timeIntervalSince1970];
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedMeUser] retain];
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
- (void)release {
    // never release
}
- (id)autorelease {
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
    [sharedMeUser release];
    [super dealloc];
}
@end