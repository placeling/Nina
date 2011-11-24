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
#import "LoginController.h"

@interface NearbySuggestedPlaceController (Private)
-(void)findNearbyPlaces;
-(void)dataSourceDidFinishLoadingNewData;
-(NSString*) encodeForUrl:(NSString*)string;
@end


@implementation NearbySuggestedPlaceController

@synthesize searchBar=_searchBar, popularPlacesButton, topLocalsButton, toolbar;
@synthesize reloading=_reloading, showAll, placesTableView, searchTerm, category, dataLoaded, locationEnabled;

-(IBAction)topLocals:(id)sender{
    SuggestUserViewController *suggestUserViewController = [[SuggestUserViewController alloc] init];
    
    suggestUserViewController.query = [self encodeForUrl:self.searchBar.text];
    
    suggestUserViewController.title = @"Top Locals";
    
    [self.navigationController pushViewController:suggestUserViewController animated:YES];
    [suggestUserViewController release];
    
}

-(IBAction)popularPlaces:(id)sender{
    
    NearbySuggestedPlaceController *placeController = [[NearbySuggestedPlaceController alloc] init];
    
    placeController.showAll = true;
    placeController.category = self.category;
    placeController.searchTerm = self.searchTerm;
    
    [self.navigationController pushViewController:placeController animated:true];
    [placeController release];
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
        
        NSString *queryString = [self encodeForUrl:self.searchTerm];
        NSString *categoryString = [self encodeForUrl:self.category];
        
        
        NSString *currentUser = [NinaHelper getUsername];            
        if (showAll || !currentUser || currentUser.length == 0 ){
            urlString = [NSString stringWithFormat:@"%@?socialgraph=false&lat=%@&lng=%@&accuracy=%@&query=%@&category=%@", urlString, lat, lng, radius, queryString, categoryString];
        } else {
            urlString = [NSString stringWithFormat:@"%@?socialgraph=true&lat=%@&lng=%@&accuracy=%@&query=%@&category=%@", urlString, lat, lng, radius, queryString, categoryString];
        }
        
        NSURL *url = [NSURL URLWithString:urlString];
        
        self.locationEnabled = TRUE;
        
		ASIHTTPRequest  *request =  [[[ASIHTTPRequest  alloc]  initWithURL:url] autorelease];
        request.tag = 80;
        [NinaHelper signRequest:request];
		[request setDelegate:self];
		[request startAsynchronous];
	} else {
        self.dataLoaded = TRUE;
        self.locationEnabled = FALSE;
        if (nearbyPlaces) {
            [nearbyPlaces release];            
        }
        nearbyPlaces = [[NSMutableArray alloc] initWithCapacity:0];
        
        [self.placesTableView reloadData];
        
        DLog(@"UNABLE TO GET CURRENT LOCATION FOR NEARBY");
    }
    
}

#pragma mark - Login delegate methods
- (void) loadContent {
    [self findNearbyPlaces];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.dataLoaded = FALSE;
    self.locationEnabled = TRUE;
    
    if (refreshHeaderView == nil) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.placesTableView.bounds.size.height, 320.0f, self.placesTableView.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		[self.placesTableView addSubview:refreshHeaderView];
		self.placesTableView.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
    
    if (!self.category){
        self.category = @""; //can't be a nil
    }
        
    if (!self.searchTerm){
        self.searchTerm = @"";
        self.searchBar.text = @"";
        self.searchBar.placeholder = @"search";
    } else {
        self.searchBar.text = self.searchTerm;
    }
    
    if (self.showAll){
        [self.placesTableView setFrame:CGRectMake(self.placesTableView.frame.origin.x, self.placesTableView.frame.origin.y, self.placesTableView.frame.size.width, self.placesTableView.frame.size.height + self.toolbar.frame.size.height)];
        self.toolbar.hidden = true;
    }
    
    self.searchBar.delegate = self;
    self.placesTableView.delegate = self;
    
    [self loadContent];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.category &&  [self.category length] > 0){
        self.navigationItem.title = self.category;
    } else {
        self.navigationItem.title = @"Nearby";
    }
    
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
    [category release];
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

