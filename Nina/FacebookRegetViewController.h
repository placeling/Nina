//
//  FacebookRegetViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 12-07-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NinaHelper.h"
#import "ApplicationController.h"

@interface FacebookRegetViewController : ApplicationController<UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, ASIHTTPRequestDelegate>{
    
}    
-(IBAction) logout;
-(IBAction) signupFacebook;

@end

