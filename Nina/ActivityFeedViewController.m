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


@interface ActivityFeedViewController (Private)
-(void)dataSourceDidFinishLoadingNewData;
-(void)getActivities;
@end

@implementation ActivityFeedViewController
@synthesize reloading=_reloading;
@synthesize activityTableView;

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)getActivities{
    
    NSString *currentUser = [NinaHelper getUsername];
    //cover not logged in situation
    if (currentUser && currentUser.length > 0){
        NSString *urlString = [NSString stringWithFormat:@"%@/v1/feeds/home_timeline", [NinaHelper getHostname]];		
        NSURL *url = [NSURL URLWithString:urlString];
        
        ASIHTTPRequest  *request =  [[[ASIHTTPRequest  alloc]  initWithURL:url] autorelease];
        request.tag = 70;
        [NinaHelper signRequest:request];
        [request setDelegate:self];
        [request startAsynchronous];   
        loadingMore = true;
    } 
}

#pragma mark - Login Controller Delegate Methods
- (void) loadContent {
    NSString *currentUser = [NinaHelper getUsername];
    
    if (currentUser && currentUser.length > 0) {
        [self getActivities];   
    }    

}

#pragma mark - View lifecycle
- (void)reloadTableViewDataSource{
	[self getActivities];
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
    

    if(hasMore && y > h + reload_distance && loadingMore == false) {
        loadingMore = true;
        
        // Call url to get profile details
        NSString *urlText = [NSString stringWithFormat:@"%@/v1/feeds/home_timeline?start=%i", [NinaHelper getHostname], [recentActivities count]];
        
        NSURL *url = [NSURL URLWithString:urlText];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setDelegate:self];
        [request setTag:71];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [NinaHelper signRequest:request];
        [request startAsynchronous];
        [self.activityTableView reloadData];
        
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
    recentActivities = [[NSMutableArray alloc] init];
    
    [FlurryAnalytics logEvent:@"ACTIVITY_FEED_VIEW"];
    
    self.navigationItem.title = @"Recent Activity";
    
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark ASIhttprequest

- (void)requestFailed:(ASIHTTPRequest *)request{
	[NinaHelper handleBadRequest:request sender:self];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	if (200 != [request responseStatusCode]){
		[NinaHelper handleBadRequest:request sender:self];
        return;
	} 

    switch (request.tag){
        case 70:{
            // Store incoming data into a string
            NSString *jsonString = [request responseString];
            DLog(@"Got JSON BACK: %@", jsonString);
            // Create a dictionary from the JSON string
            NSDictionary *jsonDict = [[jsonString JSONValue] retain];
            NSArray *rawActivities = [jsonDict objectForKey:@"home_feed"];
            
            if ( [recentActivities count] > 0){
                //case where we have to worry about overlap
                NSString *mostRecentId = [[recentActivities objectAtIndex:0]objectForKey:@"id"];
                for (NSDictionary *activity in rawActivities){
                    if ( [mostRecentId isEqualToString:[activity objectForKey:@"id"]] ){
                        break;
                    } else {
                        [recentActivities insertObject:activity atIndex:[rawActivities indexOfObject:activity]];
                    }
                }
                        
            } else {
                [recentActivities addObjectsFromArray:rawActivities];
            }

            
            [self.activityTableView  reloadData];
            [jsonDict release];
            loadingMore = false;
            break;
        }
        case 71:
        {
            NSString *responseString = [request responseString];            
            DLog(@"activites got returned: %@", responseString);
            
            NSDictionary *jsonDict =  [responseString JSONValue];            
            
            if ([jsonDict objectForKey:@"home_feed"]){
                //has perspectives in call, seed with to make quicker
                NSMutableArray *rawActivities = [jsonDict objectForKey:@"home_feed"];               
                if ([rawActivities count] == 0){
                    hasMore = false;
                } else {
                    [recentActivities addObjectsFromArray:rawActivities];
                }
            }
            
            loadingMore = false;
            [self.activityTableView  reloadData];
            break;
        }
	}
    
    [self dataSourceDidFinishLoadingNewData];
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
    } else if ( currentUser && [recentActivities count] == 0) {
        return 1;
    } else {
        if (loadingMore){
            return [recentActivities count] +1;
        }else{ 
            return [recentActivities count];
        }
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{    
    NSString *currentUser = [NinaHelper getUsername];
    
    if (currentUser == (id)[NSNull null] || currentUser.length == 0) {
        return 90;
        /*
    } else if ((user) && (user.followingCount == 0 || [recentActivities count] == 0)) {
        return 54; */
    }else if (indexPath.row >= [recentActivities count]){
        return 44;
    } else {
        NSDictionary *activity;
        activity = [recentActivities objectAtIndex:indexPath.row];
        return [ActivityTableViewCell cellHeightForActivity:activity];
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ActivityCell";
    static NSString *LoginCellIdentifier = @"LoginCell";
    static NSString *NoActivityCellIdentifier = @"NoActivityCell";
    
    ActivityTableViewCell *cell;
    if ([recentActivities count] > 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    } else {
        NSString *currentUser = [NinaHelper getUsername];
        
        if ( !currentUser || currentUser.length == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:LoginCellIdentifier];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:NoActivityCellIdentifier];
        }
    }
    
    NSString *currentUser = [NinaHelper getUsername];
    
    if ( currentUser && [recentActivities count] == 0 ) {
        tableView.allowsSelection = FALSE;
    } else {
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
        } else if ([recentActivities count] <= indexPath.row && !loadingMore){
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
        } else if ([recentActivities count] <= indexPath.row && loadingMore){
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SpinnerTableCell" owner:self options:nil];
            
            for(id item in objects){
                if ( [item isKindOfClass:[UITableViewCell class]]){
                    cell = item;
                }
            }    
            [cell setUserInteractionEnabled:NO];
        } else {
            UITextView *existingText = (UITextView *)[cell viewWithTag:778];
            if (existingText) {
                [existingText removeFromSuperview];
                [existingText release];
            }
            
            NSDictionary *activity = [recentActivities objectAtIndex:indexPath.row];
            
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
    } else if ([recentActivities count] <= indexPath.row && !loadingMore){
        FriendFindController *friendFindController = [[FriendFindController alloc] init];
        [self.navigationController pushViewController:friendFindController animated:YES];
        [friendFindController release]; 
    } else {
        NSDictionary *activity = [recentActivities objectAtIndex:indexPath.row];
        
        NSString *activityType = [activity objectForKey:@"activity_type"];
        
        UIViewController *viewController;
        
        
        if ([activityType isEqualToString:@"UPDATE_PERSPECTIVE"]){
            PlacePageViewController *placeController = [[PlacePageViewController alloc]init];
            placeController.perspective_id = [activity objectForKey:@"subject"];
            placeController.referrer = [activity objectForKey:@"username1"];
            //placeController.initialSelectedIndex = [NSNumber numberWithInt:1];
            viewController = placeController;
        }else if ([activityType isEqualToString:@"NEW_PERSPECTIVE"]){
            PlacePageViewController *placeController = [[PlacePageViewController alloc]init];
            placeController.perspective_id = [activity objectForKey:@"subject"];
            placeController.referrer = [activity objectForKey:@"username1"];
            //placeController.initialSelectedIndex = [NSNumber numberWithInt:1];
            viewController = placeController;
        } else if ([activityType isEqualToString:@"STAR_PERSPECTIVE"]){
            PlacePageViewController *placeController = [[PlacePageViewController alloc]init];
            placeController.perspective_id = [activity objectForKey:@"subject"];
            placeController.referrer = [activity objectForKey:@"username1"];
            //placeController.initialSelectedIndex = [NSNumber numberWithInt:1];
            viewController = placeController;
        }  else if ([activityType isEqualToString:@"FOLLOW"]){
            MemberProfileViewController *memberView = [[MemberProfileViewController alloc]init];
            memberView.username = [activity objectForKey:@"username2"];
            viewController = memberView;
        } else {
            PlacePageViewController *placeController = [[PlacePageViewController alloc]init];
            viewController = placeController;
            DLog(@"ERROR: unknown activity story type");
        }
        
        [self.navigationController pushViewController:viewController animated:TRUE];
        [viewController release];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
    }
}


- (void)dealloc{
    [NinaHelper clearActiveRequests:70];
    [recentActivities release];
    [activityTableView release];
    [super dealloc];
    
}


@end
