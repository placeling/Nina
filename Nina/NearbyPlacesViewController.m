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
#import "FlurryAnalytics.h"


@interface NearbyPlacesViewController (Private)
    -(void)dataSourceDidFinishLoadingNewData;
    -(void)findNearbyPlaces;
    -(void)findNearbyPlaces:(NSString*)searchTerm;
    -(void)impatientUser;
    -(BOOL)showPredictive;
    -(void)getNearbyPlaces:(NSString*)searchTerm;
@end

@implementation NearbyPlacesViewController 

@synthesize reloading=_reloading;
@synthesize placesTableView;
@synthesize searchBar=_searchBar, toolBar;
@synthesize tableFooterView, gpsLabel;
@synthesize dataLoaded, locationEnabled, location=_location;



-(BOOL) showPredictive{
    return showPredictive;        
}

-(void)findNearbyPlaces {
    [self findNearbyPlaces:@""];
}

-(void)findNearbyPlaces:(NSString*)searchTerm {
    //clear predictive places
    [predictivePlaces release];
    predictivePlaces = [[NSMutableArray alloc] init];
    showPredictive = false;
    
    CLLocationManager *manager = [LocationManagerManager sharedCLLocationManager];
    self.location = manager.location;
    NSDate *now = [[NSDate alloc]init];
    float accuracy = pow(self.location.horizontalAccuracy,2)  + pow(self.location.verticalAccuracy,2);
    accuracy = sqrt( accuracy ); //take accuracy as single vector, rather than 2 values -iMack
    
    if (!narrowed && ([now timeIntervalSinceDate:self.location.timestamp] > (60 * 5) || accuracy > 200)){
        //if the location is more than 5 minutes old, or over 200m in accuracy, wait
        //for an update, to a maximum of "n" seconds
        narrowed = TRUE;
        [FlurryAnalytics logEvent:@"LOW_ACCURACY_NEARBY"];
        
        manager.delegate = self;
        [manager startUpdatingLocation]; //should already be going
        
        timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(impatientUser) userInfo:nil repeats:NO];
        
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
        
        self.locationEnabled = FALSE;
        DLog(@"UNABLE TO GET CURRENT LOCATION FOR NEARBY");
    }
    [now release];
    
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
        if (timer){ //no guarantee timer is set
            [timer invalidate];
        }
        [self findNearbyPlaces:self.searchBar.text];
    }
}

-(void)impatientUser{    
    if (timer){ //no guarantee timer is set
        [timer invalidate];
    }
    [self getNearbyPlaces:self.searchBar.text];
}

