//
//  MemberProfileViewController.m
//  placeling2
//
//  Created by Lindsay Watt on 11-06-16.
//  Copyright 2011 Placeling. All rights reserved.
//

#import "MemberProfileViewController.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"
#import <QuartzCore/QuartzCore.h>
#import "FollowViewController.h"
#import "Perspective.h"
#import "PerspectiveTableViewCell.h"
#import "MyPerspectiveCellViewController.h"
#import "PlacePageViewController.h"
#import "PerspectivesMapViewController.h"
#import "ASIDownloadCache.h"
#import "NinaHelper.h"
#import "EditProfileViewController.h"
#import "LoginController.h"
#import "UIImageView+WebCache.h"
#import "NinaAppDelegate.h"
#import "FlurryAnalytics.h"

@interface MemberProfileViewController() 
-(void) blankLoad;
-(void) toggleFollow;
-(IBAction)editUser;

@end


@implementation MemberProfileViewController

@synthesize username, perspectives;
@synthesize user=_user, profileImageView, headerView;
@synthesize usernameLabel, userDescriptionLabel;
@synthesize followButton, locationLabel;
@synthesize followersButton, followingButton, placeMarkButton;

#pragma mark - View lifecycle

- (void)viewDidLoad{    
    [[NSBundle mainBundle] loadNibNamed:@"ProfileHeaderView" owner:self options:nil];
    
    [super viewDidLoad];
    loadingMore = true;
    hasMore = true;
	
    expandedIndexPaths = [[NSMutableSet alloc] init];
    self.tableView.tableHeaderView = self.headerView;
    
	[self blankLoad];
}

-(IBAction)editUser{
    
    EditProfileViewController *editProfileViewController = [[EditProfileViewController alloc] initWithStyle:UITableViewStyleGrouped];
    editProfileViewController.user = self.user;
    editProfileViewController.delegate = self;
    
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:editProfileViewController];
    [StyleHelper styleNavigationBar:navBar.navigationBar];
    [self.navigationController presentModalViewController:navBar animated:YES];
    [navBar release];
    
    [editProfileViewController release]; 
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [StyleHelper styleBackgroundView:self.tableView];
    
    self.profileImageView.layer.cornerRadius = 4.0f;
    self.profileImageView.layer.borderWidth = 1.0f;
    self.profileImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.profileImageView.layer.masksToBounds = YES; 
    
    [StyleHelper styleInfoView:self.headerView];
    
    if (self.user.modified){
        self.user.modified = false;
        [self loadData];
    } else {
        for (Perspective *perspective in perspectives){
            if (perspective.modified){
                perspective.modified = false;            
                [self.tableView reloadData];
                break;
            }
        }
    }
}

-(void) blankLoad{
    UIImage *profileImage = [UIImage imageNamed:@"profile.png"];
    self.profileImageView.image = profileImage;
    
    if ((self.user.username == (id)[NSNull null] || self.user.username.length == 0) && (self.username == (id)[NSNull null] || self.username.length == 0)) {
        self.usernameLabel.text = @"Your Name Here";
    } else {
        self.usernameLabel.text = @"";
    }
    self.locationLabel.text = @"";
    self.userDescriptionLabel.text = @"";
    
    self.followingButton.detailLabel.text = @"Following";    
    self.followersButton.detailLabel.text = @"Followers";
    self.placeMarkButton.detailLabel.text = @"Places";
    
    self.followingButton.numberLabel.text = @"-";
    self.followingButton.numberLabel.text = @"-";
    self.followingButton.numberLabel.text = @"-";
    
    self.placeMarkButton.enabled = false;
    self.followButton.enabled = false;
    self.followersButton.enabled = false;
    self.followingButton.enabled = false;
    
    [self mainContentLoad];
}

-(IBAction) userPerspectives{
    PerspectivesMapViewController *userPerspectives = [[PerspectivesMapViewController alloc] init];
    userPerspectives.username = self.user.username;
    userPerspectives.user = self.user;
    [self.navigationController pushViewController:userPerspectives animated:YES];
    [userPerspectives release];
}

