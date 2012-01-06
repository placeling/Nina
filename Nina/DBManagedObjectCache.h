//
//  DBManagedObjectCache.h
//  Nina
//
//  Created by Ian MacKinnon on 12-01-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RKManagedObjectCache.h>

/**
 * An implementation of the RestKit object cache. The object cache is
 * used to return locally cached objects that live in a known resource path.
 * This can be used to avoid trips to the network.
 */
@interface DBManagedObjectCache : NSObject <RKManagedObjectCache> {
    
}

@end

