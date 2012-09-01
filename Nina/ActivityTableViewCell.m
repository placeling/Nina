//
//  ActivityTableViewCell.m
//  Nina
//
//  Created by Ian MacKinnon on 11-09-29.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ActivityTableViewCell.h"
#import "NinaHelper.h"
#import "UIImageView+WebCache.h"
#import "NSDictionary+Utility.h"

@interface ActivityTableViewCell (Private) 
+(NSMutableAttributedString*) getTitleTextForActivity:(Activity*)dict;
+(NSMutableAttributedString*) getTitleTextForNotification:(Notification*)dict;
+(void) setupCell:(ActivityTableViewCell*)cell;
@end


@implementation ActivityTableViewCell
@synthesize activity, userImage, notification, titleLabel, timeAgo;

#pragma mark - View lifecycle

+(CGFloat) cellHeightForActivity:(Activity*)activity{

    CGSize textAreaSize;
    textAreaSize.height = 500;
    textAreaSize.width = 265;
    
    CGSize textSize = [[[self getTitleTextForActivity:activity]string] sizeWithFont:[StyleHelper textFont] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat heightCalc = 21 + 8;
    
    heightCalc += textSize.height;
    
    if (heightCalc < (8 + 32 + 8)) { // top margin + thumbnail + bottom margin
        return 48;
    } else {
        return heightCalc;
    }
}

+(CGFloat) cellHeightForNotification:(Notification *)notification{
    
    CGSize textAreaSize;
    textAreaSize.height = 500;
    textAreaSize.width = 265;
    
    CGSize textSize = [[[self getTitleTextForNotification:notification] string] sizeWithFont:[StyleHelper textFont] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat heightCalc = 21 + 8;
    
    heightCalc += textSize.height;
    
    if (heightCalc < (8 + 32 + 8)) { // top margin + thumbnail + bottom margin
        return 48;
    } else {
        return heightCalc;
    }
}

+(void) setupCell:(ActivityTableViewCell*)cell{
    
    CGSize textAreaSize;
    textAreaSize.height = 500;
    textAreaSize.width = 265;
    
    CGFloat verticalCursor = cell.titleLabel.frame.origin.y;
    
    CGSize textSize = [cell.titleLabel.text sizeWithFont:[StyleHelper textFont] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect detailFrame = CGRectMake(cell.titleLabel.frame.origin.x, cell.titleLabel.frame.origin.y, textSize.width, textSize.height);
    
    [cell.titleLabel setFrame:detailFrame];
    
    cell.titleLabel.backgroundColor = [UIColor clearColor];
    
    verticalCursor += cell.titleLabel.frame.size.height;
    
    cell.backgroundColor = [UIColor clearColor];
    
    [cell.userImage.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [cell.userImage.layer setBorderWidth: 2.0];
    cell.userImage.layer.cornerRadius = 1.0f;
    cell.userImage.layer.masksToBounds = YES;
    
    
    cell.timeAgo.frame = CGRectMake(cell.timeAgo.frame.origin.x, verticalCursor, cell.timeAgo.frame.size.width, cell.timeAgo.frame.size.height);
    cell.timeAgo.backgroundColor = [UIColor clearColor];
    
    UIImageView *dividerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, cell.timeAgo.frame.origin.y + cell.timeAgo.frame.size.height +1, 320, 2)];
    [dividerView setImage:[UIImage imageNamed:@"horizontalDivider.png"]];
    [cell addSubview:dividerView];
    [dividerView release];
    
}

+(void) setupCell:(ActivityTableViewCell*)cell forActivity:(Activity*)activity{
    cell.activity = activity;
    
    cell.titleLabel.text = [self getTitleTextForActivity:activity];
    cell.timeAgo.text = [NinaHelper dateDiff:activity.updatedAt];

    // Here we use the new provided setImageWithURL: method to load the web image
    [cell.userImage setImageWithURL:[NSURL URLWithString:activity.thumb1]
                   placeholderImage:[UIImage imageNamed:@"profile.png"]];

    
    return [self setupCell:cell];
}

+(void) setupCell:(ActivityTableViewCell*)cell forNotification:(Notification *)notification{
    cell.notification = notification;
    [cell.titleLabel setText:[self getTitleTextForNotification:notification]];
    cell.timeAgo.text = [NinaHelper dateDiff:notification.createdAt];
    
    // Here we use the new provided setImageWithURL: method to load the web image
    [cell.userImage setImageWithURL:[NSURL URLWithString:notification.actor.profilePic.thumbUrl]
                   placeholderImage:[UIImage imageNamed:@"profile.png"]];

    return [self setupCell:cell];
}


+(NSMutableAttributedString*) getTitleTextForNotification:(Notification*)notification{
    NSString *titleText;
    NSRange actorRange;
    NSRange subjectRange = NSMakeRange (0,0);
    
    if ([notification.notificationType isEqualToString:@"STAR_PERSPECTIVE"]){
        titleText = [NSString stringWithFormat:@"%@ favorited your placemark for %@", notification.actor.username, notification.subjectName];
        actorRange = NSMakeRange (0, [notification.actor.username length]);
        subjectRange = NSMakeRange ([titleText length] - [notification.subjectName length], [notification.subjectName length]);
    }  else if ([notification.notificationType isEqualToString:@"COMMENT_PERSPECTIVE"]){
        titleText = [NSString stringWithFormat:@"%@ commented on your placemark for %@", notification.actor.username, notification.subjectName];
        actorRange = NSMakeRange (0, [notification.actor.username length]);
        subjectRange = NSMakeRange ([titleText length] - [notification.subjectName length], [notification.subjectName length]);
    }else if ([notification.notificationType isEqualToString:@"FOLLOW"]){
        titleText = [NSString stringWithFormat:@"%@ started following you", notification.actor.username];
        actorRange = NSMakeRange (0, [notification.actor.username length]);
    } else if ( [notification.notificationType isEqualToString:@"FACEBOOK_FRIEND"] ){
        titleText = [NSString stringWithFormat:@"Your Facebook friend %@ joined Placeling as %@", notification.subjectName, notification.actor.username];
        actorRange = NSMakeRange ([titleText length] - [notification.actor.username length], [notification.actor.username length]);
        subjectRange = NSMakeRange (21, [notification.subjectName length]);
    } else if ( [notification.notificationType isEqualToString:@"SUGGESTED_PLACE"] ){
        titleText = [NSString stringWithFormat:@"%@ suggested you try %@", notification.actor.username, notification.subjectName];
        actorRange = NSMakeRange (0, [notification.actor.username length]);
        subjectRange = NSMakeRange ([titleText length] - [notification.subjectName length], [notification.subjectName length]);
    } else {
        DLog(@"ERROR: unknown notification story type");
        titleText = @"";
    }
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:titleText];

    UIFont *boldSystemFont = [StyleHelper textFont];
    
    CTFontRef font = CTFontCreateWithName((CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
    if (font) {
        [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(id)font range:NSMakeRange(0,[titleText length])];
        
        [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(id)font range:actorRange];
        [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[[StyleHelper highlightTextColor] CGColor] range:actorRange];
        
        if (subjectRange.length > 0){
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(id)font range:subjectRange];
            [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[[StyleHelper highlightTextColor] CGColor] range:subjectRange];
        }
        CFRelease(font);
    }
    
    return mutableAttributedString;
    
}

+(NSMutableAttributedString*) getTitleTextForActivity:(Activity *)activity{
    NSString *activityType = activity.activityType;
    NSRange actorRange;
    NSRange actor2Range = NSMakeRange (0,0);
    NSRange subjectRange = NSMakeRange (0,0);
    NSString *titleText;
    
    if ([activityType isEqualToString:@"UPDATE_PERSPECTIVE"]){
        titleText = [NSString stringWithFormat:@"%@ updated placemark on %@", activity.username1, activity.subjectTitle];
        actorRange = NSMakeRange (0, [activity.username1 length]);
        subjectRange = NSMakeRange ([titleText length] - [activity.subjectTitle length], [activity.subjectTitle length]);
    }else if ([activityType isEqualToString:@"NEW_PERSPECTIVE"]){
        titleText = [NSString stringWithFormat:@"%@ placemarked %@", activity.username1, activity.subjectTitle];
        actorRange = NSMakeRange (0, [activity.username1 length]);
        subjectRange = NSMakeRange ([titleText length] - [activity.subjectTitle length], [activity.subjectTitle length]);
    } else if ([activityType isEqualToString:@"STAR_PERSPECTIVE"]){
        titleText = [NSString stringWithFormat:@"%@ favorited %@'s placemark for %@", activity.username1, activity.username2, activity.subjectTitle];
        actorRange = NSMakeRange (0, [activity.username1 length]);
        actor2Range =  NSMakeRange ([activity.username1 length]+11, [activity.username2 length]);
        subjectRange = NSMakeRange ([titleText length] - [activity.subjectTitle length], [activity.subjectTitle length]);
    }  else if ([activityType isEqualToString:@"FOLLOW"]){
        titleText = [NSString stringWithFormat:@"%@ started following %@", activity.username1, activity.username2];
        actorRange = NSMakeRange (0, [activity.username1 length]);
        subjectRange = NSMakeRange ([titleText length] - [activity.username2 length], [activity.username2 length]);
        
    } else {
        DLog(@"ERROR: unknown activity story type");
        titleText = @"";
    }
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:titleText];
    
    NSRange boldRange = [titleText rangeOfString:activity.username1 options:NSCaseInsensitiveSearch];
    
    // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
    UIFont *boldSystemFont = [StyleHelper textFont];
    
    CTFontRef font = CTFontCreateWithName((CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
    if (font) {
        [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(id)font range:NSMakeRange(0,[titleText length])];
        
        [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(id)font range:boldRange];
        
        [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[[StyleHelper highlightTextColor] CGColor] range:boldRange];
        if (subjectRange.length > 0){
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(id)font range:subjectRange];
            [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[[StyleHelper highlightTextColor] CGColor] range:subjectRange];
        }
        
        if( actor2Range.length > 0){
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(id)font range:actor2Range];
            [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[[StyleHelper highlightTextColor] CGColor] range:actor2Range];
        }
        
        CFRelease(font);
    }
    
    return mutableAttributedString;
    
}


-(void) dealloc{
    [activity release];
    [userImage release];
    [notification release];
    [titleLabel release];
    [timeAgo release];
    [super dealloc];
}


@end
