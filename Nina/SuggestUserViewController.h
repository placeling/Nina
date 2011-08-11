//
//  SuggestUserViewController.h
//  placeling2
//
//  Created by Lindsay Watt on 11-06-07.
//  Copyright 2011 Placeling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface SuggestUserViewController : UITableViewController {
    NSMutableArray *members; // An array where each item is a dictionary with name, photo url and city
}

@property (nonatomic, retain) NSMutableArray *members;

@end