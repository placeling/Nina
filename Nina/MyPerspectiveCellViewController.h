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
}

@property(nonatomic,retain) IBOutlet UIScrollView *imageScroll;
@property(nonatomic,retain) IBOutlet UILabel *memoLabel;
@property(nonatomic,retain) Perspective *perspective;

@end
