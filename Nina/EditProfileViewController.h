//
//  EditProfileViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-10-05.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "MemberProfileViewController.h"
#import "NinaHelper.h"
#import "MBProgressHUD.h"

@interface EditProfileViewController : UITableViewController<UIActionSheetDelegate, ASIHTTPRequestDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    
    NSNumber *lat;
    NSNumber *lng;
    User *user;
    MemberProfileViewController *delegate;
    
    MBProgressHUD *hud;
    UIImage *uploadingImage;
}


@property(nonatomic, retain) User *user;

@property(nonatomic, retain) NSNumber *lat;
@property(nonatomic, retain) NSNumber *lng;
@property(nonatomic, assign) MemberProfileViewController *delegate;

-(IBAction)saveUser;
-(IBAction)updateHomeLocation;

@end
