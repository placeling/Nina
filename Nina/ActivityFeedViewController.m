//
//  ActivityFeedViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-09-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ActivityFeedViewController.h"
#import "NSString+SBJSON.h"
#import "PlacePageViewController.h"
#import "MemberProfileViewController.h"
#import "User.h"
#import "LoginController.h"
#import "FlurryAnalytics.h"
#import "FriendFindController.h"
#import "Activity.h"
#import "Notification.h"
#import "NotificationTableViewCell.h"

@interface ActivityFeedViewController (Private)
-(void)dataSourceDidFinishLoadingNewData;
-(void)getActivities;
-(void)getNotifications;
-(NSMutableArray*) presentedValues;
@end

@implementation ActivityFeedViewController
@synthesize reloading=_reloading;
@synthesize activityTableView, segmentControl, toolbar;

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
        
        [objectManager loadObjectsAtResourcePath:targetURL delegate:self block:^(RKObjectLoader* loader) {  
            loader.userData = [NSNumber numberWithInt:70]; //use as a tag
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
        
        [objectManager loadObjectsAtResourcePath:targetURL delegate:self block:^(RKObjectLoader* loader) {        
            loader.userData = [NSNumber numberWithInt:72]; //use as a tag
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
    
	if (scrollView.isDragging) {
		if (refreshHeaderView.state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshNormal];
		} else if (refreshHeaderView.state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshPulling];
		}
	}
    
    if ( self.segmentControl.selectedSegmentIndex ==1 ){
        if(hasMore && y > h + reload_distance && loadingMore == false) {
            loadingMore = true;        
            
            RKObjectManager* objectManager = [RKObjectManager sharedManager];        
            NSString *targetURL = [NSString stringWithFormat:@"/v1/feeds/home_timeline?start=%", [recentActivities count]];
            
            [objectManager loadObjectsAtResourcePath:targetURL delegate:self block:^(RKObjectLoader* loader) {  
                loader.userData = [NSNumber numberWithInt:71]; //use as a tag
            }];    
            
            [self.activityTableView reloadData];        
        }
    } else {
        if(hasMoreNotifications && y > h + reload_distance && loadingMore == false) {
            loadingMore = true;        
            
            RKObjectManager* objectManager = [RKObjectManager sharedManager];        
            NSString *targetURL = [NSString stringWithFormat:@"/v1/users/notifications?start=%", [recentNotifications count]];
            
            [objectManager loadObjectsAtResourcePath:targetURL delegate:self block:^(RKObjectLoader* loader) {  
                loader.userData = [NSNumber numberWithInt:73]; //use as a tag
            }];    
            
            [self.activityTableView reloadData];        
        }        
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
	if (scrollView.contentOffset.y <= - 65.0f && !_reloading) {
        _reloading = YES;
        [self reloadTableViewDataSource];
        [refreshHeaderView setState:EGOOPullRefreshLoading];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        self.activityTableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
	}
}

- (void)dataSourceDidFinishLoadingNewData{
    
	_reloading = NO;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.activityTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
    
	[refreshHeaderView setState:EGOOPullRefreshNormal];
	[refreshHeaderView setCurrentDate];  //  should check if data reload was successful 
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
    
    [FlurryAnalytics logEvent:@"ACTIVITY_FEED_VIEW"];
    [self.segmentControl setSelectedSegmentIndex:0];
    
    self.navigationItem.title = @"Updates";
    
    if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.activityTableView.bounds.size.height, 320.0f, self.activityTableView.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		[self.activityTableView addSubview:refreshHeaderView];
		self.activityTableView.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
    
    [self loadContent];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [StyleHelper styleBackgroundView:self.activityTableView];
    [StyleHelper styleBackgroundView:self.view];
    [StyleHelper styleToolBar:self.toolbar];
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


#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    loadingMore = false;
    
    if ( [(NSNumber*)objectLoader.userData intValue] == 70){
        [recentActivities removeAllObjects];
        [recentActivities addObjectsFromArray:objects];
        [self.activityTableView reloadData];
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 71){
        [recentActivities addObjectsFromArray:objects];
        [self.activityTableView reloadData];
        
        if ( [objects count] == 0 ) {
            hasMore = false;
        }
        
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 72){
        [recentNotifications removeAllObjects];
        [recentNotifications addObjectsFromArray:objects];
        [self.activityTableView reloadData];
        
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 73){
        [recentNotifications addObjectsFromArray:objects];
        [self.activityTableView reloadData];
        
        if ( [objects count] == 0 ) {
            hasMoreNotifications = false;
        }
        
    } 
    
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
            return [NotificationTableViewCell cellHeightForNotification:notification];            
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
            
            loginText.font = [UIFont fontWithName:@"Helvetica" size:14.0];
            
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
            
            loginText.font = [UIFont fontWithName:@"Helvetica" size:14.0];
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
            
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"NotificationTableViewCell" owner:self options:nil];
            
            for(id item in objects){
                if ( [item isKindOfClass:[UITableViewCell class]]){
                    NotificationTableViewCell *pcell = (NotificationTableViewCell *)item;                  
                    [NotificationTableViewCell setupCell:pcell forNotification:notification];
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
                //placeController.initialSelectedIndex = [NSNumber numberWithInt:1];
                viewController = placeController;
            }else if ([activity.activityType isEqualToString:@"NEW_PERSPECTIVE"]){
                PlacePageViewController *placeController = [[PlacePageViewController alloc]init];
                placeController.perspective_id = activity.subjectId;
                placeController.referrer = activity.username1;
                //placeController.initialSelectedIndex = [NSNumber numberWithInt:1];
                viewController = placeController;
            } else if ([activity.activityType isEqualToString:@"STAR_PERSPECTIVE"]){
                PlacePageViewController *placeController = [[PlacePageViewController alloc]init];
                placeController.perspective_id = activity.subjectId;
                placeController.referrer = activity.username1;
                //placeController.initialSelectedIndex = [NSNumber numberWithInt:1];
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
            }  else if ([notification.notificationType isEqualToString:@"FOLLOW"]){
                MemberProfileViewController *memberView = [[MemberProfileViewController alloc]init];
                memberView.user = notification.actor;
                viewController = memberView;
            } else if ( [notification.notificationType isEqualToString:@"FACEBOOK_FRIEND"] ){
                MemberProfileViewController *memberView = [[MemberProfileViewController alloc]init];
                memberView.user = notification.actor;
                viewController = memberView;  
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
