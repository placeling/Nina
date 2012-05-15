//
//  MyPerspectiveCellViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-08-29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Perspective.h"
#import "NinaHelper.h"

@interface MyPerspectiveCellViewController : UITableViewCell{

    UIScrollView *imageScroll;
    UILabel *memoLabel;
    Perspective *_perspective;
    
    UIView *footerView;
    
    UILabel *footerLabel;
    UILabel *editPromptLabel;
    UIButton *modifyPicsButton;
    UIButton *modifyNotesButton;
    UIButton *showMoreButton;
    UIButton *highlightButton;
    
    UIViewController *requestDelegate;
    
}

@property(nonatomic,retain) IBOutlet UIScrollView *imageScroll;
@property(nonatomic,retain) IBOutlet UILabel *memoLabel;
@property(nonatomic,retain) Perspective *perspective;

@property(nonatomic,retain) IBOutlet UILabel *footerLabel;
@property(nonatomic,retain) IBOutlet UILabel *editPromptLabel;
@property(nonatomic,retain) IBOutlet UIButton *modifyPicsButton;
@property(nonatomic,retain) IBOutlet UIButton *modifyNotesButton;

@property(nonatomic,retain) IBOutlet UIView *footerView;
@property(nonatomic,retain) IBOutlet UIButton *showMoreButton;
@property(nonatomic,retain) IBOutlet UIButton *highlightButton;

@property(nonatomic,assign) UIViewController *requestDelegate;

+(CGFloat) cellHeightForPerspective:(Perspective*)perspective;
+(void) setupCell:(MyPerspectiveCellViewController*)cell forPerspective:(Perspective*)perspective;


@end
