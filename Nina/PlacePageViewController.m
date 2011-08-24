//
//  PlacePageViewController.m
//  placeling2
//
//  Created by Lindsay Watt on 11-06-23.
//  Copyright 2011 Placeling. All rights reserved.
//

#import "PlacePageViewController.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#import <QuartzCore/QuartzCore.h>

#import "Perspective.h"
#import "Photo.h"
#import "Place.h"

#import "NSString+SBJSON.h"
#import <CoreLocation/CoreLocation.h>


#define kMinCellHeight 60

@interface PlacePageViewController ()
-(void) loadData;
-(void) blankLoad;
-(void) toggleBookmarked;
@end

@implementation PlacePageViewController

@synthesize dataLoaded;
@synthesize google_id, google_ref;
@synthesize place=_place, mapImage;
@synthesize bookmarkButton, phoneButton;
@synthesize nameLabel, addressLabel, cityLabel, categoriesLabel;
@synthesize segmentedControl;
@synthesize mapImageView, googlePlacesButton;
@synthesize perspectivesView, perspectiveType;
@synthesize homePerspectives, followingPerspectives, everyonePerspectives;

- (id) initWithPlace:(Place *)place{
    if(self = [super init]){
        self.place = place;
        self.google_id = place.google_id;
	}
	return self;    
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    // Initializations
    [self blankLoad];
    
    NSString *urlText = [NSString stringWithFormat:@"%@/v1/places/%@?google_ref=%@", [NinaHelper getHostname], self.google_id, self.google_ref];
    
    NSURL *url = [NSURL URLWithString:urlText];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [NinaHelper signRequest:request];
    
    [request setDelegate:self];
    [request startAsynchronous];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.perspectiveType = home;
    
    self.homePerspectives = [[NSMutableArray alloc]initWithObjects: nil];
    perspectives = self.homePerspectives;

}

#pragma mark - Selectors for responding to initial URLs

-(void)requestFailed:(ASIHTTPRequest *)request{
    [NinaHelper handleBadRequest:request sender:self];
}


- (void)requestFinished:(ASIHTTPRequest *)request{    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    if (200 != [request responseStatusCode]){
		[NinaHelper handleBadRequest:request sender:self];
	} else {
        NSString *responseString = [request responseString];        
        DLog(@"%@", responseString);
        
        NSDictionary *json_place = [responseString JSONValue];  
        
        Place *newPlace = [[Place alloc] initFromJsonDict:json_place];
        
        self.place = newPlace;
        [newPlace release];
        
        [self loadData];
        
        if (self.place.bookmarked){
            [self toggleBookmarked];
        }
	}
}

- (void)mapDownloaded:(ASIHTTPRequest *)request{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    int statusCode = [request responseStatusCode];
    NSString *responseBody = [request responseString];
    if ([request responseStatusCode] != 200){
        DLog(@"%i - %@", statusCode, responseBody);
    } else {
        NSData *responseData = [request responseData];
        self.mapImage = [UIImage imageWithData:responseData];
        
        self.mapImageView.image = self.mapImage;
    }
}


#pragma mark - Image Lazy Loader Helpers


#pragma mark - UIScrollViewDelegate


#pragma mark - Table view delegate
-(void) blankLoad{
    if (self.place){
        //loads what we have before grabbing detailed view
        self.nameLabel.text = self.place.name;
        self.addressLabel.text = self.place.address;
        self.cityLabel.text = self.place.city;
        self.phoneButton.titleLabel.text = self.place.phone;
        self.googlePlacesButton.titleLabel.textColor = [UIColor blueColor];
        self.categoriesLabel.text = [self.place.categories componentsJoinedByString:@","];
    } else {
        //puts empty values to show while data being downloaded
        self.nameLabel.text = @"";
        self.addressLabel.text = @"";
        self.phoneButton.titleLabel.text = @"";
        self.googlePlacesButton.titleLabel.textColor = [UIColor grayColor];
        self.categoriesLabel.text = @"";
        self.cityLabel.text = @"";
    }
}

