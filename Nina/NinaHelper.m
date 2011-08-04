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

+(void) handleBadRequest:(ASIHTTPRequest *)request sender:(UIViewController*)sender{
    int statusCode = [request responseStatusCode];
    NSString *alertMessage;
    LoginController *loginController;
    
    switch (statusCode) {
        case 401:

            DLog(@"Got a 401, with access_token: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"]);
            
            loginController = [[LoginController alloc] init];
            [sender presentModalViewController:loginController animated:YES];
            
            
            break;
            
        default:            
            alertMessage = [[NSString stringWithFormat:@"Request returned %i error", statusCode] init];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage
                                                           delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [alert release];	
            break;
    }

}

+(void) signRequest:(ASIHTTPRequest *)request{
    [request signRequestWithClientIdentifier:[NinaHelper getConsumerKey] secret:[NinaHelper getConsumerSecret]
            tokenIdentifier:[NinaHelper getAccessToken] secret:[NinaHelper getAccessTokenSecret]
                                     usingMethod:ASIOAuthHMAC_SHA1SignatureMethod];    

}


+(NSString*) getAccessToken{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults objectForKey:@"access_token"];    
}

+(NSString*) getAccessTokenSecret{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults objectForKey:@"access_token_secret"];    
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
    return @"CyAy0KjXeqZUCoHjgcfo3qSLCDdCgSFhrcH6S4We";
}

+(NSString*) getConsumerSecret{
    return @"W8TfZ3myhkmA7wYb6B62nmcS9nUl7fsY6Tqw4Dxw";
}

@end
