//
//  ASIFormDataRequest+OAuth.m
//
//  Created by Scott James Remnant on 6/3/11.
//  Copyright 2011 Scott James Remnant <scott@netsplit.com>. All rights reserved.
//

#import "ASIFormDataRequest+OAuth.h"


@implementation ASIFormDataRequest (ASIFormDataRequest_OAuth)

- (NSArray *)oauthPostBodyParameters
{
	//if ([fileData count] > 0) this was in original, but it causes some hyper-fails as 
      // it no longer returns postdata, which is still necessary in multi-part
        //return nil;

    return postData;
}

@end
