//
//  AttachPerspectiveViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-07-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AttachPerspectiveViewController.h"
#import "ASIFormDataRequest.h"

@implementation AttachPerspectiveViewController

@synthesize rawPlace;
@synthesize placeName;
@synthesize perspective;
@synthesize postButton;
@synthesize locationManager;


-(IBAction) postPerspective{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
	NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
	NSString *urlString = [NSString stringWithFormat:@"%@/perspectives/create", [plistData objectForKey:@"server_url"]];
	NSURL *url = [NSURL URLWithString:urlString];
    
	ASIFormDataRequest *request =  [[ASIFormDataRequest  alloc]  initWithURL:url];
    CLLocation *location = locationManager.location;
    
	NSString* y = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
	NSString* x = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    [request setPostValue:[NSArray arrayWithObjects:y,x, nil] forKey:@"perspective[location]"];

    float accuracy = pow(location.horizontalAccuracy,2)  + pow(location.verticalAccuracy,2);
    accuracy = sqrt( accuracy ); //take accuracy as single vector, rather than 2 values -iMack
    NSString *radius = [NSString stringWithFormat:@"%f", accuracy];
    [request setPostValue:radius forKey:@"perspective[radius]"];
    
    
	[request setPostValue:perspective.text forKey:@"memo"];

	[request setTimeOutSeconds:60];
    
	[request startSynchronous];//is being run on child thread, so not threat to main -iMack

    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc{
    [rawPlace release];
    [placeName release];
    [perspective release];
    [postButton release];
    [locationManager release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.placeName.text = [rawPlace objectForKey:@"name"];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
