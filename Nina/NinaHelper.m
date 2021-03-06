//
//  NinaHelper.m
//  Nina
//
//  Created by Ian MacKinnon on 11-07-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NinaHelper.h"
#import "LoginController.h"
#import "Flurry.h"
#import <RestKit/RestKit.h>
#import "WBNoticeView.h"
#import "MTPopupWindow.h"
#import "UserManager.h"
#import "Crittercism.h"

@interface NinaHelper()
+(void) handleBadRequest:(int)statuscode host:(NSString*)host error:(NSError *)error sender:(UIViewController*)sender;
@end

@implementation NinaHelper

+(void) handleCoreLocationError:(NSError *)error{
    if ([error domain] == kCLErrorDomain) {		
		// We handle CoreLocation-related errors here
		switch ([error code]) {
			case kCLErrorDenied:
			{
				// Now display problem alert to user.
				UIAlertView *baseAlert;
				NSString *alertTitle = @"Location Needed";
				NSString *alertMessage = @"It's your choice, but Placeling needs your location to be useful\n\nPlease hit the \"Home\" button in the top left, try adding a new place again and allow us to use your location";
				baseAlert = [[UIAlertView alloc] 
							 initWithTitle:alertTitle message:alertMessage 
							 delegate:self cancelButtonTitle:nil 
							 otherButtonTitles:@"OK", nil];
				[baseAlert show];
				[baseAlert release];
			}
			case kCLErrorLocationUnknown:
			{
				// Now display problem alert to user.
				UIAlertView *baseAlert;
				NSString *alertTitle = @"Whoops...";
				NSString *alertMessage = @"Unfortunately we can't pinpoint your location right now. Please try again later";
				baseAlert = [[UIAlertView alloc] 
							 initWithTitle:alertTitle message:alertMessage 
							 delegate:self cancelButtonTitle:nil 
							 otherButtonTitles:@"OK", nil];
				[baseAlert show];
				[baseAlert release];
			}				
			default:
				break;
		}
	} else {
		// All non-CoreLocation errors here
	}

}

+(void) clearCredentials{
    
    //this needs to go first since it's an authenticated call
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"" forKey:@"ios_notification_token"];
    
    if ( [NinaHelper getUsername] ){
        [NinaHelper uploadNotificationToken:@""];
    }
    
    [NinaHelper setAccessToken:nil];
    [NinaHelper setAccessTokenSecret:nil];
    [NinaHelper setUsername:nil];
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [[objectManager client] setOAuth1AccessToken:nil];
    [[objectManager client] setOAuth1AccessTokenSecret:nil];
    
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    
    [UserManager setUser:nil];
    
    for (int i=0; i< 3; i++){
        [defaults removeObjectForKey:[NSString stringWithFormat:@"recent_search_%i", i]];                 
    }
    
    [defaults synchronize];
    
    [FBSession.activeSession closeAndClearTokenInformation];

}

+(void) showLoginController:(UIViewController<LoginControllerDelegate>*)sender{
    LoginController *loginController = [[LoginController alloc] init];
    loginController.delegate = sender;
    
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:loginController];
    [sender.navigationController presentModalViewController:navBar animated:YES];
    [navBar release];
    [loginController release];
}


+(void) handleBadRKRequest:(RKResponse *)response sender:(UIViewController*)sender{
    int statusCode = response.statusCode;
    NSString *host = [[response.request URL] host];
    NSError *error = response.failureError;
    
    [NinaHelper handleBadRequest:statusCode host:host error:error sender:sender];  
}

