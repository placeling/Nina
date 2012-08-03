//
//  ActivityTableViewCell.m
//  Nina
//
//  Created by Ian MacKinnon on 11-09-29.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NotificationTableViewCell.h"
#import "NinaHelper.h"
#import "UIImageView+WebCache.h"
#import "NSDictionary+Utility.h"

@interface NotificationTableViewCell (Private) 
+(NSString*) getTitleText:(Notification*)dict;

@end


@implementation NotificationTableViewCell
@synthesize notification, userImage, detailText, titleLabel, timeAgo;

#pragma mark - View lifecycle

+(CGFloat) cellHeightForNotification:(Notification *)notification{

    CGSize textAreaSize;
    textAreaSize.height = 500;
    textAreaSize.width = 265;
    
    CGSize textSize = [[self getTitleText:notification] sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat heightCalc = 21 + 8;
    
    heightCalc += textSize.height;
    
    if (heightCalc < (8 + 32 + 8)) { // top margin + thumbnail + bottom margin
        return 48;
    } else {
        return heightCalc;
    }
}

+(void) setupCell:(NotificationTableViewCell*)cell forNotification:(Notification *)notification{
    CGFloat verticalCursor = cell.titleLabel.frame.origin.y;
    
    cell.notification = notification;
    
    cell.detailText.text = @"";
    cell.titleLabel.text = [self getTitleText:notification];
    
    CGSize textAreaSize;
    textAreaSize.height = 500;
    textAreaSize.width = 265;
    
    CGSize textSize = [[self getTitleText:notification] sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect detailFrame = CGRectMake(cell.titleLabel.frame.origin.x, cell.titleLabel.frame.origin.y, textSize.width, textSize.height);
    
    [cell.titleLabel setFrame:detailFrame];
    
    cell.titleLabel.backgroundColor = [UIColor clearColor];
    
    verticalCursor += cell.titleLabel.frame.size.height;
    
    cell.backgroundColor = [UIColor clearColor];
    
    [cell.userImage.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [cell.userImage.layer setBorderWidth: 2.0];
    cell.userImage.layer.cornerRadius = 1.0f;
    cell.userImage.layer.masksToBounds = YES;
    
    if ( notification.thumb1 ){
        // Here we use the new provided setImageWithURL: method to load the web image
        [cell.userImage setImageWithURL:[NSURL URLWithString:notification.thumb1]
                       placeholderImage:[UIImage imageNamed:@"profile.png"]];
    }
        
    cell.timeAgo.frame = CGRectMake(cell.timeAgo.frame.origin.x, verticalCursor, cell.timeAgo.frame.size.width, cell.timeAgo.frame.size.height);    
    cell.timeAgo.backgroundColor = [UIColor clearColor];
    
    //NSDateFormatter *jsonFormatter = [[RKObjectMapping defaultDateFormatters] objectAtIndex:0];
    NSString *timeGap = [NinaHelper dateDiff:notification.createdAt];
    
    cell.timeAgo.text = timeGap;
}

+(NSString*) getTitleText:(Notification*)notification{
    
    //NSString *activityType = notification.activityType;
    
    if ([notification.notificationType isEqualToString:@"STAR_PERSPECTIVE"]){
        return [NSString stringWithFormat:@"%@ favorited your placemark for %@", notification.actor.username, notification.subjectName];    
    }  else if ([notification.notificationType isEqualToString:@"FOLLOW"]){
        return [NSString stringWithFormat:@"%@ started following you", notification.actor.username]; 
    } else if ( [notification.notificationType isEqualToString:@"FACEBOOK_FRIEND"] ){
        return [NSString stringWithFormat:@"Your Facebook friend %@ joined Placeling as %@", notification.subjectName, notification.actor.username]; 
    } else {
        DLog(@"ERROR: unknown notification story type");
        return @"";
    }
}


-(void) dealloc{
    [notification release];
    [userImage release];
    [detailText release];
    [titleLabel release];
    [timeAgo release];
    [super dealloc];
}


@end
