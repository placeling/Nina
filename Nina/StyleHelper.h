//
//  StyleHelper.h
//  Nina
//
//  Created by Ian MacKinnon on 11-09-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StyleHelper : NSObject

+(void) styleNavigationBar:(UINavigationBar*)navbar;
+(void) styleBackgroundView:(UIView*)view;
+(void) styleSearchBar:(UISearchBar*)searchBar;
+(void) styleToolBar:(UIToolbar *)toolBar;
+(void) styleInfoView:(UIView *)view;
+(void) styleBookmarkButton:(UIButton*)button;
+(void) styleMapImage:(UIButton*)button;

@end
