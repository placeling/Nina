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
#import "GenericWebViewController.h"
#import "MyPerspectiveCellViewController.h"

#import "SinglePlaceMapView.h"
#import "ASIDownloadCache.h"

#import "NearbySuggestedPlaceController.h"
#import "FullPerspectiveViewController.h"
#import "CustomSegmentedControl.h"

#import "LoginController.h"

#define kMinCellHeight 60
#define SectionHeaderHeight 60

typedef enum {
    CapLeft          = 0,
    CapMiddle        = 1,
    CapRight         = 2,
    CapLeftAndRight  = 3
} CapLocation;

@interface PlacePageViewController ()
-(void) loadData;
-(void) blankLoad;
-(void) loadMap;
-(bool) shouldShowSectionView;
-(int) numberOfSectionBookmarks;
-(void) flagPerspective:(Perspective*)perspective;
-(void) deletePerspective:(Perspective*)perspective;
@end

@implementation PlacePageViewController

@synthesize dataLoaded;
@synthesize place_id, google_ref, perspective_id;
@synthesize place=_place, mapImage, referrer;
@synthesize nameLabel, addressLabel, cityLabel, categoriesLabel;
@synthesize segmentedControl, tagScrollView;
@synthesize mapButtonView, googlePlacesButton, bookmarkButton;
@synthesize tableHeaderView, tableFooterView, bookmarkView, perspectiveType, topofHeaderView;
@synthesize homePerspectives, followingPerspectives, everyonePerspectives;

- (id) initWithPlace:(Place *)place{
    if(self = [super init]){
        self.place = place;
        self.place_id = place.place_id;
        
	}
	return self;    
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    
    //the place header subview - needs this line, no more
    [[NSBundle mainBundle] loadNibNamed:@"PlaceHeaderView" owner:self options:nil];
    [[NSBundle mainBundle] loadNibNamed:@"PlaceFooterView" owner:self options:nil];
    [[NSBundle mainBundle] loadNibNamed:@"BookmarkTableViewCell" owner:self options:nil];
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"Details";
    
    self.tableView.delegate = self;
    self.tableView.tableHeaderView = self.tableHeaderView;
    
    self.tableView.tableFooterView = self.tableFooterView;
    
    if (self.place){
        self.place_id = self.place.place_id;
    }
    
    // Initializations
    [self blankLoad];

    NSString *urlText;
    
    if (self.perspective_id){
        urlText = [NSString stringWithFormat:@"%@/v1/perspectives/%@", [NinaHelper getHostname], self.perspective_id];
    }else if (self.referrer){
        if (self.google_ref){
            urlText = [NSString stringWithFormat:@"%@/v1/places/%@?google_ref=%@&rf=%@", [NinaHelper getHostname], self.place_id, self.google_ref, self.referrer.username];
        } else {
            urlText = [NSString stringWithFormat:@"%@/v1/places/%@?rf=%@", [NinaHelper getHostname], self.place_id, self.referrer.username];
        }
    } else {
        if (self.google_ref){
            urlText = [NSString stringWithFormat:@"%@/v1/places/%@?google_ref=%@", [NinaHelper getHostname], self.place_id, self.google_ref];
        } else {
            urlText = [NSString stringWithFormat:@"%@/v1/places/%@", [NinaHelper getHostname], self.place_id];
        }
    }
    
    
    NSURL *url = [NSURL URLWithString:urlText];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    homePerspectives = [[NSMutableArray alloc] initWithObjects:@"Loading", nil];
    followingPerspectives = [[NSMutableArray alloc] init];
    everyonePerspectives = [[NSMutableArray alloc] init];
    perspectives = homePerspectives;
    self.perspectiveType = home;
    
    [request setDelegate:self];
    [request setTag:0];
    
    [NinaHelper signRequest:request];
    [request startAsynchronous];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
     buttons = 
    [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"Home", @"Following", @"Everyone", nil], @"titles", [NSValue valueWithCGSize:CGSizeMake(106,69)], @"size", @"segmentedBackground.png", @"button-image", @"segmentedSelected.png", @"button-highlight-image", @"red-divider.png", @"divider-image", [NSNumber numberWithFloat:14.0], @"cap-width", nil];
    
    // A red segment control with 3 values
    NSDictionary* redSegmentedControlData = buttons;
    NSArray* redSegmentedControlTitles = [redSegmentedControlData objectForKey:@"titles"];
    CustomSegmentedControl* redSegmentedControl = [[[CustomSegmentedControl alloc] initWithSegmentCount:redSegmentedControlTitles.count segmentsize:[[redSegmentedControlData objectForKey:@"size"] CGSizeValue] dividerImage:[UIImage imageNamed:[redSegmentedControlData objectForKey:@"divider-image"]] tag:1 delegate:self] autorelease];
    redSegmentedControl.frame = CGRectMake(0, self.tagScrollView.frame.size.height + self.tagScrollView.frame.origin.y, 320, 69);
    
    [self.tableHeaderView addSubview:redSegmentedControl];
    self.segmentedControl = redSegmentedControl;
    
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


