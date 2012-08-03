//
//  ActivityTableViewCell.h
//  Nina
//
//  Created by Ian MacKinnon on 11-09-29.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Notification.h"

@interface NotificationTableViewCell : UITableViewCell{
    Notification *notification;
    IBOutlet UIImageView *userImage;
    IBOutlet UITextView *detailText;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *timeAgo;
}


@property(nonatomic,retain) Notification *notification;
@property(nonatomic,retain) IBOutlet UIImageView *userImage;
@property(nonatomic,retain) IBOutlet UITextView *detailText;
@property(nonatomic,retain) IBOutlet UILabel *titleLabel;
@property(nonatomic,retain) IBOutlet UILabel *timeAgo;


//for calculating heights
+(CGFloat) cellHeightForNotification:(Notification*)notification;
+(void) setupCell:(NotificationTableViewCell*)cell forNotification:(Notification*)notification;


@end
