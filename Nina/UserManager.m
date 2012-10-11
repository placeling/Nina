//
//  UserManager.m
//  Nina
//
//  Created by Ian MacKinnon on 12-05-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserManager.h"
#import <RestKit/RestKit.h>

@implementation UserManager

static User *sharedMeUser = nil;

#pragma mark Singleton Methods
+ (id)sharedMeUser {
    
    @synchronized(self) {
        if(sharedMeUser == nil){        
            [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/v1/users/me.json" usingBlock:^(RKObjectLoader* loader) {
                RKObjectMapping *userMapping = [User getObjectMapping];
                loader.objectMapping = userMapping;
                [loader setOnDidLoadObjects:^(NSArray *objects){
                    User *user = [objects objectAtIndex:0];
                    [UserManager setUser:user];
                }];
                [loader sendSynchronously];
            }];
            
        }
    }
    return sharedMeUser;
}

+ (id)sharedMeUserNoGrab {    
    @synchronized(self) {
        if(sharedMeUser == nil){
            return nil;            
        }
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
                [sharedMeUser.perspectives replaceObjectAtIndex:i withObject:newPerspective];
            }
        }
        sharedMeUser.timestamp = [[NSDate date] timeIntervalSince1970];
    }
}

+(void) removePerspective:(Perspective*)deletedPerspective{
    if ( sharedMeUser){
        for ( int i =0; i < [sharedMeUser.perspectives count]; i++){
            Perspective *perspective  = [sharedMeUser.perspectives objectAtIndex:i];
            if ( [perspective.perspectiveId isEqualToString:deletedPerspective.perspectiveId] ){
                [sharedMeUser.perspectives removeObject:perspective];
            }
        }
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
- (oneway void)release {
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
