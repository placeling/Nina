//
//  LoginController.m
//  
//
//  Created by Ian MacKinnon on 11-08-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginController.h"
#import "ASIFormDataRequest+OAuth.h"
#import "ASIHTTPRequest+OAuth.h"
#import "NinaHelper.h"

@implementation LoginController


@synthesize username;
@synthesize password;
@synthesize submitButton;

-(IBAction) submitLogin{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/oauth/access_token", [plistData objectForKey:@"server_url"]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIFormDataRequest *request =  [[ASIFormDataRequest  alloc]  initWithURL:url];
    [request setPostValue:@"client_auth" forKey:@"x_auth_mode"];
    [request setPostValue:username.text forKey:@"x_auth_username"];
    [request setPostValue:password.text forKey:@"x_auth_password"];

    [request setDelegate:self];
    
    [request signRequestWithClientIdentifier:[NinaHelper getConsumerKey] secret:[NinaHelper getConsumerSecret]
                             tokenIdentifier:nil secret:nil
                                 usingMethod:ASIOAuthHMAC_SHA1SignatureMethod];
    [request startAsynchronous];
    
}

#pragma mark ASIhttprequest

- (void)requestFailed:(ASIHTTPRequest *)request{
	//NSError *error = [request error];
    
    int statusCode = [request responseStatusCode];
	
    if (statusCode == 401){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"bad_login", "") delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        DLog(@"401 on oauth login request");
        
	} else {
		NSString *body = [request responseString];
        
		DLog(@"Failed on %i, Got BACK: %@",statusCode, body);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"cant_connect", "")
          delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
	
}

- (void)requestFinished:(ASIHTTPRequest *)request{
	// Use when fetching binary data
	int statusCode = [request responseStatusCode];
	if (200 != statusCode){
        NSString *body = [request responseString];
        
		DLog(@"got response back: %@", body);
		DLog(@"request finished with non-200, WTF");
    }else {
        NSString *body = [request responseString];
        DLog(@"got response back: %@", body);
        
        NSArray *tokens = [body componentsSeparatedByString:@"&"];
        
        for (NSString* token in tokens){
            NSArray *component = [token componentsSeparatedByString:@"="];
            if ( [[NSString stringWithString:@"oauth_token"] isEqualToString:[component objectAtIndex:0]] ){
                [NinaHelper setAccessToken:[component objectAtIndex:1]];
            } else if ( [[NSString stringWithString:@"oauth_token_secret"] isEqualToString:[component objectAtIndex:0]] ){
                [NinaHelper setAccessTokenSecret:[component objectAtIndex:1]];
            }
        } 
        
        
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.username) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

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

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [username becomeFirstResponder];
}

- (void)viewDidUnload
{
    [username release];
    [password release];
    [submitButton release];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end