//
//  NearbyPlacesViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-07-19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NearbyPlacesViewController.h"
#import "NSString+SBJSON.h"
#import "AttachPerspectiveViewController.h"
#import "ASIHTTPRequest.h"
#import "NinaHelper.h"

@interface NearbyPlacesViewController (Private)
    -(void)dataSourceDidFinishLoadingNewData;
    -(void)findNearbyPlaces;
@end

@implementation NearbyPlacesViewController 

@synthesize reloading=_reloading;
@synthesize locationManager;
@synthesize placesTableView;

-(void)findNearbyPlaces {
	//NSDate *now = [NSDate date];
	CLLocation *location = locationManager.location;
    
	if (location != nil){ //[now timeIntervalSinceDate:location.timestamp] < (60 * 5)){
		NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
		NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        
		NSString *urlString = [NSString stringWithFormat:@"%@/places/nearby_places", [plistData objectForKey:@"server_url"]];		
        
		NSString* x = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
		NSString* y = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
		float accuracy = pow(location.horizontalAccuracy,2)  + pow(location.verticalAccuracy,2);
		accuracy = sqrt( accuracy ); //take accuracy as single vector, rather than 2 values -iMack
        NSString *radius = [NSString stringWithFormat:@"%f", accuracy];
        
        urlString = [NSString stringWithFormat:@"%@?x=%@&y=%@&radius=%@", urlString, x, y, radius];
        NSURL *url = [NSURL URLWithString:urlString];
        
		ASIHTTPRequest  *request =  [[[ASIHTTPRequest  alloc]  initWithURL:url] autorelease];
        
		[request setDelegate:self];
		[request startAsynchronous];
	}
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc{
    [super dealloc];
    [placesTableView release];
    [locationManager release];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - EgoTablerefresh

- (void)reloadTableViewDataSource{
	[self findNearbyPlaces];
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
        self.placesTableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
	}
}

- (void)dataSourceDidFinishLoadingNewData{
    
	_reloading = NO;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.placesTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
    
	[refreshHeaderView setState:EGOOPullRefreshNormal];
	[refreshHeaderView setCurrentDate];  //  should check if data reload was successful 
}


#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self; // send loc updates to myself -iMack
	[self.locationManager startUpdatingLocation];
    
    self.placesTableView.delegate = self;
    
    if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.placesTableView.bounds.size.height, 320.0f, self.placesTableView.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		[self.placesTableView addSubview:refreshHeaderView];
		self.placesTableView.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}


    [self findNearbyPlaces];
    
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark ASIhttprequest

- (void)requestFailed:(ASIHTTPRequest *)request{
	//NSError *error = [request error];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't connect to server"
                                                   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
	// Use when fetching binary data
	int statusCode = [request responseStatusCode];
	if (200 != statusCode){
		[NinaHelper handleBadRequest:request];
	} else {
		NSData *data = [request responseData];
        
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		DLog(@"Got JSON BACK: %@", jsonString);
		// Create a dictionary from the JSON string
        
		[nearbyPlaces release];
		nearbyPlaces = [[jsonString JSONValue] retain];
        
		[self.placesTableView  reloadData];
		[jsonString release];
	}
    
    [self dataSourceDidFinishLoadingNewData];
}



#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [nearbyPlaces count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    NSDictionary *place = [nearbyPlaces objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if ( [place objectForKey:@"name"] != [NSNull null] ){
		cell.textLabel.text = [place objectForKey:@"name"];
	} else {
		cell.textLabel.text = @"n/a";
	}
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *place = [nearbyPlaces objectAtIndex:indexPath.row];
    AttachPerspectiveViewController *attachPerspectiveViewController = [[AttachPerspectiveViewController alloc] init];
    attachPerspectiveViewController.rawPlace = place;
    attachPerspectiveViewController.locationManager = locationManager;
	[[self navigationController] pushViewController:attachPerspectiveViewController animated:YES];
	[attachPerspectiveViewController release];
}



@end