-(UIImage*)image:(UIImage*)image withCap:(CapLocation)location capWidth:(NSUInteger)capWidth buttonWidth:(NSUInteger)buttonWidth
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(buttonWidth, image.size.height), NO, 0.0);
    
    if (location == CapLeft)
        // To draw the left cap and not the right, we start at 0, and increase the width of the image by the cap width to push the right cap out of view
        [image drawInRect:CGRectMake(0, 0, buttonWidth, image.size.height)];
    else if (location == CapRight)
        // To draw the right cap and not the left, we start at negative the cap width and increase the width of the image by the cap width to push the left cap out of view
        [image drawInRect:CGRectMake(0.0, 0, buttonWidth, image.size.height)];
    else if (location == CapMiddle)
        // To draw neither cap, we start at negative the cap width and increase the width of the image by both cap widths to push out both caps out of view
        [image drawInRect:CGRectMake(0.0, 0, buttonWidth, image.size.height)];
    
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

#pragma mark -
#pragma mark CustomSegmentedControlDelegate
- (UIButton*) buttonFor:(CustomSegmentedControl*)segmentedControl atIndex:(NSUInteger)segmentIndex;
{
    NSDictionary* data = buttons;
    NSArray* titles = [data objectForKey:@"titles"];
    
    CapLocation location;
    if (segmentIndex == 0)
        location = CapLeft;
    else if (segmentIndex == titles.count - 1)
        location = CapRight;
    else
        location = CapMiddle;
    
    UIImage* buttonImage = nil;
    UIImage* buttonPressedImage = nil;
    
    CGFloat capWidth = [[data objectForKey:@"cap-width"] floatValue];
    CGSize buttonSize = [[data objectForKey:@"size"] CGSizeValue];
    
    if (location == CapLeftAndRight)
    {
        buttonImage = [[UIImage imageNamed:[data objectForKey:@"button-image"]] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0];
        buttonPressedImage = [[UIImage imageNamed:[data objectForKey:@"button-highlight-image"]] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0];
    }
    else
    {
        buttonImage = [self image:[[UIImage imageNamed:[data objectForKey:@"button-image"]] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0] withCap:location capWidth:capWidth buttonWidth:buttonSize.width];
        buttonPressedImage = [self image:[[UIImage imageNamed:[data objectForKey:@"button-highlight-image"]] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0] withCap:location capWidth:capWidth buttonWidth:buttonSize.width];
    }
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0.0, 0.0, buttonSize.width, buttonSize.height)];
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor colorWithRed:101/255.0 green:79/255.0 blue:42/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    UILabel *buttonLabel = button.titleLabel;
    [buttonLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0]];
    
    [button setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(17.0, 0.0, 0.0, 0.0)];
    
    [button setTitle:[titles objectAtIndex:segmentIndex] forState:UIControlStateNormal];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:buttonPressedImage forState:UIControlStateSelected];
    button.adjustsImageWhenHighlighted = NO;
    
    if (segmentIndex == 0)
        button.selected = YES;
    return button;
}


