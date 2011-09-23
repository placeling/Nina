//
//  photo.h
//  placeling2
//
//  Created by Lindsay Watt on 11-06-27.
//  Copyright 2011 Placeling. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Photo : NSObject {
    UIImage *thumb_image;
    UIImage *iphone_image;
    UIImage *main_image;
    
    NSString *thumb_url;
    NSString *iphone_url;
    NSString *main_url;
    
    NSString *photo_id;
}

@property (nonatomic, retain) UIImage *thumb_image;
@property (nonatomic, retain) UIImage *iphone_image;
@property (nonatomic, retain) UIImage *main_image;

@property (nonatomic, retain) NSString *thumb_url;
@property (nonatomic, retain) NSString *iphone_url;
@property (nonatomic, retain) NSString *main_url;
@property (nonatomic, retain) NSString *photo_id;


- (id) initFromJsonDict:(NSDictionary *)jsonDict;
- (void) updateFromJsonDict:(NSDictionary *)jsonDict;

@end
