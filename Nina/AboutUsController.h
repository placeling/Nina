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
}

@property (nonatomic, retain) IBOutlet UIButton *contactButton;

- (IBAction)contactUs:(id)sender;

@end
