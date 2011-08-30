//
//  EditPerspectiveViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-08-29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Perspective.h"

@interface EditPerspectiveViewController : UIViewController<UITextViewDelegate>{
    Perspective *_perspective;
    
    IBOutlet UITextView *memoTextView;
    IBOutlet UIButton *photoButton;
}

@property(nonatomic,retain) Perspective *perspective;
@property(nonatomic,retain) IBOutlet UITextView *memoTextView;
@property(nonatomic,retain) IBOutlet UIButton *photoButton;

- (id) initWithPerspective:(Perspective *)perspective;
-(IBAction)savePerspective;
-(IBAction)showPhotos;

@end
