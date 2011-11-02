//
//  AboutUsController.m
//  Nina
//
//  Created by Lindsay Watt on 11-10-17.
//  Copyright 2011 Placeling. All rights reserved.
//

#import "AboutUsController.h"
#import "GenericWebViewController.h"

@implementation AboutUsController

@synthesize contactButton, termsButton, privacyButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"About Placeling";
    [StyleHelper styleBookmarkButton:self.contactButton];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [contactButton release];
    [termsButton release];
    [privacyButton release];
    [super dealloc];
}

#pragma mark -
#pragma mark Contact Us

- (IBAction)contactUs:(id) sender
{
	MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
	controller.mailComposeDelegate = self;
	[controller setSubject:@"Greetings Placeling!"];
    [controller setToRecipients:[NSArray arrayWithObject:@"contact@placeling.com"]];
	if (controller) [self presentModalViewController:controller animated:YES];
	[controller release];	
}

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction) showTerms {
    GenericWebViewController *genericWebViewController = [[GenericWebViewController alloc] initWithUrl:@"http://www.placeling.com/terms/"];
    
    genericWebViewController.title = @"Terms & Conditions";
    [self.navigationController pushViewController:genericWebViewController animated:true];
    
    [genericWebViewController release];
}

-(IBAction) showPrivacy {
    GenericWebViewController *genericWebViewController = [[GenericWebViewController alloc] initWithUrl:@"http://www.placeling.com/privacy/"];
    
    genericWebViewController.title = @"Privacy Policy";
    [self.navigationController pushViewController:genericWebViewController animated:true];
    
    [genericWebViewController release];
}

@end
