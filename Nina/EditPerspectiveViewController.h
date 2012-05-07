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
#import "MBProgressHUD.h"
#import "UIPlaceHolderTextView.h"
#import "ApplicationController.h"
#import "CMPopTipView.h"


@protocol EditPerspectiveDelegate
//so long as it can accept the returned request, its all good.
-(void)requestFailed:(ASIHTTPRequest *)request;
-(void)requestFinished:(ASIHTTPRequest *)request;
-(void)updatePerspective:(Perspective *)perspective;
@end

@interface EditPerspectiveViewController : ApplicationController<UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, ASIHTTPRequestDelegate>{
    Perspective *_perspective;
    id<EditPerspectiveDelegate> delegate;
    
    IBOutlet UIPlaceHolderTextView *memoTextView;
    UIButton *photoButton;
    UIButton *facebookButton;
    UIButton *delayButton;
    
    UIButton *existingButton;
	UIButton *takeButton;
    
    IBOutlet UIScrollView *scrollView;
    
    MBProgressHUD *hud;
    
    NSMutableDictionary *uploadingPics;
    int requestCount;
    NSString *updatedMemo;
    
    NSOperationQueue *queue;
    
    bool facebookEnabled;
    bool delayedPost;
    int delayTime;
    
}

@property(nonatomic,retain) Perspective *perspective;
@property(nonatomic,retain) IBOutlet UIPlaceHolderTextView *memoTextView;
@property(nonatomic,retain) IBOutlet UIButton *photoButton;
@property(nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic,retain) IBOutlet UIButton *existingButton;
@property(nonatomic,retain) IBOutlet UIButton *takeButton;
@property(nonatomic,retain) IBOutlet UIButton *facebookButton;
@property(nonatomic,retain) IBOutlet UIButton *delayButton;

@property(nonatomic,retain) IBOutlet NSOperationQueue *queue;
@property(nonatomic,retain) IBOutlet NSString *updatedMemo;

@property(nonatomic,retain) NSMutableDictionary *uploadingPics;

@property(nonatomic,assign) id<EditPerspectiveDelegate> delegate;

- (id) initWithPerspective:(Perspective *)perspective;
-(IBAction)savePerspective;
-(IBAction)showPhotos;

-(IBAction)existingImage;
-(IBAction)takeImage;

-(IBAction)facebookToggle;

-(IBAction)toggleDelayedAction;


@end