-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [StyleHelper styleBackgroundView:self.view];
    [StyleHelper styleBookmarkButton:self.bookmarkButton];
    [StyleHelper styleInfoView:self.topofHeaderView];
    [StyleHelper styleInfoView:self.tableFooterView];
    [StyleHelper styleMapImage:self.mapButtonView];
    [StyleHelper styleBackgroundView:self.tableHeaderView];
    
    self.bookmarkView.backgroundColor = [UIColor clearColor];
    self.tagScrollView.backgroundColor = [UIColor clearColor];
    
    if (myPerspective && myPerspective.mine && myPerspective.modified){
        myPerspective.modified = false;
        [self.tableView reloadData];
    }
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
                self.place_id = newPlace.place_id;
                [newPlace release];
                
                [homePerspectives removeLastObject]; //get rid of spinner wait
                
                NSArray *jsonPerspectives = [jsonDict objectForKey:@"perspectives"];
                for (NSDictionary *rawDict in jsonPerspectives){
                    Perspective *perspective = [[Perspective alloc] initFromJsonDict:rawDict];
                    perspective.place = self.place;
                    [homePerspectives addObject:perspective];
                    [perspective release];
                }
                
                jsonPerspectives = [jsonDict objectForKey:@"referring_perspectives"];
                for (NSDictionary *rawDict in jsonPerspectives){
                    //only add referring perspectives if they aren't already there
                    BOOL exists = false;
                    for (Perspective *p in homePerspectives){
                        if ([p.perspectiveId isEqualToString:[rawDict objectForKey:@"_id"]]){
                            exists = true;
                            break;
                        }
                    }
                    
                    if (exists) break;
                             
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
                self.mapButtonView.contentMode = UIViewContentModeScaleToFill;
                self.mapImage = [UIImage imageWithData:responseData];
                
                [self.mapButtonView setImage:self.mapImage forState:UIControlStateNormal];
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
                myPerspective.place = self.place;
                
                
                self.place.bookmarked = true;
                [self.tableView reloadData];                
                
                break;
            }
            case 5:{
                //starred perspective 
                //perspective modified return
                NSString *responseString = [request responseString];        
                DLog(@"%@", responseString);
                
                self.place.bookmarked = true;
                [self.tableView reloadData];                
                
                break;
            }
            case 6:{
                //deleted perspective
                NSString *responseString = [request responseString];        
                DLog(@"%@", responseString);
                        
                break;
            }
            case 7:{
                //flag perspective
                NSString *responseString = [request responseString];        
                DLog(@"%@", responseString);

                break;
            }
        }

	}
}

#pragma mark - UIScrollViewDelegate


#pragma mark - Table view delegate

-(void) flagPerspective:(Perspective*)perspective{
    
    
}

-(void) deletePerspective:(Perspective*)perspective{
    
    NSString *urlText = [NSString stringWithFormat:@"%@/v1/places/%@/perspectives/", [NinaHelper getHostname], perspective.place.place_id];

    NSURL *url = [NSURL URLWithString:urlText];
    
    ASIHTTPRequest  *request =  [[[ASIHTTPRequest  alloc]  initWithURL:url] autorelease];
    
    request.delegate = self;
    request.tag = 6;
    
    [request setRequestMethod:@"DELETE"];
    [NinaHelper signRequest:request];
    [request startAsynchronous];
}

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
        self.categoriesLabel.text = @"";
        self.cityLabel.text = @"";
    }
}

