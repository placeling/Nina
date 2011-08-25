//
//  PerspectiveTableViewCell.h
//  Nina
//
//  Created by Ian MacKinnon on 11-08-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Perspective.h"

@interface PerspectiveTableViewCell : UITableViewCell{
    Perspective *perspective;
    IBOutlet UIImageView *userImage;
    IBOutlet UIButton *upvoteButton;
    IBOutlet UILabel *memoLabel;
}

@property(nonatomic,retain) Perspective *perspective; 
@property(nonatomic,retain) IBOutlet UIImageView *userImage;
@property(nonatomic,retain) IBOutlet UIButton *upvoteButton;
@property(nonatomic,retain) IBOutlet UILabel *memoLabel;

@end
