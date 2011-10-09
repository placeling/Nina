//
//  NSDictionary+Utility.m
//  Nina
//
//  Created by Ian MacKinnon on 11-10-09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+Utility.h"


@implementation NSDictionary (Utility)

- (id)objectForKeyNotNull:(NSString *)key {
    id object = [self objectForKey:key];
    if ((NSNull *)object == [NSNull null] || (CFNullRef)object == kCFNull)
        return nil;
    
    return object;
}

@end