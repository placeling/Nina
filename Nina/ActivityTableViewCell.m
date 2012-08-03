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
+(NSString*) getTitleText:(Activity*)dict;

@end


@implementation ActivityTableViewCell
@synthesize activity, userImage, detailText, titleLabel, timeAgo;

#pragma mark - View lifecycle

+(CGFloat) cellHeightForActivity:(Activity*)activity{

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

+(void) setupCell:(ActivityTableViewCell*)cell forActivity:(Activity*)activity{
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
    
    [cell.userImage.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [cell.userImage.layer setBorderWidth: 2.0];
    cell.userImage.layer.cornerRadius = 1.0f;
    cell.userImage.layer.masksToBounds = YES;
    
    
    if ( activity.thumb1 ){
        // Here we use the new provided setImageWithURL: method to load the web image
        [cell.userImage setImageWithURL:[NSURL URLWithString:activity.thumb1]
                       placeholderImage:[UIImage imageNamed:@"profile.png"]];
    }
        
    cell.timeAgo.frame = CGRectMake(cell.timeAgo.frame.origin.x, verticalCursor, cell.timeAgo.frame.size.width, cell.timeAgo.frame.size.height);    
    cell.timeAgo.backgroundColor = [UIColor clearColor];
    
    //NSDateFormatter *jsonFormatter = [[RKObjectMapping defaultDateFormatters] objectAtIndex:0];
    NSString *timeGap = [NinaHelper dateDiff:activity.updatedAt];
    
    cell.timeAgo.text = timeGap;
}

+(NSString*) getTitleText:(Activity*)activity{
    
    NSString *activityType = activity.activityType;
    
    if ([activityType isEqualToString:@"UPDATE_PERSPECTIVE"]){
        return [NSString stringWithFormat:@"%@ updated placemark on %@", activity.username1, activity.subjectTitle];
    }else if ([activityType isEqualToString:@"NEW_PERSPECTIVE"]){
        return [NSString stringWithFormat:@"%@ placemarked %@", activity.username1, activity.subjectTitle];    
        
    } else if ([activityType isEqualToString:@"STAR_PERSPECTIVE"]){
        return [NSString stringWithFormat:@"%@ favorited %@'s placemark for %@", activity.username1, activity.username2, activity.subjectTitle];    
        
    }  else if ([activityType isEqualToString:@"FOLLOW"]){
        return [NSString stringWithFormat:@"%@ started following %@", activity.username1, activity.username2];    
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
