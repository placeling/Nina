//
//  PlacePageViewController.m
//  placeling2
//
//  Created by Lindsay Watt on 11-06-23.
//  Copyright 2011 Placeling. All rights reserved.
//

#import "PlacePageViewController.h"
#import "NinaAppDelegate.h"
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
#import "CustomSegmentedControl.h"
#import "FollowViewController.h"

#import "LoginController.h"
#import "MemberProfileViewController.h"

#import "FlurryAnalytics.h"


#define kMinCellHeight 60

#define minTableHeight 118

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
-(void) deletePerspective:(Perspective*)perspective;
-(NSString*) numberBookmarkCopy;
-(NSString*) getUrlString;
-(NSString*) getRestUrl;
-(bool) returnMinRowHeight:(NSIndexPath *)indexPath;
@end

@implementation PlacePageViewController

@synthesize dataLoaded;
@synthesize place_id, google_ref, perspective_id;
@synthesize place=_place, mapImage, referrer;
@synthesize nameLabel, addressLabel, cityLabel, categoriesLabel;
@synthesize segmentedControl, tagScrollView;
@synthesize mapButtonView, googlePlacesButton, bookmarkButton;
@synthesize tableHeaderView, tableFooterView, perspectiveType, topofHeaderView;
@synthesize homePerspectives, followingPerspectives, everyonePerspectives;

