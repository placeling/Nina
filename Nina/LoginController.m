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
#import "SignupController.h"
#import "NinaAppDelegate.h"
#import "SBJSON.h"
#import "GenericWebViewController.h"
#import "MBProgressHUD.h"
#import "FlurryAnalytics.h"
#import "User.h"
#import "UserManager.h"

@interface LoginController (Private)
    -(void)close;
    -(BOOL)testAlreadyLoggedInFacebook:(NSDictionary*)fbDict;
    -(void)dismissKeyboard:(id)sender;
@end


@implementation LoginController


@synthesize username, password, submitButton;
@synthesize forgotPasswordButton, delegate;

-(IBAction) submitLogin{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/oauth/access_token?newlogin=true", [plistData objectForKey:@"server_url"]];
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
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    
    HUD.delegate = self;
    HUD.labelText = @"Logging in";
    
    [HUD show:TRUE];
}

-(IBAction) forgotPassword {
    GenericWebViewController *genericWebViewController = [[GenericWebViewController alloc] initWithUrl:[NSString stringWithFormat:@"%@/users/password/new", [NinaHelper getHostname]]];
    
    genericWebViewController.title = @"Reset Password";
    [self.navigationController pushViewController:genericWebViewController animated:true];
    
    [genericWebViewController release];
}


-(void) receiveGraphConnection:(FBRequestConnection*)connection
                userDictionary:(NSDictionary<FBGraphUser>*)user
                         error:(NSError*)error{
    [HUD hide:TRUE];
    
    DLog(@"got facebook response: %@", user);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (![self testAlreadyLoggedInFacebook:user]){
        SignupController *signupController = [[SignupController alloc ] initWithStyle:UITableViewStyleGrouped];
        
        signupController.fbDict = user;
        signupController.delegate = delegate;
        
        [self.navigationController pushViewController:signupController animated:true];
        
        [signupController release];
    } else {
        [self close];
    }
    [HUD hide:TRUE];
}


- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    [HUD hide:TRUE];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    switch (state) {
        case FBSessionStateOpen: {
            
            HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            
            HUD.delegate = self;
            HUD.labelText = @"Authenticating";
            HUD.detailsLabelText = @"Getting Facebook Stuff";
            
            [HUD show:TRUE];
            
            [[FBRequest requestForMe] startWithCompletionHandler:
             ^(FBRequestConnection *connection,
               NSDictionary<FBGraphUser> *user,
               NSError *error) {
                 [self receiveGraphConnection:connection userDictionary:user error:error];
             }];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
        }
            break;
        case FBSessionStateClosed:
            
            [FlurryAnalytics logEvent:@"REJECTED_PERMISSIONS"];
            break;
        case FBSessionStateClosedLoginFailed:
           
            DLog(@"got facebook response: %@", [error localizedDescription]);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSDictionary *details = [error userInfo];
            
            [FlurryAnalytics logEvent:@"UNKNOWN_FB_FAIL" withParameters:details];                        
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                            message:@"Facebook returned a credential error, try again"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}


-(IBAction) signupFacebook{
    if (!FBSession.activeSession.isOpen) {
        
        [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObjects:@"email", @"publish_actions", nil] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:TRUE completionHandler:^(FBSession *session,
                                                                                                                                                                                                              FBSessionState state, NSError *error) {
            [self sessionStateChanged:session state:state error:error];
        }];
    } else {
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        
        HUD.delegate = self;
        HUD.labelText = @"Authenticating";
        HUD.detailsLabelText = @"Getting Facebook Stuff";
        
        [HUD show:TRUE];
        
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             [self receiveGraphConnection:connection userDictionary:user error:error];
         }];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    } 
}