-(IBAction) userFollowers{
    FollowViewController *followViewController = [[FollowViewController alloc] initWithUser:_user andFollowing:false];
    [self.navigationController pushViewController:followViewController animated:YES];
    [followViewController release];
}

-(IBAction) userFollowing{
    FollowViewController *followViewController = [[FollowViewController alloc] initWithUser:_user andFollowing:true];
    [self.navigationController pushViewController:followViewController animated:YES];
    [followViewController release];
}

-(void) loadData{
    
    self.usernameLabel.text = self.user.username;
    self.locationLabel.text = self.user.city;
    self.userDescriptionLabel.text = self.user.userDescription;
    
    
    self.followingButton.detailLabel.text = @"Following";    
    self.followersButton.detailLabel.text = @"Followers";
    self.placeMarkButton.detailLabel.text = @"Places";
    
    self.placeMarkButton.enabled = true;
    self.followersButton.enabled = true;
    self.followingButton.enabled = true;
  
    [self toggleFollow];
    
    self.followingButton.numberLabel.text = [NSString stringWithFormat:@"%@", self.user.followingCount];
    self.followersButton.numberLabel.text = [NSString stringWithFormat:@"%@", self.user.followerCount];
    self.placeMarkButton.numberLabel.text = [NSString stringWithFormat:@"%@", self.user.placeCount];
    
    
    [FlurryAnalytics logEvent:@"PROFILE_VIEW" withParameters:[NSDictionary dictionaryWithKeysAndObjects:@"username", self.username, nil]];
    
    if (perspectives == nil && self.user.placeCount != 0){
        loadingMore = true;
        
        RKObjectManager* objectManager = [RKObjectManager sharedManager];        
        NSString *targetURL = [NSString stringWithFormat:@"/v1/users/%@/perspectives", self.username];
        
        [objectManager loadObjectsAtResourcePath:targetURL delegate:self block:^(RKObjectLoader* loader) {        
            loader.userData = [NSNumber numberWithInt:13]; //use as a tag
        }];

    } else {
        [self.tableView reloadData];
    }

    UIBarButtonItem *shareButton =  [[UIBarButtonItem  alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showShareSheet)];
    self.navigationItem.rightBarButtonItem = shareButton;
    [shareButton release];
        
    // Here we use the new provided setImageWithURL: method to load the web image
    
    [self.profileImageView setImageWithURL:[NSURL URLWithString:self.user.profilePic.thumbUrl] placeholderImage:[UIImage imageNamed:@"profile.png"]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) mainContentLoad {
    //NSString *currentUser = [NinaHelper getUsername];
    
    if (( !self.user.username ) && ( !self.username || self.username.length == 0)) {
        self.navigationItem.title = @"Your Profile";
    } else {        
        if ( self.user ) {
            self.username = self.user.username;
        }
        
        self.navigationItem.title = @"Profile";
        loadingMore = true;
        
        // Call url to get profile details                
        RKObjectManager* objectManager = [RKObjectManager sharedManager];   
        NSString *targetURL = [NSString stringWithFormat:@"/v1/users/%@", self.username];
        
        [objectManager loadObjectsAtResourcePath:targetURL delegate:self block:^(RKObjectLoader* loader) {        
            loader.objectMapping = [User getObjectMapping];
            loader.userData = [NSNumber numberWithInt:10]; //use as a tag
        }];

    }
}

#pragma mark -
#pragma mark Login Controller Delegate
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
#pragma mark Follow/Unfollow

-(IBAction) followUser{
    NSString *currentUser = [NinaHelper getUsername];
    
    if (!currentUser || [currentUser length] == 0) {
        UIAlertView *baseAlert;
        NSString *alertMessage = @"Sign up or log in to follow people and get updates on places they love";
        baseAlert = [[UIAlertView alloc] 
                     initWithTitle:nil message:alertMessage 
                     delegate:self cancelButtonTitle:@"Not Now" 
                     otherButtonTitles:@"Let's Go", nil];
        baseAlert.tag = 0;
        
        [baseAlert show];
        [baseAlert release];
    } else {
        // Get the URL to call to follow/unfollow
        
        if (self.followButton.tag == 0){
            self.user.following = [NSNumber numberWithBool:false];
            [self toggleFollow];
            NSString *actionURL = [NSString stringWithFormat:@"%@/v1/users/%@/follow", [NinaHelper getHostname], self.user.username];
            DLog(@"Follow/unfollow url is: %@", actionURL);
            NSURL *url = [NSURL URLWithString:actionURL];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            [request setRequestMethod:@"POST"];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            [request setDelegate:self];
            [request setTag:11];
            [NinaHelper signRequest:request];
            [request startAsynchronous];
        } else {
            UIAlertView *baseAlert;
            NSString *alertMessage = [NSString stringWithFormat:@"Unfollow %@?", self.user.username];
            baseAlert = [[UIAlertView alloc] 
                         initWithTitle:nil message:alertMessage 
                         delegate:self cancelButtonTitle:@"Cancel" 
                         otherButtonTitles:@"Unfollow", nil];
            baseAlert.tag = 1;
            
            [baseAlert show];
            [baseAlert release];
        }
    }	
}

#pragma mark - Unregistered experience methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0 && buttonIndex == 1) {
        LoginController *loginController = [[LoginController alloc] init];
        loginController.delegate = self;
        
        UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:loginController];
        [self.navigationController presentModalViewController:navBar animated:YES];
        [navBar release];
        [loginController release];
    } else if (alertView.tag == 1 && buttonIndex == 1){
        NSString *actionURL = [NSString stringWithFormat:@"%@/v1/users/%@/unfollow", [NinaHelper getHostname], self.user.username];
        DLog(@"Follow/unfollow url is: %@", actionURL);
        NSURL *url = [NSURL URLWithString:actionURL];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setRequestMethod:@"POST"];
        self.user.following = false;
        [self toggleFollow];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [request setDelegate:self];
        [request setTag:15];
        [NinaHelper signRequest:request];
        [request startAsynchronous];
    }
}


