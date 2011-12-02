//
//  SuggestUserViewController.h
//  placeling2
//
//  Created by Lindsay Watt on 11-06-07.
//  Copyright 2011 Placeling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "NinaHelper.h"

@interface SuggestUserViewController : UITableViewController<ASIHTTPRequestDelegate> {
    NSMutableArray *members; // An array where each item is a dictionary with name, photo url and city
    BOOL loadingMore;
    
    NSString *query; //for finding users based on a specific area
}

@property (nonatomic, retain) NSMutableArray *members;
@property (nonatomic, retain) NSString *query; 

@end