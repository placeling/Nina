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

@interface SuggestionViewController : UIViewController<RKObjectLoaderDelegate, MBProgressHUDDelegate>{
    Suggestion *suggestion;
    NSString *suggestionId;
    bool dataLoaded;
    
    MBProgressHUD *HUD;
}

@property(nonatomic, retain) Suggestion *suggestion;
@property(nonatomic, retain) NSString *suggestionId;

@end