-(void) loadData{
    self.nameLabel.text = self.place.name;
    self.addressLabel.text = self.place.address;
    
    // Call asychronously to get image
    NSString* lat = [NSString stringWithFormat:@"%f",self.place.location.coordinate.latitude];
    NSString* lng = [NSString stringWithFormat:@"%f",self.place.location.coordinate.longitude];    
    
    NSString* imageMapWidth = [NSString stringWithFormat:@"%i", (int)self.mapImageView.frame.size.width ];
    NSString* imageMapHeight = [NSString stringWithFormat:@"%i", (int)self.mapImageView.frame.size.height ];
    
    NSString *mapURL = [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?center=%@,%@&zoom=15&size=%@x%@&&markers=color:red%%7C%@,%@&sensor=false", lat, lng, imageMapWidth, imageMapHeight, lat, lng];
    NSURL *url = [NSURL URLWithString:mapURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDidFinishSelector:@selector(mapDownloaded:)];
    [request setDidFailSelector:@selector(requestWentWrong:)];
    [request setDelegate:self];
    [request startAsynchronous];
        
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    self.phoneButton.titleLabel.text = self.place.phone;
    self.cityLabel.text = self.place.city;
    self.categoriesLabel.text = [self.place.categories componentsJoinedByString:@","];
}


#pragma mark - IBActions

-(IBAction) changedSegment{
    NSUInteger index = self.segmentedControl.selectedSegmentIndex;
    
    if (index == 0){
        self.perspectiveType = home;
    } else if (index == 1){
        self.perspectiveType = following;
    } else if (index == 2){
        self.perspectiveType = everyone;
    }
    
    [self.perspectivesView reloadData];
    
}

-(IBAction) googlePlacePage{
    NSURL *webURL = [NSURL URLWithString:self.place.googlePlacesUrl];
    [[UIApplication sharedApplication] openURL: webURL];
    
}

- (IBAction) phonePlace {    
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"] ) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.place.phone]]];
    } else {
        UIAlertView *Notpermitted=[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Your device doesn't support this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [Notpermitted show];
        [Notpermitted release];
    }
}

#pragma mark - Table View


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ( self.perspectiveType == home ){
        return [perspectives count] +1;
    } else {
        return [perspectives count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *perspectiveCellIdentifier = @"Cell";
    static NSString *bookmarkCellIdentifier = @"BookmarkTableViewCell";
    UITableViewCell *cell;
    
    if ( indexPath.row == 0 && self.perspectiveType == home ){
        cell = [tableView dequeueReusableCellWithIdentifier:bookmarkCellIdentifier];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:perspectiveCellIdentifier];
    }
    
    
    if (cell == nil) {
        if ( indexPath.row == 0 && self.perspectiveType == home ){
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"BookmarkTableViewCell" owner:self options:nil];

            for(id item in objects)
            {
                if ( [item isKindOfClass:[UITableViewCell class]])
                {
                    BookmarkTableViewCell *bmcell = (BookmarkTableViewCell *)item;
                    bmcell.place = self.place;
                    cell = bmcell;
                    break;
                }
            }
                        
        } else {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:perspectiveCellIdentifier] autorelease];
        }
        
    }
    
    // Configure the cell...
    
    return cell;
}




- (void)bookmarkFinished:(ASIFormDataRequest *)request{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSString *responseString = [request responseString];
    DLog(@"Returned: %@", responseString);
    // NSDictionary *placeOutcome = [responseString JSONValue];  
    [self toggleBookmarked];
}

-(void) toggleBookmarked{
    
    self.bookmarkButton.enabled = false;
    self.bookmarkButton.titleLabel.textColor = [UIColor grayColor];
    self.bookmarkButton.titleLabel.text = @"bookmarked";
}


- (void)dealloc{
    [google_id release];
    [google_ref release];
    [_place release];
    [mapImage release];
    [googlePlacesButton release];
    [bookmarkButton release];
    [phoneButton release];
    [nameLabel release];
    [addressLabel release];
    [mapImageView release];
    [cityLabel release];
    [perspectivesView release];
    
    [super dealloc];
}

@end
