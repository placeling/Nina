//
//  StyleHelper.m
//  Nina
//
//  Created by Ian MacKinnon on 11-09-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StyleHelper.h"
#import <QuartzCore/QuartzCore.h>

@interface StyleHelper(Private)
+(UIColor*) getTintColour;
+(UIColor*) getPanelColour;
+(void) styleFollowButtonCommon:(UIButton*)button;
@end

@implementation StyleHelper

+(void) styleBackgroundView:(UIView*)view{
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"CanvasBG.png"] ];
    //view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"DarkerCanvas.png"] ];
}

+(void) styleNavigationBar:(UINavigationBar*)navbar{
    navbar.tintColor = [self getTintColour];

    navbar.backgroundColor = [self getTintColour];
    UIImage *image = [UIImage imageNamed: @"TopBar.png"];
    //[image drawInRect:CGRectMake(0, 0, navbar.frame.size.width, navbar.frame.size.height)];
    [navbar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

+(void) styleSearchBar:(UISearchBar*)searchBar{
    searchBar.tintColor = [self getTintColour];
}

+(void) styleToolBar:(UIToolbar *)toolBar{
    toolBar.tintColor = [self getTintColour];
    toolBar.backgroundColor = [self getTintColour];
    UIImage *image = [UIImage imageNamed: @"TopBar.png"];
    //[image drawInRect:CGRectMake(0, 0, navbar.frame.size.width, navbar.frame.size.height)];
    [toolBar setBackgroundImage:image forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
}
     

+(void) styleInfoView:(UIView *)view{
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"InfoViewBG.png"]];    
    //view.opaque =NO;
    //view.layer.opaque = NO;
}

+(void) styleBookmarkButton:(UIButton*)button{
    [button setBackgroundImage:[UIImage imageNamed:@"redLeather.png"] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"MarketingScript" size:30]];
    [button.layer setCornerRadius:5.0f];
    [button.layer setMasksToBounds:YES];
}

