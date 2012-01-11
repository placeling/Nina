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
#import "PlaceSuggestTableViewCell.h"
#import "Place.h"
#import "LoginController.h"
#import "UIImageView+WebCache.h"


@implementation NearbySuggestedPlaceController

@synthesize searchBar=_searchBar, placesTableView;

-(IBAction)toggleMapList{
    NearbySuggestedPlaceController *nsController = [[NearbySuggestedPlaceController alloc] init];
    
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration:0.80];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [UIView setAnimationTransition:
     UIViewAnimationTransitionFlipFromRight
                           forView:self.navigationController.view cache:NO];
    
    
    [self.navigationController pushViewController:nsController animated:YES];
    [UIView commitAnimations];

}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.locationEnabled = TRUE;
    
    if (!self.category){
        self.category = @""; //can't be a nil
    }
        
    if (!self.searchTerm){
        self.searchTerm = @"";
        self.searchBar.text = @"";
        self.searchBar.placeholder = @"search tags";
    } else {
        self.searchBar.text = self.searchTerm;
    }
    
    UIBarButtonItem *shareButton =  [[UIBarButtonItem  alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(toggleMapList)];
    self.navigationItem.rightBarButtonItem = shareButton;
    [shareButton release];
    
    
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
    [StyleHelper styleSearchBar:self.searchBar];
    [StyleHelper styleBackgroundView:self.placesTableView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) dealloc{
    [_searchBar release]; 
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
    [self.placesTableView reloadData]; 
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section ==0){
        return 0;
    }else if (section == 1){
        return MAX([followingPlaces count], 1);
    } else {
        return MAX([popularPlaces count], 1);
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{    
    NSString *currentUser = [NinaHelper getUsername];
    
    if (!currentUser && indexPath.section == 0) {
        return 90;
    } else {
        return 70;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
    if (section == 1){
        return nil;
    } else if (section == 2){
        return @"Popular Places";
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *placeCellIdentifier = @"PlaceCell";
    static NSString *loginCellIdentifier = @"LoginCell";
    static NSString *noNearbyCellIdentifier = @"NoNearbyCell";
    
    NSMutableArray *places;
    BOOL dataloaded;
    if (indexPath.section ==2){
        places = popularPlaces;
        dataloaded = popularLoaded;
    } else {
        places = followingPlaces;
        dataloaded = followingLoaded;
    }
    
    Place *place;
    PlaceSuggestTableViewCell *cell;
    
    if ([places count] > 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:placeCellIdentifier];
        if (cell == nil) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PlaceSuggestTableViewCell" owner:self options:nil];
            
            for(id item in objects){
                if ( [item isKindOfClass:[UITableViewCell class]]){
                    cell = item;
                }
            }
        }
    } else {
        NSString *currentUser = [NinaHelper getUsername];
        if (!currentUser) {
            cell = [tableView dequeueReusableCellWithIdentifier:loginCellIdentifier];
            if (cell == nil){
                cell = [[[PlaceSuggestTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:loginCellIdentifier] autorelease];
            }
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:noNearbyCellIdentifier];
            if (cell == nil){
                cell = [[[PlaceSuggestTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:noNearbyCellIdentifier] autorelease];
            }
        }
    }
        
    NSString *currentUser = [NinaHelper getUsername];
    if (indexPath.section == 0 && !currentUser) {
        cell = [[[PlaceSuggestTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:loginCellIdentifier] autorelease];
        
        tableView.allowsSelection = YES;
        
        cell.titleLabel.text = @"";
        cell.addressLabel.text = @"";
        cell.distanceLabel.text = @"";
        cell.usersLabel.text = @"";
        
        UITextView *loginText = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 70)];
        
        loginText.backgroundColor = [UIColor clearColor];
        
        loginText.text = @"Sign up or log in to check out nearby places you and the people you follow love.\n\nTap here to get started.";
        loginText.tag = 778;
        
        [loginText setUserInteractionEnabled:NO];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell addSubview:loginText];
        [loginText release];
    } else if (dataloaded && [places count] == 0 ) {
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
        errorText.backgroundColor = [UIColor clearColor];
        
        if (self.locationEnabled == FALSE) {
            errorText.text = [NSString stringWithFormat:@"We can't show you any nearby places as you've got location services turned off."];
        } else {
            if (indexPath.section == 2) {
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
    } else if (!dataloaded){
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SpinnerTableCell" owner:self options:nil];

        for(id item in objects){
           if ( [item isKindOfClass:[UITableViewCell class]]){
               cell = item;
           }
        }    
    
    }else{
        tableView.allowsSelection = YES;
        
        place = [places objectAtIndex:indexPath.row];
        
        UITextView *errorText = (UITextView *)[cell viewWithTag:778];
        if (errorText) {
            [errorText removeFromSuperview];
        }
        
        [cell.imageView setImageWithURL:[NSURL URLWithString:place.placeThumbUrl] placeholderImage:[UIImage imageNamed:@"DefaultPhoto.png"]];
        
        cell.titleLabel.text = place.name;
        cell.addressLabel.text = place.address;
        cell.distanceLabel.text = [NinaHelper metersToLocalizedDistance:place.distance];
        cell.usersLabel.text = place.usersBookmarkingString;   
        [StyleHelper colourHomePageLabel:cell.usersLabel];
        /* [StyleHelper colourTitleLabel:cell.titleLabel];
        [StyleHelper colourTitleLabel:cell.addressLabel];
        [StyleHelper colourTitleLabel:cell.distanceLabel]; */           
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    }
        
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *currentUser = [NinaHelper getUsername];
    
    if ( !currentUser && indexPath.section == 0) {
        LoginController *loginController = [[LoginController alloc] init];
        loginController.delegate = self;
        
        UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:loginController];
        [self.navigationController presentModalViewController:navBar animated:YES];
        [navBar release];
        [loginController release];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (indexPath.row < [followingPlaces count]){
            Place *place = [followingPlaces objectAtIndex:indexPath.row];
            
            PlacePageViewController *placeController = [[PlacePageViewController alloc] initWithPlace:place];
            
            if (place.google_ref){
                placeController.google_ref = place.google_ref;
            }
            
            [self.navigationController pushViewController:placeController animated:TRUE];
            [placeController release];
        
        }
    }
}

@end
