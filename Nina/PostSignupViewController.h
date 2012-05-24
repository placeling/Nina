//
//  PostSignupViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 12-05-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "NinaHelper.h"
#import "User.h"
#import "MBProgressHUD.h"
#import "LoginController.h"


@interface PostSignupViewController : UIViewController<UIActionSheetDelegate, ASIHTTPRequestDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RKObjectLoaderDelegate> {
    id <LoginControllerDelegate> delegate;
    MBProgressHUD *HUD;
    
    NSString *username;
    User *user;
    
    UIImage *uploadingImage;
    
    UITextView *textView;
    UITextField *cityField;
    UIImageView *profileImageView;
    UIButton *changeImageButton;
}

@property(nonatomic, assign) id <LoginControllerDelegate> delegate;
@property(nonatomic, retain) NSString *username;
@property(nonatomic, retain) User *user;
@property(nonatomic, retain) UIImage *uploadingImage;
@property(nonatomic, retain) IBOutlet UITextView *textView;
@property(nonatomic, retain) IBOutlet UIImageView *profileImageView;
@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) IBOutlet UIButton *changeImageButton;
@property(nonatomic, retain) IBOutlet UITextField *cityField;

@property(nonatomic, retain) MBProgressHUD *HUD;


-(IBAction)saveUser;

@end
