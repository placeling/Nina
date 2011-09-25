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


@protocol EditPerspectiveDelegate
//so long as it can accept the returned request, its all good.
-(void)requestFailed:(ASIHTTPRequest *)request;
-(void)requestFinished:(ASIHTTPRequest *)request;
@end

@interface EditPerspectiveViewController : UIViewController<UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, ASIHTTPRequestDelegate>{
    Perspective *_perspective;
    id<EditPerspectiveDelegate> delegate;
    
    IBOutlet UITextView *memoTextView;
    IBOutlet UIButton *photoButton;
    
    IBOutlet UIButton *existingButton;
	IBOutlet UIButton *takeButton;
    
    IBOutlet UIScrollView *scrollView;
    
    MBProgressHUD *hud;
    
    NSMutableDictionary *uploadingPics;
    int requestCount;
    
    NSOperationQueue *queue;
}

@property(nonatomic,retain) Perspective *perspective;
@property(nonatomic,retain) IBOutlet UITextView *memoTextView;
@property(nonatomic,retain) IBOutlet UIButton *photoButton;
@property(nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic,retain) IBOutlet UIButton *existingButton;
@property(nonatomic,retain) IBOutlet UIButton *takeButton;
@property(nonatomic,retain) IBOutlet NSOperationQueue *queue;

@property(nonatomic,assign) id<EditPerspectiveDelegate> delegate;

- (id) initWithPerspective:(Perspective *)perspective;
-(IBAction)savePerspective;
-(IBAction)showPhotos;

-(IBAction)existingImage;
-(IBAction)takeImage;


@end