- (id) initWithPlace:(Place *)place{
    if(self = [super init]){
        self.place = place;
        self.place_id = place.pid;
        
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
    
    expandedCells = 
    [[NSArray arrayWithObjects:[[[NSMutableSet alloc] init]autorelease], 
     [[[NSMutableSet alloc] init]autorelease], 
     [[[NSMutableSet alloc] init]autorelease], nil] retain];
    
    self.navigationItem.title = @"Place Info";
    
    self.tableView.delegate = self;
    self.tableView.tableHeaderView = self.tableHeaderView;
    
    self.tableView.tableFooterView = self.tableFooterView;
    
    if (self.place){
        self.place_id = self.place.pid;
    }
        
    UIBarButtonItem *shareButton =  [[UIBarButtonItem  alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showShareSheet)];
    self.navigationItem.rightBarButtonItem = shareButton;
    [shareButton release];
    
    
    // Initializations
    [self blankLoad];
    [self mainContentLoad];
    
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
    
    [StyleHelper styleContactInfoButton:self.googlePlacesButton];
    
    self.navigationController.title = self.place.name;
    
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

-(NSString*) getUrlString{
    if (self.perspective_id){
        return [NSString stringWithFormat:@"%@/v1/perspectives/%@", [NinaHelper getHostname], self.perspective_id];
    }else if (self.referrer){
        if (self.google_ref){
            return [NSString stringWithFormat:@"%@/v1/places/%@?google_ref=%@&rf=%@", [NinaHelper getHostname], self.place_id, self.google_ref, self.referrer.username];
        } else {
            return [NSString stringWithFormat:@"%@/v1/places/%@?rf=%@", [NinaHelper getHostname], self.place_id, self.referrer.username];
        }
    } else {
        if (self.google_ref){
            return [NSString stringWithFormat:@"%@/v1/places/%@?google_ref=%@", [NinaHelper getHostname], self.place_id, self.google_ref];
        } else {
            return [NSString stringWithFormat:@"%@/v1/places/%@", [NinaHelper getHostname], self.place_id];
        }
    }
}


-(NSString*) getRestUrl{
    if (self.perspective_id){
        return [NSString stringWithFormat:@"/v1/perspectives/%@", self.perspective_id];
    }else if (self.referrer){
        if (self.google_ref){
            return [NSString stringWithFormat:@"/v1/places/%@?google_ref=%@&rf=%@", self.place_id, self.google_ref, self.referrer.username];
        } else {
            return [NSString stringWithFormat:@"/v1/places/%@?rf=%@", self.place_id, self.referrer.username];
        }
    } else {
        if (self.google_ref){
            return [NSString stringWithFormat:@"/v1/places/%@?google_ref=%@", self.place_id, self.google_ref];
        } else {
            return [NSString stringWithFormat:@"/v1/places/%@", self.place_id];
        }
    }
}

-(void) mainContentLoad {
    
    homePerspectives = [[NSMutableArray alloc] initWithObjects:@"Loading", nil];
    followingPerspectives = [[NSMutableArray alloc] init];
    everyonePerspectives = [[NSMutableArray alloc] init];
    perspectives = homePerspectives;
    self.perspectiveType = home;
    
    // Call url to get profile details                
    RKObjectManager* objectManager = [RKObjectManager sharedManager];       
    
    [objectManager loadObjectsAtResourcePath:[self getRestUrl] delegate:self block:^(RKObjectLoader* loader) {     
        loader.objectMapping = [Place getObjectMapping];
        loader.userData = [NSNumber numberWithInt:0]; //use as a tag
    }];
}


#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    
    if ( [(NSNumber*)objectLoader.userData intValue] == 0){

        Place *newPlace = [objects objectAtIndex:0];
        
        self.place = newPlace;
        self.place_id = newPlace.pid;
        
        [homePerspectives removeLastObject]; //get rid of spinner wait
        
        for (Perspective *perspective in newPlace.homePerspectives){
            [homePerspectives addObject:perspective];
        }
        
        //so child view can modify in place
        self.place.homePerspectives = self.homePerspectives;
        self.place.followingPerspectives = self.followingPerspectives;
        self.place.everyonePerspectives = self.everyonePerspectives;
        
        /*
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
         */
        
        if (self.place.bookmarked){
            //should be the first one of the home persepectives
            myPerspective = [homePerspectives objectAtIndex:0];
        }
        
        [self loadData];

    } else if ( [(NSNumber*)objectLoader.userData intValue] == 2){
        //following perspectives
        [followingPerspectives removeLastObject]; //get rid of spinner wait
        
        for (Perspective *perspective in objects){
            perspective.place = self.place;
            [followingPerspectives addObject:perspective];
        }
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 3){
        //everyone perspectives
        [everyonePerspectives removeLastObject]; //get rid of spinner wait
        
        for (Perspective *perspective in objects){
            perspective.place = self.place;
            [everyonePerspectives addObject:perspective];
        }
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 5){
        //everyone perspectives

        Perspective *newPerspective = [objects objectAtIndex:0];
        
        if (myPerspective){
            myPerspective = newPerspective;
            [homePerspectives replaceObjectAtIndex:0 withObject:newPerspective];
        } else {
            myPerspective = newPerspective;
            [homePerspectives insertObject:myPerspective atIndex:0];
        }
        myPerspective.mine = true;
        
        self.place = newPerspective.place;
        
        myPerspective.place = self.place;                
        
        self.place.bookmarked = true;
        [self loadData];

    } else if ( [(NSNumber*)objectLoader.userData intValue] == 7){
        //flag perspective
    }
    
    [self.tableView reloadData];
    
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [NinaHelper handleBadRKRequest:objectLoader.response sender:self];
    DLog(@"Encountered an error: %@", error); 
}


#pragma mark -
#pragma mark LoginController Delegate Methods
-(void) loadContent {
    // Go back through navigation stack
    for (int i=[[[self navigationController] viewControllers] count] - 2; i > 0; i--) {
        NSObject *parentController = [[[self navigationController] viewControllers] objectAtIndex:i];
        
        if ([parentController isKindOfClass:[MemberProfileViewController class]]) {
            MemberProfileViewController *profile = (MemberProfileViewController *)[[[self navigationController] viewControllers] objectAtIndex:i];
            [profile mainContentLoad];
        } else if ([parentController isKindOfClass:[PlacePageViewController class]]) {
            PlacePageViewController *place = (PlacePageViewController *)[[[self navigationController] viewControllers] objectAtIndex:i];
            [place mainContentLoad];
        } 
    }
    
    [self mainContentLoad];
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
    } else {
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
    [StyleHelper styleInfoView:self.topofHeaderView];
    [StyleHelper styleInfoView:self.tableFooterView];
    [StyleHelper styleMapImage:self.mapButtonView];
    [StyleHelper styleBackgroundView:self.tableHeaderView];
    
    self.tagScrollView.backgroundColor = [UIColor clearColor];
    
    if (myPerspective && myPerspective.mine && myPerspective.modified){
        myPerspective.modified = false;
        [self.tableView reloadData];
    } else if (self.place.dirty){
        [self loadData];
        [self.tableView reloadData];
    }
    
}

#pragma mark - Share Sheet

-(void) showShareSheet{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share by Email", @"Share on Facebook", nil];
    
    [actionSheet showInView:self.view];
    [actionSheet release];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *urlString = [NSString stringWithFormat:@"https://www.placeling.com/places/%@", self.place.pid];
    
    if (buttonIndex == 0){
        DLog(@"share by email");
        
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:[NSString stringWithFormat:@"\"%@\" on Placeling", self.place.name]];
        [controller setMessageBody:[NSString stringWithFormat:@"\n\n%@", urlString] isHTML:TRUE];
        
        if (controller) [self presentModalViewController:controller animated:YES];
        [controller release];	
        
        
    }else if (buttonIndex == 1) {
        DLog(@"share on facebook");
        
        NinaAppDelegate *appDelegate = (NinaAppDelegate*)[[UIApplication sharedApplication] delegate];
        Facebook *facebook = appDelegate.facebook;
        
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NinaHelper getFacebookAppId], @"app_id",
                                       urlString, @"link",
                                       self.place.placeThumbUrl, @"picture",
                                       self.place.name, @"name",
                                       (self.place.streetAddress && self.place.city) ? [NSString stringWithFormat:@"%@ %@", self.place.streetAddress, self.place.city] : @"", @"caption",
                                       [NSString stringWithFormat:@"Check out %@ on Placeling!", self.place.name], @"description",
                                       nil];
        
        [facebook dialog:@"feed" andParams:params andDelegate:self];
    } 
}

