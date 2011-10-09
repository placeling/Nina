//
//  NSDictionary+Utility.h
//  Nina
//
//  Created by Ian MacKinnon on 11-10-09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (Utility) 
- (id)objectForKeyNotNull:(id)key;
@end