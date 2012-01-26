//
//  StyleHelper.h
//  Nina
//
//  Created by Ian MacKinnon on 11-09-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaceSuggestTableViewCell.h"

@interface StyleHelper : NSObject

+(void) styleNavigationBar:(UINavigationBar*)navbar;
+(void) styleBackgroundView:(UIView*)view;
+(void) styleSearchBar:(UISearchBar*)searchBar;
+(void) styleToolBar:(UIToolbar *)toolBar;
+(void) styleInfoView:(UIView *)view;
+(void) styleBookmarkButton:(UIButton*)button;
+(void) styleMapImage:(UIButton*)button;
+(void) styleTagButton:(UIButton*)button;
+(void) styleContactInfoButton:(UIButton*)button;
+(void) styleSubmitTypeButton:(UIButton*)button;
+(void) styleFollowButton:(UIButton*)button;
+(void) styleUnFollowButton:(UIButton*)button;
+(void) styleHomePageLabel:(UILabel*)label;
+(void) styleQuickPickCell:(PlaceSuggestTableViewCell*)cell;
+(void) styleGenericTableCell:(UITableViewCell*)cell;
+(void) colourTitleLabel:(UILabel*)label;
+(void) colourHomePageLabel:(UILabel*)label;

+(void) colourTextLabel:(UILabel*)label;


@end
