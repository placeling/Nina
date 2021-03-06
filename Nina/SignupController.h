//
//  SignupController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-09-06.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "MBProgressHUD.h"

@protocol LoginControllerDelegate;

@interface SignupController : UITableViewController<RKObjectLoaderDelegate, UITextFieldDelegate>{
    NSDictionary *fbDict;
    
    NSString *accessKey;
    NSString *accessSecret;
    
    UIView *tableFooterView;
    UIView *tableHeaderView;
    UIButton *termsButton;
    UIButton *privacyButton;

    id <LoginControllerDelegate> delegate;
    
    UILabel *urlLabel;
    MBProgressHUD *HUD;
}


@property(nonatomic,retain) NSDictionary *fbDict;
@property(nonatomic,retain) NSString *accessKey;
@property(nonatomic,retain) NSString *accessSecret;
@property(nonatomic,retain) IBOutlet UIView *tableFooterView;
@property(nonatomic,retain) IBOutlet UIView *tableHeaderView;
@property(nonatomic,retain) IBOutlet UIButton *termsButton;
@property(nonatomic,retain) IBOutlet UIButton *privacyButton;
@property(nonatomic,retain) IBOutlet UILabel *urlLabel;
@property(nonatomic,retain) MBProgressHUD *HUD;
@property(nonatomic, assign) id <LoginControllerDelegate> delegate;

-(IBAction)signup;
-(IBAction)showTerms;
-(IBAction)showPrivacy;
-(void)usernameChanged:(id)sender;

@end
