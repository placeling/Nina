//
//  NearbySuggestedPlaceController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-10-03.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NearbySuggestedPlaceController.h"
#import "SBJSON.h"
#import "PlacePageViewController.h"
#import "PlaceSuggestTableViewCell.h"
#import "Place.h"
#import "LoginController.h"
#import "UIImageView+WebCache.h"
#import "NearbySuggestedMapController.h"
#import "AdTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "GenericWebViewController.h"

@interface NearbySuggestedMapController(Private)
-(void)makeFilteredPlaces;
@end

@implementation NearbySuggestedPlaceController

@synthesize placesTableView;

-(IBAction)toggleMapList{
    NearbySuggestedMapController *nsController = [[NearbySuggestedMapController alloc] init];
    
    nsController.category = self.category;
    nsController.searchTerm = self.searchTerm;
    nsController.followingPlaces = self.followingPlaces;
    nsController.popularPlaces = self.popularPlaces;
    nsController.initialIndex = self.segmentedControl.selectedSegmentIndex;
    nsController.myPlaces = self.myPlaces;
    
    nsController.popularLoaded = self.popularLoaded;
    nsController.myLoaded = self.myLoaded;
    nsController.followingLoaded = self.followingLoaded;
    nsController.navTitle = self.navTitle;
    
    nsController.ad = self.ad;
    nsController.latitudeDelta = self.latitudeDelta;
    nsController.origin = self.origin;
    nsController.quickpick = self.quickpick;
    
    UINavigationController *navController = self.navigationController;
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [UIView setAnimationTransition:
     UIViewAnimationTransitionFlipFromRight
                           forView:self.navigationController.view cache:NO];
    
    NSMutableArray *controllers = [[self.navigationController.viewControllers mutableCopy] autorelease];
    [controllers removeLastObject];
    navController.viewControllers = controllers;
    
    [navController pushViewController:nsController animated: YES];
    [UIView commitAnimations];
    [nsController release];
        
    if ( self.userFilter ){
        [nsController setUserFilter:self.userFilter];
    }
    if ( self.tagFilter ){
        [nsController setTagFilter:self.tagFilter];
    }

}

-(NSMutableArray*)visiblePlaces{
    return self.places;
}

-(IBAction)reloadList{    
    //[self.spinnerView startAnimating];
    //self.spinnerView.hidden = false;
    
    if ( self.quickpick ){
        if (!self.popularLoaded){
            [super findNearbyPlaces];
        }        
    } else {
        if ( self.segmentedControl.selectedSegmentIndex == 0 && !self.myLoaded ){
            [super findNearbyPlaces];
        } else if ( self.segmentedControl.selectedSegmentIndex == 1 && !self.followingLoaded ){
            [super findNearbyPlaces];
        } else if ( self.segmentedControl.selectedSegmentIndex == 2 && !self.popularLoaded ){
            [super findNearbyPlaces];
        }
    }
    
    [self.placesTableView reloadData];
}

#pragma mark - Login delegate methods
- (void) loadContent {
    [super findNearbyPlaces];
    [self.placesTableView reloadData];
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.locationEnabled = TRUE;
    
    [Flurry logEvent:@"QUICK_PICK" withParameters:[NSDictionary dictionaryWithKeysAndObjects:@"category", self.category, nil]];
    
    UIImage *mapImage = [UIImage imageNamed:@"103-map.png"];
    UIBarButtonItem *shareButton =  [[UIBarButtonItem alloc] initWithImage:mapImage style:UIBarButtonItemStylePlain target:self action:@selector(toggleMapList)];
    self.navigationItem.rightBarButtonItem = shareButton;
    [shareButton release];
    
    if ( quickpick ){
        [self.placesTableView setFrame:CGRectMake(self.toolbar.frame.origin.x, self.toolbar.frame.origin.y, self.placesTableView.frame.size.width, self.placesTableView.frame.size.height + self.toolbar.frame.size.height)];
        self.toolbar.hidden = true;
        self.segmentedControl.enabled = false;        
    }
    
    self.placesTableView.delegate = self;
    
    if ( ![self dataLoaded] ){
        //if a set of places hasn't already been set, get them for current location
        [super findNearbyPlaces];
    }
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [StyleHelper styleNavigationBar:self.navigationController.navigationBar];
    [StyleHelper styleBackgroundView:self.placesTableView];
    [self.placesTableView setSeparatorColor:[UIColor clearColor]];
    [self.placesTableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) dealloc{
    [placesTableView release];
    [super dealloc] ;
}

#pragma mark Search Bar Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.searchTerm = searchBar.text;
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:FALSE animated:true];
    [self findNearbyPlaces];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{	
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

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    [super objectLoader:objectLoader didLoadObjects:objects];
    [self makeFilteredPlaces];
    [self.placesTableView reloadData];
}

// CMPopTipViewDelegate method
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    [super popTipViewWasDismissedByUser:popTipView];
    [self makeFilteredPlaces];
    [self.placesTableView reloadData]; 
}

