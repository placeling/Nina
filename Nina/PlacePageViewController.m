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
@synthesize segmentedControl, tagScrollView;
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
    
    homePerspectives = [[NSMutableArray alloc] initWithObjects:@"Loading", nil];
    followingPerspectives = [[NSMutableArray alloc] init];
    everyonePerspectives = [[NSMutableArray alloc] init];
    perspectives = homePerspectives;
    self.perspectiveType = home;
    
    [request setDelegate:self];
    [request setTag:0];
    [request startAsynchronous];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    
    if (self.place){
        [self loadMap];
    } else {
        mapRequested = false;
    }
    
    
    self.navigationController.title = self.place.name;
    
    UIBarButtonItem *shareButton =  [[UIBarButtonItem  alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showShareSheet)];
    //self.navigationItem.rightBarButtonItem = shareButton;
    [shareButton release];
    
}

#pragma mark - Share Sheet

-(void) showShareSheet{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share on Twitter", @"Share on Facebook", @"Check-in with Foursquare", nil];
    
    [actionSheet showInView:self.view];
    [actionSheet release];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        DLog(@"share on twitter");
    }else if (buttonIndex == 1) {
        DLog(@"share on facebook");
    }else if (buttonIndex == 2){
        DLog(@"check-in with foursquare");
    } else {
        DLog(@"WARNING - Invalid actionsheet button pressed: %i", buttonIndex);
    }    
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
                
                [homePerspectives removeLastObject]; //get rid of spinner wait
                
                NSArray *jsonPerspectives = [jsonDict objectForKey:@"perspectives"];
                for (NSDictionary *rawDict in jsonPerspectives){
                    Perspective *perspective = [[Perspective alloc] initFromJsonDict:rawDict];
                    perspective.place = self.place;
                    [homePerspectives addObject:perspective];
                    [perspective release];
                }
                
                if (self.place.bookmarked){
                    //should be the first one of the home persepectives
                    myPerspective = [homePerspectives objectAtIndex:0];
                }
                
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
                //following perspectives
                NSString *responseString = [request responseString];        
                DLog(@"%@", responseString);
                
                NSDictionary *jsonDict = [responseString JSONValue];  
                NSArray *jsonPerspectives = [jsonDict objectForKey:@"perspectives"];
                
                [followingPerspectives removeLastObject]; //get rid of spinner wait
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
                //everyone perspectives
                NSString *responseString = [request responseString];        
                DLog(@"%@", responseString);
                
                NSDictionary *jsonDict = [responseString JSONValue];  
                NSArray *jsonPerspectives = [jsonDict objectForKey:@"perspectives"];
                //this only called if array was previously nil
                
                [everyonePerspectives removeLastObject]; //get rid of spinner wait
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
                //perspective modified return
                NSString *responseString = [request responseString];        
                DLog(@"%@", responseString);
                NSDictionary *jsonString = [responseString JSONValue];
                
                if (myPerspective){
                    [myPerspective updateFromJsonDict:jsonString];
                } else {
                    myPerspective = [[Perspective alloc]initFromJsonDict:jsonString];
                    [homePerspectives insertObject:myPerspective atIndex:0];
                }
                
                
                self.place.bookmarked = true;
                [self.tableView reloadData];                
                
                break;
            }
        }

	}
}

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

-(IBAction)editPerspective{
    DLog(@"modifying on perspective on %@", self.place.name);
    EditPerspectiveViewController *editPerspectiveViewController = [[EditPerspectiveViewController alloc] initWithPerspective:myPerspective];
    
    editPerspectiveViewController.delegate = self;
    [self.navigationController pushViewController:editPerspectiveViewController animated:YES];
    
    [editPerspectiveViewController release];       
}


-(IBAction)editPerspectivePhotos{
    DLog(@"modifying on perspective on %@", self.place.name);
    EditPerspectiveViewController *editPerspectiveViewController = [[EditPerspectiveViewController alloc] initWithPerspective:myPerspective];
    
    editPerspectiveViewController.delegate = self;
    
    [self.navigationController pushViewController:editPerspectiveViewController animated:YES];
    [editPerspectiveViewController.memoTextView resignFirstResponder];
    [editPerspectiveViewController release];       
}


#pragma mark - IBActions

-(IBAction) shareTwitter{

}


-(IBAction) shareFacebook{

}

-(IBAction) checkinFoursquare{
    
}

