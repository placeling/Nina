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
#import "GenericWebViewController.h"
#import "MBProgressHUD.h"
#import "FlurryAnalytics.h"

@interface LoginController (Private)
    -(void)close;
    -(BOOL)testAlreadyLoggedInFacebook:(NSDictionary*)fbDict;
    -(void)dismissKeyboard:(id)sender;
@end


@implementation LoginController


@synthesize username;
@synthesize password;
@synthesize submitButton;
@synthesize forgotPasswordButton;
@synthesize delegate;

-(IBAction) submitLogin{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/oauth/access_token", [plistData objectForKey:@"server_url"]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    [NinaHelper clearCredentials];
    
    ASIFormDataRequest *request =  [[ASIFormDataRequest  alloc]  initWithURL:url];
    [request setPostValue:@"client_auth" forKey:@"x_auth_mode"];
    [request setPostValue:username.text forKey:@"x_auth_username"];
    [request setPostValue:password.text forKey:@"x_auth_password"];
    savedUsername = username.text;
    request.tag = 110;
    [request setDelegate:self];
    
    [request signRequestWithClientIdentifier:[NinaHelper getConsumerKey] secret:[NinaHelper getConsumerSecret]
                             tokenIdentifier:nil secret:nil
                                 usingMethod:ASIOAuthHMAC_SHA1SignatureMethod];
    [request startAsynchronous];
}

-(IBAction) forgotPassword {
    GenericWebViewController *genericWebViewController = [[GenericWebViewController alloc] initWithUrl:[NSString stringWithFormat:@"%@/users/password/new", [NinaHelper getHostname]]];
    
    genericWebViewController.title = @"Reset Password";
    [self.navigationController pushViewController:genericWebViewController animated:true];
    
    [genericWebViewController release];
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

        facebook.sessionDelegate = self;
        [facebook authorize:permissions];
                                 
        [permissions release];
    } else {        
        
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        
        HUD.delegate = self;
        HUD.labelText = @"Authenticating";
        HUD.detailsLabelText = @"Getting Facebook Stuff";
        
        [HUD show:TRUE];
        
        [facebook requestWithGraphPath:@"me" andDelegate:self];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    } 
}

-(BOOL)testAlreadyLoggedInFacebook:(NSDictionary*)fbDict{
    
    NSString *urlString = [NSString stringWithFormat:@"%@/v1/auth/facebook/login", [NinaHelper getHostname]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIFormDataRequest *request =  [[[ASIFormDataRequest  alloc]  initWithURL:url] autorelease];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [request setPostValue:[defaults objectForKey:@"FBAccessTokenKey"] forKey:@"token" ];
    [request setPostValue:[defaults objectForKey:@"FBExpirationDateKey"] forKey:@"expiry" ];
    [request setPostValue:[fbDict objectForKey:@"id"] forKey:@"uid"];

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

- (void)fbDidLogin {
    NinaAppDelegate *appDelegate = (NinaAppDelegate*)[[UIApplication sharedApplication] delegate];
    Facebook *facebook = appDelegate.facebook;
    facebook.sessionDelegate = appDelegate; //put back where found
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    HUD.delegate = self;
    HUD.labelText = @"Authenticating";
    HUD.detailsLabelText = @"Getting Facebook Stuff";
    
    [HUD show:TRUE];
    
    [facebook requestWithGraphPath:@"me" andDelegate:self];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
}

- (void)fbDidNotLogin:(BOOL)cancelled{
    NinaAppDelegate *appDelegate = (NinaAppDelegate*)[[UIApplication sharedApplication] delegate];
    Facebook *facebook = appDelegate.facebook;
    facebook.sessionDelegate = appDelegate; //put back where found
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [FlurryAnalytics logEvent:@"REJECTED_PERMISSIONS"];
} 

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error{
    [HUD hide:TRUE];
    DLog(@"got facebook response: %@", [error localizedDescription]);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSDictionary *details = [error userInfo];
    
    [FlurryAnalytics logEvent:@"UNKNOWN_FB_FAIL" withParameters:details];

    NinaAppDelegate *appDelegate = (NinaAppDelegate*)[[UIApplication sharedApplication] delegate];
    Facebook *facebook = appDelegate.facebook;
    
    facebook.expirationDate = nil;
    facebook.accessToken = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" 
                                                    message:@"Facebook returned a credential error, try again" 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    
}
- (void)request:(FBRequest *)request didLoad:(id)result{
    DLog(@"got facebook response: %@", result);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSDictionary *fbDict = (NSDictionary*)result;
    if (![self testAlreadyLoggedInFacebook:fbDict]){
        SignupController *signupController = [[SignupController alloc ] initWithStyle:UITableViewStyleGrouped];
                                              
        signupController.fbDict = fbDict;
        
        [self.navigationController pushViewController:signupController animated:true];
        
        [signupController release];
    } else {
        [self close];
    }
    [HUD hide:TRUE];    
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


#pragma mark - Unregistered experience methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2 && buttonIndex == 1) {
        DLog(@"Resending confirmation email to : %@", savedUsername);
        NSString *actionURL = [NSString stringWithFormat:@"%@/v1/users/resend", [NinaHelper getHostname] ];
        
        NSURL *url = [NSURL URLWithString:actionURL];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setPostValue:savedUsername forKey:@"username"];
        [request setRequestMethod:@"POST"];
        
        [request setCompletionBlock:^{
            DLog(@"Successfully sent Resend confirmation email");
        }];
        [request setFailedBlock:^{
            DLog(@"Error on triggering Resend");
            [NinaHelper handleBadRequest:request sender:self];
        }];
        [NinaHelper signRequest:request];
        [request startAsynchronous];
        
        [self.navigationController dismissModalViewControllerAnimated:TRUE];
    }
}


