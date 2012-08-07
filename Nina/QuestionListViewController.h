//
//  QuestionListViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 12-08-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NinaHelper.h"
#import <RestKit/RestKit.h>
#import "Facebook.h"
#import "LoginController.h"
#import "ApplicationController.h"
#import "Question.h"


@interface QuestionListViewController : ApplicationController<RKObjectLoaderDelegate>{
    
    NSMutableArray *questions;
    UITableView *_tableView;
    
    bool dataLoaded;
    CLLocationCoordinate2D origin;
}


@property(nonatomic, assign) bool dataLoaded;
@property(nonatomic, retain) NSMutableArray *questions;
@property(nonatomic, retain) IBOutlet UITableView *tableView;

@property(nonatomic,assign) CLLocationCoordinate2D origin;



@end