+(void) handleBadRequest:(int)statusCode host:(NSString*)host error:(NSError *)error sender:(UIViewController*)sender{      
    NSString *errorMessage = [error localizedDescription];
    if (errorMessage == nil){
        errorMessage = @""; //prevents a "nil" error on dictionary creation
    } else {
        DLog(@"ERROR: %@", errorMessage);
    }
    
    if ( host ){
        NSRange textRange =[[[NinaHelper getHostname] lowercaseString] rangeOfString:[host lowercaseString]];
        
        if (textRange.location == NSNotFound){
            DLog(@"Error for which host isn't a placeling server");
            [Flurry logEvent:@"ERROR_NOT_OUR_FAULT"];
            //return; //Issue with server we can't really help, likely google
        }
    }

    if (statusCode == 401){
        DLog(@"Got a 401, with access_token: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"]);
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"]){
            //only send event on a hard reset
            [Flurry logEvent:@"401_CREDENTIAL_RESET"];
        }
        WBNoticeView *nm = [WBNoticeView defaultManager];
        [nm showErrorNoticeInView:sender.view title:@"Unauthorized" message:@"Token fail, please re-login"];
        
       //[self clearCredentials];
    }else if (400 <= statusCode && statusCode <= 499){
        //non-401 400 series server error
        NSNumber *code = [NSNumber numberWithInt:statusCode];
        [Flurry logEvent:@"400_ERROR" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                         code,@"status_code",   errorMessage,@"message", nil]];
        
        NSString *alertMessage = [NSString stringWithFormat:@"%@ Error", code];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertMessage message:errorMessage
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];	
    } else if (statusCode == 503){
        DLog(@"Got a 503, Maintenance mode");
        [MTPopupWindow showWindowWithHTMLFile:@"https://www.placeling.com/503.html" insideView:sender.navigationController.view];
        //[self clearCredentials];
    }else if (500 <= statusCode && statusCode <= 599){
        //500 series server error
        NSNumber *code = [NSNumber numberWithInt:statusCode];
        [Flurry logEvent:@"500_ERROR" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                        code, @"status_code",  errorMessage,@"message", nil]];
        
        NSString *alertMessage = [NSString stringWithFormat:@"Server Error\n %@", errorMessage];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];	
    } else if ([error code] == 0 || [error code] == 1){
        //can't connect to server
        [Flurry logEvent:@"CONNECT_ERROR" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                        errorMessage, @"message", nil]];
        
        WBNoticeView *nm = [WBNoticeView defaultManager];
        [nm showErrorNoticeInView:sender.view title:@"Network Error" message:@"We can't connect to Placeling servers right now."];
        
    } else if ([error code] == 2){
        //timed out
        [Flurry logEvent:@"TIMEOUT" ];
        WBNoticeView *nm = [WBNoticeView defaultManager];
        [nm showErrorNoticeInView:sender.view title:@"Whoops" message:@"Request Timed Out"];
    } else {
        DLog(@"Untested error: %@", errorMessage );
        [Flurry logEvent:@"UNKNOWN_ERROR" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                    errorMessage,@"message", nil]];
        NSString *alertMessage = [NSString stringWithFormat:@"Request returned: %@", errorMessage];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];	
    }

}

+(NSString *)dateDiff:(NSDate *)convertedDate {
    NSDate *todayDate = [NSDate date];
    double ti = [convertedDate timeIntervalSinceDate:todayDate];
    ti = fabs(ti);
    if (ti < 60) {
        return @"less than a minute ago";
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        if (diff == 1){
            return[NSString stringWithFormat:@"%d minute ago", diff];
        } else {
            return[NSString stringWithFormat:@"%d minutes ago", diff];
        }
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        if (diff == 1){
            return[NSString stringWithFormat:@"%d hour ago", diff];
        } else {
            return[NSString stringWithFormat:@"%d hours ago", diff];
        }
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        if (diff == 1){
            return[NSString stringWithFormat:@"%d day ago", diff];
        } else {
            return[NSString stringWithFormat:@"%d days ago", diff];
        }
    } else {
        int diff = round(ti / 60 / 60 / 24 / 30);
        if (diff == 1){
            return[NSString stringWithFormat:@"%d month ago", diff];
        } else {
            return[NSString stringWithFormat:@"%d months ago", diff];
        }
        
    }   
}


+(void) setUsername:(NSString*)username{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [Crittercism setUsername:username];
    
    if (standardUserDefaults ){
        [standardUserDefaults setObject:username forKey:@"current_username"];
    } else {
        DLog(@"FATAL ERROR, NULL standardUserDefaults");
        exit(-1);
    }
    [standardUserDefaults synchronize]; 
}


+(NSString*) getUsername{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if ([standardUserDefaults objectForKey:@"current_username"]){
        return [standardUserDefaults objectForKey:@"current_username"];    
    } else {
        return nil;
    }  
}

+(NSString*) getHostname{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    return [plistData objectForKey:@"server_url"];
}

+(BOOL) isProductionRun{
    return [self.getHostname isEqualToString:@"http://api.placeling.com"] || [self.getHostname isEqualToString:@"https://api.placeling.com"];
}



+(NSString*) metersToLocalizedDistance:(float)m{
    NSLocale *currentUsersLocale = [NSLocale currentLocale];
    DLog(@"Current Locale: %@", [currentUsersLocale localeIdentifier]);
    
    
    if ( [[currentUsersLocale localeIdentifier] isEqualToString:@"en_US"]){
        //Yankee mother fucker
        float ft = 3.2808399 * m; //meters to feet
        
        if (ft < 528){
            return [NSString stringWithFormat:@"%.0f ft", ft];
        } else {
            float mi = ft / 5280;
            return [NSString stringWithFormat:@"%.1f mi", mi];
        }        
        
    } else {
        if (m < 300){
            return [NSString stringWithFormat:@"%.0f m", m];
        } else {
            float km = m / 1000;
            return [NSString stringWithFormat:@"%.1f km", km];
        }       
        
    }
}


