//
//  SuggestedPlaceController.h
//  Nina
//
//  Created by Ian MacKinnon on 12-01-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NinaHelper.h"
#import "LoginController.h"
#import <RestKit/RestKit.h>
#import "Place.h"

@interface SuggestedPlaceController : UIViewController<LoginControllerDelegate, RKObjectLoaderDelegate>{
    BOOL locationEnabled;
    
    BOOL followingLoaded;
    BOOL popularLoaded;
    
    int initialIndex;
    
    NSMutableArray  *followingPlaces;
    NSMutableArray  *popularPlaces;
    
    NSString* lat;
    NSString* lng;
    
    NSString *searchTerm;
    NSString *category;
}

@property(nonatomic, assign) BOOL followingLoaded;
@property(nonatomic, assign) BOOL popularLoaded;
@property(nonatomic, assign) BOOL locationEnabled;
@property(nonatomic, assign) int initialIndex;;

@property(nonatomic,retain) NSString *searchTerm;
@property(nonatomic,retain) NSString *category;

@property(nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property(nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;

@property(nonatomic,retain) NSString *lat;
@property(nonatomic,retain) NSString *lng;

@property(nonatomic,retain) NSMutableArray  *followingPlaces;
@property(nonatomic,retain) NSMutableArray  *popularPlaces;


-(void)findNearbyPlaces;
-(IBAction)toggleMapList;

-(bool)dataLoaded;
-(NSMutableArray*)places;

@end
