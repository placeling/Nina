//
//  PlaceSuggestTableViewCell.h
//  Nina
//
//  Created by Ian MacKinnon on 11-10-05.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//



@interface PlaceSuggestTableViewCell : UITableViewCell{
    
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *addressLabel;
    IBOutlet UILabel *distanceLabel;
    IBOutlet UILabel *usersLabel; 
}

@property(nonatomic, retain) IBOutlet UIImageView *imageView;
@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UILabel *addressLabel;
@property(nonatomic, retain) IBOutlet UILabel *distanceLabel;
@property(nonatomic, retain) IBOutlet UILabel *usersLabel; 

@end