-(void) loadMap{    
    // Call asychronously to get image
    NSString* lat = [NSString stringWithFormat:@"%f",self.place.location.coordinate.latitude];
    NSString* lng = [NSString stringWithFormat:@"%f",self.place.location.coordinate.longitude];    
    
    NSString* imageMapWidth = [NSString stringWithFormat:@"%i", (int)self.mapButtonView.frame.size.width ];
    NSString* imageMapHeight = [NSString stringWithFormat:@"%i", (int)self.mapButtonView.frame.size.height ];
    
    NSString *mapURL;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        mapURL = [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?center=%@,%@&zoom=15&size=%@x%@&&markers=color:red%%7C%@,%@&sensor=false&scale=2", lat, lng, imageMapWidth, imageMapHeight, lat, lng];
    } else {
        mapURL = [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?center=%@,%@&zoom=15&size=%@x%@&&markers=color:red%%7C%@,%@&sensor=false", lat, lng, imageMapWidth, imageMapHeight, lat, lng];
    }
    
    NSURL *url = [NSURL URLWithString:mapURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request setTag:1];
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
    [request startAsynchronous];
    
    mapRequested = true;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(IBAction)tagSearch:(id)sender{
    
    UIButton *button = (UIButton*)sender;
    NSString *searchString = button.titleLabel.text;
    
    NearbySuggestedPlaceController *suggestedPlaceController = [[NearbySuggestedPlaceController alloc] init];
    
    suggestedPlaceController.searchTerm = searchString;
    
    [self.navigationController pushViewController:suggestedPlaceController animated:TRUE];
    
    [suggestedPlaceController release];
    
}


-(void) loadData{
    self.nameLabel.text = self.place.name;
    self.addressLabel.text = self.place.address;
    
    if (!mapRequested){
        [self loadMap];
    } 

    self.cityLabel.text = self.place.city;
    self.categoriesLabel.text = [self.place.categories componentsJoinedByString:@","];
    
    UIButton *button = [self.segmentedControl.buttons objectAtIndex:1];
    
    [button setTitle:[NSString stringWithFormat:@"Following (%i)", self.place.followingPerspectiveCount] forState:UIControlStateNormal];
    
    button = [self.segmentedControl.buttons objectAtIndex:2];
    [button setTitle:[NSString stringWithFormat:@"Everyone (%i)", self.place.perspectiveCount] forState:UIControlStateNormal];
    
    CGFloat cx = 7;
    
    for ( NSString* tag in self.place.tags ){        
        UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        CGSize textsize = [tag sizeWithFont:tagButton.titleLabel.font forWidth:100.0 lineBreakMode: tagButton.titleLabel.lineBreakMode];
        CGRect rect = CGRectMake(cx, 15, textsize.width+4, 26);       
        
        tagButton.frame = rect;
        [tagButton setTitle:[NSString stringWithFormat:@"#%@", tag] forState:UIControlStateNormal];
        [StyleHelper styleTagButton:tagButton];
        
        [tagButton addTarget:self action:@selector(tagSearch:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.tagScrollView addSubview:tagButton];        
        cx += tagButton.frame.size.width+7;
        
    }
    
    [self.tagScrollView setContentSize:CGSizeMake(cx, [self.tagScrollView bounds].size.height)];    
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

-(IBAction)showSingleAnnotatedMap{
    DLog(@"Spawning map for place: %@", self.place.name);
      
    SinglePlaceMapView *singlePlaceMapView = [[SinglePlaceMapView alloc] initWithPlace:self.place];
    
    [self.navigationController pushViewController:singlePlaceMapView animated:TRUE];
    [singlePlaceMapView release];
    
}

-(IBAction) shareTwitter{

}


-(IBAction) shareFacebook{

}

-(IBAction) checkinFoursquare{
    
}

- (void) touchUpInsideSegmentIndex:(NSUInteger)segmentIndex{
    NSUInteger index = segmentIndex;
    
    if (index == 0){
        self.perspectiveType = home;
        perspectives = homePerspectives;
    } else if (index == 1){
        self.perspectiveType = following;
        if (self.place.followingPerspectiveCount > 0 && (self.followingPerspectives.count == 0)){
            //only call if we know something there
            NSString *urlText = [NSString stringWithFormat:@"%@/v1/places/%@/perspectives/following", [NinaHelper getHostname], self.place_id];
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlText]];
            [followingPerspectives addObject:@"Loading"]; //marker for spinner cell
            [request setDelegate:self];
            [request setTag:2];
            [NinaHelper signRequest:request];
            [request startAsynchronous];
        } 
        perspectives = followingPerspectives;
    } else if (index == 2){
        self.perspectiveType = everyone;
        if (self.place.perspectiveCount > 0 && (self.everyonePerspectives.count ==0)){
            //only call if we know something there
            NSString *urlText = [NSString stringWithFormat:@"%@/v1/places/%@/perspectives/all", [NinaHelper getHostname], self.place_id];
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlText]];
            [everyonePerspectives addObject:@"Loading"]; //marker for spinner cell
            [request setDelegate:self];
            [request setTag:3];
            [NinaHelper signRequest:request];
            [request startAsynchronous];
        }
        perspectives = everyonePerspectives;
    }
    
    [self.tableView reloadData];
    
}

-(IBAction) googlePlacePage{    
    
    if (self.place.googlePlacesUrl != nil && ![self.place.googlePlacesUrl isKindOfClass:NSNull.class]){
        GenericWebViewController *genericWebViewController = [[GenericWebViewController alloc] initWithUrl:self.place.googlePlacesUrl];
        
        genericWebViewController.title = @"Contact info";
        [self.navigationController pushViewController:genericWebViewController animated:true];
        
        [genericWebViewController release];
    }
}