+(NSString*) encodeForUrl:(NSString*)string{
    
    NSMutableString *escaped = [NSMutableString stringWithString:[string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];   
    
    [escaped replaceOccurrencesOfString:@"$" withString:@"%24" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"&" withString:@"%26" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"+" withString:@"%2B" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"," withString:@"%2C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"/" withString:@"%2F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@":" withString:@"%3A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@";" withString:@"%3B" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"=" withString:@"%3D" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"?" withString:@"%3F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"@" withString:@"%40" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@" " withString:@"%20" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"\t" withString:@"%09" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"#" withString:@"%23" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"<" withString:@"%3C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@">" withString:@"%3E" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"\"" withString:@"%22" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"\n" withString:@"%0A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    
    return escaped;
}




+(NSString*) getAccessToken{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if ([standardUserDefaults objectForKey:@"access_token"]){
        return [standardUserDefaults objectForKey:@"access_token"];    
    } else {
        return nil;
    }  
}

+(NSString*) getAccessTokenSecret{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if ([standardUserDefaults objectForKey:@"access_token_secret"]){
        return [standardUserDefaults objectForKey:@"access_token_secret"];    
    } else {
        return nil;
    }
}

+(void) setAccessTokenSecret:(NSString*)accessTokenSecret {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [[objectManager client] setOAuth1AccessTokenSecret:accessTokenSecret];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults ){
        [standardUserDefaults setObject:accessTokenSecret forKey:@"access_token_secret"];
    } else {
        DLog(@"FATAL ERROR, NULL standardUserDefaults");
        exit(-1);
    }
    [standardUserDefaults synchronize];
}

+(void) setAccessToken:(NSString*)accessToken {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [[objectManager client] setOAuth1AccessToken:accessToken];
     
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];

    if (standardUserDefaults ){
        [standardUserDefaults setObject:accessToken forKey:@"access_token"];
    } else {
        DLog(@"FATAL ERROR, NULL standardUserDefaults");
        exit(-1);
    }
    [standardUserDefaults synchronize];
}

+(void) uploadNotificationToken:(NSString*)notificationToken{
    
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/v1/ios/update_token" usingBlock:^(RKObjectLoader *loader) {
        loader.method = RKRequestMethodPOST;
        RKParams* params = [RKParams params];
        [params setValue:notificationToken forParam:@"ios_notification_token"];
        loader.params = params;
        loader.onDidLoadResponse = ^(RKResponse *response){
            NSString *responseString = response.bodyAsString;
            DLog( @"Got %@ back from token set", responseString );
        };
        loader.onDidFailWithError = ^(NSError *error){
            DLog( @"%@", [error localizedDescription] );
        };
        
    }];
}

+(void) updateFacebookCredentials:(FBSession*)session forUser:(User*)user{
    
    if (FBSession.activeSession.isOpen) {
        //don't need to send facebook uid, can be grabbed server-side
        Authentication *auth = [[Authentication alloc] init];        
        auth.token = [FBSession.activeSession accessToken];
        auth.expiry = [FBSession.activeSession expirationDate];
        auth.provider = @"facebook";
        
        [[RKObjectManager sharedManager] postObject:auth usingBlock:^(RKObjectLoader *loader) {
            
        }];
        
        [user.auths addObject:auth];
        
        [user retain]; // need this to help along usermanager
        [UserManager setUser:user];
        
        [user release];
        [auth release];

    }
    
}



+(NSString*) getConsumerKey{
    return @"zSlSqVLDnS0sGr8rvGbk4Q2dCpoa1T0zplf284Tt";
}

+(NSString*) getConsumerSecret{
    return @"kODuCtHsB0poBe62J3FfWB2rCEUeyeYQkEWW0R6i";
}


+(BOOL) twitterEnabled {    
    User *user = [UserManager sharedMeUser];
    
    return ( user && user.twitter ); 
}


+(NSString*) getTwitterKey{
    return @"xPkAq3QvMxR4Py1OuI0Mw";
}

+(NSString*) getTwitterSecret{
    return @"23nCVVsBPLfYxjLSnqiR7LML93rv1MVXOUjeJyOWU";
}

+(NSString*) getHtmlWrapper{
    return @"<html><head><link rel='stylesheet' type='text/css' href='style.css' /></head><body>%@</body></html>";
}

@end
