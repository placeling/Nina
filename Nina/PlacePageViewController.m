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

#import "MBProgressHUD.h"
#import "PerspectiveTableViewCell.h"
#import "MyPerspectiveCellViewController.h"
#import "EditPerspectiveViewController.h"


#define kMinCellHeight 60

@interface PlacePageViewController ()
-(void) loadData;
-(void) blankLoad;
-(void) loadMap;
@end

@implementation PlacePageViewController

@synthesize dataLoaded;
@synthesize google_id, google_ref;
@synthesize place=_place, mapImage;
@synthesize nameLabel, addressLabel, cityLabel, categoriesLabel;
@synthesize segmentedControl;
@synthesize mapImageView, googlePlacesButton;
@synthesize tableHeaderView, tableFooterView, perspectiveType;
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
    
    //the place header subview - needs this line, no more
    [[NSBundle mainBundle] loadNibNamed:@"PlaceHeaderView" owner:self options:nil];
    [[NSBundle mainBundle] loadNibNamed:@"PlaceFooterView" owner:self options:nil];
    
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.tableHeaderView = self.tableHeaderView;
    self.tableView.tableFooterView = self.tableFooterView;
    // Initializations
    [self blankLoad];
    
    NSString *urlText = [NSString stringWithFormat:@"%@/v1/places/%@?google_ref=%@", [NinaHelper getHostname], self.google_id, self.google_ref];
    
    NSURL *url = [NSURL URLWithString:urlText];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [NinaHelper signRequest:request];
    
    [request setDelegate:self];
    [request setTag:0];
    [request startAsynchronous];
    
    if (self.place){
        [self loadMap];
    } else {
        mapRequested = false;
    }
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.perspectiveType = home;
    
    self.navigationController.title = self.place.name;

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
  
        switch( [request tag] ){
            case 0:{
                //place detail
                NSString *responseString = [request responseString];        
                DLog(@"%@", responseString);
                
                NSDictionary *jsonDict = [responseString JSONValue];  
                
                Place *newPlace = [[Place alloc] initFromJsonDict:jsonDict];
                
                self.place = newPlace;
                [newPlace release];
                
                NSArray *jsonPerspectives = [jsonDict objectForKey:@"perspectives"];
                homePerspectives = [[NSMutableArray alloc] initWithCapacity:[jsonPerspectives count]];
                for (NSDictionary *rawDict in jsonPerspectives){
                    Perspective *perspective = [[Perspective alloc] initFromJsonDict:rawDict];
                    perspective.place = self.place;
                    [homePerspectives addObject:perspective];
                    [perspective release];
                }
                perspectives = self.homePerspectives;
                
                [self loadData];
                [self.tableView reloadData];
                
                break;
            }
            case 1:{
                //map download
                NSData *responseData = [request responseData];
                self.mapImage = [UIImage imageWithData:responseData];
                
                self.mapImageView.image = self.mapImage;
                break;
            }
            case 2:{
                NSString *responseString = [request responseString];        
                DLog(@"%@", responseString);
                
                NSDictionary *jsonDict = [responseString JSONValue];  
                NSArray *jsonPerspectives = [jsonDict objectForKey:@"perspectives"];
                
                //this only called if array was previously nil
                followingPerspectives = [[NSMutableArray alloc] initWithCapacity:[jsonPerspectives count]];
                for (NSDictionary *rawDict in jsonPerspectives){
                    Perspective *perspective = [[Perspective alloc] initFromJsonDict:rawDict];
                    perspective.place = self.place;
                    [followingPerspectives addObject:perspective];
                    [perspective release];
                }
                
                [self.tableView reloadData];
                break;
            }
            case 3:{
                NSString *responseString = [request responseString];        
                DLog(@"%@", responseString);
                
                NSDictionary *jsonDict = [responseString JSONValue];  
                NSArray *jsonPerspectives = [jsonDict objectForKey:@"perspectives"];
                //this only called if array was previously nil
                
                for (NSDictionary *rawDict in jsonPerspectives){
                    Perspective *perspective = [[Perspective alloc] initFromJsonDict:rawDict];
                    perspective.place = self.place;
                    [everyonePerspectives addObject:perspective];
                    [perspective release];
                }
                
                [self.tableView reloadData];
                break;
            }
            case 4:{
                //bookmark return
                NSString *responseString = [request responseString];        
                DLog(@"%@", responseString);
                self.place.bookmarked = true;
                [self.tableView reloadData];                
                
                break;
            }
        }

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

        self.categoriesLabel.text = [self.place.categories componentsJoinedByString:@","];
    } else {
        //puts empty values to show while data being downloaded
        self.nameLabel.text = @"";
        self.addressLabel.text = @"";
        self.googlePlacesButton.titleLabel.textColor = [UIColor grayColor];
        self.categoriesLabel.text = @"";
        self.cityLabel.text = @"";
    }
}

