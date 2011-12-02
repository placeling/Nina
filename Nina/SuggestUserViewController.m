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
#import "User.h"
#import "asyncimageview.h"
#import "LoginController.h"

@implementation SuggestUserViewController
@synthesize members, query;


- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc{
    [members release];
    [query release];
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
    loadingMore = true;
    // Set up buttons
    self.navigationItem.title = @"Top Locals";
    
    /*
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Done"
                                    style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(goHome)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release]; */
    
    CLLocationManager *manager = [LocationManagerManager sharedCLLocationManager];
    CLLocationCoordinate2D location = [manager location].coordinate;
	
	NSString *targetURL = [NSString stringWithFormat:@"%@/v1/users/suggested?lat=%f&lng=%f&q=%@", [NinaHelper getHostname], location.latitude, location.longitude, self.query];
    
    NSURL *url = [NSURL URLWithString:targetURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [NinaHelper signRequest:request];
    [request setDelegate:self];
    [request startAsynchronous];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request{
	[NinaHelper handleBadRequest:request sender:self];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	if (200 != [request responseStatusCode]){
		[NinaHelper handleBadRequest:request sender:self];
	} else {
        NSString *responseString = [request responseString];
        DLog(@"%@", responseString);
        [members release];
        
        NSArray *rawUsers = [[responseString JSONValue] objectForKey:@"suggested"];
        members = [[NSMutableArray alloc]initWithCapacity:[rawUsers count]];
        
        for (NSDictionary* rawUser in rawUsers){
            User *user = [[User alloc] initFromJsonDict:rawUser];
            [members addObject:user];
            [user release];
        }
        [self.tableView reloadData];
	}
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
    [self.navigationController dismissModalViewControllerAnimated:YES];
};


#pragma mark -
#pragma mark Get data for table view

#pragma mark - Table view data source

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    int previous = [[[self navigationController] viewControllers] count] - 2;
    NSObject *parentController = [[[self navigationController] viewControllers] objectAtIndex:previous];
    
    NSLog(@"parent controller is: %@", parentController);
    
    if ([parentController isKindOfClass:[LoginController class]]) {
        UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)] autorelease];
        
        UIImageView *imagePattern = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"canvas.png"]];
        imagePattern.frame = CGRectMake(0, 0, 320, 60);
        [view addSubview:imagePattern];
        [imagePattern release];
        
        UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 50)];
        info.text = @"Placeling's better when you follow others to discover new places. Here are some suggestions.";
        info.numberOfLines = 3;
        info.lineBreakMode = UILineBreakModeWordWrap;
        info.textAlignment = UITextAlignmentCenter;
        info.backgroundColor = [UIColor clearColor];
        [info setFont:[UIFont systemFontOfSize:12.0f]];
        
        [view addSubview:info];
        
        [info release];
        
        return view;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0;
    
    int previous = [[[self navigationController] viewControllers] count] - 2;
    NSObject *parentController = [[[self navigationController] viewControllers] objectAtIndex:previous];
    
    if ([parentController isKindOfClass:[LoginController class]]) {
        height = 60;
    }
    
    return height;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Number of rows on screen
    return MAX([self.members count], 1); //in "1" case we have a memo
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *UserCellIdentifier = @"UserCell";
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell;
    
    if ([members count] > 0){
        cell = [tableView dequeueReusableCellWithIdentifier:UserCellIdentifier];
        tableView.allowsSelection = YES;
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:UserCellIdentifier] autorelease];
        }
    }else if (loadingMore) {        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SpinnerTableCell" owner:self options:nil];
        tableView.allowsSelection = NO;
        for(id item in objects){
            if ( [item isKindOfClass:[UITableViewCell class]]){
                cell = item;
            }
        }      
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        tableView.allowsSelection = NO;
        if (cell == nil){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
    }

    
    if ([members count] > 0){
        User *user = [members objectAtIndex:indexPath.row];
        cell.textLabel.text = user.username;
        cell.detailTextLabel.text = user.description;
        
        cell.accessoryView.tag = indexPath.row;
        
        cell.imageView.image = [UIImage imageNamed:@"default_profile_image.png"];
        
        AsyncImageView *aImageView = [[AsyncImageView alloc] initWithPhoto:user.profilePic];
        aImageView.frame = cell.imageView.frame;
        aImageView.populate = cell.imageView;
        [aImageView loadImage];
        [cell addSubview:aImageView]; //mostly to handle de-allocation
        [aImageView release];
        
    }else if (!loadingMore) {        
        cell.detailTextLabel.text = @"";
        cell.textLabel.text = @"No Suggested Users Nearby";    
        cell.textLabel.textColor = [UIColor grayColor];
    } 
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    User *user = [members objectAtIndex:indexPath.row];
    MemberProfileViewController *memberProfileViewController = [[MemberProfileViewController alloc] init];
    memberProfileViewController.user = user;
    [self.navigationController pushViewController:memberProfileViewController animated:YES];
    [memberProfileViewController release];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
