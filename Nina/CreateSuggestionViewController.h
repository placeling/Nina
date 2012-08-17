//
//  CreateSuggestionViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 12-08-15.
//
//

#import <UIKit/UIKit.h>
#import "NinaHelper.h"
#import "Suggestion.h"
#import "Place.h"
#import "User.h"
#import <RestKit/RestKit.h>
#import "UIPlaceHolderTextView.h"
#import "MBProgressHUD.h"


@interface CreateSuggestionViewController : UIViewController<UITableViewDataSource, UITabBarControllerDelegate, RKObjectLoaderDelegate, MBProgressHUDDelegate>{
    Place *place;
    User *_user;
    
    UITableView *_tableView;
    UIPlaceHolderTextView *textView;
    UITextField *_textField;
    UIButton *cancelButton;
    
    NSMutableArray *suggestedUsers;
    bool loading;
    
    MBProgressHUD *HUD;
}

@property(nonatomic, retain) Place *place;
@property(nonatomic, retain) User *user;
@property(nonatomic, retain) NSMutableArray *suggestedUsers;
@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet UIPlaceHolderTextView *textView;
@property(nonatomic, retain) IBOutlet UITextField *textField;
@property(nonatomic, retain) IBOutlet UIButton *cancelButton;

-(IBAction)clearUser;

@end