-(void) loadMap{    
    // Call asychronously to get image
    NSString* lat = [NSString stringWithFormat:@"%f",self.place.location.coordinate.latitude];
    NSString* lng = [NSString stringWithFormat:@"%f",self.place.location.coordinate.longitude];    
    
    NSString* imageMapWidth = [NSString stringWithFormat:@"%i", (int)self.mapImageView.frame.size.width ];
    NSString* imageMapHeight = [NSString stringWithFormat:@"%i", (int)self.mapImageView.frame.size.height ];
    
    NSString *mapURL = [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?center=%@,%@&zoom=15&size=%@x%@&&markers=color:red%%7C%@,%@&sensor=false", lat, lng, imageMapWidth, imageMapHeight, lat, lng];
    NSURL *url = [NSURL URLWithString:mapURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request setTag:1];
    [request startAsynchronous];
    
    mapRequested = true;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


-(void) loadData{
    self.nameLabel.text = self.place.name;
    self.addressLabel.text = self.place.address;
    
    
    if (!mapRequested){
        [self loadMap];
    } 
   

    self.cityLabel.text = self.place.city;
    self.categoriesLabel.text = [self.place.categories componentsJoinedByString:@","];
    [self.segmentedControl setTitle:[NSString stringWithFormat:@"Following (%i)", self.place.followingPerspectiveCount] forSegmentAtIndex:1];
    [self.segmentedControl setTitle:[NSString stringWithFormat:@"Everyone (%i)", self.place.perspectiveCount] forSegmentAtIndex:2];
    
}


#pragma mark - IBActions

-(IBAction) changedSegment{
    NSUInteger index = self.segmentedControl.selectedSegmentIndex;
    
    if (index == 0){
        self.perspectiveType = home;
        perspectives = homePerspectives;
    } else if (index == 1){
        self.perspectiveType = following;
        if (self.place.followingPerspectiveCount > 0 && self.followingPerspectives == nil){
            //only call if we know something there
            NSString *urlText = [NSString stringWithFormat:@"%@/v1/places/%@/perspectives/following", [NinaHelper getHostname], self.google_id];
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlText]];
            [NinaHelper signRequest:request];
            
            [request setDelegate:self];
            [request setTag:2];
            [request startAsynchronous];
            followingPerspectives = [[NSMutableArray alloc] init];
        } 
        perspectives = followingPerspectives;
    } else if (index == 2){
        self.perspectiveType = everyone;
        if (self.place.perspectiveCount > 0 && self.everyonePerspectives == nil){
            //only call if we know something there
            NSString *urlText = [NSString stringWithFormat:@"%@/v1/places/%@/perspectives/all", [NinaHelper getHostname], self.google_id];
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlText]];
            [NinaHelper signRequest:request];
            
            [request setDelegate:self];
            [request setTag:3];
            [request startAsynchronous];
            everyonePerspectives = [[NSMutableArray alloc] init];
        }
        perspectives = everyonePerspectives;
    }
    
    [self.tableView reloadData];
    
}

-(IBAction) googlePlacePage{
    NSURL *webURL = [NSURL URLWithString:self.place.googlePlacesUrl];
    [[UIApplication sharedApplication] openURL: webURL];
    
}