-(void)makeFilteredPlaces{
    
    for (Place *place in self.places){
        if (userFilter || tagFilter){
            place.hidden = true;
        } else {
            place.hidden = false;
        }
        for (Perspective *perspective in place.placemarks){
            if ( (!userFilter || [perspective.user.username isEqualToString:userFilter]) && (!tagFilter || [perspective.tags indexOfObject:tagFilter] != NSNotFound ) ){
                perspective.hidden = false;
                place.hidden = false;
            } else {
                perspective.hidden = true;
            }
        }
    }
}



-(void)setTagFilter:(NSString*)hashTag{
    [super setTagFilter:hashTag];    
    [self makeFilteredPlaces];
    [self.placesTableView reloadData]; 
}

-(void)setUserFilter:(NSString*)username{
    [super setUserFilter:username];
    [self makeFilteredPlaces];
    [self.placesTableView reloadData]; 
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSString *currentUser = [NinaHelper getUsername];
    if (section ==0){
        if (self.ad){
            return 1;
        } else if ( [self dataLoaded] && [self.places count] ==0){
            return 1;
        } else if ( !currentUser && self.segmentedControl.selectedSegmentIndex != 2){  
            return 1;
        } else {
            return 0;
        }
    } else {
        if ( [self dataLoaded] ){
           return [[self places] count];
        } else {
            return 1;
        }
    } 
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{    
    NSString *currentUser = [NinaHelper getUsername];
    
    if ( indexPath.section == 0 ) {
        
        if ( !currentUser && self.segmentedControl.selectedSegmentIndex != 2){
            return 90;
        } else if ( [self dataLoaded] && [self.places count] ==0){
            return 90;
        } else if ( self.ad ){
            return [self.ad.height intValue];
        } else {
            return 0;
        }
    } else {
        if ( [[self places] count] > indexPath.row ){
            Place *place = [[self places] objectAtIndex:indexPath.row];
            if ( place.hidden ){
                return 0;
            } 
        }
        return 70;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *placeCellIdentifier = @"PlaceCell";
    static NSString *loginCellIdentifier = @"LoginCell";
    static NSString *noNearbyCellIdentifier = @"NoNearbyCell";
    static NSString *adCellIdentifier = @"AdCell";
    
    Place *place;
    
    UITableViewCell *cell;
    
    NSString *currentUser = [NinaHelper getUsername];
    
    if (indexPath.section == 1 && indexPath.row ==0 && ![self dataLoaded]){
        //spinner wait, don't actually recycle
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SpinnerTableCell" owner:self options:nil];
        
        for(id item in objects){
            if ( [item isKindOfClass:[UITableViewCell class]]){
                cell = item;
                break;
            }
        }    
        
    } else if (indexPath.section == 0 && self.segmentedControl.selectedSegmentIndex != 2 && !currentUser){
        PlaceSuggestTableViewCell *pCell;
        pCell = [tableView dequeueReusableCellWithIdentifier:loginCellIdentifier];
        if (pCell == nil){
            pCell = [[[PlaceSuggestTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:loginCellIdentifier] autorelease];
        }
        
        tableView.allowsSelection = YES;
        
        pCell.titleLabel.text = @"";
        pCell.addressLabel.text = @"";
        pCell.distanceLabel.text = @"";
        pCell.usersLabel.text = @"";
        
        UITextView *errorText = (UITextView *)[pCell viewWithTag:778];
        if (errorText) {
            [errorText removeFromSuperview];
        }
        
        UITextView *loginText = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 70)];
        
        loginText.backgroundColor = [UIColor clearColor];
        
        if ( self.segmentedControl.selectedSegmentIndex == 0 ){
            loginText.text = @"Sign up or log in to see the nearby places you love.\n\nTap here to get started";
        } else {
            loginText.text = @"Sign up or log in to see nearby places you and the people you follow love.\n\nTap here to get started.";
        }
        loginText.tag = 778;
        
        [loginText setUserInteractionEnabled:NO];
        pCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [pCell addSubview:loginText];
        [loginText release];
        
        cell = pCell;

        
    } else if (indexPath.section == 0 && [[self places] count] == 0 && [self dataLoaded] ){
        PlaceSuggestTableViewCell *pCell;
        pCell = [tableView dequeueReusableCellWithIdentifier:noNearbyCellIdentifier];
        if (pCell == nil){
            pCell = [[[PlaceSuggestTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:noNearbyCellIdentifier] autorelease];
        }
        
        UITextView *existingText = (UITextView *)[pCell viewWithTag:778];
        if (existingText) {
            [existingText removeFromSuperview];
        }
        
        tableView.allowsSelection = NO;
        
        pCell.titleLabel.text = @"";
        pCell.addressLabel.text = @"";
        pCell.distanceLabel.text = @"";
        pCell.usersLabel.text = @"";
        
        UITextView *errorText = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 50)];
        errorText.backgroundColor = [UIColor clearColor];
        
        if (self.locationEnabled == FALSE) {
            errorText.text = [NSString stringWithFormat:@"We can't show you any nearby places as you've got location services turned off."];
        } else {
            if (self.segmentedControl.selectedSegmentIndex == 2) {
                if ([self.searchTerm isEqualToString:@""]) {
                    errorText.text = [NSString stringWithFormat:@"Boo! We don't know of any nearby places."];
                } else {
                    errorText.text = [NSString stringWithFormat:@"Boo! We don't know of any nearby places tagged '%@'.", [self.searchTerm stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
                }
            } else if (self.segmentedControl.selectedSegmentIndex == 1) {
                if ([self.searchTerm isEqualToString:@""]) {
                    errorText.text = [NSString stringWithFormat:@"No one you follow has placemarked anywhere nearby."];
                } else {
                    errorText.text = [NSString stringWithFormat:@"No one you follow has placemarked anywhere nearby tagged '%@'.", [self.searchTerm stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
                }
            }else {
                if ([self.searchTerm isEqualToString:@""]) {
                    errorText.text = [NSString stringWithFormat:@"You haven't placemarked anything nearby."];
                } else {
                    errorText.text = [NSString stringWithFormat:@"You haven't placemearked anything nearby tagged '%@'.", [self.searchTerm stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
                }
                
                
                self.searchTerm  = [self.searchTerm stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            }
        }        
        
        errorText.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        [errorText setUserInteractionEnabled:NO];
        
        errorText.tag = 778;
        [pCell addSubview:errorText];
        [errorText release];
        cell = pCell;
    
    } else if (indexPath.section == 0 && self.ad){
        AdTableViewCell *aCell;
        aCell = [tableView dequeueReusableCellWithIdentifier:adCellIdentifier];
        
        if (aCell == nil){
            aCell = [[[AdTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:adCellIdentifier] autorelease];
        }        
        
        UIImageView *imageView = [[UIImageView alloc]init];
        
        [imageView setImageWithURL:[NSURL URLWithString:self.ad.imageUrl] ];
        [Flurry logEvent:@"AD_DISPLAY" withParameters:[NSDictionary dictionaryWithKeysAndObjects:@"type", self.ad.adType, nil]];
        aCell.backgroundView = imageView;   
        [imageView release];                    
        cell = aCell;     
        
    } else {//if ( indexPath.section == 1 && [[self places] count] > 0) {
        PlaceSuggestTableViewCell *pCell;
        pCell = [tableView dequeueReusableCellWithIdentifier:placeCellIdentifier];
        if (pCell == nil) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PlaceSuggestTableViewCell" owner:self options:nil];
            
            for(id item in objects){
                if ( [item isKindOfClass:[UITableViewCell class]]){
                    pCell = item;
                }
            }
        }
        tableView.allowsSelection = YES;
        place = [[self places] objectAtIndex:indexPath.row];
        
        UITextView *errorText = (UITextView *)[pCell viewWithTag:778];
        if (errorText) {
            [errorText removeFromSuperview];
        }
        
        if (place.highlighted){
            [pCell.imageView setImageWithURL:[NSURL URLWithString:place.highlightUrl] placeholderImage:[UIImage imageNamed:@"DefaultPhoto.png"]];
        } else {
            [pCell.imageView setImageWithURL:[NSURL URLWithString:place.placeThumbUrl] placeholderImage:[UIImage imageNamed:@"DefaultPhoto.png"]];
        }
        
        
        
        pCell.titleLabel.text = place.name;
        pCell.addressLabel.text = place.streetAddress;
        pCell.distanceLabel.text = [NinaHelper metersToLocalizedDistance:place.distance];
        pCell.usersLabel.text = place.usersBookmarkingString;   
        [StyleHelper styleQuickPickCell:pCell]; 
        
        cell = pCell;
        
        if (place.hidden){
            cell.hidden = true;
        }
        
    }   
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *currentUser = [NinaHelper getUsername];
    [tableView deselectRowAtIndexPath:indexPath animated:true];

    if (indexPath.section == 0 && self.segmentedControl.selectedSegmentIndex !=2 && !currentUser){
        LoginController *loginController = [[LoginController alloc] init];
        loginController.delegate = self;
        
        UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:loginController];
        [self.navigationController presentModalViewController:navBar animated:YES];
        [navBar release];
        [loginController release];
        
    } else if (indexPath.section == 0 && self.ad){
        [Flurry logEvent:@"AD_CLICK" withParameters:[NSDictionary dictionaryWithKeysAndObjects:@"type", self.ad.adType, nil]];
        
        GenericWebViewController *webController = [[GenericWebViewController alloc] initWithUrl:self.ad.targetUrl];
        
        [self.navigationController pushViewController:webController animated:true];
        [webController release];
        
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (indexPath.row < [[self places] count]){
            Place *place = [[self places] objectAtIndex:indexPath.row];
            
            PlacePageViewController *placeController = [[PlacePageViewController alloc] initWithPlace:place];
            
            if (place.google_ref){
                placeController.google_ref = place.google_ref;
            }
            
            placeController.initialSelectedIndex = [NSNumber numberWithInt:self.segmentedControl.selectedSegmentIndex];
            
            [self.navigationController pushViewController:placeController animated:TRUE];
            [placeController release];
        }
    }  
    
}

@end
