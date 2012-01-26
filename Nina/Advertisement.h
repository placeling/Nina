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
    NSString *targetUrl;
    NSString *imageUrl;
    NSNumber *height;
    NSNumber *width;
}

@property(nonatomic, retain) NSString *adType;
@property(nonatomic, retain) NSString *targetUrl;
@property(nonatomic, retain) NSString *imageUrl;
@property(nonatomic, retain) NSNumber *height;
@property(nonatomic, retain) NSNumber *width;

+(RKObjectMapping*)getObjectMapping;

@end
