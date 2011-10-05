//
//  NearbySuggestedPlaceController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-10-03.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NearbySuggestedPlaceController.h"
#import "NSString+SBJSON.h"
#import "Place.h"

@interface NearbySuggestedPlaceController (Private)
-(void)findNearbyPlaces;
-(void)findNearbyPlaces:(NSString*)searchTerm;
-(void)dataSourceDidFinishLoadingNewData;
@end


@implementation NearbySuggestedPlaceController

@synthesize searchBar=_searchBar, popularPlacesButton, topLocalsButton, toolbar;
@synthesize reloading=_reloading, placesTableView;

-(IBAction)topLocals:(id)sender{
    
}

-(IBAction)popularPlaces:(id)sender{
    
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


-(void)findNearbyPlaces {
    [self findNearbyPlaces:@""];
}

-(void)findNearbyPlaces:(NSString*)searchTerm {
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
        
        searchTerm  = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        
        urlString = [NSString stringWithFormat:@"%@?lat=%@&lng=%@&accuracy=%@&query=%@", urlString, lat, lng, radius, searchTerm];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.placesTableView.bounds.size.height, 320.0f, self.placesTableView.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		[self.placesTableView addSubview:refreshHeaderView];
		self.placesTableView.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
    
    self.searchBar.delegate = self;
    self.placesTableView.delegate = self;
    [self findNearbyPlaces];

}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
    [self findNearbyPlaces:searchBar.text];
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
    return [nearbyPlaces count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    Place *place;
    
    if (indexPath.row >= [nearbyPlaces count]){
        
    
    } else {
        place = [nearbyPlaces objectAtIndex:indexPath.row];
    }
    
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    if (indexPath.row >= [nearbyPlaces count]){
        cell.textLabel.text = @"...Spinner Wait...";
    } else {
        cell.textLabel.text = place.name;
        cell.detailTextLabel.text = place.usersBookmarking;
    }
    if (place){

    }
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}




@end
