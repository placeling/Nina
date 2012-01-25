//
//  Advertisement.h
//  Nina
//
//  Created by Ian MacKinnon on 12-01-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>


@interface Advertisement : NSObject {
    NSString *adType;
}

@property(nonatomic, retain) NSString *adType;

+(RKObjectMapping*)getObjectMapping;

@end
