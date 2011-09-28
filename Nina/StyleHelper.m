//
//  StyleHelper.m
//  Nina
//
//  Created by Ian MacKinnon on 11-09-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StyleHelper.h"

@interface StyleHelper(Private)
+(UIColor*) getTintColour;
@end

@implementation StyleHelper

+(void) styleBackgroundView:(UIView*)view{
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"canvas.png"]];
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

+(UIColor*) getTintColour{
    return [UIColor colorWithRed:0/255.0 green:130/255.0 blue:121/255.0 alpha:1.0];
}

@end
