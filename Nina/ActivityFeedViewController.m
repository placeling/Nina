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


@interface ActivityFeedViewController (Private)
-(void)dataSourceDidFinishLoadingNewData;
-(void)getActivities;
@end

@implementation ActivityFeedViewController
@synthesize reloading=_reloading;
@synthesize activityTableView;
@synthesize user;

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)getActivities{
    NSString *urlString = [NSString stringWithFormat:@"%@/v1/feeds/home_timeline", [NinaHelper getHostname]];		

    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIHTTPRequest  *request =  [[[ASIHTTPRequest  alloc]  initWithURL:url] autorelease];
    request.tag = 70;
    [NinaHelper signRequest:request];
    [request setDelegate:self];
    [request startAsynchronous];    
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
	if (scrollView.isDragging) {
		if (refreshHeaderView.state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshNormal];
		} else if (refreshHeaderView.state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshPulling];
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
    
    self.navigationItem.title = @"Recent activity";
    
    if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.activityTableView.bounds.size.height, 320.0f, self.activityTableView.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		[self.activityTableView addSubview:refreshHeaderView];
		self.activityTableView.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
    
    [self getActivities];
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.title = @"Activity Feed";
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
    
	if (200 != [request responseStatusCode]){
		[NinaHelper handleBadRequest:request sender:self];
	} else {
		// Store incoming data into a string
		NSString *jsonString = [request responseString];
		DLog(@"Got JSON BACK: %@", jsonString);
		// Create a dictionary from the JSON string
        
		[recentActivities release];
        NSDictionary *jsonDict = [[jsonString JSONValue] retain];
		recentActivities = [[jsonDict objectForKey:@"home_feed"] retain];
        
        if (!user) {
            self.user = [[[User alloc] initFromJsonDict:[jsonDict objectForKey:@"user"]]autorelease];    
        }
        
		[self.activityTableView  reloadData];
		[jsonDict release];
	}
    
    [self dataSourceDidFinishLoadingNewData];
}



#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ((user) && user.followingCount == 0) {
        return 1;
    } else if ((user) && [recentActivities count] == 0) {
        return 1;
    } else {
        return [recentActivities count];
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{    
    if ((user) && (user.followingCount == 0 || [recentActivities count] == 0)) {
        return 54;
    } else {
        NSDictionary *activity;
        activity = [recentActivities objectAtIndex:indexPath.row];
        return [ActivityTableViewCell cellHeightForActivity:activity];
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ActivityCell";
    
    ActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ((user) && (user.followingCount == 0 || [recentActivities count] == 0)) {
        tableView.allowsSelection = FALSE;
    } else {
        tableView.allowsSelection = TRUE;
    }
    
    if (cell == nil) {
        if ((user) && (user.followingCount == 0 || [recentActivities count] == 0)) {            
            cell = [[[ActivityTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            
            UITextView *errorText = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
            
            if (user.followingCount == 0) {
                errorText.text = @"Start following people and you'll see what they do here";
            } else {
                errorText.text = @"There's no recent activity by people you follow";
            }
            
            errorText.font = [UIFont fontWithName:@"Helvetica" size:14.0];
            [errorText setUserInteractionEnabled:NO];
            [errorText setBackgroundColor:[UIColor clearColor]];
            
            [cell addSubview:errorText];
            [errorText release];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        } else {
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
        }        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *activity = [recentActivities objectAtIndex:indexPath.row];
    
    NSString *activityType = [activity objectForKey:@"activity_type"];
    
    UIViewController *viewController;
    
        
    if ([activityType isEqualToString:@"UPDATE_PERSPECTIVE"]){
        PlacePageViewController *placeController = [[PlacePageViewController alloc]init];
        placeController.perspective_id = [activity objectForKey:@"subject"];
        viewController = placeController;
    }else if ([activityType isEqualToString:@"NEW_PERSPECTIVE"]){
        PlacePageViewController *placeController = [[PlacePageViewController alloc]init];
        placeController.perspective_id = [activity objectForKey:@"subject"];
        viewController = placeController;
    } else if ([activityType isEqualToString:@"STAR_PERSPECTIVE"]){
        PlacePageViewController *placeController = [[PlacePageViewController alloc]init];
        placeController.perspective_id = [activity objectForKey:@"subject"];
        viewController = placeController;
    }  else if ([activityType isEqualToString:@"FOLLOW"]){
        MemberProfileViewController *memberView = [[MemberProfileViewController alloc]init];
        memberView.username = [activity objectForKey:@"username2"];
        viewController = memberView;
    } else {
        DLog(@"ERROR: unknown activity story type");
    }
    
    [self.navigationController pushViewController:viewController animated:TRUE];
    [viewController release];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
    
}


- (void)dealloc{
    [NinaHelper clearActiveRequests:70];
    [recentActivities release];
    [activityTableView release];
    [user release];
    [super dealloc];
    
}


@end
