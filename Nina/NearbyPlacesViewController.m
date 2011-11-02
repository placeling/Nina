//
//  NearbyPlacesViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-07-19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NearbyPlacesViewController.h"
#import "NSString+SBJSON.h"
#import "PlacePageViewController.h"
#import "ASIHTTPRequest.h"
#import <CoreLocation/CoreLocation.h>
#import "NinaHelper.h"


@interface NearbyPlacesViewController (Private)
    -(void)dataSourceDidFinishLoadingNewData;
    -(void)findNearbyPlaces;
    -(void)findNearbyPlaces:(NSString*)searchTerm;
    -(void)impatientUser;
-(void)getNearbyPlaces:(NSString*)searchTerm;
@end

@implementation NearbyPlacesViewController 

@synthesize reloading=_reloading;
@synthesize placesTableView;
@synthesize searchBar=_searchBar, toolBar;
@synthesize tableFooterView, gpsLabel;
@synthesize dataLoaded, locationEnabled, location=_location;
-(void)findNearbyPlaces {
    [self findNearbyPlaces:@""];
}

-(void)findNearbyPlaces:(NSString*)searchTerm {
    CLLocationManager *manager = [LocationManagerManager sharedCLLocationManager];
    self.location = manager.location;
    NSDate *now = [[NSDate alloc]init];
    float accuracy = pow(self.location.horizontalAccuracy,2)  + pow(self.location.verticalAccuracy,2);
    accuracy = sqrt( accuracy ); //take accuracy as single vector, rather than 2 values -iMack
    
    if ([now timeIntervalSinceDate:self.location.timestamp] > (60 * 5) || accuracy > 200){
        //if the location is more than 5 minutes old, or over 200m in accuracy, wait
        //for an update, to a maximum of "n" seconds
        needLocationUpdate = TRUE;
        
        manager.delegate = self;
        [manager startUpdatingLocation]; //should already be going
        
        timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(impatientUser) userInfo:nil repeats:NO];
        
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.delegate = self;
        HUD.labelText = @"Narrowing Location";
        [HUD show:YES];
        
    }else if (self.location != nil){ //
        [self getNearbyPlaces:self.searchBar.text];
	} else {
        
        self.gpsLabel.text = [NSString stringWithFormat:@"GPS: n/a"];
        
        self.dataLoaded = TRUE;
        self.locationEnabled = FALSE;
        if (nearbyPlaces) {
            [nearbyPlaces release];            
        }
        nearbyPlaces = [[NSMutableArray alloc] initWithCapacity:0];
        
        needLocationUpdate = true;
        self.locationEnabled = FALSE;
        DLog(@"UNABLE TO GET CURRENT LOCATION FOR NEARBY");
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    self.location = newLocation;
    
    float accuracy = pow(self.location.horizontalAccuracy,2)  + pow(self.location.verticalAccuracy,2);
    accuracy = sqrt( accuracy ); 
    if (accuracy < 200){
        manager.delegate = nil;
        [timer invalidate];
        [self findNearbyPlaces:self.searchBar.text];
    }
}

-(void)impatientUser{    
    [timer invalidate];
    [self getNearbyPlaces:self.searchBar.text];
}

-(void)getNearbyPlaces:(NSString*)searchTerm{
    [HUD removeFromSuperview];
    
    if (!searchTerm){
        searchTerm = @"";
    }
    
    self.locationEnabled = TRUE;
    float accuracy = pow(self.location.horizontalAccuracy,2)  + pow(self.location.verticalAccuracy,2);
    accuracy = sqrt( accuracy );
    
    self.gpsLabel.text = [NSString stringWithFormat:@"GPS: %im", (int)accuracy];
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@/v1/places/nearby", [NinaHelper getHostname]];		
    
    NSString* lat = [NSString stringWithFormat:@"%f", self.location.coordinate.latitude];
    NSString* lon = [NSString stringWithFormat:@"%f", self.location.coordinate.longitude];
    
    
    NSString *radius = [NSString stringWithFormat:@"%f", accuracy];
    
    searchTerm  = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    urlString = [NSString stringWithFormat:@"%@?lat=%@&lng=%@&accuracy=%@&query=%@", urlString, lat, lon, radius, searchTerm];
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIHTTPRequest  *request =  [[[ASIHTTPRequest  alloc]  initWithURL:url] autorelease];
    request.tag = 20;
    [NinaHelper signRequest:request];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)dealloc{
    [NinaHelper clearActiveRequests:20];
    [placesTableView release];
    [_searchBar release];
    [nearbyPlaces release];
    [gpsLabel release];
    [toolBar release];
    [_location release];
    [super dealloc];
    
}