#pragma mark - Share Sheet
-(void) showShareSheet{
    UIActionSheet *actionSheet;
    if ([self.username isEqualToString:[NinaHelper getUsername]]){
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share by Email", @"Share on Facebook", @"Edit My Profile", nil];
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share by Email", @"Share on Facebook", nil];
    } 
    
    [actionSheet showInView:self.view];
    [actionSheet release];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *urlString = [NSString stringWithFormat:@"https://www.placeling.com/%@", self.user.username];

    if (buttonIndex == 0){
        DLog(@"share member by email");
        
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:[NSString stringWithFormat:@"\"%@\" on Placeling", self.user.username]];
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
                                       self.user.city ? self.user.city : @"", @"caption",
                                       self.user.userThumbUrl, @"picture",
                                       [NSString stringWithFormat:@"%@'s profile on Placeling", self.user.username], @"name",
                                       self.user.userDescription, @"description",
                                       nil];
        
        [facebook dialog:@"feed" andParams:params andDelegate:self];
    } else if (([actionSheet numberOfButtons] ==4) && buttonIndex ==2){
        DLog(@"edit my profile");
        [self editUser];
    }
}


- (void)dialogDidComplete:(FBDialog *)dialog{
    DLog(@"Share on Facebook Dialog completed %@", dialog)
    [FlurryAnalytics logEvent:@"FACEBOOK_SHARE_USER"];
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
    

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    loadingMore = false;
    
    if ( [(NSNumber*)objectLoader.userData intValue] == 10){
        User* user = [objects objectAtIndex:0];
        DLog(@"Loaded User: %@", user.username);        
        self.user = user;
        [self loadData];
        [self.tableView reloadData]; 
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 13){     
        // get initial perspectives
        loadingMore = false;
        if ( [objects count] == 0 ){
            hasMore = false;
        }
        
        self.perspectives = [[[NSMutableArray alloc] init] autorelease];
        
        for (Perspective *perspective in objects){
            perspective.user = self.user;
            [perspectives addObject:perspective]; 
        }
        
        [self loadData];
        [self.tableView reloadData]; 
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 14){
        // adding more perspectives
        loadingMore = false;
        if ( [objects count] == 0 ){
            hasMore = false;
        }
        
        for (Perspective *perspective in objects){
            perspective.user = self.user;
            [perspectives addObject:perspective]; 
        }
        
        [self loadData];
        [self.tableView reloadData]; 
    }

}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    //objectLoader.response.
    loadingMore = false;
    [NinaHelper handleBadRKRequest:objectLoader.response sender:self];
    DLog(@"Encountered an error: %@", error);
}

