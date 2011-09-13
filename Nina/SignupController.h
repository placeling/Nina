//
//  SignupController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-09-06.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NinaHelper.h"
#import "ASIHTTPRequest.h"
#import "Facebook.h"

@interface SignupController : UITableViewController<ASIHTTPRequestDelegate>{
    NSDictionary *fbDict;
    
    NSString *accessKey;
    NSString *accessSecret;
    
    ASIFormDataRequest *request;
}


@property(nonatomic,retain) NSDictionary *fbDict;
@property(nonatomic,retain) NSString *accessKey;
@property(nonatomic,retain) NSString *accessSecret;

-(IBAction)signup;

@end
