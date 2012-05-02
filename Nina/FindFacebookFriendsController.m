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
@synthesize  facebookFriends;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

- (void)viewDidAppear:(BOOL)animated
{
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


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

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
