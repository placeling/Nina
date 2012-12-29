//
//  LoginController.m
//  
//
//  Created by Ian MacKinnon on 11-08-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginController.h"
#import "SignupController.h"
#import "NinaAppDelegate.h"
#import "SBJSON.h"
#import "GenericWebViewController.h"
#import "MBProgressHUD.h"
#import "Flurry.h"
#import "User.h"
#import "UserManager.h"

@interface LoginController (Private)
    -(void)close;
    -(void)dismissKeyboard:(id)sender;
    -(void)showSignup:(NSDictionary *)user;
@end


@implementation LoginController

@synthesize username, password, submitButton;
@synthesize forgotPasswordButton, delegate;

-(IBAction) submitLogin{
    
    [NinaHelper clearCredentials];
    NSDictionary *authDict = [NSDictionary dictionaryWithKeysAndObjects:
            @"x_auth_mode", @"client_auth",
            @"x_auth_username", username.text,
            @"x_auth_password", password.text,
            @"newlogin", @"true",
                              nil];
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    [objectManager loadObjectsAtResourcePath:@"/oauth/access_token" usingBlock:^(RKObjectLoader* loader) {
        loader.delegate = self;
        loader.method = RKRequestMethodPOST;
        loader.params = authDict;
        loader.userData = [NSNumber numberWithInt:110];
    }];

    savedUsername = username.text;
    
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
    
    DLog(@"got facebook response: %@", user);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSDateFormatter *formatter = (NSDateFormatter*)[RKObjectMapping preferredDateFormatter];
    
    NSDictionary *authDict = [NSDictionary dictionaryWithKeysAndObjects:
                              @"token", [FBSession.activeSession accessToken],
                              @"expiry", [formatter stringFromDate:[FBSession.activeSession expirationDate]],
                              @"uid", [user objectForKey:@"id"],
                              @"newlogin", @"true", nil];
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    [objectManager loadObjectsAtResourcePath:@"/v1/auth/facebook/login" usingBlock:^(RKObjectLoader* loader) {
        loader.method = RKRequestMethodPOST;
        loader.params = authDict;
        loader.userData = [NSNumber numberWithInt:110];
        
        loader.onDidLoadObjects = ^(NSArray *objects) {
            NSDictionary *jsonDict = [loader.response.bodyAsString JSONValue];
            [HUD hide:TRUE];
            if ( [@"success" isEqualToString:(NSString*)[jsonDict objectForKey:@"status"] ]){
                [self objectLoader:loader didLoadObjects:objects];
                [self close];
            } else {
                [self showSignup:user];
            }
        };
        
        loader.onDidFailWithError = ^(NSError *error) {
            [HUD hide:TRUE];
            [self showSignup:user];
        };
    }];
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
            
            [Flurry logEvent:@"REJECTED_PERMISSIONS"];
            break;
        case FBSessionStateClosedLoginFailed:
           
            DLog(@"got facebook response: %@", [error localizedDescription]);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSDictionary *details = [error userInfo];
            
            [Flurry logEvent:@"UNKNOWN_FB_FAIL" withParameters:details];                        
            
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

-(void) showSignup:(NSDictionary *)user{
    SignupController *signupController = [[SignupController alloc ] initWithStyle:UITableViewStyleGrouped];
    
    signupController.fbDict = user;
    signupController.delegate = delegate;
    
    [self.navigationController pushViewController:signupController animated:true];
    
    [signupController release];
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


#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    [HUD hide:TRUE];
    if ( [(NSNumber*)objectLoader.userData intValue] == 110){
        NSString *body = objectLoader.response.bodyAsString;
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
            
            User *user = [objects objectAtIndex:0];
            
            NSString *userName = user.username;
            [NinaHelper setUsername:userName];
            [UserManager setUser:user];
            
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

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [HUD hide:TRUE];
    DLog(@"Encountered an error: %@", error);

    int statusCode = objectLoader.response.statusCode;
    NSString *errorString = objectLoader.response.bodyAsString;
	NSArray *component = [errorString componentsSeparatedByString:@":"];
    
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
		[NinaHelper handleBadRKRequest:objectLoader.response sender:self];
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
        
        NSDictionary *paramDict = [NSDictionary dictionaryWithObject:savedUsername forKey:@"username"];
        
        [ [RKClient sharedClient] post:@"/v1/users/resend" usingBlock:^(RKRequest *request){
            request.params = paramDict;
            request.onDidFailLoadWithError = ^(NSError* error) {
                [NinaHelper handleBadRKRequest:request.response sender:self];
            };
        }];
        
        
        [self.navigationController dismissModalViewControllerAnimated:TRUE];
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
    [[[[RKObjectManager sharedManager] client] requestQueue] cancelRequestsWithDelegate:self];
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