-(void)getNearbyPlaces:(NSString*)searchTerm{
    [HUD removeFromSuperview];
    
    if (!searchTerm){
        searchTerm = @"";
    }
    [FlurryAnalytics logEvent:@"GOOGLE_PLACES_NEABY_QUERY"];
    self.locationEnabled = TRUE;
    float accuracy = pow(self.location.horizontalAccuracy,2)  + pow(self.location.verticalAccuracy,2);
    accuracy = sqrt( accuracy );
    
    self.gpsLabel.text = [NSString stringWithFormat:@"GPS: %@", [NinaHelper metersToLocalizedDistance:accuracy]];
    
    NSString* lat = [NSString stringWithFormat:@"%f", self.location.coordinate.latitude];
    NSString* lon = [NSString stringWithFormat:@"%f", self.location.coordinate.longitude];
    
    NSString *urlString = @"https://maps.googleapis.com/maps/api/place/search/json?sensor=true&key=AIzaSyAjwCd4DzOM_sQsR7JyXMhA60vEfRXRT-Y";		
    
    searchTerm  = [NinaHelper encodeForUrl:searchTerm];
    
    if ([searchTerm length] > 0){
        accuracy = 15000.0;
        urlString = [NSString stringWithFormat:@"%@&location=%@,%@&radius=%f&name=%@", urlString, lat, lon, accuracy, searchTerm];
    } else {
        accuracy = MAX(100.0, MIN(300.0, accuracy));
        urlString = [NSString stringWithFormat:@"%@&location=%@,%@&radius=%f", urlString, lat, lon, accuracy];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    loading = true;
    ASIHTTPRequest  *request =  [[[ASIHTTPRequest  alloc]  initWithURL:url] autorelease];
    request.tag = 20;
    //[NinaHelper signRequest:request]; //don't sign for Google
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)dealloc{
    [NinaHelper clearActiveRequests:20];
    [placesTableView release];
    [_searchBar release];
    [nearbyPlaces release];
    [predictivePlaces release];
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
    narrowed = false;
    showPredictive = false;
    _reloading = NO;

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

    [FlurryAnalytics logEvent:@"NEARBY_PLACES_VIEW"];
    
    self.searchBar.delegate = self;
    [self findNearbyPlaces];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [StyleHelper styleSearchBar:self.searchBar];
    [StyleHelper styleToolBar:self.toolBar];
    [StyleHelper styleBackgroundView:self.placesTableView];
    [StyleHelper styleBackgroundView:self.tableFooterView];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
    loading = false;
    self.placesTableView.tableFooterView = self.tableFooterView;
    
	if (200 != [request responseStatusCode]){
		[NinaHelper handleBadRequest:request sender:self];
	} else {        
        self.dataLoaded = TRUE;

		// Store incoming data into a string
		NSString *jsonString = [request responseString];
		DLog(@"Got JSON BACK: %@", jsonString);
		// Create a dictionary from the JSON string
        
        NSDictionary *jsonDict = [[jsonString JSONValue] retain];
		//nearbyPlaces = [[jsonDict objectForKey:@"places"] retain];
        
        
        if (request.tag == 20){
            [nearbyPlaces release];
            nearbyPlaces = [[NSMutableArray alloc] init];
        
        
            //remove results we don't really care about
            for (NSDictionary *place in [jsonDict objectForKey:@"results"]){
                NSMutableArray *types = [place objectForKey:@"types"];
                for (int i=0; i<[types count]; i++){
                    [types replaceObjectAtIndex:i withObject:[(NSString*)[types objectAtIndex:i] lowercaseString]];
                }
                if ([types indexOfObject:@"political"] == NSNotFound && 
                     [types indexOfObject:@"route"] == NSNotFound){
                    [nearbyPlaces addObject:place];                
                }
            }
        } else if (request.tag == 21) {
            [predictivePlaces release];
            predictivePlaces = [[NSMutableArray alloc] init];
                        
            //remove results we don't really care about
            for (NSDictionary *place in [jsonDict objectForKey:@"predictions"]){
                NSMutableArray *types = [place objectForKey:@"types"];
                for (int i=0; i<[types count]; i++){
                    [types replaceObjectAtIndex:i withObject:[(NSString*)[types objectAtIndex:i] lowercaseString]];
                }
                if ([types indexOfObject:@"political"] == NSNotFound && 
                    [types indexOfObject:@"route"] == NSNotFound){
                    [predictivePlaces addObject:place];                
                }
            }
        }
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
    DLog(@"%i", self.dataLoaded);
    DLog(@"%i", [nearbyPlaces count]);
    if (self.dataLoaded && [nearbyPlaces count] == 0 && [predictivePlaces count] ==0) {
        return 1;
    } else if (loading){
        return 1;
    }else {
        if ([self showPredictive]){
            return [predictivePlaces count];
        } else {
            return [nearbyPlaces count];
        }
    }
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
    
    static NSString *CellIdentifier;
    
    if (self.dataLoaded && [nearbyPlaces count] == 0 && [predictivePlaces count] ==0) {
        tableView.allowsSelection = NO;
        CellIdentifier = @"CopyCell";
    } else {
        tableView.allowsSelection = YES;
        CellIdentifier = @"DataCell";
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    
    if (self.dataLoaded && [nearbyPlaces count] == 0 && [predictivePlaces count] ==0) {
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
        
        if ([self showPredictive]){
            NSDictionary *place = [predictivePlaces objectAtIndex:indexPath.row];
            NSMutableArray *terms = [place objectForKey:@"terms"];
            cell.textLabel.text = [[terms objectAtIndex:0] objectForKey:@"value"];
            
            NSString *subtitle = @"";
            for (int i =1; i < MIN([terms count], 3); i++){
                subtitle = [NSString stringWithFormat:@"%@ %@", subtitle, [[terms objectAtIndex:i] objectForKey:@"value"]];
            }
            
            cell.detailTextLabel.text = subtitle;
        }else if ( loading ){
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SpinnerTableCell" owner:self options:nil];
            
            for(id item in objects){
                if ( [item isKindOfClass:[UITableViewCell class]]){
                    cell = item;
                }
            }               
            
        } else {
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
                cell.detailTextLabel.text = [NinaHelper metersToLocalizedDistance:target];
            } else {
                cell.detailTextLabel.text = @"Can't get location";
            }
            [loc release];
            [StyleHelper styleGenericTableCell:cell];
        }
    }
    
    return cell;
}


#pragma mark Search Bar Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    //http://code.google.com/apis/maps/documentation/places/autocomplete.html
    showPredictive = true;
    NSString* lat = [NSString stringWithFormat:@"%f", self.location.coordinate.latitude];
    NSString* lon = [NSString stringWithFormat:@"%f", self.location.coordinate.longitude];
    
    NSString *urlString = @"https://maps.googleapis.com/maps/api/place/autocomplete/json?sensor=true&key=AIzaSyAjwCd4DzOM_sQsR7JyXMhA60vEfRXRT-Y&";		
    
    NSString *searchTerm  = [NinaHelper encodeForUrl:searchBar.text];
    
    if ([searchText length] > 0){
        urlString = [NSString stringWithFormat:@"%@&location=%@,%@&radius=%f&input=%@", urlString, lat, lon, 500.0, searchTerm];
        NSURL *url = [NSURL URLWithString:urlString];
        
        ASIHTTPRequest  *request =  [[[ASIHTTPRequest  alloc]  initWithURL:url] autorelease];
        request.tag = 21;
        [request setDelegate:self];
        [request startAsynchronous];
    } else {
        showPredictive = false;
        [predictivePlaces release];
        predictivePlaces = [[NSMutableArray alloc] init];
        [self.placesTableView  reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{	
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:FALSE animated:true];
    
    searchBar.text = @"";
    [self findNearbyPlaces:@""];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
	[searchBar setShowsCancelButton:TRUE animated:true];
    
    if (!searchLogged){
        [FlurryAnalytics logEvent:@"NEARBY_PLACES_VIEW_TEXT_SEARCH"];
        searchLogged = true;
    }
    
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:FALSE animated:true];
    [self findNearbyPlaces:searchBar.text];
}


-(void) keyboardWillShow:(NSNotification *)note {
    CGRect keyboardEndFrame;
    [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];

    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    CGFloat keyboardHeight = keyboardFrame.size.height;

    CGRect frame = self.placesTableView.frame;
    frame.size.height -= (keyboardHeight - self.toolBar.frame.size.height);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    self.placesTableView.frame = frame;
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note {    
    CGRect keyboardEndFrame;
    [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    
    CGRect frame = self.placesTableView.frame;
    frame.size.height += (keyboardHeight - self.toolBar.frame.size.height);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    self.placesTableView.frame = frame;
    [UIView commitAnimations];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *place;
    if ([self showPredictive]){
        place = [predictivePlaces objectAtIndex:indexPath.row];
    } else {
        place = [nearbyPlaces objectAtIndex:indexPath.row];
    }
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
