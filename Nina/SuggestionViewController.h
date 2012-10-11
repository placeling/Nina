//
//  SuggestionViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 12-08-17.
//
//

#import <UIKit/UIKit.h>
#import "Suggestion.h"
#import <RestKit/RestKit.h>
#import "MBProgressHUD.h"
#import "NinaHelper.h"
#import "EditPerspectiveViewController.h"
#import "Perspective.h"

@interface SuggestionViewController : UIViewController<RKObjectLoaderDelegate, MBProgressHUDDelegate, EditPerspectiveDelegate, RKRequestDelegate>{
    Suggestion *suggestion;
    NSString *suggestionId;
    bool dataLoaded;
    
    MBProgressHUD *HUD;

    UIImageView *imageView;
    UITextView *messageView;
    UILabel *senderLabel;
    
    UIButton *placemark;
    UIButton *placeButton;
    
    UILabel *alreadyOnLabel;
    UIButton *editButton;
    UIView *usernameView;
}

@property(nonatomic, retain) Suggestion *suggestion;
@property(nonatomic, retain) NSString *suggestionId;

@property(nonatomic, retain) IBOutlet UIImageView *imageView;
@property(nonatomic, retain) IBOutlet UITextView *messageView;
@property(nonatomic, retain) IBOutlet UILabel *senderLabel;
@property(nonatomic, retain) IBOutlet UIButton *placemark;
@property(nonatomic, retain) IBOutlet UIButton *placeButton;

@property(nonatomic, retain) IBOutlet UILabel *alreadyOnLabel;
@property(nonatomic, retain) IBOutlet UIButton *editButton;

@property(nonatomic, retain) IBOutlet UIView *usernameView;

-(IBAction)placemark:(id)sender;
-(IBAction)placeAction:(id)sender;

@end
