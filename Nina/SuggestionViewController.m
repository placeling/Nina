//
//  SuggestionViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 12-08-17.
//
//

#import "SuggestionViewController.h"

@interface SuggestionViewController ()
-(void)contentLoad;

@end

@implementation SuggestionViewController

@synthesize suggestion, suggestionId;

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
    
    [StyleHelper styleBackgroundView:self.view];
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


-(void)contentLoad{
    
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc{
    [[[[RKObjectManager sharedManager] client] requestQueue] cancelRequestsWithDelegate:self];
    [suggestion release];
    [suggestionId release];
    [super dealloc];
}


@end
