//
//  PlaceMark.h
//  Nina
//
//  Created by Ian MacKinnon on 11-08-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Perspective.h"
#import <CoreLocation/CoreLocation.h>

@interface PlaceMark : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
    Place *_place;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(id)initWithCoordinate:(CLLocationCoordinate2D) coordinate;
-(id)initWithPlace:(Place*) place;

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;
@property(nonatomic, retain) Place *place;

@end