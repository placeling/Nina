//
//  ActivityTableViewCell.h
//  Nina
//
//  Created by Ian MacKinnon on 11-09-29.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Activity.h"
#import "Notification.h"
#import "TTTAttributedLabel.h"

@interface ActivityTableViewCell : UITableViewCell{
    Activity *activity;
    Notification *notification;
    
    IBOutlet UIImageView *userImage;
    TTTAttributedLabel *titleLabel;
    IBOutlet UILabel *timeAgo;
}


@property(nonatomic,retain) Activity *activity;
@property(nonatomic,retain) IBOutlet UIImageView *userImage;
@property(nonatomic,retain) IBOutlet UILabel *timeAgo;
@property(nonatomic,retain) Notification *notification;
@property(nonatomic,retain) IBOutlet TTTAttributedLabel *titleLabel;


//for calculating heights
+(CGFloat) cellHeightForActivity:(Activity*)activity;
+(void) setupCell:(ActivityTableViewCell*)cell forActivity:(Activity*)activity;

+(CGFloat) cellHeightForNotification:(Notification*)notification;
+(void) setupCell:(ActivityTableViewCell*)cell forNotification:(Notification*)notification;

@end
