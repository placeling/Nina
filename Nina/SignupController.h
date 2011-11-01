//
//  SignupController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-09-06.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NinaHelper.h"
#import "ASIHTTPRequest.h"
#import "Facebook.h"

@interface SignupController : UITableViewController<ASIHTTPRequestDelegate, UITextFieldDelegate>{
    NSDictionary *fbDict;
    
    NSString *accessKey;
    NSString *accessSecret;
    
    IBOutlet UIView *tableFooterView;
    IBOutlet UIButton *termsButton;
    IBOutlet UIButton *privacyButton;

}


@property(nonatomic,retain) NSDictionary *fbDict;
@property(nonatomic,retain) NSString *accessKey;
@property(nonatomic,retain) NSString *accessSecret;
@property(nonatomic,retain) IBOutlet UIView *tableFooterView;
@property(nonatomic,retain) IBOutlet UIButton *termsButton;
@property(nonatomic,retain) IBOutlet UIButton *privacyButton;

-(IBAction)signup;
-(IBAction)showTerms;
-(IBAction)showPrivacy;

@end
