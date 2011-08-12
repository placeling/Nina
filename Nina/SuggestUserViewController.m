//
//  SuggestUserViewController.m
//  placeling2
//
//  Created by Lindsay Watt on 11-06-07.
//  Copyright 2011 Placeling. All rights reserved.
//

#import "SuggestUserViewController.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "NinaHelper.h"
#import "JSON.h"
#import <QuartzCore/QuartzCore.h>
#import "MemberProfileViewController.h"

@implementation SuggestUserViewController
@synthesize members;


- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc{
    [members release];
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
    
    // Set up buttons
    self.navigationItem.title = @"Follow Suggestions";
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Done"
                                    style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(goHome)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
    
    CLLocationManager *manager = [LocationManagerManager sharedCLLocationManager];
    CLLocationCoordinate2D location = [manager location].coordinate;
	
	NSString *targetURL = [NSString stringWithFormat:@"%@/v1/users/suggested?lat=%i&long=%i", [NinaHelper getHostname], location.latitude, location.longitude];
    
    NSURL *url = [NSURL URLWithString:targetURL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [NinaHelper signRequest:request];
    [request setDelegate:self];
    [request startSynchronous];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if ([request error]){
        [NinaHelper handleBadRequest:request sender:self];
    } else {
		// Check if results valid
		NSString *responseString = [request responseString];
        DLog(@"%@", responseString);
        [members release];
		members = [[responseString JSONValue] retain];
        [self.tableView reloadData];
	}
	
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark - Actions for Buttons
- (void)goHome {
    // Take the user to their home screen
    [self.navigationController popToRootViewControllerAnimated:YES];
};

- (void)socialAction:(id)sender {
    /*
    UIButton *button = (UIButton *)sender;
    int row = [button superview].tag;
    
    NSString *actionURL = [NSString stringWithFormat:@"%@%@", TOP_LEVEL_DOMAIN, [[members objectAtIndex:row] objectForKey:@"url"]];
	NSLog(@"Need to call: %@", actionURL);
	NSURL *url = [NSURL URLWithString:actionURL];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setRequestMethod:@"POST"]; 
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [request setDelegate:self];
    [request startSynchronous];

     */
}

#pragma mark -
#pragma mark Get data for table view

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Number of rows on screen
    return [self.members count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self action:@selector(socialAction:) forControlEvents:UIControlEventTouchDown];
        [button setTitle:@"Follow" forState:UIControlStateNormal];
        
        button.frame = CGRectMake(0.0, 0.0, 80.0, 25.0);
        
        [cell setAccessoryView:button];
    }
    
	NSDictionary *entry = [self.members objectAtIndex:indexPath.row];
    cell.textLabel.text = [entry objectForKey:@"username"];
    cell.detailTextLabel.text = [entry objectForKey:@"desc"];
	
    cell.accessoryView.tag = indexPath.row;
    
	NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[entry objectForKey:@"profile_pic"]]];
	UIImage *myimage = [[UIImage alloc] initWithData:imageData];    
	cell.imageView.image = myimage;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
     MemberProfileViewController *memberProfileViewController = [[MemberProfileViewController alloc] init];
     [self.navigationController pushViewController:memberProfileViewController animated:YES];
     [memberProfileViewController release];
}

@end