//
//  LocationManagerManager.h
//  Nina
//
//  Created by Ian MacKinnon on 11-08-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManagerManager : NSObject

+ (id)sharedCLLocationManager;

@end