-(IBAction) changedSegment{
    NSUInteger index = self.segmentedControl.selectedSegmentIndex;
    
    if (index == 0){
        self.perspectiveType = home;
        perspectives = homePerspectives;
    } else if (index == 1){
        self.perspectiveType = following;
        if (self.place.followingPerspectiveCount > 0 && (self.followingPerspectives.count == 0)){
            //only call if we know something there
            NSString *urlText = [NSString stringWithFormat:@"%@/v1/places/%@/perspectives/following", [NinaHelper getHostname], self.google_id];
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlText]];
            [NinaHelper signRequest:request];
            [followingPerspectives addObject:@"Loading"]; //marker for spinner cell
            [request setDelegate:self];
            [request setTag:2];
            [request startAsynchronous];
        } 
        perspectives = followingPerspectives;
    } else if (index == 2){
        self.perspectiveType = everyone;
        if (self.place.perspectiveCount > 0 && (self.everyonePerspectives.count ==0)){
            //only call if we know something there
            NSString *urlText = [NSString stringWithFormat:@"%@/v1/places/%@/perspectives/all", [NinaHelper getHostname], self.google_id];
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlText]];
            [NinaHelper signRequest:request];
            [everyonePerspectives addObject:@"Loading"]; //marker for spinner cell
            [request setDelegate:self];
            [request setTag:3];
            [request startAsynchronous];
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

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (([perspectives count] > 0) && [[perspectives objectAtIndex:0] isKindOfClass:[NSString class]]){
        //loading case
        return 44;
    }else if ( self.perspectiveType == home && indexPath.row == 0){
        //own perspective row
        if (myPerspective){
            return [MyPerspectiveCellViewController cellHeightForPerspective:myPerspective];            
        } else {
            //BookmarkTableViewCell 
            return 44;
        }
        
    } else {
        //a visible perspective row PerspectiveTableViewCell
        
        Perspective *perspective;
        
        if(self.perspectiveType == home){
            perspective = [perspectives objectAtIndex:indexPath.row-1];
        }else{
            perspective = [perspectives objectAtIndex:indexPath.row];
        }
        
        return [PerspectiveTableViewCell cellHeightForPerspective:perspective];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    if (([perspectives count] > 0) && [[perspectives objectAtIndex:0] isKindOfClass:[NSString class]]){
        //loading case
        return 1;
    }else if ( self.perspectiveType == home && self.place.bookmarked == false){
        return [perspectives count] +1;
    } else {
        return [perspectives count];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *perspectiveCellIdentifier = @"Cell";
    static NSString *bookmarkCellIdentifier = @"BookmarkTableViewCell";
    static NSString *editableCellIdentifier = @"CellIdentifier";
    static NSString *spinnerCellIdentifier = @"SpinnerCellIdentifier";
    
    UITableViewCell *cell;
    
     if (([perspectives count] > 0) && [[perspectives objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]){
        cell = [tableView dequeueReusableCellWithIdentifier:spinnerCellIdentifier];
    }else if ( indexPath.row == 0 && self.perspectiveType == home ){
        if (self.place.bookmarked){
            cell = [tableView dequeueReusableCellWithIdentifier:editableCellIdentifier];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:bookmarkCellIdentifier];
        }        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:perspectiveCellIdentifier];
    }
    
    
    if (cell == nil) {
        if (([perspectives count] > 0) && [[perspectives objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]){
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SpinnerTableCell" owner:self options:nil];
            
            for(id item in objects){
                if ( [item isKindOfClass:[UITableViewCell class]]){
                    cell = item;
                }
            }            
        } else if ( indexPath.row == 0 && self.perspectiveType == home ){
            
            if (myPerspective){
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MyPerspectiveCellViewController" owner:self options:nil];
                
                for(id item in objects){
                    if ( [item isKindOfClass:[UITableViewCell class]]){
                        MyPerspectiveCellViewController *mCell = (MyPerspectiveCellViewController*) item;                        
                        [MyPerspectiveCellViewController setupCell:mCell forPerspective:myPerspective];
                        cell = mCell;
                    }
                }

            } else {              
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"BookmarkTableViewCell" owner:self options:nil];

                for(id item in objects){
                    if ( [item isKindOfClass:[UITableViewCell class]]){
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
            if ( self.perspectiveType == home && !self.place.bookmarked ){
                perspective = [perspectives objectAtIndex:indexPath.row-1];
            } else {
                perspective = [perspectives objectAtIndex:indexPath.row];
            }
            
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PerspectiveTableViewCell" owner:self options:nil];
            
            for(id item in objects){
                if ( [item isKindOfClass:[UITableViewCell class]]){
                    PerspectiveTableViewCell *pcell = (PerspectiveTableViewCell *)item;                  
                    [PerspectiveTableViewCell setupCell:pcell forPerspective:perspective];
                    cell = pcell;
                    break;
                }
            }

        }
        
    }
    
    // Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