- (void)dialogDidComplete:(FBDialog *)dialog{
    DLog(@"Share on Facebook Dialog completed %@", dialog)
    [FlurryAnalytics logEvent:@"FACEBOOK_SHARE_PLACE"];
}

- (void)dialogDidNotComplete:(FBDialog *)dialog{
    DLog(@"Share on Facebook Dialog completed %@", dialog)
}


- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
	[self dismissModalViewControllerAnimated:YES];
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
            case 1:{
                //map download
                NSData *responseData = [request responseData];
                self.mapButtonView.contentMode = UIViewContentModeScaleToFill;
                self.mapImage = [UIImage imageWithData:responseData];
                
                [self.mapButtonView setImage:self.mapImage forState:UIControlStateNormal];
                break;
            }
            case 4:{
                //bookmarked
                NSString *responseString = [request responseString];        
                DLog(@"%@", responseString);
                NSDictionary *jsonString = [responseString JSONValue];
                
                if (myPerspective){
                    [myPerspective updateFromJsonDict:jsonString];
                } else {
                    myPerspective = [[Perspective alloc]initFromJsonDict:jsonString];
                    [homePerspectives insertObject:myPerspective atIndex:0];
                }
                
                //handles updates tags, etc
                [self.place updateFromJsonDict:[jsonString objectForKey:@"place"]];
                
                myPerspective.place = self.place;                
                
                self.place.bookmarked = true;
                [self.tableView reloadData];      
                [self loadData];
                
                [self editPerspective]; //popup after bookmark
                
                break;
            }

            case 6:{
                //deleted perspective
                NSString *responseString = [request responseString];        
                DLog(@"%@", responseString);
                if (self.homePerspectives){
                    for (Perspective *perspective in self.homePerspectives){
                        if (perspective.starred){
                            [self.homePerspectives removeObject:perspective];
                        }
                    }
                }   
                        
                [self.tableView reloadData];
                break;
            }
            case 9:{
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
                
                //handles updates tags, etc
                [self.place updateFromJsonDict:[jsonString objectForKey:@"place"]];
                
                myPerspective.place = self.place;                
                
                self.place.bookmarked = true;
                [self.tableView reloadData];      
                [self loadData];
                
                break;
            }
        }

	}
}

#pragma mark - UIScrollViewDelegate


#pragma mark - Table view delegate

