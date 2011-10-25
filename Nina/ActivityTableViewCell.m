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
    
    cell.timeAgo.frame = CGRectMake(cell.timeAgo.frame.origin.x, verticalCursor, cell.timeAgo.frame.size.width, cell.timeAgo.frame.size.height);    
    cell.timeAgo.backgroundColor = [UIColor clearColor];
    
    // Need to remove last colon in timestamp as will break an NSDateFormatter
    // See http://stackoverflow.com/questions/4330137/parsing-rfc3339-dates-with-nsdateformatter-in-ios-4-x-and-macos-x-10-6-impossib/
    NSString *RFC3339String = [NSString stringWithFormat:@"%@", [activity objectForKey:@"updated_at"]];
    RFC3339String = [RFC3339String stringByReplacingOccurrencesOfString:@":" 
                                                                  withString:@"" 
                                                                     options:0
                                                                       range:NSMakeRange(20, RFC3339String.length-20)];
    
    NSString* format = @"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ";
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale* enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:format];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
    [enUSPOSIXLocale release];
    
    NSString *timeGap = [NSString stringWithFormat:@""];
    
    NSDate *convertedDate = [dateFormatter dateFromString:RFC3339String];
    [dateFormatter release];
    NSDate *todayDate = [NSDate date];
    double ti = [convertedDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    if(ti < 1) {
        timeGap = @"never";
    } else      if (ti < 60) {
        timeGap =  @"less than a minute ago";
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        if (diff == 1) {
            timeGap = [NSString stringWithFormat:@"%d minute ago", diff];
        } else {
            timeGap = [NSString stringWithFormat:@"%d minutes ago", diff];
        }
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        if (diff == 1) {
            timeGap = [NSString stringWithFormat:@"%d hour ago", diff];
        } else {
            timeGap = [NSString stringWithFormat:@"%d hours ago", diff];            
        }
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        if (diff == 1) {
            timeGap = [NSString stringWithFormat:@"%d day ago", diff];
        } else {
            timeGap = [NSString stringWithFormat:@"%d days ago", diff];
        }
    } else {
        timeGap = @"never";
    }
    
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
