//
//  UserManager.h
//  Nina
//
//  Created by Ian MacKinnon on 12-05-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Perspective.h"

@interface UserManager : NSObject

+ (id)sharedMeUser;

+(void) setUser:(User*)user;

+(void) updatePerspective:(Perspective*)perspective;
+(void) removePerspective:(Perspective*)perspective;

@end