#pragma mark ASIhttprequest

- (void)requestFailed:(ASIHTTPRequest *)request{
	//NSError *error = [request error];
    
    int statusCode = [request responseStatusCode];
    NSString *error = [request responseString];
	NSArray *component = [error componentsSeparatedByString:@":"];
    
    if (statusCode == 401){
        UIAlertView *alert;
        
        if ( [[NSString stringWithString:@"unconfirmed"] isEqualToString:[[component objectAtIndex:0] lowercaseString] ] ){
            
            NSString *alertMessage = @"We can't let you log back in until you confirm your email, would you like to resend the confirmation email?";
            alert = [[UIAlertView alloc] 
                     initWithTitle:@"Unconfirmed Email" message:alertMessage 
                     delegate:self cancelButtonTitle:@"Not Now" 
                     otherButtonTitles:@"Resend Email", nil];
            alert.tag = 2;
        } else {
            alert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Incorrect Username/Password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        }
        
        [alert show];
        [alert release];
        DLog(@"401 on oauth login request");
        
	} else { 
		[NinaHelper handleBadRequest:request sender:self];
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
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        
        if (standardUserDefaults && savedUsername){
            [standardUserDefaults setObject:savedUsername forKey:@"current_username"];
        } else {
            DLog(@"FATAL ERROR, NULL standardUserDefaults");
            exit(-1);
        }
        [standardUserDefaults synchronize];
        
        //[delegate viewDidLoad];
        [self close];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.username) {
        [theTextField resignFirstResponder];
        [self.password becomeFirstResponder];
    } else if (theTextField == self.password) {
        [theTextField resignFirstResponder];
        [self performSelector:@selector(submitLogin)];
    }
    
    return YES;
}

-(void)dismissKeyboard:(id)sender {
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
    
    [StyleHelper styleSubmitTypeButton:submitButton];
    
    self.username.delegate = self;
    self.password.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
}

// Dismiss keyboard if tap outside text field and not on button/reset password link
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
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


- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
	HUD = nil;
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

-(void) dealloc{    
    [NinaHelper clearActiveRequests:110];
    [username release];
    [password release];
    [submitButton release];
    [forgotPasswordButton release];    
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt{
    
}

-(void)fbSessionInvalidated{
    
}

-(void)fbDidLogout{
    
}



@end
