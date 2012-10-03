//
//  ApplicationController.h
//  Nina
//
//  Created by Ian MacKinnon on 12-05-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApplicationController : UIViewController

-(BOOL) authorizeTwitter;
-(void) handleTwitterCredentials:(NSDictionary*)creds;

@end
