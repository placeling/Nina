//
//  DBManagedObjectCache.m
//  Nina
//
//  Created by Ian MacKinnon on 12-01-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DBManagedObjectCache.h"
#import "User.h"
#import "Photo.h"

@implementation DBManagedObjectCache

- (NSArray*)fetchRequestsForResourcePath:(NSString*)resourcePath {
    /*
    if ([resourcePath isEqualToString:@"/v1/users/imack"]) {
		NSFetchRequest* request = [User requestFirstByAttribute:@"username" withValue:@"imack"];
		return [NSArray arrayWithObject:request];
	}
     */
	
	return nil;
}

@end