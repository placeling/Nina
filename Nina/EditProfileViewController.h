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
#import "ApplicationController.h"
#import "NinaHelper.h"
#import "MBProgressHUD.h"
#import "YIPopupTextView.h"


@interface EditProfileViewController : ApplicationController<UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate, RKObjectLoaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, MBProgressHUDDelegate,YIPopupTextViewDelegate>{
    
    NSNumber *lat;
    NSNumber *lng;
    User *user;
    
    MBProgressHUD *HUD;
    UIImage *uploadingImage;
    
    CLLocation *currentLocation;
    UITableView *_tableView;
}


@property(nonatomic, retain) User *user;

@property(nonatomic, retain) NSNumber *lat;
@property(nonatomic, retain) NSNumber *lng;
@property(nonatomic, retain) CLLocation *currentLocation;

@property(nonatomic, retain) IBOutlet UITableView *tableView;

-(IBAction)saveUser;
-(IBAction)updateHomeLocation;

@end
