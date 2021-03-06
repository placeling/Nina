//
//  ActivityFeedViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-09-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ActivityFeedViewController.h"
#import "SBJSON.h"
#import "PlacePageViewController.h"
#import "MemberProfileViewController.h"
#import "User.h"
#import "LoginController.h"
#import "Flurry.h"
#import "FriendFindController.h"
#import "Activity.h"
#import "Notification.h"
#import "SuggestionViewController.h"
#import "UserManager.h"

@interface ActivityFeedViewController (Private)
-(void)dataSourceDidFinishLoadingNewData;
-(void)getActivities;
-(void)getNotifications;
-(NSMutableArray*) presentedValues;
@end

@implementation ActivityFeedViewController
@synthesize reloading=_reloading;
@synthesize activityTableView, segmentControl, toolbar, initialIndex;

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)getActivities{
    
    NSString *currentUser = [NinaHelper getUsername];
    //cover not logged in situation
    if (currentUser && currentUser.length > 0){
        loadingMore = true;
        
        RKObjectManager* objectManager = [RKObjectManager sharedManager];
        
        NSString *targetURL = [NSString stringWithFormat:@"/v1/feeds/home_timeline"];
        
        [objectManager loadObjectsAtResourcePath:targetURL usingBlock:^(RKObjectLoader* loader) {
            loader.userData = [NSNumber numberWithInt:70]; //use as a tag
            loader.delegate = self;
        }];        
    } 
}

-(NSMutableArray*) presentedValues{
    if (self.segmentControl.selectedSegmentIndex == 0){
        return recentNotifications;
    } else {
        return recentActivities;
    }                                                
}


-(void)getNotifications{

    NSString *currentUser = [NinaHelper getUsername];
    //cover not logged in situation
    if (currentUser && currentUser.length > 0){
        loadingMore = true;
        
        RKObjectManager* objectManager = [RKObjectManager sharedManager];
        
        NSString *targetURL = [NSString stringWithFormat:@"/v1/users/notifications"];
        
        [objectManager loadObjectsAtResourcePath:targetURL usingBlock:^(RKObjectLoader* loader) {
            loader.userData = [NSNumber numberWithInt:72]; //use as a tag
            loader.delegate = self;
        }];        
    } 
}

#pragma mark - Login Controller Delegate Methods
- (void) loadContent {
    NSString *currentUser = [NinaHelper getUsername];
    
    if (currentUser && currentUser.length > 0) {
        if ( self.segmentControl.selectedSegmentIndex == 1 ){
            [self getActivities];   
        } else {
            [self getNotifications];
        }
    }    

}

