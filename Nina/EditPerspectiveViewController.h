//
//  EditPerspectiveViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-08-29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Perspective.h"
#import "NinaHelper.h"


@protocol EditPerspectiveDelegate
//so long as it can accept the returned request, its all good.
-(void)requestFailed:(ASIHTTPRequest *)request;
-(void)requestFinished:(ASIHTTPRequest *)request;
@end

@interface EditPerspectiveViewController : UIViewController<UITextViewDelegate>{
    Perspective *_perspective;
    id<EditPerspectiveDelegate> delegate;
    
    IBOutlet UITextView *memoTextView;
    IBOutlet UIButton *photoButton;
}

@property(nonatomic,retain) Perspective *perspective;
@property(nonatomic,retain) IBOutlet UITextView *memoTextView;
@property(nonatomic,retain) IBOutlet UIButton *photoButton;
@property(nonatomic,retain) id<EditPerspectiveDelegate> delegate;

- (id) initWithPerspective:(Perspective *)perspective;
-(IBAction)savePerspective;
-(IBAction)showPhotos;

@end