-(void) deletePerspective:(Perspective*)perspective{
    
    NSString *urlText = [NSString stringWithFormat:@"%@/v1/places/%@/perspectives/", [NinaHelper getHostname], perspective.place.pid];

    NSURL *url = [NSURL URLWithString:urlText];
    
    ASIHTTPRequest  *request =  [[[ASIHTTPRequest  alloc]  initWithURL:url] autorelease];
    
    request.delegate = self;
    request.tag = 6;
    
    self.place.perspectiveCount -=1;
    
    for (Perspective *p in self.place.everyonePerspectives){
        if ( [p.perspectiveId isEqualToString:perspective.perspectiveId] ){
            [self.place.everyonePerspectives removeObject:p];
        }
    }
    self.place.dirty = true;
    
    [request setRequestMethod:@"DELETE"];
    [NinaHelper signRequest:request];
    [request startAsynchronous];
}

-(void) blankLoad{
    if (self.place){
        //loads what we have before grabbing detailed view
        self.nameLabel.text = self.place.name;
        self.addressLabel.text = self.place.streetAddress;
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
    self.addressLabel.text = self.place.streetAddress;
    self.cityLabel.text = self.place.city;
    
    [FlurryAnalytics logEvent:@"PLACE_PAGE_VIEW" withParameters:[NSDictionary dictionaryWithKeysAndObjects:@"name", self.place.name, @"city", self.place.city ? self.place.city : @"", nil]];
    
    
    if (!mapRequested){
        [self loadMap];
    } 
    
    self.categoriesLabel.text = [self.place.categories componentsJoinedByString:@","];
    
    UIButton *button = [self.segmentedControl.buttons objectAtIndex:1];
    
    [button setTitle:[NSString stringWithFormat:@"Following (%i)", self.place.followingPerspectiveCount] forState:UIControlStateNormal];
    
    button = [self.segmentedControl.buttons objectAtIndex:2];
    [button setTitle:[NSString stringWithFormat:@"Everyone (%i)", self.place.perspectiveCount] forState:UIControlStateNormal];
    
    CGFloat cx = 7;
    
    for (UIView *view in [self.tagScrollView subviews]) {
        [view removeFromSuperview];
    }
     
    for ( NSString* tag in self.place.tags ){        
        UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        CGSize textsize = [tag sizeWithFont:tagButton.titleLabel.font forWidth:100.0 lineBreakMode: tagButton.titleLabel.lineBreakMode];
        CGRect rect = CGRectMake(cx, 13, textsize.width+4, 26);       
        
        tagButton.frame = rect;
        [tagButton setTitle:[NSString stringWithFormat:@"#%@", [tag lowercaseString]] forState:UIControlStateNormal];
        [StyleHelper styleTagButton:tagButton];
        
        [tagButton addTarget:self action:@selector(tagSearch:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.tagScrollView addSubview:tagButton];        
        cx += tagButton.frame.size.width+7;
        
    }
    
    [self.tagScrollView setContentSize:CGSizeMake(cx, [self.tagScrollView bounds].size.height)];  
    self.place.dirty = false;
}

-(IBAction)editPerspective{
    DLog(@"modifying on perspective on %@", self.place.name);
    myPerspective.place = self.place;
    EditPerspectiveViewController *editPerspectiveViewController = [[EditPerspectiveViewController alloc] initWithPerspective:myPerspective];
    
    editPerspectiveViewController.delegate = self;
    
    [FlurryAnalytics logEvent:@"EDIT_PERSPECTIVE_WRITE"];
    
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:editPerspectiveViewController];
    [StyleHelper styleNavigationBar:navBar.navigationBar];
    [self.navigationController presentModalViewController:navBar animated:YES];
    [navBar release];
    
    [editPerspectiveViewController release];       
}


-(IBAction)editPerspectivePhotos{
    DLog(@"modifying on perspective on %@", self.place.name);
    myPerspective.place = self.place;
    
    EditPerspectiveViewController *editPerspectiveViewController = [[EditPerspectiveViewController alloc] initWithPerspective:myPerspective];
    
    editPerspectiveViewController.delegate = self;
    
    [FlurryAnalytics logEvent:@"EDIT_PERSPECTIVE_PHOTO" ];
    
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:editPerspectiveViewController];
    [StyleHelper styleNavigationBar:navBar.navigationBar];
    [self.navigationController presentModalViewController:navBar animated:YES];
    [navBar release];
    [editPerspectiveViewController.memoTextView resignFirstResponder];
    [editPerspectiveViewController release];       
}


