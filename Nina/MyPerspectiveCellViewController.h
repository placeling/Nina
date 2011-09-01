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

    IBOutlet UIScrollView *imageScroll;
    IBOutlet UILabel *memoLabel;
    Perspective *_perspective;
    
    IBOutlet UIView *footerView;
    
    IBOutlet UILabel *footerLabel;
    IBOutlet UILabel *editPromptLabel;
    IBOutlet UIButton *modifyPicsButton;
    IBOutlet UIButton *modifyNotesButton;
}

@property(nonatomic,retain) IBOutlet UIScrollView *imageScroll;
@property(nonatomic,retain) IBOutlet UILabel *memoLabel;
@property(nonatomic,retain) Perspective *perspective;

@property(nonatomic,retain) IBOutlet UILabel *footerLabel;
@property(nonatomic,retain) IBOutlet UILabel *editPromptLabel;
@property(nonatomic,retain) IBOutlet UIButton *modifyPicsButton;
@property(nonatomic,retain) IBOutlet UIButton *modifyNotesButton;

@property(nonatomic,retain) IBOutlet UIView *footerView;

+(CGFloat) cellHeightForPerspective:(Perspective*)perspective;
+(void) setupCell:(MyPerspectiveCellViewController*)cell forPerspective:(Perspective*)perspective;


@end
