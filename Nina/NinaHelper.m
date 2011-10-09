//
//  NinaHelper.m
//  Nina
//
//  Created by Ian MacKinnon on 11-07-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NinaHelper.h"
#import "LoginController.h"
#import "ASIFormDataRequest+OAuth.h"
#import "ASIHTTPRequest+OAuth.h"
#import "FlurryAnalytics.h"


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
    [NinaHelper setAccessToken:nil];
    [NinaHelper setAccessTokenSecret:nil];
    [NinaHelper setUsername:nil];
}

+(void) showLoginController:(UIViewController*)sender{
    LoginController *loginController = [[LoginController alloc] init];
    loginController.delegate = sender;
    
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:loginController];
    [sender.navigationController presentModalViewController:navBar animated:YES];
    [navBar release];
    [loginController release];
}

+(void) handleBadRequest:(ASIHTTPRequest *)request sender:(UIViewController*)sender{
    int statusCode = [request responseStatusCode];
    NSError *error = [request error];
    NSString *errorMessage = [error localizedDescription];
    if (errorMessage == nil){
        errorMessage = @""; //prevents a "nil" error on dictionary creation
    }
    
    if (![[[request url]  host] isEqualToString:[NinaHelper getHostname]]){
        DLog(@"Error for which host isn't a placeling server");
        [FlurryAnalytics logEvent:@"ERROR_NOT_OUR_FAULT"];
        return; //Issue with server we can't really help, likely google
    }
    
    if (statusCode == 401){
        DLog(@"Got a 401, with access_token: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"]);
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"]){
            //only send event on a hard reset
            [FlurryAnalytics logEvent:@"401_CREDENTIAL_RESET"];
        }
       //[self clearCredentials];
        
        //if ([request.responseString rangeOfString:@"BAD_PASS"].location != NSNotFound){
            //[NinaHelper showLoginController:sender];    
        //}
    }  
    if (400 <= statusCode && statusCode <= 499){
        //non-401 400 series server error
        NSNumber *code = [NSNumber numberWithInt:statusCode];
        [FlurryAnalytics logEvent:@"400_ERROR" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                               @"status_code", 
                                                               code, @"message", errorMessage, nil]];
        
        NSString *alertMessage = [NSString stringWithFormat:@"%@ Error", code];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertMessage message:errorMessage
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];	
    } else if (500 <= statusCode && statusCode <= 599){
        //500 series server error
        NSNumber *code = [NSNumber numberWithInt:statusCode];
        [FlurryAnalytics logEvent:@"500_ERROR" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                        @"status_code", 
                                                        code, @"message", errorMessage, nil]];
        
        NSString *alertMessage = [NSString stringWithFormat:@"Server Error\n %@", errorMessage];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];	
    } else if ([error code] == 0 || [error code] == 1){
        //can't connect to server
        [FlurryAnalytics logEvent:@"CONNECT_ERROR" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                   @"message", 
                                                                   errorMessage, nil]];
        NSString *alertMessage = [NSString stringWithFormat:@"Can't Connect to Server"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];	
    } else if ([error code] == 2){
        //timed out
        [FlurryAnalytics logEvent:@"TIMEOUT" ];
        NSString *alertMessage = [NSString stringWithFormat:@"Request Timed Out"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];	
    } else {
        DLog(@"Untested error: %@", errorMessage );
        [FlurryAnalytics logEvent:@"UNKNOWN_ERROR" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  @"message", 
                                                                  errorMessage, nil]];
        NSString *alertMessage = [NSString stringWithFormat:@"Request returned: %@", errorMessage];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];	
    }

}


+(void) signRequest:(ASIHTTPRequest *)request{
    NSString *userAgent = [NSString stringWithFormat:@"nina-client-%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    [request addRequestHeader:@"User-Agent" value:userAgent];
    [request setTimeOutSeconds:120];
    
    if ([request isKindOfClass:[ASIFormDataRequest class]]){
        
        ASIFormDataRequest *formRequest = (ASIFormDataRequest*) request;
        
        CLLocationManager *locationManager = [LocationManagerManager sharedCLLocationManager];
        CLLocation *location =  locationManager.location;
        
        if (location){
            NSString* lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
            NSString* lng = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
            float accuracy = pow(location.horizontalAccuracy,2)  + pow(location.verticalAccuracy,2);
            accuracy = sqrt( accuracy ); //take accuracy as single vector, rather than 2 values -iMack
            
            [formRequest setPostValue:lat forKey:@"lat"];
            [formRequest setPostValue:lng forKey:@"long"];
            [formRequest setPostValue:[NSString stringWithFormat:@"%f", accuracy] forKey:@"accuracy"];
        }
        
        //for debugging, for now.
        for (NSDictionary* dict in [formRequest postData]){
            if ([dict objectForKey:@"value"] == nil){
                DLog(@"ALERT-NULL POST VALUE");
            }
        }
    }
    
    [request signRequestWithClientIdentifier:[NinaHelper getConsumerKey] secret:[NinaHelper getConsumerSecret]
            tokenIdentifier:[NinaHelper getAccessToken] secret:[NinaHelper getAccessTokenSecret]
                                     usingMethod:ASIOAuthHMAC_SHA1SignatureMethod];    

}

+(void) clearActiveRequests:(NSInteger) range{
    //for nil'ing out active asi request to prevent exc_bad_acces on their return
    
    
    for (ASIHTTPRequest *req in ASIHTTPRequest.sharedQueue.operations){
        NSInteger tag = req.tag;
        
        if ((range <= tag && tag < range+10) || (tag >= 1000 && range >= 1000)){
            [req cancel];
            [req setDelegate:nil];
        }
    }
}



+(void) setUsername:(NSString*)username{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
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
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];

    if (standardUserDefaults ){
        [standardUserDefaults setObject:accessToken forKey:@"access_token"];
    } else {
        DLog(@"FATAL ERROR, NULL standardUserDefaults");
        exit(-1);
    }
    [standardUserDefaults synchronize];
}


+(NSString*) getConsumerKey{
    return @"zSlSqVLDnS0sGr8rvGbk4Q2dCpoa1T0zplf284Tt";
}

+(NSString*) getConsumerSecret{
    return @"kODuCtHsB0poBe62J3FfWB2rCEUeyeYQkEWW0R6i";
}

@end
