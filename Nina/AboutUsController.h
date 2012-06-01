//
//  AboutUsController.h
//  Nina
//
//  Created by Lindsay Watt on 11-10-17.
//  Copyright 2011 Placeling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NinaHelper.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface AboutUsController : UIViewController <MFMailComposeViewControllerDelegate> {
    IBOutlet UIButton *contactButton;
    
    IBOutlet UIButton *termsButton;
    IBOutlet UIButton *privacyButton;
}

@property (nonatomic, retain) IBOutlet UIButton *contactButton;
@property (nonatomic, retain) IBOutlet UIButton *termsButton;
@property (nonatomic, retain) IBOutlet UIButton *privacyButton;

- (IBAction)contactUs:(id)sender;
-(IBAction)showTerms;
-(IBAction)showPrivacy;

-(IBAction) crashPressed:(id) sender;

@end