-(IBAction) bookmark {
    NSString *currentUser = [NinaHelper getUsername];
    
    if (currentUser == (id)[NSNull null] || currentUser.length == 0) {
        UIAlertView *baseAlert;
        NSString *alertMessage = @"Sign up or log in to bookmark locations";
        baseAlert = [[UIAlertView alloc] 
                     initWithTitle:nil message:alertMessage 
                     delegate:self cancelButtonTitle:@"Not Now" 
                     otherButtonTitles:@"Let's Go", nil];
        
        [baseAlert show];
        [baseAlert release];
    } else {
        NSString *urlText = [NSString stringWithFormat:@"%@/v1/places/%@/perspectives", [NinaHelper getHostname], self.place.pid];
        
        NSURL *url = [NSURL URLWithString:urlText];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        [request setRequestMethod:@"POST"];
        [request setDelegate:self];
        [request setTag:4];
        
        [NinaHelper signRequest:request];
        [request startAsynchronous];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

#pragma mark - Unregistered experience methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        LoginController *loginController = [[LoginController alloc] init];
        
        UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:loginController];
        [self.navigationController presentModalViewController:navBar animated:YES];
        [navBar release];
        [loginController release];
    }
}

#pragma mark - Table View


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [perspectives count]){
        return NO;
    } else {
        //handling editing case before refresh       
        Perspective *perspective = [perspectives objectAtIndex:indexPath.row];
        
        if ( [perspective isKindOfClass:[NSString class]] ){
            return NO;
        }else {         
            if (perspective.mine){
                return YES;
            } else {
                return NO;
            }
        }
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Perspective *perspective = [perspectives objectAtIndex:indexPath.row];
        DLog(@"Deleting perspective");
        
        [self deletePerspective:perspective];
        
        if ([homePerspectives count] > 0){
            [homePerspectives removeObject:perspective];
        }
             
        if ([everyonePerspectives count] > 0){
            [everyonePerspectives removeObject:perspective];
        }
        myPerspective = nil;
        self.place.bookmarked = false;
        [self.tableView reloadData];        
    }    
}

-(bool)shouldShowSectionView{
    
    if (([perspectives count] > 0) && [[perspectives objectAtIndex:0] isKindOfClass:[NSString class]]){
        return false;
    }
    
    
    if ( self.perspectiveType == home && self.place.bookmarked == false){
        return true; //show bookmark bar
    } else if (self.perspectiveType != home && [perspectives count] == 0){
        return true; //to show "0 bookmarks" text
    } else if ( self.perspectiveType == following && self.place.followingPerspectiveCount != [followingPerspectives count] ){
        return true;
    } else if ( self.perspectiveType == everyone && self.place.perspectiveCount != [everyonePerspectives count] ){
        return true;
    } 
    
    return false;
}

