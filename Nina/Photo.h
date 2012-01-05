//
//  photo.h
//  placeling2
//
//  Created by Lindsay Watt on 11-06-27.
//  Copyright 2011 Placeling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>

@class Perspective;


@interface Photo : NSManagedObject {
    UIImage *thumb_image;
    UIImage *iphone_image;
    UIImage *main_image;
    
    NSString *thumbUrl;
    NSString *iphoneUrl;
    NSString *mainUrl;
    
    NSString *photoId;
    Perspective *perspective;
    BOOL mine;
}

@property (nonatomic, retain) UIImage *thumb_image;
@property (nonatomic, retain) UIImage *iphone_image;
@property (nonatomic, retain) UIImage *main_image;

@property (nonatomic, retain) NSString *thumbUrl;
@property (nonatomic, retain) NSString *iphoneUrl;
@property (nonatomic, retain) NSString *mainUrl;
@property (nonatomic, retain) NSString *photoId;
@property (nonatomic, assign) BOOL mine;
@property (nonatomic, assign) Perspective *perspective; //assign to prevent circular ref

- (void) updateFromJsonDict:(NSDictionary *)jsonDict;

+(RKManagedObjectMapping*)getObjectMapping;

@end
