//
//  ActivityTableViewCell.m
//  Nina
//
//  Created by Ian MacKinnon on 11-09-29.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "NinaHelper.h"
#import "UIImageView+WebCache.h"
#import "NSDictionary+Utility.h"

@interface CommentTableViewCell (Private) 
@end


@implementation CommentTableViewCell
@synthesize comment, userImage, detailText, titleLabel, timeAgo;

#pragma mark - View lifecycle

+(CGFloat) cellHeightForComment:(PlacemarkComment*)comment{

    CGSize textAreaSize;
    textAreaSize.height = 500;
    textAreaSize.width = 265;
    NSString *commentText = [NSString stringWithFormat:@"%@ - %@", comment.user.username, comment.comment];
    
    CGSize textSize = [commentText sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat heightCalc = 21 + 8;
    
    heightCalc += textSize.height;
    
    if (heightCalc < (8 + 32 + 8)) { // top margin + thumbnail + bottom margin
        return 48;
    } else {
        return heightCalc;
    }
}

+(void) setupCell:(CommentTableViewCell*)cell forComment:(PlacemarkComment *)comment{
    CGFloat verticalCursor = cell.titleLabel.frame.origin.y;
    
    cell.comment = comment;
    
    NSString *commentText = [NSString stringWithFormat:@"%@ - %@", comment.user.username, comment.comment];
    cell.detailText.text = @"";
    cell.titleLabel.text = commentText;
    
    CGSize textAreaSize;
    textAreaSize.height = 500;
    textAreaSize.width = 265;
    
    CGSize textSize = [commentText  sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect detailFrame = CGRectMake(cell.titleLabel.frame.origin.x, cell.titleLabel.frame.origin.y, textSize.width, textSize.height);
    
    [cell.titleLabel setFrame:detailFrame];
    
    cell.titleLabel.backgroundColor = [UIColor clearColor];
    
    verticalCursor += cell.titleLabel.frame.size.height;
    
    cell.backgroundColor = [UIColor clearColor];
    
    [cell.userImage.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [cell.userImage.layer setBorderWidth: 2.0];
    cell.userImage.layer.cornerRadius = 1.0f;
    cell.userImage.layer.masksToBounds = YES;
    
    
    if ( comment.user.profilePic.thumbUrl ){
        // Here we use the new provided setImageWithURL: method to load the web image
        [cell.userImage setImageWithURL:[NSURL URLWithString:comment.user.profilePic.thumbUrl ]
                       placeholderImage:[UIImage imageNamed:@"profile.png"]];
    }
        
    cell.timeAgo.frame = CGRectMake(cell.timeAgo.frame.origin.x, verticalCursor, cell.timeAgo.frame.size.width, cell.timeAgo.frame.size.height);    
    cell.timeAgo.backgroundColor = [UIColor clearColor];
    
    //NSDateFormatter *jsonFormatter = [[RKObjectMapping defaultDateFormatters] objectAtIndex:0];
    NSString *timeGap = [NinaHelper dateDiff:comment.createdAt];
    
    cell.timeAgo.text = timeGap;
}

-(void) dealloc{
    [comment release];
    [userImage release];
    [detailText release];
    [titleLabel release];
    [timeAgo release];
    [super dealloc];
}


@end