-(IBAction) bookmark {
    NSString *urlText = [NSString stringWithFormat:@"%@/v1/places/%@/perspectives", [NinaHelper getHostname], self.place.pid];
    
    NSURL *url = [NSURL URLWithString:urlText];
    
    CLLocationManager *locationManager = [LocationManagerManager sharedCLLocationManager];
    CLLocation *location =  locationManager.location;
    
    NSString* lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString* lng = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    float accuracy = pow(location.horizontalAccuracy,2)  + pow(location.verticalAccuracy,2);
    accuracy = sqrt( accuracy ); //take accuracy as single vector, rather than 2 values -iMack
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:lat forKey:@"lat"];
    [request setPostValue:lng forKey:@"long"];
    [request setPostValue:[NSString stringWithFormat:@"%f", accuracy] forKey:@"accuracy"];
    
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    [request setTag:4];
    
    [NinaHelper signRequest:request];
    [request startAsynchronous];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


#pragma mark - Table View


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    if ( self.perspectiveType == home && self.place.bookmarked == false){
        return [perspectives count] +1;
    } else {
        return [perspectives count];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ( indexPath.row == 0 && self.perspectiveType == home ){
        DLog(@"modifying on perspective on %@", self.place.name);
        EditPerspectiveViewController *editPerspectiveViewController = [[EditPerspectiveViewController alloc] initWithPerspective:[self.homePerspectives objectAtIndex:0]];
        
        [self.navigationController pushViewController:editPerspectiveViewController animated:YES];
        
        [editPerspectiveViewController release];        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *perspectiveCellIdentifier = @"Cell";
    static NSString *bookmarkCellIdentifier = @"BookmarkTableViewCell";
    static NSString *editableCellIdentifier = @"CellIdentifier";
    UITableViewCell *cell;
    
    if ( indexPath.row == 0 && self.perspectiveType == home ){
        if (self.place.bookmarked){
            cell = [tableView dequeueReusableCellWithIdentifier:editableCellIdentifier];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:bookmarkCellIdentifier];
        }        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:perspectiveCellIdentifier];
    }
    
    
    if (cell == nil) {
        if ( indexPath.row == 0 && self.perspectiveType == home ){
            
            if (self.place.bookmarked){
                Perspective *perspective = [homePerspectives objectAtIndex:0];
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MyPerspectiveCellViewController" owner:self options:nil];
                
                for(id item in objects)
                {
                    if ( [item isKindOfClass:[UITableViewCell class]])
                    {
                        MyPerspectiveCellViewController *myPerspectiveCell = (MyPerspectiveCellViewController*) item;
                        myPerspectiveCell.perspective = perspective;
                        
                        if (perspective.notes){
                            myPerspectiveCell.memoLabel.text = perspective.notes;
                            myPerspectiveCell.memoLabel.textColor = [UIColor blackColor];
                        } else {
                            myPerspectiveCell.memoLabel.text = @"click to add notes to bookmark";
                            myPerspectiveCell.memoLabel.textColor = [UIColor grayColor];
                        }
                        
                        
                        cell = myPerspectiveCell;
                    }
                }

            } else {              
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"BookmarkTableViewCell" owner:self options:nil];

                for(id item in objects)
                {
                    if ( [item isKindOfClass:[UITableViewCell class]])
                    {
                        BookmarkTableViewCell *bmcell = (BookmarkTableViewCell *)item;
                        bmcell.place = self.place;
                        bmcell.delegate = self;
                        cell = bmcell;
                        break;
                    }
                }
            }
                        
        } else {
            Perspective *perspective;
            if ( self.perspectiveType == home && self.place.bookmarked ){
                perspective = [perspectives objectAtIndex:indexPath.row-1];
            } else {
                perspective = [perspectives objectAtIndex:indexPath.row];
            }
            
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PerspectiveTableViewCell" owner:self options:nil];
            
            for(id item in objects)
            {
                if ( [item isKindOfClass:[UITableViewCell class]])
                {
                    PerspectiveTableViewCell *pcell = (PerspectiveTableViewCell *)item;
                    pcell.perspective = perspective;
                    pcell.memoText.text = perspective.notes;
                    cell = pcell;
                    break;
                }
            }

        }
        
    }
    
    // Configure the cell...
    [cell setEditing:false];
    
    return cell;
}



- (void)dealloc{
    [google_id release];
    [google_ref release];
    [_place release];
    [mapImage release];
    [googlePlacesButton release];
    [nameLabel release];
    [addressLabel release];
    [mapImageView release];
    [cityLabel release];
    [tableHeaderView release];
    
    [super dealloc];
}

@end