-(BOOL)testAlreadyLoggedInFacebook:(NSDictionary*)fbDict{
    
    NSString *urlString = [NSString stringWithFormat:@"%@/v1/auth/facebook/login?newlogin=true", [NinaHelper getHostname]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIFormDataRequest *request =  [[[ASIFormDataRequest  alloc]  initWithURL:url] autorelease];
    [request setPostValue:[FBSession.activeSession accessToken] forKey:@"token" ];
    [request setPostValue:[FBSession.activeSession expirationDate] forKey:@"expiry" ];
    [request setPostValue:[fbDict objectForKey:@"id"] forKey:@"uid"];

    [NinaHelper signRequest:request];

    [request startSynchronous];
    
    NSString *body = [request responseString];
    
    DLog(@"got response back: %@", body);
    
    NSDictionary *jsonDict = [body JSONValue];  
    
    if ( [@"success" isEqualToString:(NSString*)[jsonDict objectForKey:@"status"] ]){
        NSArray *tokens = [[jsonDict objectForKey:@"token"] componentsSeparatedByString:@"&"];
        
        for (NSString* token in tokens){
            NSArray *component = [token componentsSeparatedByString:@"="];
            if ( [@"oauth_token" isEqualToString:[component objectAtIndex:0]] ){
                [NinaHelper setAccessToken:[component objectAtIndex:1]];
            } else if ( [@"oauth_token_secret" isEqualToString:[component objectAtIndex:0]] ){
                [NinaHelper setAccessTokenSecret:[component objectAtIndex:1]];
            }
        } 
        
        User *user = [[User alloc] init];
        [user updateFromJsonDict:[jsonDict objectForKey:@"user"]];    
        
        NSString *userName = user.username;
        [NinaHelper setUsername:userName];
        [UserManager setUser:user];
        
        [user release];
        [[UIApplication sharedApplication] 
         registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeAlert | 
          UIRemoteNotificationTypeBadge | 
          UIRemoteNotificationTypeSound)];
        return true;
    } else {
        return false;
    }
}


-(IBAction) signupOldSchool{
    
    SignupController *signupController = [[SignupController alloc]initWithStyle:UITableViewStyleGrouped];
    signupController.delegate = delegate;
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
    [HUD hide:TRUE];
    
    int statusCode = [request responseStatusCode];
    NSString *error = [request responseString];
	NSArray *component = [error componentsSeparatedByString:@":"];
    
    if (statusCode == 401){
        UIAlertView *alert;
        
        if ( [@"unconfirmed" isEqualToString:[[component objectAtIndex:0] lowercaseString] ] ){
            
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
    [HUD hide:TRUE];
	int statusCode = [request responseStatusCode];
	if (200 != statusCode){
        NSString *body = [request responseString];
        
		DLog(@"got response back: %@", body);
		DLog(@"request finished with non-200, WTF");
    }else {
        NSString *body = [request responseString];
        DLog(@"got response back: %@", body);
        
        
        NSDictionary *jsonDict = [body JSONValue];  
        
        if ( [@"success" isEqualToString:(NSString*)[jsonDict objectForKey:@"status"] ]){
            NSArray *tokens = [[jsonDict objectForKey:@"token"] componentsSeparatedByString:@"&"];
            
            for (NSString* token in tokens){
                NSArray *component = [token componentsSeparatedByString:@"="];
                if ( [@"oauth_token" isEqualToString:[component objectAtIndex:0]] ){
                    [NinaHelper setAccessToken:[component objectAtIndex:1]];
                } else if ( [@"oauth_token_secret" isEqualToString:[component objectAtIndex:0]] ){
                    [NinaHelper setAccessTokenSecret:[component objectAtIndex:1]];
                }
            } 
            
            User *user = [[User alloc] init];
            [user updateFromJsonDict:[jsonDict objectForKey:@"user"]];    
            
            NSString *userName = user.username;
            [NinaHelper setUsername:userName];
            [UserManager setUser:user];
            
            [user release];
            [[UIApplication sharedApplication] 
             registerForRemoteNotificationTypes:
             (UIRemoteNotificationTypeAlert | 
              UIRemoteNotificationTypeBadge | 
              UIRemoteNotificationTypeSound)];
        }
        
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



@end
