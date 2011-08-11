//
//  LoginController.h
//  
//
//  Created by Ian MacKinnon on 11-08-03.
//  Copyright 2011 placeling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"
#import "ASIHTTPRequest.h"
#import "NinaHelper.h"


@interface LoginController : UIViewController<UITextFieldDelegate, ASIHTTPRequestDelegate>{
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
    IBOutlet UIButton *submitButton;
}

@property(nonatomic, retain) IBOutlet UITextField *username;
@property(nonatomic, retain) IBOutlet UITextField *password;
@property(nonatomic, retain) IBOutlet UIButton *submitButton;

-(IBAction) submitLogin;


@end