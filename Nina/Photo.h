//
//  photo.h
//  placeling2
//
//  Created by Lindsay Watt on 11-06-27.
//  Copyright 2011 Placeling. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Photo : NSObject {
    UIImage *image;
    NSString *url;
}

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSString *url;

@end
