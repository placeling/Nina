//
//  NinaHelper.m
//  Nina
//
//  Created by Ian MacKinnon on 11-07-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define CONSUMER_KEY @"CyAy0KjXeqZUCoHjgcfo3qSLCDdCgSFhrcH6S4We"
#define CONSUMER_SECRET @"W8TfZ3myhkmA7wYb6B62nmcS9nUl7fsY6Tqw4Dxw"

#import "NinaHelper.h"
#import "OAuthCore.h"

@interface NinaHelper (Private)
    +(NSString*) getAccessToken;
    +(NSString*) getAccessTokenSecret;
    +(void) setAccessTokenSecret:(NSString*)accessToken;
    +(void) setAccessTokenSecret:(NSString*)accessTokenSecret;
@end



@implementation NinaHelper

+(void) handleBadRequest:(ASIHTTPRequest *)request{
    int statusCode = [request responseStatusCode];
    NSString *alertMessage = [[NSString stringWithFormat:@"Request returned %i error", statusCode] init];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage
                                                   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];	
}


+(ASIHTTPRequest*) signOauthRequest:(ASIHTTPRequest *)request{
    [request buildPostBody];
    NSString *header = OAuthorizationHeader([request url],
                                            [request requestMethod],                                            
                                            [request postBody],
                                            CONSUMER_KEY,
                                            CONSUMER_SECRET,
                                            [NinaHelper getAccessToken],
                                            [NinaHelper getAccessTokenSecret]);
    
    [request addRequestHeader:@"Authorization" value:header];
    
    return request;
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

@end