#pragma mark - IBActions

-(IBAction)showSingleAnnotatedMap{
    DLog(@"Spawning map for place: %@", self.place.name);
    [FlurryAnalytics logEvent:@"GOOGLE_SINGLE_PLACE_MAP"];
    SinglePlaceMapView *singlePlaceMapView = [[SinglePlaceMapView alloc] initWithPlace:self.place];
    
    [self.navigationController pushViewController:singlePlaceMapView animated:TRUE];
    [singlePlaceMapView release];
    
}


- (void) touchUpInsideSegmentIndex:(NSUInteger)segmentIndex{
    NSUInteger index = segmentIndex;
    
    [FlurryAnalytics logEvent:@"PLACE_PAGE_VIEW_TOGGLE" withParameters:[NSDictionary dictionaryWithKeysAndObjects:@"CLICK_TO", [NSString stringWithFormat:@"%i", index] , nil]];
    
    if (index == 0){
        self.perspectiveType = home;
        if (self.place.dirty){
            
            //only call if we know something there
            NSString *urlText = [self getUrlString];
            
            // Call url to get profile details                
            RKObjectManager* objectManager = [RKObjectManager sharedManager];       
            
            [objectManager loadObjectsAtResourcePath:urlText delegate:self block:^(RKObjectLoader* loader) {     
                //loader
                loader.userData = [NSNumber numberWithInt:0]; //use as a tag
            }];
        } 
        perspectives = homePerspectives;
    } else if (index == 1){
        self.perspectiveType = following;
        if (self.place.followingPerspectiveCount > 0 && (self.followingPerspectives.count == 0)){
            
            //only call if we know something there
            NSString *urlText = [NSString stringWithFormat:@"/v1/places/%@/perspectives/following", self.place_id];
            
            // Call url to get profile details                
            RKObjectManager* objectManager = [RKObjectManager sharedManager];       
            
            [objectManager loadObjectsAtResourcePath:urlText delegate:self block:^(RKObjectLoader* loader) {     
                //loader.objectMapping = [Perspective getObjectMapping];
                loader.userData = [NSNumber numberWithInt:2]; //use as a tag
            }];
            
            [followingPerspectives addObject:@"Loading"]; //marker for spinner cell
        } 
        perspectives = followingPerspectives;
    } else if (index == 2){
        self.perspectiveType = everyone;
        if (self.place.perspectiveCount > 0 && (self.everyonePerspectives.count ==0)){          
            //only call if we know something there
            NSString *urlText = [NSString stringWithFormat:@"/v1/places/%@/perspectives/all", self.place_id];
            
            // Call url to get profile details                
            RKObjectManager* objectManager = [RKObjectManager sharedManager];       
            
            [objectManager loadObjectsAtResourcePath:urlText delegate:self block:^(RKObjectLoader* loader) {     
                //loader.objectMapping = [Perspective getObjectMapping];
                loader.userData = [NSNumber numberWithInt:3]; //use as a tag
            }];
            
            [everyonePerspectives addObject:@"Loading"]; //marker for spinner cell
        }
        perspectives = everyonePerspectives;
    }
    
    [self.tableView reloadData];
    
}

-(IBAction) googlePlacePage{    
    [FlurryAnalytics logEvent:@"GOOGLE_PLACES_CLICK"];
    if (self.place.googlePlacesUrl != nil && ![self.place.googlePlacesUrl isKindOfClass:NSNull.class]){
        GenericWebViewController *genericWebViewController = [[GenericWebViewController alloc] initWithUrl:self.place.googlePlacesUrl];
        
        genericWebViewController.title = @"Contact info";
        [self.navigationController pushViewController:genericWebViewController animated:true];
        
        [genericWebViewController release];
    }
}


