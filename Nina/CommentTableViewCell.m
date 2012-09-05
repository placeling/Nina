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
@synthesize comment, userImage, titleLabel, timeAgo;

#pragma mark - View lifecycle

+(CGFloat) cellHeightForComment:(PlacemarkComment*)comment{

    CGSize textAreaSize;
    textAreaSize.height = 500;
    textAreaSize.width = 265;
    NSString *commentText = [NSString stringWithFormat:@"%@ - %@", comment.user.username, comment.comment];
    
    CGSize textSize = [commentText sizeWithFont:[StyleHelper textFont] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
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

    cell.titleLabel.text = commentText;
    [cell.titleLabel setText:commentText afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange usernameRange = NSMakeRange(0, [comment.user.username length]);
        
        UIFont *systemFont = [StyleHelper textFont];
        UIFont *boldSystemFont = [UIFont fontWithName:@"Helvetica-Bold" size:systemFont.pointSize];
        
        CTFontRef font = CTFontCreateWithName((CFStringRef)systemFont.fontName, boldSystemFont.pointSize, NULL);
        
        CTFontRef boldFont = CTFontCreateWithName((CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(id)font range:NSMakeRange(0,[commentText length])];
            [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[[StyleHelper basicTextColor] CGColor] range:NSMakeRange(0,[commentText length])];
            
            [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[[StyleHelper highlightTextColor] CGColor] range:usernameRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(id)boldFont range:usernameRange];
            CFRelease(font);
        }
        
        return mutableAttributedString;
    }];
    
    CGSize textAreaSize;
    textAreaSize.height = 500;
    textAreaSize.width = 265;
    
    CGSize textSize = [commentText  sizeWithFont:[StyleHelper textFont] constrainedToSize:textAreaSize lineBreakMode:UILineBreakModeWordWrap];
    
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
                       placeholderImage:[UIImage imageNamed:@"DefaultUserPhoto.png"]];
    }
        
    cell.timeAgo.frame = CGRectMake(cell.timeAgo.frame.origin.x, verticalCursor, cell.timeAgo.frame.size.width, cell.timeAgo.frame.size.height);    
    cell.timeAgo.backgroundColor = [UIColor clearColor];
    cell.timeAgo.textColor = [StyleHelper basicTextColor];
    
    //NSDateFormatter *jsonFormatter = [[RKObjectMapping defaultDateFormatters] objectAtIndex:0];
    NSString *timeGap = [NinaHelper dateDiff:comment.createdAt];
    
    cell.timeAgo.text = timeGap;
}

-(void) dealloc{
    [comment release];
    [userImage release];
    [titleLabel release];
    [timeAgo release];
    [super dealloc];
}


@end
