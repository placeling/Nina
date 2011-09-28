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
    view.backgroundColor = [self getPanelColour];    
    view.opaque =NO;
    //view.layer.opacity = 0.5;
}

+(void) styleBookmarkButton:(UIButton*)button{
    button.imageView.image = [UIImage imageNamed:@"leather.png"];

}

+(void) styleMapImage:(UIButton*)button{
    //button.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leather.png"] ];
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOpacity = 0.8;
    button.layer.shadowRadius = 5;
    button.layer.shadowOffset = CGSizeMake(6.0f, 6.0f);
    //[UIColor colorWithPatternImage:[UIImage imageNamed:@"leather.png"] ];
}

+(UIColor*) getTintColour{
    return [UIColor colorWithRed:0/255.0 green:130/255.0 blue:121/255.0 alpha:1.0];
}

+(UIColor*) getPanelColour{
    return [UIColor colorWithRed:201/255.0 green:181/255.0 blue:111/255.0 alpha:1.0];
}




@end