-(IBAction) bookmark {
    NSString *currentUser = [NinaHelper getUsername];
    
    if (!currentUser || currentUser.length == 0) {
        UIAlertView *baseAlert;
        NSString *alertMessage = @"Sign up or log in\n to bookmark locations";
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
        self.place.perspectiveCount += 1;
        
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
        loginController.delegate = self;
        
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

-(NSString*) numberBookmarkCopy{
    DLog(@"Index of segmented control is: %i", self.segmentedControl.selectedSegmentIndex);
  
    
    if ( [self numberOfSectionBookmarks] == 0 ){
        //label.textColor = [UIColor grayColor];
        if (self.segmentedControl.selectedSegmentIndex == 1) {
            return [NSString stringWithFormat:@"No one you follow has placemarks here place"];
        } else {
            return [NSString stringWithFormat:@"No one has placemarks here yet"];
        }
        //label.text = [NSString stringWithFormat:@"0 bookmarks so far"];
    } else if ( [self numberOfSectionBookmarks] == 1) {
        if (self.segmentedControl.selectedSegmentIndex == 1) {
           return [NSString stringWithFormat:@"%i person you follow has a placemark here", [self numberOfSectionBookmarks]];
        } else {
            // How do I update this to include a saying if you're the only one has done this
            if (self.place.bookmarked == TRUE) {
                return [NSString stringWithFormat:@"You have the only placemark here"];
            } else {
                return [NSString stringWithFormat:@"%i person has a placemark here", [self numberOfSectionBookmarks]];
            }
        }
    } else {
        if (self.segmentedControl.selectedSegmentIndex == 1) {
            return [NSString stringWithFormat:@"%i people you follow have placemarks here", [self numberOfSectionBookmarks]];
        } else {
            return [NSString stringWithFormat:@"%i people have placemarks here", [self numberOfSectionBookmarks]];   
        }            
    }
}

-(bool)returnMinRowHeight:(NSIndexPath *)indexPath {
    // Goal is to always have the contact info as a sticky footer at the bottom of the view
    // However, table has variable number of rows and sections
    
    // 1. No perspective at all
    Perspective *perspective;
    if ([perspectives count] > 0) {
        perspective = [perspectives objectAtIndex:indexPath.row];
    } else {
        return true;
    }
    
    // 2. Loading
    if ([perspective isKindOfClass:[NSString class]]) {
        return true;
    }
    
    // 3. Home, not bookmarked, no referrer
    if (self.perspectiveType == home && [perspectives count] == 0) {
        return true;
    }
    
    // 4. Home, bookmarked but no referrer and not enough notes/photos to push off bottom of screen
    if (self.perspectiveType == home && self.place.bookmarked == true && [perspectives count] < 2) {
        if ([MyPerspectiveCellViewController cellHeightForPerspective:perspective] < minTableHeight) {
            return true;
        }
    }
    
    // 5. "Everyone" or "Following" and no content
    if (self.perspectiveType != home && [perspectives count] == 0) {
        return true;
    }
    
    // 6. "Everyone" or "Following" and only one cell, but not enough content in cell to push below screen
    if (self.perspectiveType != home && [perspectives count] < 2) {
        if ([PerspectiveTableViewCell cellHeightForPerspective:perspective] < minTableHeight) {
            return true;
        }
    }
    
    return false;
}


- (void)expandAtIndexPath:(NSIndexPath*)indexPath{
        
    [[expandedCells objectAtIndex:self.segmentedControl.selectedSegmentIndex ] addObject:indexPath];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}



-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    // Need to calculate height so that footer always sticks to bottom of screen
    if ([self returnMinRowHeight:indexPath]) {
        return minTableHeight;
    }
    
    if (indexPath.section == 0){
        if (self.perspectiveType == home && self.place.bookmarked == false){
            return 64;
        }else{
            return 44;
        }
    }
    
    Perspective *perspective = [perspectives objectAtIndex:indexPath.row];
    
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ( [perspective isKindOfClass:[NSString class]] ){
        //loading case
        return 44;
    }else if ( self.perspectiveType == home && perspective.mine){
        return [MyPerspectiveCellViewController cellHeightForPerspective:perspective];            
    } else {
        //a visible perspective row PerspectiveTableViewCell 
        NSMutableSet *expandedIndexPaths = [expandedCells objectAtIndex:self.segmentedControl.selectedSegmentIndex];
        
        if( [expandedIndexPaths member:indexPath]){  
            return [PerspectiveTableViewCell cellHeightUnboundedForPerspective:perspective];
        } else {
            return [PerspectiveTableViewCell cellHeightForPerspective:perspective];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    if (section == 1){
        return [perspectives count];   
    } else if ([self shouldShowSectionView] && section == 0){
        return 1;
    }else {
        return 0;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *perspectiveCellIdentifier = @"PerspectiveCellIdentifier";
    static NSString *editableCellIdentifier = @"MyPerspectiveCellIdentifier";
    static NSString *spinnerCellIdentifier = @"SpinnerCellIdentifier";
    static NSString *infoCellIdentifier = @"infoCellIdentifier";
    static NSString *bookmarkCellIdentifier = @"bookmarkCellIdentifier";
    
    UITableViewCell *cell;
    
    
    if (indexPath.section == 0){
        if (self.perspectiveType == home && self.place.bookmarked == false){
            cell = [tableView dequeueReusableCellWithIdentifier:bookmarkCellIdentifier];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:infoCellIdentifier];
        }
            
        if (cell == nil) {
            if (self.perspectiveType == home && self.place.bookmarked == false){
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"BookmarkTableViewCell" owner:self options:nil];
                
                for(id item in objects){
                    if ( [item isKindOfClass:[UITableViewCell class]]){
                        BookmarkTableViewCell *mCell = (BookmarkTableViewCell*) item;  
                        mCell.backgroundColor = [UIColor clearColor];
                        cell = mCell;
                    }
                }
            }else{
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infoCellIdentifier] autorelease];
            }            
            
        } 
        
        if (!(self.perspectiveType == home && self.place.bookmarked == false)){
            cell.textLabel.text = [self numberBookmarkCopy];
            cell.textLabel.textColor = self.addressLabel.textColor;
            cell.textLabel.font = [UIFont fontWithName:self.nameLabel.font.fontName size:13];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
        }
   
        return cell;

    }
    
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
                        NSMutableSet *expandedIndexPaths = [expandedCells objectAtIndex:self.segmentedControl.selectedSegmentIndex];
                        
                        if( [expandedIndexPaths member:indexPath]){  
                            pcell.expanded = true;
                        }
                        pcell.requestDelegate = self;
                        pcell.indexpath = indexPath;
                        [PerspectiveTableViewCell setupCell:pcell forPerspective:perspective userSource:false];
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
    
    if ([self shouldShowSectionView] && indexPath.section == 0 && self.perspectiveType != home){
        FollowViewController *followViewController;
        
        if(self.perspectiveType == following){
            followViewController = [[FollowViewController alloc] initWithPlace:self.place andFollowing:TRUE];
        } else {
            followViewController = [[FollowViewController alloc] initWithPlace:self.place andFollowing:FALSE];
        }
        
        [self.navigationController pushViewController:followViewController animated:TRUE];
        [followViewController release];
        
    } else if (indexPath.section == 1){
        Perspective *perspective = [perspectives objectAtIndex:indexPath.row];
        
        BOOL emptyPerspective = true;
        
        if(perspective.notes && perspective.notes.length > 0){
            emptyPerspective = false;
        }
        if(perspective.photos && perspective.photos.count > 0){
            emptyPerspective = false;
        }
        if(emptyPerspective && perspective.mine){
            EditPerspectiveViewController *editPerspectiveViewController = [[EditPerspectiveViewController alloc] initWithPerspective:myPerspective];
            
            editPerspectiveViewController.delegate = self;
            
            UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:editPerspectiveViewController];
            [StyleHelper styleNavigationBar:navBar.navigationBar];
            [self.navigationController presentModalViewController:navBar animated:YES];
            [navBar release];
            
            [editPerspectiveViewController release];         

        } 
    }
}

- (void)dealloc{
    [NinaHelper clearActiveRequests:0];
    [[[[RKObjectManager sharedManager] client] requestQueue] cancelRequestsWithDelegate:self];
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
    [expandedCells release];
    
    [super dealloc];
}

@end
