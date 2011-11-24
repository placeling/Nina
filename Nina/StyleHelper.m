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
@end

@implementation StyleHelper

+(void) styleBackgroundView:(UIView*)view{
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"canvas.png"] ];
}

+(void) styleNavigationBar:(UINavigationBar*)navbar{
    navbar.tintColor = [self getTintColour];
}

+(void) styleSearchBar:(UISearchBar*)searchBar{
    searchBar.tintColor = [self getTintColour];
}

+(void) styleToolBar:(UIToolbar *)toolBar{
    toolBar.tintColor = [self getTintColour];
}

+(void) styleInfoView:(UIView *)view{
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"infoBackground.png"]];    
    view.opaque =NO;
    view.layer.opaque = NO;
}

+(void) styleBookmarkButton:(UIButton*)button{
    [button setBackgroundImage:[UIImage imageNamed:@"redLeather.png"] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"MarketingScript" size:30]];
    [button.layer setCornerRadius:5.0f];
    [button.layer setMasksToBounds:YES];
}

+(void) styleMapImage:(UIButton*)button{
    [button.layer setCornerRadius:4.0f];
    [button.layer setMasksToBounds:YES];
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = [UIColor colorWithRed:203.0f/255.0f green:196.0f/255.0f blue:151.0f/255.0f alpha:1.0f].CGColor;
}

+(void) styleTagButton:(UIButton*)button{
    button.titleLabel.textColor = [UIColor whiteColor];
    [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    
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

+(void) styleFollowButton:(UIButton*)button {
    button.layer.borderWidth = 2.0f;
    [button.layer setCornerRadius:5.0f];
    button.layer.borderColor = [UIColor colorWithRed:189.0f/255.0f green:61.0f/255.0f blue:64.0f/255.0f alpha:1.0f].CGColor;
    button.layer.backgroundColor = [UIColor colorWithRed:213.0f/255.0f green:168.0f/255.0f blue:157.0f/255.0f alpha:1.0f].CGColor;
    [button.titleLabel setFont:[UIFont fontWithName:@"MarketingScript" size:18]];
    [button.titleLabel setTextColor:[UIColor whiteColor]];
    [button.layer setMasksToBounds:YES];
}

+(UIColor*) getTintColour{
    return [UIColor colorWithRed:0/255.0 green:130/255.0 blue:121/255.0 alpha:1.0];
}

+(UIColor*) getPanelColour{
    return [UIColor colorWithRed:201/255.0 green:181/255.0 blue:111/255.0 alpha:1.0];
}




@end
