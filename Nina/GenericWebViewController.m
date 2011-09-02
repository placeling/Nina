//
//  GenericWebViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-09-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GenericWebViewController.h"
#import "MBProgressHUD.h"

@implementation GenericWebViewController
@synthesize webView, url=_url;

- (id)initWithUrl:(NSString *)url{
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}


-(void)dealloc{
    [webView release];
    [_url release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Share Sheet

-(void) showShareSheet{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari", nil];
    
    [actionSheet showInView:self.view];
    [actionSheet release];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        DLog(@"Open in Safari");
        NSString *url = self.webView.request.URL.absoluteString;
        NSURL *webURL = [NSURL URLWithString:url];
        [[UIApplication sharedApplication] openURL: webURL];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        DLog(@"WARNING - Invalid actionsheet button pressed: %i", buttonIndex);
    }    
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Create NSURL string from formatted string
	NSURL *webUrl = [NSURL URLWithString:self.url];
    
	//URL Requst Object
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:webUrl];
    
	//Load the request in the UIWebView.
	[webView loadRequest:requestObj];
    [webView setDelegate:self];
    
    
    UIBarButtonItem *shareButton =  [[UIBarButtonItem  alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showShareSheet)];
    self.navigationItem.rightBarButtonItem = shareButton;
    [shareButton release];
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Loading";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Can't Load" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
