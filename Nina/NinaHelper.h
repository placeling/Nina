//
//  NinaHelper.h
//  Nina
//
//  Created by Ian MacKinnon on 11-07-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//single place to define debugging or not -iMack
#ifndef DEBUG 
#define DEBUG 
#endif

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface NinaHelper : NSObject 

+(void) handleBadRequest:(ASIHTTPRequest *)request sender:(UIViewController*)sender;
+(void) signRequest:(ASIHTTPRequest *)request; 

+(void) setAccessToken:(NSString*)accessToken;
+(void) setAccessTokenSecret:(NSString*)accessTokenSecret;

+(NSString*) getAccessToken;
+(NSString*) getAccessTokenSecret;

+(NSString*) getConsumerKey;
+(NSString*) getConsumerSecret;

@end
