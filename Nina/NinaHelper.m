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

+(void) showLoginController:(UIViewController*)sender{
    LoginController *loginController = [[LoginController alloc] init];
    [sender presentModalViewController:loginController animated:YES];; 
}

+(void) handleBadRequest:(ASIHTTPRequest *)request sender:(UIViewController*)sender{
    int statusCode = [request responseStatusCode];
    NSError *error = [request error];
    NSString *errorMessage = [error localizedDescription];
    
    if ([error code] == 0){
        //can't connect to server
        NSString *alertMessage = [NSString stringWithFormat:@"Can't Connect to Server"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];	
    } else if ([error code] == 2){
        //timed out
        NSString *alertMessage = [NSString stringWithFormat:@"Request Timed Out"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];	
    } else if (statusCode == 401){
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"access_token"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"access_token_secret"];
        DLog(@"Got a 401, with access_token: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"]);
        
        //if ([request.responseString rangeOfString:@"BAD_PASS"].location != NSNotFound){
            [NinaHelper showLoginController:sender];    
        //}
    } else {
        DLog(@"Untested error: %@", errorMessage );
        NSString *alertMessage = [[NSString stringWithFormat:@"Request returned: %@", errorMessage] init];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];	
    }

}


+(void) signRequest:(ASIHTTPRequest *)request{
    [request signRequestWithClientIdentifier:[NinaHelper getConsumerKey] secret:[NinaHelper getConsumerSecret]
            tokenIdentifier:[NinaHelper getAccessToken] secret:[NinaHelper getAccessTokenSecret]
                                     usingMethod:ASIOAuthHMAC_SHA1SignatureMethod];    

}

+(void) clearActiveRequests:(NSInteger) range{
    //for nil'ing out active asi request to prevent exc_bad_acces on their return
    
    
    for (ASIHTTPRequest *req in ASIHTTPRequest.sharedQueue.operations){
        NSInteger tag = req.tag;
        
        if (range <= tag && tag < range+10){
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
    return @"7pAO2eGdlMn6OHpBoAs7SqkNZlEB2uij2CRhtxWu";
}

+(NSString*) getConsumerSecret{
    return @"bJERnC21b7toDaC8l6zHGI1geY8EPJhDirNxcmcc";
}

@end