- (void)didReceiveMemoryWarning {
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
    self.dataLoaded = FALSE;
    // Do any additional setup after loading the view from its nib.
    needLocationUpdate = false;

    self.navigationItem.title = @"Nearby";

    [[NSBundle mainBundle] loadNibNamed:@"NearbyPlacesFooterView" owner:self options:nil];
    
    self.placesTableView.delegate = self;
    
    if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.placesTableView.bounds.size.height, 320.0f, self.placesTableView.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		[self.placesTableView addSubview:refreshHeaderView];
		self.placesTableView.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}

    self.searchBar.delegate = self;
    [self findNearbyPlaces];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [StyleHelper styleSearchBar:self.searchBar];
    [StyleHelper styleToolBar:self.toolBar];
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
    
    self.placesTableView.tableFooterView = self.tableFooterView;
    
	if (200 != [request responseStatusCode]){
		[NinaHelper handleBadRequest:request sender:self];
	} else {        
        self.dataLoaded = TRUE;

		// Store incoming data into a string
		NSString *jsonString = [request responseString];
		DLog(@"Got JSON BACK: %@", jsonString);
		// Create a dictionary from the JSON string
        
		[nearbyPlaces release];
        NSDictionary *jsonDict = [[jsonString JSONValue] retain];
		nearbyPlaces = [[jsonDict objectForKey:@"places"] retain];
        
		[self.placesTableView  reloadData];
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
    // Return the number of rows in the section.
    NSLog(@"%i", self.dataLoaded);
    NSLog(@"%i", [nearbyPlaces count]);
    if (self.dataLoaded && [nearbyPlaces count] == 0) {
        return 1;
    } else {
        return [nearbyPlaces count];
    }
    //return [nearbyPlaces count];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{    
    if (self.dataLoaded && [nearbyPlaces count] == 0) {
        return 70;
    } else {
        return 44;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (self.dataLoaded && [nearbyPlaces count] == 0) {
        tableView.allowsSelection = NO;
    } else {
        tableView.allowsSelection = YES;
    }
    
    
    if (self.dataLoaded && [nearbyPlaces count] == 0) {
        cell.detailTextLabel.text = @"";
        cell.textLabel.text = @"";
        
        UITextView *errorText = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 50)];
        
        if (self.locationEnabled == FALSE) {
            errorText.text = [NSString stringWithFormat:@"We can't show you any nearby places as you've got location services turned off."];
        } else {
            if (_searchBar.text == (id)[NSNull null] || _searchBar.text.length == 0) {
                errorText.text = [NSString stringWithFormat:@"Boo! We don't know of any nearby places."];
            } else {
                errorText.text = [NSString stringWithFormat:@"Boo! We don't know of any nearby places called '%@'.", _searchBar.text];
            }
        }        
        
        errorText.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        [errorText setUserInteractionEnabled:NO];
        
        errorText.tag = 778;
        [cell addSubview:errorText];
        [errorText release];
    } else {
        DLog(@"Search bar text is: %@", _searchBar.text);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        NSDictionary *place = [nearbyPlaces objectAtIndex:indexPath.row];
        
        if ( [place objectForKey:@"name"] != [NSNull null] ){
            cell.textLabel.text = [place objectForKey:@"name"];
        } else {
            DLog(@"got a place with no-name: %@", [place objectForKey:@"google_id"]);
            cell.textLabel.text = @"n/a";
        }
        
        float lat =   [[[[place objectForKey:@"geometry"] objectForKey: @"location" ] objectForKey:@"lat"] floatValue];
        float lng =   [[[[place objectForKey:@"geometry"] objectForKey: @"location" ] objectForKey:@"lng"] floatValue];
        
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
        
        CLLocationManager *manager = [LocationManagerManager sharedCLLocationManager];
        CLLocation *userLocation = manager.location;
        
        if (userLocation != nil){ 
            float target = [userLocation distanceFromLocation:loc];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0fm", target];
        } else {
            cell.detailTextLabel.text = @"Can't get location";
        }
    }
    
    return cell;
}


#pragma mark Search Bar Methods

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{	
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:FALSE animated:true];
    
    searchBar.text = @"";
    [self findNearbyPlaces:@""];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
	[searchBar setShowsCancelButton:TRUE animated:true];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:FALSE animated:true];
    [self findNearbyPlaces:searchBar.text];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *place = [nearbyPlaces objectAtIndex:indexPath.row];
    PlacePageViewController *placePageViewController = [[PlacePageViewController alloc] init];
    
    placePageViewController.place_id = [place objectForKey:@"id"];
    placePageViewController.google_ref = [place objectForKey:@"reference"];
	[[self navigationController] pushViewController:placePageViewController animated:YES];
	[placePageViewController release];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
	HUD = nil;
}

-(void)hudWasHidden{
    [HUD removeFromSuperview];
    [HUD release];
	HUD = nil;
}


@end
