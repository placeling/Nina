//
//  PlacePageViewController.h
//  placeling2
//
//  Created by Lindsay Watt on 11-06-23.
//  Copyright 2011 Placeling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Perspective.h"
#import "Place.h"
#import "User.h"
#import "ASIHTTPRequestDelegate.h"
#import "NinaHelper.h"

//#import "EditViewController.h"

@interface PlacePageViewController : UIViewController <UIActionSheetDelegate, UIScrollViewDelegate> {        
    NSString *google_id; 
    NSString *google_ref;
    
    Place *place;
    UIImage *mapImage; // Static Google Map of Location
    
    IBOutlet UIButton *bookmarkButton;
    IBOutlet UIButton *phoneButton;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *addressLabel;
    IBOutlet UIImageView *mapImageView;
    IBOutlet UITableView *table;
}

@property BOOL dataLoaded;

@property (nonatomic, retain) NSString *google_id;
@property (nonatomic, retain) NSString *google_ref;
@property (nonatomic, retain) Place *place;
@property (nonatomic, retain) UIImage *mapImage;

@property (nonatomic, retain) IBOutlet UIButton *bookmarkButton;
@property (nonatomic, retain) IBOutlet UIButton *phoneButton;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *addressLabel;
@property (nonatomic, retain) IBOutlet UIImageView *mapImageView;
@property (nonatomic, retain) IBOutlet UITableView *table;

-(IBAction) bookmark;
-(IBAction) phonePlace;


@end