#pragma mark - View lifecycle
- (void)reloadTableViewDataSource{
    _reloading = true;
    if ( self.segmentControl.selectedSegmentIndex == 1 ){
        [self getActivities];   
    } else {
        [self getNotifications];
    }
	//[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}


- (void)doneLoadingTableViewData{
	[self dataSourceDidFinishLoadingNewData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
    
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = 10;
    
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
    if ( self.segmentControl.selectedSegmentIndex ==1 ){
        if(hasMore && y > h + reload_distance && loadingMore == false) {
            loadingMore = true;        
            
            RKObjectManager* objectManager = [RKObjectManager sharedManager];        
            NSString *targetURL = [NSString stringWithFormat:@"/v1/feeds/home_timeline?start=%i", [recentActivities count]];
            
            [objectManager loadObjectsAtResourcePath:targetURL usingBlock:^(RKObjectLoader* loader) {
                loader.userData = [NSNumber numberWithInt:71]; //use as a tag
                loader.delegate = self;
            }];    
            
            [self.activityTableView reloadData];        
        }
    } else {
        if(hasMoreNotifications && y > h + reload_distance && loadingMore == false) {
            loadingMore = true;        
            
            RKObjectManager* objectManager = [RKObjectManager sharedManager];        
            NSString *targetURL = [NSString stringWithFormat:@"/v1/users/notifications?start=%i", [recentNotifications count]];
            
            [objectManager loadObjectsAtResourcePath:targetURL  usingBlock:^(RKObjectLoader* loader) {
                loader.userData = [NSNumber numberWithInt:73]; //use as a tag
                loader.delegate = self;
            }];    
            
            [self.activityTableView reloadData];        
        }        
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}


- (void)dataSourceDidFinishLoadingNewData{
    
	_reloading = NO;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.activityTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
    
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.activityTableView];
}


#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    self.activityTableView.delegate = self;
    self.activityTableView.backgroundColor = [UIColor clearColor];
    
    loadingMore = true;
    hasMore = true;
    hasMoreNotifications = true;
    recentActivities = [[NSMutableArray alloc] init];
    recentNotifications = [[NSMutableArray alloc] init];
    
    [Flurry logEvent:@"ACTIVITY_FEED_VIEW"];
    
    [self.segmentControl setSelectedSegmentIndex:initialIndex];
    
    self.navigationItem.title = @"Updates";
    
	if (_refreshHeaderView == nil) {
        
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.activityTableView.bounds.size.height, self.view.frame.size.width, self.activityTableView.bounds.size.height)];
		view.delegate = self;
		[self.activityTableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
        
	}
    
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    [self loadContent];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [StyleHelper styleBackgroundView:self.activityTableView];
    [StyleHelper styleBackgroundView:self.view];
    [StyleHelper styleToolBar:self.toolbar];
    [self.activityTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)toggleType{
    if ( self.segmentControl.selectedSegmentIndex == 0){
        if ( [recentNotifications count] == 0){
            [self getNotifications];
        } 
    } else {
        if ( [recentActivities count] == 0){
            [self getActivities];
        }
    
    }
    
    [self.activityTableView reloadData];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
	return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
	return [NSDate date]; // should return date data source was last changed
    
}

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    loadingMore = false;
    
    if ( [(NSNumber*)objectLoader.userData intValue] == 70){
        [recentActivities removeAllObjects];
        for (NSObject* object in objects){
            if ( [object isKindOfClass:[Activity class]] ){
                [recentActivities addObject: object];
            }
        }
        [self.activityTableView reloadData];
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 71){
        for (NSObject* object in objects){
            if ( [object isKindOfClass:[Activity class]] ){
                [recentActivities addObject: object];
            }
        }
        [self.activityTableView reloadData];
        
        if ( [objects count] == 0 ) {
            hasMore = false;
        }
        
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 72){
        [recentNotifications removeAllObjects];
        [recentNotifications addObjectsFromArray:objects];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
        User *user = [UserManager sharedMeUser];
        user.notificationCount = [NSNumber numberWithInt:0];
        [self.activityTableView reloadData];
        
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 73){
        [recentNotifications addObjectsFromArray:objects];
        [self.activityTableView reloadData];
        
        if ( [objects count] == 0 ) {
            hasMoreNotifications = false;
        }
        
    }
                    
    [self dataSourceDidFinishLoadingNewData];
    
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    //objectLoader.response.
    loadingMore = false;
    [NinaHelper handleBadRKRequest:objectLoader.response sender:self];
    DLog(@"Encountered an error: %@", error);
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *currentUser = [NinaHelper getUsername];
    
    if ( !currentUser || currentUser.length == 0) {
        return 1;
    } else if ( currentUser && [[self presentedValues] count] == 0) {
        return 1;
    } else {
        if (loadingMore){
            return [[self presentedValues] count] +1;
        }else{ 
            return [[self presentedValues] count];
        }
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{    
    NSString *currentUser = [NinaHelper getUsername];
    
    if ( !currentUser ) {
        return 90;
        /*
    } else if ((user) && (user.followingCount == 0 || [recentActivities count] == 0)) {
        return 54; */
    }else if (indexPath.row >= [[self presentedValues] count]){
        return 44;
    } else {
        if ( self.segmentControl.selectedSegmentIndex == 1){
            Activity *activity = [recentActivities objectAtIndex:indexPath.row];
            return [ActivityTableViewCell cellHeightForActivity:activity];
        } else {
            Notification *notification = [recentNotifications objectAtIndex:indexPath.row];
            return [ActivityTableViewCell cellHeightForNotification:notification];            
        }
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ActivityCell";
    static NSString *NotificationCellIdentifier = @"NotificationCell";
    static NSString *LoginCellIdentifier = @"LoginCell";
    static NSString *NoActivityCellIdentifier = @"NoActivityCell";
    
    UITableViewCell *cell;
    
    if ( self.segmentControl.selectedSegmentIndex == 1 && [recentActivities count] > 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    } else if ( self.segmentControl.selectedSegmentIndex == 0 && [recentNotifications count] > 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:NotificationCellIdentifier];
    }  else {
        NSString *currentUser = [NinaHelper getUsername];
        
        if ( !currentUser || currentUser.length == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:LoginCellIdentifier];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:NoActivityCellIdentifier];
        }
    }
    
    NSString *currentUser = [NinaHelper getUsername];
    
    if ( currentUser &&  self.segmentControl.selectedSegmentIndex == 1 && [recentActivities count] == 0 ) {
        tableView.allowsSelection = FALSE;
    } else if ( currentUser &&  self.segmentControl.selectedSegmentIndex == 0 && [recentNotifications count] == 0 ) {
        tableView.allowsSelection = FALSE;
    }else {
        tableView.allowsSelection = TRUE;
    }
    
    if (cell == nil) {
        NSString *currentUser = [NinaHelper getUsername];
        
        if ( !currentUser ) {
            cell = [[[ActivityTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:LoginCellIdentifier] autorelease];
            
            UITextView *loginText = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 90)];
            
            loginText.text = @"Sign up or log in to check out what people you follow have placemarked lately.\n\nTap here to get started.";
            
            loginText.font = [StyleHelper textFont];
            
            
            loginText.tag = 778;
            [loginText setBackgroundColor:[UIColor clearColor]];
            
            [cell addSubview:loginText];
            [loginText release];
            [cell setUserInteractionEnabled:YES];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        } else if ( ( ( self.segmentControl.selectedSegmentIndex == 1 && [recentActivities count] <= indexPath.row ) ||  ( self.segmentControl.selectedSegmentIndex == 0 && [recentNotifications count] <= indexPath.row ) ) && !loadingMore){
            cell = [[[ActivityTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:LoginCellIdentifier] autorelease];
            
            UITextView *loginText = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 90)];
            
            loginText.text = @"Nothing to show you right now";
            
            loginText.font = [StyleHelper textFont];
            loginText.tag = 778;
            [loginText setBackgroundColor:[UIColor clearColor]];
            [loginText setUserInteractionEnabled:FALSE];
            
            [cell addSubview:loginText];
            [loginText release];
            [cell setUserInteractionEnabled:YES];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        } else if ( ((self.segmentControl.selectedSegmentIndex == 1 && [recentActivities count] <= indexPath.row) || (self.segmentControl.selectedSegmentIndex == 0 && [recentNotifications count] <= indexPath.row) )  && loadingMore){
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SpinnerTableCell" owner:self options:nil];
            
            for(id item in objects){
                if ( [item isKindOfClass:[UITableViewCell class]]){
                    cell = item;
                }
            }    
            [cell setUserInteractionEnabled:NO];
        } else if (self.segmentControl.selectedSegmentIndex == 1) {
            UITextView *existingText = (UITextView *)[cell viewWithTag:778];
            if (existingText) {
                [existingText removeFromSuperview];
                [existingText release];
            }
            
            Activity *activity = [recentActivities objectAtIndex:indexPath.row];
            
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ActivityTableViewCell" owner:self options:nil];
            
            for(id item in objects){
                if ( [item isKindOfClass:[UITableViewCell class]]){
                    ActivityTableViewCell *pcell = (ActivityTableViewCell *)item;                  
                    [ActivityTableViewCell setupCell:pcell forActivity:activity];
                    cell = pcell;
                    break;
                }
            }   
            [cell setUserInteractionEnabled:YES];
        } else {
            UITextView *existingText = (UITextView *)[cell viewWithTag:778];
            if (existingText) {
                [existingText removeFromSuperview];
                [existingText release];
            }
            
            Notification *notification = [recentNotifications objectAtIndex:indexPath.row];
            
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ActivityTableViewCell" owner:self options:nil];
            
            for(id item in objects){
                if ( [item isKindOfClass:[UITableViewCell class]]){
                    ActivityTableViewCell *pcell = (ActivityTableViewCell *)item;
                    [ActivityTableViewCell setupCell:pcell forNotification:notification];
                    cell = pcell;
                    break;
                }
            }   
            [cell setUserInteractionEnabled:YES];
        }        
    }    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *currentUser = [NinaHelper getUsername];
    
    if ( !currentUser ) {
        LoginController *loginController = [[LoginController alloc] init];
        loginController.delegate = self;
        
        UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:loginController];
        [self.navigationController presentModalViewController:navBar animated:YES];
        [navBar release];
        [loginController release];
    } else if (((self.segmentControl.selectedSegmentIndex == 1 && [recentActivities count] <= indexPath.row) || (self.segmentControl.selectedSegmentIndex == 0 && [recentNotifications count] <= indexPath.row) ) && !loadingMore){
        FriendFindController *friendFindController = [[FriendFindController alloc] init];
        [self.navigationController pushViewController:friendFindController animated:YES];
        [friendFindController release]; 
    } else {
        UIViewController *viewController;
        
        if (self.segmentControl.selectedSegmentIndex == 1){
            Activity *activity = [recentActivities objectAtIndex:indexPath.row];        
            
            if ([activity.activityType isEqualToString:@"UPDATE_PERSPECTIVE"]){
                PlacePageViewController *placeController = [[PlacePageViewController alloc]init];
                placeController.perspective_id = activity.subjectId;
                placeController.referrer = activity.username1;
                if ( ![activity.username1 isEqualToString:currentUser] ){
                     placeController.initialSelectedIndex = [NSNumber numberWithInt:1];
                }               
                viewController = placeController;
            }else if ([activity.activityType isEqualToString:@"NEW_PERSPECTIVE"]){
                PlacePageViewController *placeController = [[PlacePageViewController alloc]init];
                placeController.perspective_id = activity.subjectId;
                placeController.referrer = activity.username1;
                if ( ![activity.username1 isEqualToString:currentUser] ){
                    placeController.initialSelectedIndex = [NSNumber numberWithInt:1];
                }
                viewController = placeController;
            } else if ([activity.activityType isEqualToString:@"STAR_PERSPECTIVE"]){
                PlacePageViewController *placeController = [[PlacePageViewController alloc]init];
                placeController.perspective_id = activity.subjectId;
                placeController.referrer = activity.username1;
                if ( ![activity.username2 isEqualToString:currentUser] ){
                    placeController.initialSelectedIndex = [NSNumber numberWithInt:1];
                }
                viewController = placeController;
            }  else if ([activity.activityType isEqualToString:@"FOLLOW"]){
                MemberProfileViewController *memberView = [[MemberProfileViewController alloc]init];
                memberView.username = activity.username2;
                viewController = memberView;
            } else {
                PlacePageViewController *placeController = [[PlacePageViewController alloc]init];
                viewController = placeController;
                DLog(@"ERROR: unknown activity story type");
            }
        } else {
            Notification *notification = [recentNotifications objectAtIndex:indexPath.row];  
            
            if ([notification.notificationType isEqualToString:@"STAR_PERSPECTIVE"]){
                PlacePageViewController *placeController = [[PlacePageViewController alloc]init];
                placeController.perspective_id = notification.subjectId;
                placeController.referrer = notification.actor.username;
                //placeController.initialSelectedIndex = [NSNumber numberWithInt:1];
                viewController = placeController;
            }else if ([notification.notificationType isEqualToString:@"COMMENT_PERSPECTIVE"]){
                PlacePageViewController *placeController = [[PlacePageViewController alloc]init];
                placeController.perspective_id = notification.subjectId;
                placeController.referrer = notification.actor.username;
                //placeController.initialSelectedIndex = [NSNumber numberWithInt:1];
                viewController = placeController;                
            }  else if ([notification.notificationType isEqualToString:@"FOLLOW"]){
                MemberProfileViewController *memberView = [[MemberProfileViewController alloc]init];
                memberView.user = notification.actor;
                viewController = memberView;
            } else if ( [notification.notificationType isEqualToString:@"FACEBOOK_FRIEND"] ){
                MemberProfileViewController *memberView = [[MemberProfileViewController alloc]init];
                memberView.user = notification.actor;
                viewController = memberView;  
            } else if ( [notification.notificationType isEqualToString:@"SUGGESTED_PLACE"] ){
                SuggestionViewController *suggestionView = [[SuggestionViewController alloc]init];
                suggestionView.suggestionId = notification.subjectId;
                viewController = suggestionView;
            }
        }
        
        [self.navigationController pushViewController:viewController animated:TRUE];
        [viewController release];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
    }
}


- (void)dealloc{
    [[[[RKObjectManager sharedManager] client] requestQueue] cancelRequestsWithDelegate:self];
    [recentActivities release];
    [activityTableView release];
    [segmentControl release];
    [recentNotifications release];
    [toolbar release];
    [super dealloc];
    
}


@end