+(void) styleMapImage:(UIButton*)button{
    [button.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [button.layer setBorderWidth: 3.0];
}

+(void) styleTagButton:(UIButton*)button forText:(NSString*)text{    
    
    button.titleLabel.textColor = [UIColor whiteColor];
    [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    
    CGSize textsize = [text sizeWithFont:button.titleLabel.font forWidth:100.0 lineBreakMode: button.titleLabel.lineBreakMode];
    CGRect rect = CGRectMake(button.frame.origin.x, 13, textsize.width+8, 26);
    [button setFrame:rect];
    
    [button setTitle:text forState:UIControlStateNormal];    

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, button.frame.size.width, button.frame.size.height);
    [gradient setCornerRadius:4.0];
    gradient.colors = [NSArray arrayWithObjects:(id)[[self getTintColour] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    gradient.startPoint = CGPointMake(0.5, 0.0);
    gradient.endPoint = CGPointMake(0.5, 1.0);
    
    [button.layer setCornerRadius:4.0f];
    [button.layer setShadowColor:[UIColor blackColor].CGColor];
    [button.layer setShadowOpacity:0.8];
    [button.layer setShadowRadius:1.0];
    [button.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    
    button.layer.backgroundColor = [self getTintColour].CGColor;
}

+(void) styleContactInfoButton:(UIButton*)button {
    [button.layer setCornerRadius:5.0f];
    [button.layer setMasksToBounds:YES];
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = [UIColor colorWithRed:203.0f/255.0f green:196.0f/255.0f blue:151.0f/255.0f alpha:1.0f].CGColor;
}

+(void) styleSubmitTypeButton:(UIButton *)button {
    button.layer.borderWidth = 2.0f;
    button.layer.borderColor = [UIColor colorWithRed:193.0f/255.0f green:183.0f/255.0f blue:155.0f/255.0f alpha:0.8f].CGColor;
    [button.layer setCornerRadius:5.0f];
    [button.layer setMasksToBounds:YES];
    [button.layer setBackgroundColor:[UIColor colorWithRed:239.0f/255.0f green:235.0f/255.0f blue:224.0f/255.0f alpha:1.0].CGColor];
    [button.titleLabel setFont:[UIFont fontWithName:@"MarketingScript" size:22]];
    [button.titleLabel setTextColor:[UIColor colorWithRed:194.0f/255.0f green:106.0f/255.0f blue:86.0f/255.0f alpha:1.0]];
}

+(void) styleUserProfilePic:(UIImageView*)imageView{
    [imageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [imageView.layer setBorderWidth: 5.0];
    imageView.layer.masksToBounds = YES;
}


+(void) styleFollowButtonCommon:(UIButton*)button{
    //button.layer.borderWidth = 2.0f;
    //[button.layer setCornerRadius:5.0f];
    
    [button.titleLabel setFont:[UIFont fontWithName:@"MarketingScript" size:15]];
    [button.titleLabel setTextColor:[UIColor whiteColor]];
    [button.layer setMasksToBounds:YES];
}

+(void) styleFollowButton:(UIButton*)button {
    [button setImage:[UIImage imageNamed:@"followButton.png"] forState:UIControlStateNormal];
    //button.layer.backgroundColor = [UIColor colorWithRed:168.0f/255.0f green:213.0f/255.0f blue:157.0f/255.0f alpha:1.0f].CGColor;
    //button.layer.borderColor = [UIColor colorWithRed:61.0f/255.0f green:189.0f/255.0f blue:64.0f/255.0f alpha:1.0f].CGColor;
    
    [StyleHelper styleFollowButtonCommon:button];
}

+(void) styleUnFollowButton:(UIButton*)button {
    [button setImage:[UIImage imageNamed:@"UnfollowButton.png"] forState:UIControlStateNormal];
    //button.layer.backgroundColor = [UIColor colorWithRed:213.0f/255.0f green:168.0f/255.0f blue:157.0f/255.0f alpha:1.0f].CGColor;
    //button.layer.borderColor = [UIColor colorWithRed:189.0f/255.0f green:61.0f/255.0f blue:64.0f/255.0f alpha:1.0f].CGColor;
    
    [StyleHelper styleFollowButtonCommon:button];
}

+(void) styleGenericTableCell:(UITableViewCell*)cell{ 
    cell.textLabel.textColor = [StyleHelper basicTextColor];
    cell.detailTextLabel.textColor = [StyleHelper basicTextColor];
}

+(void) styleQuickPickCell:(PlaceSuggestTableViewCell*)cell{
    
    [StyleHelper colourHomePageLabel:cell.usersLabel];
    
    cell.titleLabel.textColor = [StyleHelper basicTextColor];
    cell.addressLabel.textColor = [StyleHelper basicTextColor];
    cell.distanceLabel.textColor = [StyleHelper basicTextColor];
}

+(void) styleHomePageLabel:(UILabel*)label{
    [label setFont:[UIFont fontWithName:@"Museo 500" size:18]];
    [StyleHelper colourHomePageLabel:label];
}

+(void) colourHomePageLabel:(UILabel*)label{
    label.textColor = [UIColor colorWithRed:1/255.0 green:131/255.0 blue:135/255.0 alpha:1.0]; //[StyleHelper getTintColour];    
}

+(void) colourTitleLabel:(UILabel*)label{
    label.textColor = [UIColor colorWithRed:98/255.0 green:77/255.0 blue:41/255.0 alpha:1.0];
}

+(void) colourTextLabel:(UILabel*)label{
    label.textColor = [StyleHelper basicTextColor];
}

+(UIFont*) textFont{
    return [UIFont fontWithName:@"Helvetica" size:14];
}

+(UIColor*) getTintColour{
    return [UIColor colorWithRed:0/255.0 green:151/255.0 blue:150/255.0 alpha:1.0];
}

+(UIColor*) getPanelColour{
    return [UIColor colorWithRed:201/255.0 green:181/255.0 blue:111/255.0 alpha:1.0];
}

+(UIColor*) basicTextColor{
    return [UIColor colorWithRed:104/255.0 green:80/255.0 blue:38/255.0 alpha:1.0];
}

+(UIColor*) highlightTextColor{
    return [UIColor colorWithRed:27/255.0 green:134/255.0 blue:133/255.0 alpha:1.0];
}

@end
