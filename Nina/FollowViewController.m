//
//  FollowViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-08-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FollowViewController.h"
#import "User.h"
#import "NSString+SBJSON.h"
#import "MemberProfileViewController.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface FollowViewController()
-(NSString*) restUrl:(int)start;
@end

@implementation FollowViewController

@synthesize user=_user;
@synthesize place=_place, perspective=_perspective;
@synthesize users, following;

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (id)initWithUser:(User*)focusUser andFollowing:(bool)follow{
    self = [super init];
    if (self) {
        self.following = follow;
        self.user = focusUser;
    }
    return self;
}

-(id) initWithPlace:(Place*)place andFollowing:(bool)follow{
    self = [super init];
    if (self) {
        self.place = place;
        self.following = follow;
    }
    return self;
}

-(id) initWithPerspective:(Perspective*)perspective{
    self = [super init];
    if (self) {
        self.perspective = perspective;
    }
    return self;
}

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    loadingMore = false;
    
    if ([objects count] < 20){
        hasMore = false;
    }
    
    if ( [(NSNumber*)objectLoader.userData intValue] == 40){
        users = [[NSMutableArray alloc] initWithCapacity:[objects count]];
        for (User* user in objects){
            [users addObject:user];
        }
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 41){
        for (User* user in objects){
            [users addObject:user];
        }
    }
    [self.tableView reloadData]; 
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [NinaHelper handleBadRKRequest:objectLoader.response sender:self];
    DLog(@"Encountered an error: %@", error); 
}


-(NSString*) restUrl:(int)start{
    NSString *targetURL;
    if (self.place){        
        self.navigationItem.title = self.place.name;  
        
        if (self.following){
            targetURL = [NSString stringWithFormat:@"/v1/places/%@/users?filter_follow=true&start=%i", self.place.pid, start];
        } else {
            targetURL = [NSString stringWithFormat:@"/v1/places/%@/users?start=%i", self.place.pid, start];
        }        
    } else if (self.perspective){
        targetURL = [NSString stringWithFormat:@"/v1/perspectives/%@/likers?start=%i", self.perspective.perspectiveId, start];
         self.navigationItem.title = @"Liked By";
    } else {
        if (self.following){
            targetURL = [NSString stringWithFormat:@"/v1/users/%@/following?start=%i", self.user.username, start];
            self.navigationItem.title = @"Following";
        } else {
            targetURL = [NSString stringWithFormat:@"/v1/users/%@/followers?start=%i", self.user.username, start];
            self.navigationItem.title = @"Followers";
        }
    }
    return targetURL;
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
  
    loadingMore = true;
    hasMore = true;
        	
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    [objectManager loadObjectsAtResourcePath:[self restUrl:0] usingBlock:^(RKObjectLoader* loader) {
        loader.delegate=self;
        loader.userData = [NSNumber numberWithInt:40]; //use as a tag
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
    [StyleHelper styleBackgroundView:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.

    if (users) {
        if (loadingMore){   
            return [users count] +1;
        }else{
            return [users count];
        }
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if ((users) && [users count] == 0) {
        tableView.allowsSelection = NO;
        [cell.textLabel setFont:[UIFont systemFontOfSize:14.0]];
        if (self.place){
            if (self.following) {
                cell.textLabel.text = @"Nobody you follow has bookmarked this location";
            } else {
                cell.textLabel.text = @"Nobody has bookmarked this location";
            }            
        } else {
            if (self.following) {
                if ([self.user.username isEqualToString:[NinaHelper getUsername]]) {
                    cell.textLabel.text = @"You're not yet following anyone";
                } else {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ isn't yet following anyone", self.user.username];
                }
            } else {
                if ([self.user.username isEqualToString:[NinaHelper getUsername]]) {
                    cell.textLabel.text = @"No one's yet following you";
                } else {
                    cell.textLabel.text = [NSString stringWithFormat:@"No one's yet following %@", self.user.username];
                }
            }
        }
    } else if ( loadingMore && indexPath.row >= [users count] ){
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SpinnerTableCell" owner:self options:nil];
        
        for(id item in objects){
            if ( [item isKindOfClass:[UITableViewCell class]]){
                cell = item;
            }
        }   
    } else {
        tableView.allowsSelection = YES;
        User* user = [users objectAtIndex:indexPath.row];

        cell.textLabel.text = user.username;
        cell.detailTextLabel.text = user.userDescription;
        
        cell.accessoryView.tag = indexPath.row;
        cell.imageView.contentMode = UIViewContentModeScaleToFill;
        // Here we use the new provided setImageWithURL: method to load the web image
        [cell.imageView setImageWithURL:[NSURL URLWithString:user.profilePic.thumbUrl]
                       placeholderImage:[UIImage imageNamed:@"profile.png"]];
        
        [cell.imageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [cell.imageView.layer setBorderWidth: 2.0];
    }
    
    [StyleHelper styleGenericTableCell:cell];    
    return cell;
}


- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = 10;
    if(hasMore && y > h + reload_distance && loadingMore == false) {
        loadingMore = true;
        
        RKObjectManager* objectManager = [RKObjectManager sharedManager];
        
        [objectManager loadObjectsAtResourcePath:[self restUrl:[users count]] usingBlock:^(RKObjectLoader* loader) {
            loader.delegate = self;
            loader.userData = [NSNumber numberWithInt:41]; //use as a tag
        }];
        
        [self.tableView reloadData];
    }
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MemberProfileViewController *memberProfileViewController = [[MemberProfileViewController alloc] init];
    memberProfileViewController.user = [self.users objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:memberProfileViewController animated:YES];
    [memberProfileViewController release]; 
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) dealloc{
    [[[[RKObjectManager sharedManager] client] requestQueue] cancelRequestsWithDelegate:self];
    [users release];
    [_user release];
    [_place release];
    [_perspective release];
    [super dealloc];
    
}

@end
