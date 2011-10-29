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
#import "SignupController.h"
#import "Facebook.h"
#import "NinaAppDelegate.h"
#import "NSString+SBJSON.h"

@interface LoginController (Private)
    -(void)close;
    -(BOOL)testAlreadyLoggedInFacebook:(NSDictionary*)fbDict;
@end


@implementation LoginController


@synthesize username;
@synthesize password;
@synthesize submitButton;
@synthesize delegate;

-(IBAction) submitLogin{
    NSLog(@"Submit login");
    
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
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults ){
        [standardUserDefaults setObject:username.text forKey:@"current_username"];
    } else {
        DLog(@"FATAL ERROR, NULL standardUserDefaults");
        exit(-1);
    }
    [standardUserDefaults synchronize];
    
}


-(IBAction) signupFacebook{
    NinaAppDelegate *appDelegate = (NinaAppDelegate*)[[UIApplication sharedApplication] delegate];
    Facebook *facebook = appDelegate.facebook;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }

    if (![facebook isSessionValid]) {
        NSArray* permissions =  [[NSArray arrayWithObjects:
                                  @"email", @"publish_stream",@"offline_access", nil] retain];

        [facebook authorize:permissions];
                                 
        [permissions release];
    }
    
    
    [facebook requestWithGraphPath:@"me" andDelegate:self];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(BOOL)testAlreadyLoggedInFacebook:(NSDictionary*)fbDict{
    
    NSString *urlString = [NSString stringWithFormat:@"%@/v1/oauth/login_fb", [NinaHelper getHostname]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIFormDataRequest *request =  [[ASIFormDataRequest  alloc]  initWithURL:url];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [request setPostValue:[defaults objectForKey:@"FBAccessTokenKey"] forKey:@"FBAccessTokenKey" ];
    [request setPostValue:[fbDict objectForKey:@"id"] forKey:@"facebook_id"];

    [NinaHelper signRequest:request];

    [request startSynchronous];
    
    NSString *body = [request responseString];

    NSArray *tokens = [body componentsSeparatedByString:@"&"];
    
    if ([tokens count] > 1){
        for (NSString* token in tokens){
            NSArray *component = [token componentsSeparatedByString:@"="];
            if ( [[NSString stringWithString:@"oauth_token"] isEqualToString:[component objectAtIndex:0]] ){
                [NinaHelper setAccessToken:[component objectAtIndex:1]];
            } else if ( [[NSString stringWithString:@"oauth_token_secret"] isEqualToString:[component objectAtIndex:0]] ){
                [NinaHelper setAccessTokenSecret:[component objectAtIndex:1]];
            } else if ( [[NSString stringWithString:@"username"] isEqualToString:[component objectAtIndex:0]] ){
                [NinaHelper setUsername:[component objectAtIndex:1]];
            }
        } 
        return true;
    } else {
        return false;
    }
}

- (void)request:(FBRequest *)request didLoad:(id)result{
    DLog(@"got facebook response: %@", result);
    
    NSDictionary *fbDict = (NSDictionary*)result;
    if (![self testAlreadyLoggedInFacebook:fbDict]){
        SignupController *signupController = [[SignupController alloc ] initWithStyle:UITableViewStyleGrouped];
                                              
        signupController.fbDict = fbDict;
        
        [self.navigationController pushViewController:signupController animated:true];
        
        [signupController release];
    } else {
        [self.navigationController dismissModalViewControllerAnimated:TRUE];
    }
}

-(IBAction) signupOldSchool{
    
    SignupController *signupController = [[SignupController alloc]initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:signupController animated: true];
    [signupController release];
    
}

-(IBAction)cancel{
    [username resignFirstResponder];
    [password resignFirstResponder];
}


#pragma mark ASIhttprequest

- (void)requestFailed:(ASIHTTPRequest *)request{
	//NSError *error = [request error];
    
    int statusCode = [request responseStatusCode];
	
    if (statusCode == 401){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Incorrect Username/Password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
        
        //[delegate viewDidLoad];
        [self close];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    //if (theTextField == self.username) {
    [theTextField resignFirstResponder];
    //}
    return YES;
}

-(void)dismissKeyboard {
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
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

-(void)close{
    [self.delegate loadContent];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
    //                                                                      action:@selector(dismissKeyboard)];
    
    //[self.view addGestureRecognizer:tap];
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [StyleHelper styleNavigationBar:self.navigationController.navigationBar];
    
    UIBarButtonItem *button =  [[UIBarButtonItem  alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    self.navigationItem.leftBarButtonItem = button;
    [button release];
    
    self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_script.png"]] autorelease];
}


// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{

     

}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidUnload
{
    [username release];
    [password release];
    [submitButton release];
    //[delegate release];
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
