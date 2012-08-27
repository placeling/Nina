//
//  SuggestionViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 12-08-17.
//
//

#import "SuggestionViewController.h"
#import "FlurryAnalytics.h"
#import "Place.h"
#import "UIImageView+WebCache.h"

@interface SuggestionViewController ()
-(void)contentLoad;

@end

@implementation SuggestionViewController

@synthesize suggestion, suggestionId, imageView, messageView, placemark, headerTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    NSString *targetURL = [NSString stringWithFormat:@"/v1/suggestions/%@", self.suggestionId];
    
    [objectManager loadObjectsAtResourcePath:targetURL usingBlock:^(RKObjectLoader* loader) {
        loader.userData = [NSNumber numberWithInt:150]; //use as a tag
        loader.delegate = self;
    }];
    
    
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // Set determinate mode
    HUD.labelText = @"Loading...";
    [HUD retain];
    
    dataLoaded = false;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Suggestion";
    
    [StyleHelper styleBackgroundView:self.view];
    [StyleHelper styleUserProfilePic:self.imageView];
}

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    [HUD hide:true];
    dataLoaded = true;
    if ( [(NSNumber*)objectLoader.userData intValue] == 150 ){
        self.suggestion = [objects objectAtIndex:0];
    }
    [self contentLoad];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [HUD hide:true];
    dataLoaded = true;
    [NinaHelper handleBadRKRequest:objectLoader.response sender:self];
    DLog(@"Encountered an error: %@", error);
}

-(void)hudWasHidden{
    [HUD release];
}

-(IBAction)placemark:(id)sender{
    EditPerspectiveViewController *editPerspectiveViewController;
    
    if ( self.suggestion.place.bookmarked ){
        NSMutableArray *perspectives = self.suggestion.place.homePerspectives;
        Perspective *myPerspective = [perspectives objectAtIndex:0];
        editPerspectiveViewController = [[EditPerspectiveViewController alloc] initWithPerspective:myPerspective];
    } else {
        Perspective *newPerspective = [[Perspective alloc] init];
        newPerspective.notes = self.suggestion.message;
        newPerspective.place = self.suggestion.place;
        newPerspective.photos = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        editPerspectiveViewController = [[EditPerspectiveViewController alloc] initWithPerspective:newPerspective];
        [newPerspective release];
    }
    
    editPerspectiveViewController.delegate = self;
    
    [FlurryAnalytics logEvent:@"EDIT_PERSPECTIVE_WRITE"];
    
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:editPerspectiveViewController];
    [StyleHelper styleNavigationBar:navBar.navigationBar];
    [self.navigationController presentModalViewController:navBar animated:YES];
    [navBar release];
    
    [editPerspectiveViewController release];
    
}


-(void)contentLoad{
    
    self.messageView.text = self.suggestion.message;
    [self.imageView setImageWithURL:[NSURL URLWithString:self.suggestion.sender.profilePic.thumbUrl] ];
    self.headerTextView.text = [NSString stringWithFormat:@"%@ has suggested you try %@", self.suggestion.sender.username, self.suggestion.place.name];
}


-(void)requestFailed:(ASIHTTPRequest *)request{
    [NinaHelper handleBadRequest:request sender:self];
}

-(void)requestFinished:(ASIHTTPRequest *)request{
    //[self.navigationController popViewControllerAnimated:true];
}
-(void)updatePerspective:(Perspective *)perspective{
    //[self.navigationController popViewControllerAnimated:true];
}


#pragma mark - Selectors for responding to initial URLs

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc{
    [[[[RKObjectManager sharedManager] client] requestQueue] cancelRequestsWithDelegate:self];
    [suggestion release];
    [suggestionId release];
    [imageView release];
    [messageView release];
    [placemark release];
    [headerTextView release];
    
    [super dealloc];
}


@end
