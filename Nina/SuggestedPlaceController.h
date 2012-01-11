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
    
    NSMutableArray  *followingPlaces;
    NSMutableArray  *popularPlaces;
    
    NSString *searchTerm;
    NSString *category;
}

@property(nonatomic, assign) BOOL followingLoaded;
@property(nonatomic, assign) BOOL popularLoaded;
@property(nonatomic,assign) BOOL locationEnabled;

@property(nonatomic,retain) NSString *searchTerm;
@property(nonatomic,retain) NSString *category;

-(void)findNearbyPlaces;
-(IBAction)toggleMapList;

@end
