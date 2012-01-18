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
    
    UIView *tableFooterView;
    UIView *tableHeaderView;
    UIButton *termsButton;
    UIButton *privacyButton;

    UILabel *urlLabel;
}


@property(nonatomic,retain) NSDictionary *fbDict;
@property(nonatomic,retain) NSString *accessKey;
@property(nonatomic,retain) NSString *accessSecret;
@property(nonatomic,retain) IBOutlet UIView *tableFooterView;
@property(nonatomic,retain) IBOutlet UIView *tableHeaderView;
@property(nonatomic,retain) IBOutlet UIButton *termsButton;
@property(nonatomic,retain) IBOutlet UIButton *privacyButton;
@property(nonatomic,retain) IBOutlet UILabel *urlLabel;

-(IBAction)signup;
-(IBAction)showTerms;
-(IBAction)showPrivacy;
-(void)usernameChanged:(id)sender;

@end
