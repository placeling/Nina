//
//  FindFacebookFriendsController.m
//  Nina
//
//  Created by Ian MacKinnon on 12-05-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FindFacebookFriendsController.h"
#import "MemberProfileViewController.h"
#import "UIImageView+WebCache.h"
#import "User.h"

@implementation FindFacebookFriendsController
@synthesize  facebookFriends, tableView=_tableView;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];

    self.navigationItem.title = @"Facbook Friends";
    self.facebookFriends = [[[NSMutableArray alloc]init] autorelease];

    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    //NSManagedObjectContext *managedObjectContext = objectManager.objectStore.managedObjectContext;
        
    UIBarButtonItem *shareButton =  [[UIBarButtonItem  alloc]initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(showFacebookInvite)];
    self.navigationItem.rightBarButtonItem = shareButton;
    [shareButton release];
    
    NSString *targetURL = [NSString stringWithFormat:@"/v1/auth/facebook/friends"]; 
    
    loading = true;
    
    [objectManager loadObjectsAtResourcePath:targetURL delegate:self block:^(RKObjectLoader* loader) {        
        loader.cacheTimeoutInterval = 60;
        loader.userData = [NSNumber numberWithInt:100]; //use as a tag
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated]; 
    [StyleHelper styleBackgroundView:self.tableView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(IBAction)showFacebookInvite{
    NinaAppDelegate *appDelegate = (NinaAppDelegate*)[[UIApplication sharedApplication] delegate];
    Facebook *facebook = appDelegate.facebook;
    
    NSString *username = [NinaHelper getUsername];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NinaHelper getFacebookAppId], @"app_id",
                                   @"https://www.placeling.com", @"link",
                                   [NSString stringWithFormat:@"Join %@ on Placeling", username], @"name",
                                   nil];
    
    [facebook dialog:@"feed" andParams:params andDelegate:self];    
}

- (void)dialogDidComplete:(FBDialog *)dialog{
    DLog(@"Share on Facebook Dialog completed %@", dialog)
}

- (void)dialogDidNotComplete:(FBDialog *)dialog{
    DLog(@"Share on Facebook Dialog completed %@", dialog)
}


#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    loading = false;

    [self.facebookFriends removeAllObjects];
    for (User* user in objects){
        [self.facebookFriends addObject:user];
    }    
    [self.tableView  performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:TRUE];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [NinaHelper handleBadRKRequest:objectLoader.response sender:self];
    DLog(@"Encountered an error: %@", error); 
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return MAX([self.facebookFriends count], 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    static NSString *InfoCellIdentifier = @"InfoCell";
    
    UITableViewCell *cell;
    if ( loading ){
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SpinnerTableCell" owner:self options:nil];
        
        for(id item in objects){
            if ( [item isKindOfClass:[UITableViewCell class]]){
                cell = item;
            }
        }    
        
    }else {
        
        if (indexPath.row ==0 && [self.facebookFriends count] ==0){
            
            cell = [tableView dequeueReusableCellWithIdentifier:InfoCellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:InfoCellIdentifier] autorelease];
            }
            
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.text = @"You don't have any facebook friends on Placeling";
            [cell setUserInteractionEnabled:NO];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {    
            User *user = [self.facebookFriends objectAtIndex:indexPath.row];
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.textLabel.text = user.fullname;
            cell.detailTextLabel.text = user.username;
            
            cell.accessoryView.tag = indexPath.row;
            
            DLog(@"%@ is %@", user.username, user.following);
            if ( user.following == [NSNumber numberWithBool:false] ){
                
                UIButton* accessory = [UIButton buttonWithType:UIButtonTypeCustom];
                [accessory setImage:[UIImage imageNamed:@"followButton.png"] forState:UIControlStateNormal];
                accessory.frame = CGRectMake(0, 0, 40, 40);
                accessory.userInteractionEnabled = YES;
                [accessory addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = accessory;
                cell.accessoryView.frame = CGRectMake(cell.accessoryView.frame.origin.x-10, cell.accessoryView.frame.origin.y, cell.accessoryView.frame.size.width, cell.accessoryView.frame.size.height);
                
            }
            
            [cell.imageView.layer setBorderColor:[UIColor whiteColor].CGColor];
            [cell.imageView.layer setBorderWidth:2.0];
            cell.imageView.contentMode = UIViewContentModeScaleToFill;
            // Here we use the new provided setImageWithURL: method to load the web image
            [cell.imageView setImageWithURL:[NSURL URLWithString:user.profilePic.thumbUrl]
                           placeholderImage:[UIImage imageNamed:@"profile.png"]];
            [StyleHelper styleGenericTableCell:cell];
        }
    }
    
    return cell;
}


#pragma mark - Table view delegate


- (void) accessoryButtonTapped: (UIControl *) button withEvent: (UIEvent *) event
{
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if ( indexPath == nil )
        return;
    
    User *user = [self.facebookFriends objectAtIndex:indexPath.row];
    
    user.following = [NSNumber numberWithBool:false];
    NSString *actionURL = [NSString stringWithFormat:@"%@/v1/users/%@/follow", [NinaHelper getHostname], user.username];
    DLog(@"Follow/unfollow url is: %@", actionURL);
    NSURL *url = [NSURL URLWithString:actionURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    
    [NinaHelper signRequest:request];
    [request startAsynchronous];
    
    [self.tableView cellForRowAtIndexPath:indexPath].accessoryView = nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [self.facebookFriends objectAtIndex:indexPath.row];
    MemberProfileViewController *memberProfileViewController = [[MemberProfileViewController alloc] init];
    memberProfileViewController.user = user;
    [self.navigationController pushViewController:memberProfileViewController animated:YES];
    [memberProfileViewController release];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