#pragma mark Search Bar Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.searchTerm = searchBar.text;
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:FALSE animated:true];
    [self findNearbyPlaces];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{	
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:false animated:true];
    
    searchBar.text = @"";
    
    if ([self.searchTerm isEqualToString:@""] == FALSE) {
        self.searchTerm = @"";
        [self findNearbyPlaces];
    }
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
		self.dataLoaded = TRUE;
        
        // Store incoming data into a string
		NSString *jsonString = [request responseString];
		DLog(@"Got JSON BACK: %@", jsonString);
		// Create a dictionary from the JSON string
        
		[nearbyPlaces release];
        nearbyPlaces = nil;
        NSDictionary *jsonDict = [[jsonString JSONValue] retain];
		NSArray *rawPlaces = [jsonDict objectForKey:@"suggested_places"];
        
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
    NSString *currentUser = [NinaHelper getUsername];
    // Return the number of sections.
    if (self.showAll || (currentUser && currentUser.length > 0)){
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *currentUser = [NinaHelper getUsername];
    
    if (!self.showAll && (!currentUser || currentUser.length == 0) && section == 0) {
        return 1;
    } else if (self.dataLoaded && [nearbyPlaces count] == 0) {
        return 1;
    } else {
        return [nearbyPlaces count];
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{    
    NSString *currentUser = [NinaHelper getUsername];
    
    if (!self.showAll && (!currentUser || currentUser.length == 0) && indexPath.section == 0) {
        return 90;
    } else {
        return 70;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *placeCellIdentifier = @"PlaceCell";
    static NSString *loginCellIdentifier = @"LoginCell";
    static NSString *noNearbyCellIdentifier = @"NoNearbyCell";
    
    Place *place;
    PlaceSuggestTableViewCell *cell;
    
    if ([nearbyPlaces count] > 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:placeCellIdentifier];
    } else {
        NSString *currentUser = [NinaHelper getUsername];
        if (!currentUser || currentUser.length == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:loginCellIdentifier];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:noNearbyCellIdentifier];
        }
    }
    
    //cell = [tableView dequeueReusableCellWithIdentifier:placeCellIdentifier];
    
    if (cell == nil) {
        NSString *currentUser = [NinaHelper getUsername];
        if ((!self.showAll && (!currentUser || currentUser.length == 0)) && indexPath.section == 0) {
            cell = [[[PlaceSuggestTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:loginCellIdentifier] autorelease];
            
            tableView.allowsSelection = YES;
            
            cell.titleLabel.text = @"";
            cell.addressLabel.text = @"";
            cell.distanceLabel.text = @"";
            cell.usersLabel.text = @"";
            
            UITextView *loginText = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 70)];
            
            loginText.text = @"Sign up or log in to check out nearby places you and the people you follow love.\n\nTap here to get started.";
            loginText.tag = 778;
            
            [loginText setUserInteractionEnabled:NO];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [cell addSubview:loginText];
            [loginText release];
        } else if (self.dataLoaded && [nearbyPlaces count] == 0) {
            cell = [[[PlaceSuggestTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:noNearbyCellIdentifier] autorelease];
            
            UITextView *existingText = (UITextView *)[cell viewWithTag:778];
            if (existingText) {
                [existingText removeFromSuperview];
            }
            
            tableView.allowsSelection = NO;
            
            cell.titleLabel.text = @"";
            cell.addressLabel.text = @"";
            cell.distanceLabel.text = @"";
            cell.usersLabel.text = @"";
            
            UITextView *errorText = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 50)];
            
            
            if (self.locationEnabled == FALSE) {
                errorText.text = [NSString stringWithFormat:@"We can't show you any nearby places as you've got location services turned off."];
            } else {
                if (self.showAll == TRUE) {
                    if ([self.searchTerm isEqualToString:@""] == TRUE) {
                        errorText.text = [NSString stringWithFormat:@"Boo! We don't know of any nearby places."];
                    } else {
                        errorText.text = [NSString stringWithFormat:@"Boo! We don't know of any nearby places tagged '%@'.", [self.searchTerm stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
                    }
                } else {
                    if ([self.searchTerm isEqualToString:@""] == TRUE) {
                        errorText.text = [NSString stringWithFormat:@"You and your network haven't bookmarked any nearby places."];
                    } else {
                        errorText.text = [NSString stringWithFormat:@"You and your network haven't bookmarked any nearby places tagged '%@'.", [self.searchTerm stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
                    }
                    
                    
                    self.searchTerm  = [self.searchTerm stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
                }
            }        
            
            errorText.font = [UIFont fontWithName:@"Helvetica" size:14.0];
            [errorText setUserInteractionEnabled:NO];
            
            errorText.tag = 778;
            [cell addSubview:errorText];
            [errorText release];
        } else {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PlaceSuggestTableViewCell" owner:self options:nil];
            
            for(id item in objects){
                if ( [item isKindOfClass:[UITableViewCell class]]){
                    cell = item;
                }
            }
            
            tableView.allowsSelection = YES;
            
            place = [nearbyPlaces objectAtIndex:indexPath.row];
            
            UITextView *errorText = (UITextView *)[cell viewWithTag:778];
            if (errorText) {
                [errorText removeFromSuperview];
            }
            
            cell.titleLabel.text = place.name;
            cell.addressLabel.text = place.address;
            cell.distanceLabel.text = place.distance;
            cell.usersLabel.text = place.usersBookmarkingString;   
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        }
    }
    
    return cell;
}

-(NSString*) encodeForUrl:(NSString*)string{

    NSMutableString *escaped = [NSMutableString stringWithString:[string stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];   
    
    [escaped replaceOccurrencesOfString:@"$" withString:@"%24" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"&" withString:@"%26" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"+" withString:@"%2B" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"," withString:@"%2C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"/" withString:@"%2F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@":" withString:@"%3A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@";" withString:@"%3B" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"=" withString:@"%3D" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"?" withString:@"%3F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"@" withString:@"%40" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@" " withString:@"%20" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"\t" withString:@"%09" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"#" withString:@"%23" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"<" withString:@"%3C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@">" withString:@"%3E" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"\"" withString:@"%22" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    [escaped replaceOccurrencesOfString:@"\n" withString:@"%0A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [escaped length])];
    
    return escaped;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *currentUser = [NinaHelper getUsername];
    
    if ((!self.showAll && (!currentUser || currentUser.length == 0)) && indexPath.section == 0) {
        LoginController *loginController = [[LoginController alloc] init];
        loginController.delegate = self;
        
        UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:loginController];
        [self.navigationController presentModalViewController:navBar animated:YES];
        [navBar release];
        [loginController release];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (indexPath.row < [nearbyPlaces count]){
            Place *place = [nearbyPlaces objectAtIndex:indexPath.row];
            
            PlacePageViewController *placeController = [[PlacePageViewController alloc] initWithPlace:place];
            [self.navigationController pushViewController:placeController animated:TRUE];
            [placeController release];
        
        }
    }
}

@end
