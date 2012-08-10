//
//  CommentViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 12-08-09.
//
//

#import <UIKit/UIKit.h>


#import "Perspective.h"
#import "NinaHelper.h"
#import "HPGrowingTextView.h"
#import "PlacemarkComment.h"

@interface CommentViewController : UIViewController <HPGrowingTextViewDelegate, UITableViewDataSource, UITableViewDelegate, RKObjectLoaderDelegate>{
    Perspective *perspective;
    
    UITableView *_tableView;
    UIView *containerView;
    
    HPGrowingTextView *textView;
    
    NSMutableArray *comments;
    bool dataLoaded;
    bool loadingMore;
}

@property(nonatomic, retain) Perspective *perspective;
@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) HPGrowingTextView *textView;
@property(nonatomic, retain) IBOutlet UIView *containerView;
@property(nonatomic, retain) NSMutableArray *comments;

-(IBAction)submitComment;

@end
