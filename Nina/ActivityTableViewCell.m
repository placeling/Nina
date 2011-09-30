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

@interface ActivityTableViewCell (Private) 
+(NSString*) getTitleText:(NSDictionary*)dict;

@end


@implementation ActivityTableViewCell
@synthesize activity, userImage, detailText, titleLabel, timeAgo;

#pragma mark - View lifecycle

+(CGFloat) cellHeightForActivity:(NSDictionary*)activity{

    CGSize textAreaSize;
    textAreaSize.height = 48;
    textAreaSize.width = 270;
    
    CGFloat heightCalc = 47; 
    if ([activity objectForKey:@"detail_text"]){
        CGSize textSize = [[activity objectForKey:@"detail_text"] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
        
        heightCalc += textSize.height;
    }
        
    return heightCalc;
    
}

+(void) setupCell:(ActivityTableViewCell*)cell forActivity:(NSDictionary*)activity{
    CGFloat verticalCursor = cell.titleLabel.frame.origin.y;
    
    cell.activity = activity;
    NSString *titleText = [self getTitleText:activity];
    cell.titleLabel.text =titleText;
    
    verticalCursor += cell.titleLabel.frame.size.height;
    
    if ([activity objectForKey:@"detail_text"]){
        CGRect detailFrame = cell.detailText.frame;
        cell.detailText.text = [activity objectForKey:@"detail_text"];
        
        CGSize textSize = [[activity objectForKey:@"detail_text"] sizeWithFont:cell.detailText.font constrainedToSize:detailFrame.size lineBreakMode:UILineBreakModeWordWrap];
        
        [cell.detailText setFrame:CGRectMake(cell.detailText.frame.origin.y, cell.detailText.frame.origin.y, textSize.width, MAX(textSize.height, 55))];
        
        verticalCursor += cell.detailText.frame.size.height;
    } else{
        cell.detailText.text = @""; //get rid of hipster lorem
        cell.detailText.hidden = TRUE;
    }
    
    cell.timeAgo.frame = CGRectMake(cell.timeAgo.frame.origin.x, verticalCursor, cell.timeAgo.frame.size.width, cell.timeAgo.frame.size.height);

    cell.userImage.layer.cornerRadius = 8.0f;
    cell.userImage.layer.borderWidth = 1.0f;
    cell.userImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    cell.userImage.layer.masksToBounds = YES;
    cell.detailText.backgroundColor = [UIColor clearColor];
    cell.timeAgo.backgroundColor = [UIColor clearColor];
    cell.timeAgo.text = [activity objectForKey:@"created_at"];
    
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
