//
//  ApplicationController.m
//  Nina
//
//  Created by Ian MacKinnon on 12-05-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ApplicationController.h"
#import "FlurryAnalytics.h"
#import "NinaAppDelegate.h"
#import <Twitter/Twitter.h>
#import "TWSignedRequest.h"
#import "OAuth+Additions.h"

#import <Accounts/Accounts.h>
#import "UserManager.h"

#define TW_X_AUTH_MODE_KEY                  @"x_auth_mode"
#define TW_X_AUTH_MODE_REVERSE_AUTH         @"reverse_auth"
#define TW_X_AUTH_MODE_CLIENT_AUTH          @"client_auth"
#define TW_X_AUTH_REVERSE_PARMS             @"x_reverse_auth_parameters"
#define TW_X_AUTH_REVERSE_TARGET            @"x_reverse_auth_target"
#define TW_X_AUTH_USERNAME                  @"x_auth_username"
#define TW_X_AUTH_PASSWORD                  @"x_auth_password"
#define TW_SCREEN_NAME                      @"screen_name"
#define TW_USER_ID                          @"user_id"
#define TW_OAUTH_URL_REQUEST_TOKEN          @"https://api.twitter.com/oauth/request_token"
#define TW_OAUTH_URL_AUTH_TOKEN             @"https://api.twitter.com/oauth/access_token"

@interface ApplicationController (Private)
+ (BOOL)_checkForLocalCredentials;
- (void)_handleStep2Response:(NSString *)responseStr;
@end



@implementation ApplicationController


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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

+ (BOOL)_checkForLocalCredentials
{
    BOOL resp = YES;
    
    if (![TWTweetComposeViewController canSendTweet]) {
        //[self showAlert:@"Please configure a Twitter account in Settings." title:@"Yikes"];
        resp = NO;
    }
    
    return resp;
}


-(BOOL) authorizeTwitter{
            
    //  Check to make sure that the user has added his credentials
    if ( [ApplicationController _checkForLocalCredentials] ) {
        //
        //  Step 1)  Ask Twitter for a special request_token for reverse auth
        //
        NSURL *url = [NSURL URLWithString:TW_OAUTH_URL_REQUEST_TOKEN];
        
        // "reverse_auth" is a required parameter
        NSDictionary *dict = [NSDictionary dictionaryWithObject:TW_X_AUTH_MODE_REVERSE_AUTH forKey:TW_X_AUTH_MODE_KEY];
        TWSignedRequest *signedRequest = [[TWSignedRequest alloc] initWithURL:url parameters:dict requestMethod:TWSignedRequestMethodPOST];
        
        [signedRequest performRequestWithHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!data) {
                DLog(@"Unable to receive a request_token.");
            } else {
                NSString *signedReverseAuthSignature = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                DLog(@"%@", signedReverseAuthSignature);
                //
                //  Step 2)  Ask Twitter for the user's auth token and secret
                //           include x_reverse_auth_target=CK2 and x_reverse_auth_parameters=signedReverseAuthSignature parameters
                //
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    ACAccountStore *accountStore;
                    NSDictionary *step2Params = [NSDictionary dictionaryWithObjectsAndKeys:[NinaHelper getTwitterKey], TW_X_AUTH_REVERSE_TARGET, signedReverseAuthSignature, TW_X_AUTH_REVERSE_PARMS, nil];
                    NSURL *authTokenURL = [NSURL URLWithString:TW_OAUTH_URL_AUTH_TOKEN];
                    TWRequest *step2Request = [[TWRequest alloc] initWithURL:authTokenURL parameters:step2Params requestMethod:TWRequestMethodPOST];
                    
                    //  Obtain the user's permission to access the store
                    //
                    //  NB: You *MUST* keep the ACAccountStore around for as long as you need an ACAccount around.  See WWDC 2011 Session 124 for more info.
                    accountStore = [[ACAccountStore alloc] init];
                    ACAccountType *twitterType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
                    
                    [accountStore requestAccessToAccountsWithType:twitterType withCompletionHandler:^(BOOL granted, NSError *error) {
                        if (!granted) {
                            DLog(@"User rejected access to his/her account.");
                        }
                        else {
                            // obtain all the local account instances
                            NSArray *accounts = [accountStore accountsWithAccountType:twitterType];
                            
                            // we can assume that we have at least one account thanks to +[TWTweetComposeViewController canSendTweet], let's return it
                            [step2Request setAccount:[accounts objectAtIndex:0]];
                            [step2Request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                // Thanks to Marc Delling for pointing out that we should check the status code below
                                if (!responseData || ((NSHTTPURLResponse*)response).statusCode >= 400) {
                                    DLog(@"Error occurred in Step 2.  Check console for more info.");
                                }
                                else {
                                    NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                    NSDictionary *dict = [NSURL ab_parseURLQueryString:responseStr];
                                    
                                    DLog(@"The user's info for your server:\n%@", dict);
                                    
                                    
                                    [self handleTwitterCredentials:dict];
                                    [responseStr release];
                                }
                            }];
                        }
                    }];
                });
            }
        }];
        [signedRequest release];
    }    
    
    return true;
}



-(void)handleTwitterCredentials:(NSDictionary *)creds{
    NSString *urlString = [NSString stringWithFormat:@"%@/v1/auth/twitter/add", [NinaHelper getHostname]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIFormDataRequest *request =  [[[ASIFormDataRequest  alloc]  initWithURL:url] autorelease];
    [request setPostValue:[creds objectForKey:@"oauth_token"] forKey:@"token" ];
    [request setPostValue:[creds objectForKey:@"oauth_token_secret"] forKey:@"secret"];
    [request setPostValue:[creds objectForKey:@"user_id"] forKey:@"uid"];
    
    [NinaHelper signRequest:request];
    
    [request startAsynchronous];//fire and forget
    
    User *user = [UserManager sharedMeUser];
    
    Authentication *auth = [[Authentication alloc] init];
    
    auth.uid = [creds objectForKey:@"user_id"];
    auth.token = [creds objectForKey:@"oauth_token"];
    auth.expiry = [NSDate distantFuture];
    auth.provider = @"twitter";
    
    [user.auths addObject:auth];
    [auth release];
    
}

- (void)fbDidLogin {
    NinaAppDelegate *appDelegate = (NinaAppDelegate*)[[UIApplication sharedApplication] delegate];
    Facebook *facebook = appDelegate.facebook;
    facebook.sessionDelegate = appDelegate; //put back where found
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/v1/auth/facebook/add", [NinaHelper getHostname]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIFormDataRequest *request =  [[[ASIFormDataRequest  alloc]  initWithURL:url] autorelease];
    [request setPostValue:[facebook accessToken] forKey:@"token" ];
    [request setPostValue:[facebook expirationDate] forKey:@"expiry" ];
    
    [NinaHelper signRequest:request];
    
    [request startAsynchronous];//fire and forget
    
}

- (void)fbDidNotLogin:(BOOL)cancelled{
    NinaAppDelegate *appDelegate = (NinaAppDelegate*)[[UIApplication sharedApplication] delegate];
    Facebook *facebook = appDelegate.facebook;
    facebook.sessionDelegate = appDelegate; //put back where found
    [FlurryAnalytics logEvent:@"REJECTED_PERMISSIONS"];
} 

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt{
    
}

-(void)fbSessionInvalidated{
    
}

-(void)fbDidLogout{
    
}


@end