-(int) numberOfSectionBookmarks{
    if (self.perspectiveType == following){
        return self.place.followingPerspectiveCount; 
    } else if (self.perspectiveType == everyone){
        return self.place.perspectiveCount;
    }
    return  0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self shouldShowSectionView]) {
        return SectionHeaderHeight;
    }
    else {
        // If no section header title, no section header needed
        return 0;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (![self shouldShowSectionView]){
        return nil;
    }

    UIView *view;
    
    if (self.perspectiveType == home){
        view = self.bookmarkView;
        
    } else {
        // Create label with section title
        UILabel *label = [[[UILabel alloc] init] autorelease];
        label.frame = CGRectMake(20, 6, 280, 30);
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont boldSystemFontOfSize:16];
        
        NSString *currentUser = [NinaHelper getUsername];
        if (self.segmentedControl.selectedSegmentIndex == 1 && (currentUser == (id)[NSNull null] || currentUser.length == 0)) {
            label.frame = CGRectMake(20, 6, 280, 50);
            label.numberOfLines = 2;
            label.text = [NSString stringWithFormat:@"Sign up or log in to see what\npeople you follow think about here"];
            label.textAlignment = UITextAlignmentCenter;
        } else {
            if ( [self numberOfSectionBookmarks] == 0 ){
                //label.textColor = [UIColor grayColor];
                if (self.segmentedControl.selectedSegmentIndex == 1) {
                    label.text = [NSString stringWithFormat:@"No one you follow has bookmarked this place"];
                } else {
                    label.text = [NSString stringWithFormat:@"No one has bookmarked this place yet"];
                }
                
                //label.text = [NSString stringWithFormat:@"0 bookmarks so far"];
            } else if ( [self numberOfSectionBookmarks] == 1) {
                if (self.segmentedControl.selectedSegmentIndex == 1) {
                    label.text = [NSString stringWithFormat:@"%i person you follow has bookmarked this place", [self numberOfSectionBookmarks]];
                } else {
                    label.text = [NSString stringWithFormat:@"%i person has bookmarked this place", [self numberOfSectionBookmarks]];
                }
            } else {
                if (self.segmentedControl.selectedSegmentIndex == 1) {
                    label.text = [NSString stringWithFormat:@"%i people you follow have bookmarked this place", [self numberOfSectionBookmarks]];
                } else {
                    label.text = [NSString stringWithFormat:@"%i people have bookmarked this place", [self numberOfSectionBookmarks]];   
                }            
            }
        }
        
        label.adjustsFontSizeToFitWidth = TRUE;
        
        // Create header view and add label as a subview
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, SectionHeaderHeight)];
        [view autorelease];
        [view addSubview:label];
    }
    
    return view;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Perspective *perspective = [perspectives objectAtIndex:indexPath.row];
    
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ( [perspective isKindOfClass:[NSString class]] ){
        //loading case
        return 44;
    }else if ( self.perspectiveType == home && perspective.mine){
        return [MyPerspectiveCellViewController cellHeightForPerspective:perspective];            
    } else {
        //a visible perspective row PerspectiveTableViewCell        
        return [PerspectiveTableViewCell cellHeightForPerspective:perspective];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    if (perspectives){ 
        return [perspectives count];
    } else {
        return 0; //probably shouldn't actually ever reach here
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *perspectiveCellIdentifier = @"PerspectiveCellIdentifier";
    static NSString *editableCellIdentifier = @"MyPerspectiveCellIdentifier";
    static NSString *spinnerCellIdentifier = @"SpinnerCellIdentifier";
    
    UITableViewCell *cell;
    Perspective *perspective = [perspectives objectAtIndex:indexPath.row];
    
     if ( [perspective isKindOfClass:[NSString class]] ){
        cell = [tableView dequeueReusableCellWithIdentifier:spinnerCellIdentifier];
     }else {         
        if (perspective.mine){
            cell = [tableView dequeueReusableCellWithIdentifier:editableCellIdentifier];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:perspectiveCellIdentifier];
        }
    } 
    
    
    if (cell == nil) {
        if ( [perspective isKindOfClass:[NSString class]] ){
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SpinnerTableCell" owner:self options:nil];
            
            for(id item in objects){
                if ( [item isKindOfClass:[UITableViewCell class]]){
                    cell = item;
                }
            }             
        }else {
            if ( self.perspectiveType == home && perspective.mine){
                myPerspective = perspective;
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MyPerspectiveCellViewController" owner:self options:nil];
                
                for(id item in objects){
                    if ( [item isKindOfClass:[UITableViewCell class]]){
                        MyPerspectiveCellViewController *mCell = (MyPerspectiveCellViewController*) item;                        
                        [MyPerspectiveCellViewController setupCell:mCell forPerspective:perspective];
                        cell = mCell;
                    }
                }
            } else {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PerspectiveTableViewCell" owner:self options:nil];
                
                for(id item in objects){
                    if ( [item isKindOfClass:[UITableViewCell class]]){
                        PerspectiveTableViewCell *pcell = (PerspectiveTableViewCell *)item;                  
                        [PerspectiveTableViewCell setupCell:pcell forPerspective:perspective userSource:false];
                        pcell.requestDelegate = self;
                        cell = pcell;
                        break;
                    }
                }
            }
        }
        
    }
    
    // Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Perspective *perspective = [perspectives objectAtIndex:indexPath.row];
    
    if ( !( self.perspectiveType == home && perspective.mine  ) ){
        FullPerspectiveViewController *fullPerspectiveViewController = [[FullPerspectiveViewController alloc] init];
        fullPerspectiveViewController.perspective = perspective;
        
        [[self navigationController] pushViewController:fullPerspectiveViewController animated:YES];
        [fullPerspectiveViewController release];
    }
}



- (void)dealloc{
    [NinaHelper clearActiveRequests:0];
    
    [perspective_id release];
    [place_id release];
    [google_ref release];
    [_place release];
    [mapImage release];
    [googlePlacesButton release];
    [nameLabel release];
    [addressLabel release];
    [mapButtonView release];
    [cityLabel release];
    [tableHeaderView release];
    [referrer release];
    [bookmarkButton release];
    [topofHeaderView release];
    
    [super dealloc];
}

@end