#pragma mark ASIHTTPRequest Delegate Methods

- (void)requestFinished:(ASIHTTPRequest *)request{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    loadingMore = false;
    if (request.responseStatusCode != 200){
        [NinaHelper handleBadRequest:request sender:self];
        return;
    }
    
    switch (request.tag){
        case 11:
        {
            self.user.following = [NSNumber numberWithBool:true];
            [self toggleFollow];
            break;
        }
            
        case 12:
        {
            DLog(@"Image request finished");
            // Get data and convert to image
            NSData *responseData = [request responseData];
            UIImage *newImage = [UIImage imageWithData:responseData];
            
            self.profileImageView.image = newImage;
        }
        case 15:
        {
            self.user.following = false;
            [self toggleFollow];
            break;
        }
    }

}

-(void) toggleFollow{
    
    if ( [self.user.following boolValue] || [self.username isEqualToString:[NinaHelper getUsername]] ){        
        self.followButton.enabled = true;
        self.followButton.tag = 1;
        [self.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        [StyleHelper styleUnFollowButton:self.followButton];
        
    } else {
        self.followButton.enabled = true;        
        self.followButton.tag = 0;
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        [StyleHelper styleFollowButton:self.followButton];
    }
    
    
    if ([self.username isEqualToString:[NinaHelper getUsername]]){
        self.followButton.hidden = TRUE;
    } else {
        self.followButton.hidden = FALSE;
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    [NinaHelper handleBadRequest:request sender:self];
}



- (void)expandAtIndexPath:(NSIndexPath*)indexPath{
    [expandedIndexPaths addObject:indexPath];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark Tableview Methods

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{    
    //a visible perspective row PerspectiveTableViewCell
    if (( !self.user.username || self.user.username.length == 0) && (!self.username || self.username.length == 0)) {
        return 100;
    } else {
        if ((perspectives) && [perspectives count] == 0) {
            return 70;
        } else if (indexPath.row >= [perspectives count]){
            return 44;
        } else {
            Perspective *perspective;
            perspective = [perspectives objectAtIndex:indexPath.row];
            
            if( [expandedIndexPaths member:indexPath]){  
                return [PerspectiveTableViewCell cellHeightUnboundedForPerspective:perspective];
            } else {
                return [PerspectiveTableViewCell cellHeightForPerspective:perspective];
            }
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ( (!self.user.username || self.user.username.length == 0) && (!self.username || self.username.length == 0)) {
        return 1;
    } else {
        if (perspectives) {
            if (loadingMore){   
                return [perspectives count] +1;
            }else{
                return [perspectives count];
            }
        } else {
            return 1;
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *perspectiveCellIdentifier = @"Cell";
    static NSString *loginCellIdentifier = @"LoginCell";
    static NSString *noActivityCellIdentifier = @"NoActivityCell";
    
    UITableViewCell *cell;
    
    if ((self.user.username == (id)[NSNull null] || self.user.username.length == 0) && (self.username == (id)[NSNull null] || self.username.length == 0)) {
        cell = [tableView dequeueReusableCellWithIdentifier:loginCellIdentifier];
    } else if ((perspectives) && [perspectives count] == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:noActivityCellIdentifier];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:perspectiveCellIdentifier];
    }
    
    if ((perspectives) && [perspectives count] == 0) {
        tableView.allowsSelection = NO;
    } else {
        tableView.allowsSelection = YES;
    }
    
    if (cell == nil) {
        if ((self.user.username == (id)[NSNull null] || self.user.username.length == 0) && (self.username == (id)[NSNull null] || self.username.length == 0)) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:loginCellIdentifier] autorelease];
            
            cell.detailTextLabel.text = @"";
            cell.textLabel.text = @"";
            
            UITextView *unregisteredText = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 80)];
            
            unregisteredText.text = @"Sign up or log in to get your own profile and see places you recently placemarked.\n\nTap here to get started.";
            
            
            unregisteredText.font = [UIFont fontWithName:@"Helvetica" size:14.0];
            [unregisteredText setUserInteractionEnabled:NO];
            [unregisteredText setBackgroundColor:[UIColor clearColor]];
            
            unregisteredText.tag = 778;
            [cell addSubview:unregisteredText];
            [unregisteredText release];
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        } else if ((perspectives) && [perspectives count] == 0) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:noActivityCellIdentifier] autorelease];
            
            cell.detailTextLabel.text = @"";
            cell.textLabel.text = @"";
            
            UITextView *errorText = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 50)];
            
            if ([self.username isEqualToString:[NinaHelper getUsername]]) {
                errorText.text = @"You haven't bookmarked any places yet";
            } else {
                errorText.text = [NSString stringWithFormat:@"%@ hasn't bookmarked any places yet", self.username];
            }

            errorText.font = [UIFont fontWithName:@"Helvetica" size:14.0];
            [errorText setUserInteractionEnabled:NO];
            [errorText setBackgroundColor:[UIColor clearColor]];
            
            errorText.tag = 778;
            [cell addSubview:errorText];
            [errorText release];

            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
            
        } else if ( indexPath.row >= [perspectives count] ){
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SpinnerTableCell" owner:self options:nil];
            
            for(id item in objects){
                if ( [item isKindOfClass:[UITableViewCell class]]){
                    cell = item;
                }
            }      
        } else {
            Perspective *perspective = [perspectives objectAtIndex:indexPath.row];
            
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PerspectiveTableViewCell" owner:self options:nil];
            
            for(id item in objects){
                if ( [item isKindOfClass:[UITableViewCell class]]){
                    PerspectiveTableViewCell *pcell = (PerspectiveTableViewCell *)item;
                    pcell.indexpath = indexPath;
                    pcell.requestDelegate = self;
                    if( [expandedIndexPaths member:indexPath]){  
                        pcell.expanded = true;
                    }
                    
                    [PerspectiveTableViewCell setupCell:pcell forPerspective:perspective userSource:true];
                    cell = pcell;
                    break;
                }
            }    
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ((self.user.username == (id)[NSNull null] || self.user.username.length == 0) && (self.username == (id)[NSNull null] || self.username.length == 0)) {
        LoginController *loginController = [[LoginController alloc] init];
        loginController.delegate = self;
        
        UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:loginController];
        [self.navigationController presentModalViewController:navBar animated:YES];
        [navBar release];
        [loginController release];
    } else if (indexPath.row < [perspectives count]){ 
        //in case some jackass tries to click the spin wait
        Perspective *perspective = [perspectives objectAtIndex:indexPath.row];
        PlacePageViewController *placePageViewController = [[PlacePageViewController alloc] initWithPlace:perspective.place];
        if ( ![self.user.username isEqualToString:[NinaHelper getUsername]] ){
            placePageViewController.initialSelectedIndex = [NSNumber numberWithInt:2];
            placePageViewController.referrer = self.user.username;
        }
        [[self navigationController] pushViewController:placePageViewController animated:YES];
        [placePageViewController release];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
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
        
        NSString *targetURL = [NSString stringWithFormat:@"/v1/users/%@/perspectives?start=%i", self.username, [perspectives count]];
        
        [objectManager loadObjectsAtResourcePath:targetURL delegate:self block:^(RKObjectLoader* loader) {        
            loader.userData = [NSNumber numberWithInt:14]; //use as a tag
        }];
        
        [self.tableView reloadData];
    }
}



- (void)dealloc{
    [NinaHelper clearActiveRequests:10];
    [[[[RKObjectManager sharedManager] client] requestQueue] cancelRequestsWithDelegate:self];
    [username release];
    [_user release];
    [perspectives release];
    [locationLabel release];
    [profileImageView release];
    [usernameLabel release];
    [userDescriptionLabel release];
    [followButton release];
    [expandedIndexPaths release];
    
    [super dealloc];
}

@end
