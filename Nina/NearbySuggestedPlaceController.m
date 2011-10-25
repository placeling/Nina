//
//  NearbySuggestedPlaceController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-10-03.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NearbySuggestedPlaceController.h"
#import "NSString+SBJSON.h"
#import "PlacePageViewController.h"
#import "SuggestUserViewController.h"
#import "PlaceSuggestTableViewCell.h"
#import "Place.h"

@interface NearbySuggestedPlaceController (Private)
-(void)findNearbyPlaces;
-(void)dataSourceDidFinishLoadingNewData;
@end


@implementation NearbySuggestedPlaceController

@synthesize searchBar=_searchBar, popularPlacesButton, topLocalsButton, toolbar;
@synthesize reloading=_reloading, showAll, placesTableView, searchTerm;

-(IBAction)topLocals:(id)sender{
    SuggestUserViewController *suggestUserViewController = [[SuggestUserViewController alloc] init];
    [self.navigationController pushViewController:suggestUserViewController animated:YES];
    [suggestUserViewController release]; 
    
}

-(IBAction)popularPlaces:(id)sender{
    if (!self.showAll){
        self.showAll = TRUE;
        self.popularPlacesButton.title = @"Following's Places";
    }else{
        self.showAll = false;
        self.popularPlacesButton.title = @"Popular Places";
    }
    [self findNearbyPlaces];
}



-(void)findNearbyPlaces {
	//NSDate *now = [NSDate date];
	
    CLLocationManager *manager = [LocationManagerManager sharedCLLocationManager];
    CLLocation *location = manager.location;
    
	if (location != nil){ //[now timeIntervalSinceDate:location.timestamp] < (60 * 5)){
        
        float accuracy = pow(location.horizontalAccuracy,2)  + pow(location.verticalAccuracy,2);
        accuracy = sqrt( accuracy ); //take accuracy as single vector, rather than 2 values -iMack
        
        accuracy = MAX(accuracy, 50); //govern the accuracy so a few places get in
        
		NSString *urlString = [NSString stringWithFormat:@"%@/v1/places/suggested", [NinaHelper getHostname]];		
        
		NSString* lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
		NSString* lng = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
				
        NSString *radius = [NSString stringWithFormat:@"%f", accuracy];
        
        self.searchTerm  = [self.searchTerm stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        
        if (!showAll){
            urlString = [NSString stringWithFormat:@"%@?socialgraph=true&lat=%@&lng=%@&accuracy=%@&query=%@", urlString, lat, lng, radius, self.searchTerm];
        } else {
            urlString = [NSString stringWithFormat:@"%@?socialgraph=false&lat=%@&lng=%@&accuracy=%@&query=%@", urlString, lat, lng, radius, self.searchTerm];
        }
        NSURL *url = [NSURL URLWithString:urlString];
        
		ASIHTTPRequest  *request =  [[[ASIHTTPRequest  alloc]  initWithURL:url] autorelease];
        request.tag = 80;
        [NinaHelper signRequest:request];
		[request setDelegate:self];
		[request startAsynchronous];
	} else {
        DLog(@"UNABLE TO GET CURRENT LOCATION FOR NEARBY");
    }
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.placesTableView.bounds.size.height, 320.0f, self.placesTableView.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		[self.placesTableView addSubview:refreshHeaderView];
		self.placesTableView.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
    
    if (!self.searchTerm){
        self.searchTerm = @"";
        self.searchBar.text = @"";
        self.searchBar.placeholder = @"enter tag search";
    } else {
        self.searchBar.text = self.searchTerm;
    }
    //self.searchBar.
    self.searchBar.delegate = self;
    self.placesTableView.delegate = self;
    [self findNearbyPlaces];

}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.title = @"Nearby";
    [StyleHelper styleNavigationBar:self.navigationController.navigationBar];
    [StyleHelper styleToolBar:self.toolbar];
    [StyleHelper styleSearchBar:self.searchBar];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) dealloc{
    [NinaHelper clearActiveRequests:80];
    [_searchBar release]; 
    [popularPlacesButton release]; 
    [topLocalsButton release];
    [toolbar release];
    [placesTableView release];
    [searchTerm release];
    [super dealloc] ;
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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.searchTerm = searchBar.text;
    [searchBar setShowsCancelButton:FALSE animated:true];
    [self findNearbyPlaces];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{	
	searchBar.text = searchTerm;	
	[searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:FALSE animated:true];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
	[searchBar setShowsCancelButton:TRUE animated:true];
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
        
		[nearbyPlaces release];
        nearbyPlaces = nil;
        NSDictionary *jsonDict = [[jsonString JSONValue] retain];
		NSArray *rawPlaces = [[jsonDict objectForKey:@"suggested_places"] retain];
        
        if (!nearbyPlaces){
            nearbyPlaces = [[NSMutableArray alloc] initWithCapacity:[rawPlaces count]];
        } 
        
        for (NSDictionary* dict in rawPlaces){
            Place* place = [[Place alloc] initFromJsonDict:dict];
            [nearbyPlaces  addObject:place]; 
            [place release];
        }
        
		[self.placesTableView  reloadData];
		[jsonDict release];
	}
    
    [self dataSourceDidFinishLoadingNewData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [nearbyPlaces count];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{    
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *placeCellIdentifier = @"PlaceCell";
    
    Place *place;
    PlaceSuggestTableViewCell *cell;

    cell = [tableView dequeueReusableCellWithIdentifier:placeCellIdentifier];
    place = [nearbyPlaces objectAtIndex:indexPath.row];
    //searchTerm
    
    if (cell == nil) {

        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PlaceSuggestTableViewCell" owner:self options:nil];
        
        for(id item in objects){
            if ( [item isKindOfClass:[UITableViewCell class]]){
                cell = item;
            }
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.titleLabel.text = place.name;
    cell.addressLabel.text = place.address;
    cell.distanceLabel.text = @""; //place.
    cell.usersLabel.text = place.usersBookmarkingString;

    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < [nearbyPlaces count]){
        Place *place = [nearbyPlaces objectAtIndex:indexPath.row];
        
        PlacePageViewController *placeController = [[PlacePageViewController alloc] initWithPlace:place];
        [self.navigationController pushViewController:placeController animated:TRUE];
        [placeController release];
        
    }
    
    
}




@end
