//
//  ActivityTableViewCell.m
//  Nina
//
//  Created by Ian MacKinnon on 11-09-29.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ActivityTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "NinaHelper.h"
#import "asyncimageview.h"

@interface ActivityTableViewCell (Private) 
+(NSString*) getTitleText:(NSDictionary*)dict;

@end


@implementation ActivityTableViewCell
@synthesize activity, userImage, detailText, titleLabel, timeAgo;

#pragma mark - View lifecycle

+(CGFloat) cellHeightForActivity:(NSDictionary*)activity{

    CGSize textAreaSize;
    textAreaSize.height = 500;
    textAreaSize.width = 265;
    
    CGSize textSize = [[self getTitleText:activity] sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat heightCalc = 21 + 8;
    
    heightCalc += textSize.height;
    
    if (heightCalc < (8 + 32 + 8)) { // top margin + thumbnail + bottom margin
        return 48;
    } else {
        return heightCalc;
    }
}

+(void) setupCell:(ActivityTableViewCell*)cell forActivity:(NSDictionary*)activity{
    CGFloat verticalCursor = cell.titleLabel.frame.origin.y;
    
    cell.activity = activity;
    
    cell.detailText.text = @"";
    cell.titleLabel.text = [self getTitleText:activity];
    
    CGSize textAreaSize;
    textAreaSize.height = 500;
    textAreaSize.width = 265;
    
    CGSize textSize = [[self getTitleText:activity] sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect detailFrame = CGRectMake(cell.titleLabel.frame.origin.x, cell.titleLabel.frame.origin.y, textSize.width, textSize.height);
    
    [cell.titleLabel setFrame:detailFrame];
    
    cell.titleLabel.backgroundColor = [UIColor clearColor];
    
    verticalCursor += cell.titleLabel.frame.size.height;
    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.userImage.layer.cornerRadius = 1.0f;
    cell.userImage.layer.borderWidth = 1.0f;
    cell.userImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    cell.userImage.layer.masksToBounds = YES;
    
    cell.userImage.image = [UIImage imageNamed:@"default_profile_image.png"];
    
    if ([activity objectForKey:@"thumb1"]){
        Photo *profilePic = [[Photo alloc] init];
        profilePic.thumb_url = [activity objectForKey:@"thumb1"];
        
        AsyncImageView *aImageView = [[AsyncImageView alloc] initWithPhoto:profilePic];
        aImageView.frame = cell.userImage.frame;
        aImageView.populate = cell.userImage;
        [aImageView loadImage];
        [cell addSubview:aImageView]; //mostly to handle de-allocation
        [aImageView release];
        [profilePic release];
    }
    
    
    cell.timeAgo.frame = CGRectMake(cell.timeAgo.frame.origin.x, verticalCursor, cell.timeAgo.frame.size.width, cell.timeAgo.frame.size.height);    
    cell.timeAgo.backgroundColor = [UIColor clearColor];
    
    NSString *timeGap = [NinaHelper dateDiff:[activity objectForKey:@"updated_at"]];

    
    cell.timeAgo.text = timeGap;
}

+(NSString*) getTitleText:(NSDictionary*)dict{
    
    NSString *activityType = [dict objectForKey:@"activity_type"];
    
    if ([activityType isEqualToString:@"UPDATE_PERSPECTIVE"]){
        return [NSString stringWithFormat:@"%@ updated bookmark on %@", [dict objectForKey:@"username1"], [dict objectForKey:@"subject_title"]];
    }else if ([activityType isEqualToString:@"NEW_PERSPECTIVE"]){
        return [NSString stringWithFormat:@"%@ bookmarked %@", [dict objectForKey:@"username1"], [dict objectForKey:@"subject_title"]];    
        
    } else if ([activityType isEqualToString:@"STAR_PERSPECTIVE"]){
        return [NSString stringWithFormat:@"%@ favorited %@'s bookmark for %@", [dict objectForKey:@"username1"], [dict objectForKey:@"username2"], [dict objectForKey:@"subject_title"]];    
        
    }  else if ([activityType isEqualToString:@"FOLLOW"]){
        return [NSString stringWithFormat:@"%@ started following %@", [dict objectForKey:@"username1"], [dict objectForKey:@"username2"]];    
    } else {
        DLog(@"ERROR: unknown activity story type");
        return @"";
    }
}


-(void) dealloc{
    [activity release];
    [userImage release];
    [detailText release];
    [titleLabel release];
    [timeAgo release];
    [super dealloc];
}


@end
