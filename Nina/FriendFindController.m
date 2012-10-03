//
//  FriendFindController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-11-22.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FriendFindController.h"
#import "User.h"
#import "MemberProfileViewController.h"
#import "SBJson.h"
#import "UIImageView+WebCache.h"
#import "Photo.h"
#import "FlurryAnalytics.h"
#import "FindFacebookFriendsController.h"

@interface FriendFindController ()
-(BOOL) searchResults;
-(void) performUsernameSearch:(NSString*) username;
-(IBAction)showInviteSheet;
@end


@implementation FriendFindController
@synthesize searchUsers, suggestedUsers, recentSearches;
@synthesize searchBar=_searchBar, tableView=_tableView, toolbar=_toolbar;


-(BOOL) searchResults{
    return (showSearchResults);
}

-(void) dealloc {
    [[[[RKObjectManager sharedManager] client] requestQueue] cancelRequestsWithDelegate:self];
    [searchUsers release];
    [suggestedUsers release];;
    [_searchBar release];
    [_tableView release];
    [_toolbar release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];

    showSearchResults = false;
    self.navigationItem.title = @"Find People";
    self.searchBar.delegate = self;
    self.suggestedUsers = [[[NSMutableArray alloc]init] autorelease];
    self.searchUsers = [[[NSMutableArray alloc]init]autorelease];
    self.recentSearches = [[[NSMutableArray alloc]init]autorelease];
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    //NSManagedObjectContext *managedObjectContext = objectManager.objectStore.managedObjectContext;
    
    UIBarButtonItem *shareButton =  [[UIBarButtonItem  alloc]initWithTitle:@"Invite Friend" style:UIBarButtonItemStylePlain target:self action:@selector(showInviteSheet)];
    self.navigationItem.rightBarButtonItem = shareButton;
    [shareButton release];
    
    [FlurryAnalytics logEvent:@"FIND_FRIEND_VIEW"];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    for (int i=0; i< 3; i++){
        if ([prefs dictionaryForKey:[NSString stringWithFormat:@"recent_search_%i", i]]){
            NSDictionary *jsonDict = [prefs dictionaryForKey:[NSString stringWithFormat:@"recent_search_%i", i]];
            //User *user = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
            User *user = [[User alloc] init];
            
            [user updateFromJsonDict:jsonDict];
            [self.recentSearches addObject:user];
            [user release];
        }
    }

    CLLocationManager *manager = [LocationManagerManager sharedCLLocationManager];
    CLLocationCoordinate2D location = [manager location].coordinate;
    
    loading = true;
    NSString *targetURL = [NSString stringWithFormat:@"/v1/users/suggested?lat=%f&lng=%f", location.latitude, location.longitude];    
    
    [objectManager loadObjectsAtResourcePath:targetURL usingBlock:^(RKObjectLoader* loader) {
        loader.cacheTimeoutInterval = 60*60;
        loader.delegate = self;
        loader.userData = [NSNumber numberWithInt:100]; //use as a tag
    }];
    
}

-(void) viewWillAppear:(BOOL)animated{
    [StyleHelper styleSearchBar:self.searchBar];
    [StyleHelper styleBackgroundView:self.tableView];
    [StyleHelper styleToolBar:self.toolbar];
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) performUsernameSearch:(NSString*) username{
    RKObjectManager* objectManager = [RKObjectManager sharedManager];

    NSString *targetURL = [NSString stringWithFormat:@"/v1/users/search?q=%@", username];
    
    [objectManager loadObjectsAtResourcePath:targetURL usingBlock:^(RKObjectLoader* loader) {
        loader.cacheTimeoutInterval = 60*5;
        loader.userData = [NSNumber numberWithInt:101]; //use as a tag
        loader.delegate = self;
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self performUsernameSearch:self.searchBar.text];
    [searchBar resignFirstResponder];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ( [self.searchBar.text length] >= 2){
        showSearchResults = true;
        [self performUsernameSearch:self.searchBar.text];
    } else {
        showSearchResults = false;
        [self.tableView  performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:TRUE];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [self.tableView  performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:TRUE];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
	[searchBar setShowsCancelButton:TRUE animated:true];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
	[searchBar setShowsCancelButton:FALSE animated:true];
}


-(IBAction)findFacebookFriends{
    NSString *currentUser = [NinaHelper getUsername];
    
    if ( !currentUser  ) {
        UIAlertView *baseAlert;
        NSString *alertMessage =  @"Sign up or log in to see your\nFacebook friends who are on Placeling";
        
        baseAlert = [[UIAlertView alloc] 
                     initWithTitle:nil message:alertMessage 
                     delegate:self cancelButtonTitle:@"Not Now" 
                     otherButtonTitles:@"Let's Go", nil];
        baseAlert.tag = 0;
        
        [baseAlert show];
        [baseAlert release];
    } else {
        
        if (FBSession.activeSession.isOpen) {
            [FlurryAnalytics logEvent:@"Facebook_friend_finder"];
            FindFacebookFriendsController *findFacebookFriendsController = [[FindFacebookFriendsController alloc] init];
            
            [self.navigationController pushViewController:findFacebookFriendsController animated:true];
            [findFacebookFriendsController release];
        } else {
            [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObjects:@"email", @"publish_actions", nil] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:TRUE completionHandler:^(FBSession *session,
                                                                                                                                                                                                                  FBSessionState state, NSError *error) {
                FindFacebookFriendsController *findFacebookFriendsController = [[FindFacebookFriendsController alloc] init];
                
                [self.navigationController pushViewController:findFacebookFriendsController animated:true];
                [findFacebookFriendsController release];
                
            }];
        
        }    
    }
    
}

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    loading = false;
    if ( [(NSNumber*)objectLoader.userData intValue] == 100){
        [self.suggestedUsers removeAllObjects];
        for (User* user in objects){
            [self.suggestedUsers addObject:user];
        }
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 101){
        [self.searchUsers removeAllObjects];
        
        for (User* user in objects){
            [self.searchUsers addObject:user];
        }
    }
    
    [self.tableView  performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:TRUE];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [NinaHelper handleBadRKRequest:objectLoader.response sender:self];
    DLog(@"Encountered an error: %@", error); 
}


-(IBAction)showInviteSheet{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Invite Friend by Email", nil];
    
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *currentUser = [NinaHelper getUsername];
    
    if (buttonIndex == 0){
        DLog(@"Invite Friends by Email");
        
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:@"Join me on Placeling"];
        
        NSString *message;
        
        if ( currentUser ){
            message = [NSString stringWithFormat:@"I'm using Placeling to discover new places around me - and I want to share them with you.<br/><br/>You can download Placeling at:<br/><a href=\"http://www.placeling.com\">http://www.placeling.com</a><br/><br/>You can see my places by following me. My username is \"%@\", and you can see my placees on the web at <a href='http://www.placeling.com/%@'>http://www.placeling.com/%@</a>", currentUser, currentUser, currentUser];
            
                        
        } else {
            message = [NSString stringWithFormat:@"I'm using Placeling to discover new places around me - and I want to share them with you.<br/><br/>You can download Placeling at:<br/><a href=\"http://www.placeling.com\">http://www.placeling.com</a>"];
        }
        
        [controller setMessageBody:message isHTML:TRUE];
        
        if (controller) [self presentModalViewController:controller animated:YES];
        [controller release];	
        
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{

    if (result == MFMailComposeResultSaved || result == MFMailComposeResultSent){
        [FlurryAnalytics logEvent:@"MAIL_INVITE_SENT_LINDSAY_RIGHT"];
    }
	[self dismissModalViewControllerAnimated:YES];
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

-(void)loadContent{
    //required to be a login controller delegate
    [self findFacebookFriends];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections
    if ([self searchResults]){
        return 1;
    } else {
        return 2;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Number of rows on screen
    if (tableView.numberOfSections == 2){
        if (section == 0){
            return [self.recentSearches count];
        }else {
            return MAX([self.suggestedUsers count], 1);
        }
    }else {
        return MAX([self.searchUsers count], 1); //in "1" case we have a memo
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView.numberOfSections == 2){
        if (section == 0 && [self.recentSearches count] > 0){
            return @"Recent Searches";
        }else if (section ==1) {
            return @"Top Locals";
        }else{ 
            return nil;
        }
    }else {
        return nil;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    static NSString *InfoCellIdentifier = @"InfoCell";
    
    UITableViewCell *cell;
    if (tableView.numberOfSections == 2 && indexPath.section==0){
        User *user = [self.recentSearches objectAtIndex:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        
        cell.textLabel.text = user.username;
        cell.detailTextLabel.text = user.userDescription;
        
        cell.accessoryView.tag = indexPath.row;
        
        cell.imageView.contentMode = UIViewContentModeScaleToFill;
        // Here we use the new provided setImageWithURL: method to load the web image
        [cell.imageView setImageWithURL:[NSURL URLWithString:user.profilePic.thumbUrl]
                       placeholderImage:[UIImage imageNamed:@"DefaultUserPhoto.png"]];
        [cell.imageView.layer setBorderColor:[UIColor whiteColor].CGColor];
        [cell.imageView.layer setBorderWidth:2.0];
        [StyleHelper styleGenericTableCell:cell];
        
    }else if ( tableView.numberOfSections == 2 && indexPath.section == 1 && loading ){
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SpinnerTableCell" owner:self options:nil];
        
        for(id item in objects){
            if ( [item isKindOfClass:[UITableViewCell class]]){
                cell = item;
            }
        }    
            
    }else {
        NSArray *members;
        if ([self searchResults]){
            members = self.searchUsers;
        } else {
            members = self.suggestedUsers;
        }
        
        if (indexPath.row ==0 && [members count] ==0){
            
            cell = [tableView dequeueReusableCellWithIdentifier:InfoCellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:InfoCellIdentifier] autorelease];
            }
            
            cell.textLabel.textColor = [UIColor grayColor];
            if ([self.searchBar.text length] > 0){
                cell.textLabel.text = [NSString stringWithFormat:@"No user called %@", self.searchBar.text];
            } else {
                cell.textLabel.text = @"No locals yet";
            }
            [cell setUserInteractionEnabled:NO];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {    
            User *user = [members objectAtIndex:indexPath.row];
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.textLabel.text = user.username;
            cell.detailTextLabel.text = user.userDescription;
            
            cell.accessoryView.tag = indexPath.row;
            
            [cell.imageView.layer setBorderColor:[UIColor whiteColor].CGColor];
            [cell.imageView.layer setBorderWidth:2.0];
            cell.imageView.contentMode = UIViewContentModeScaleToFill;
            // Here we use the new provided setImageWithURL: method to load the web image
            [cell.imageView setImageWithURL:[NSURL URLWithString:user.profilePic.thumbUrl]
                           placeholderImage:[UIImage imageNamed:@"DefaultUserPhoto.png"]];
            [StyleHelper styleGenericTableCell:cell];
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    User *user;
    
    [FlurryAnalytics logEvent:@"FIND_FRIEND_VIEW_USER_CLICK"];
    
    if (tableView.numberOfSections==1 && indexPath.section ==0){
        user = [self.searchUsers objectAtIndex:indexPath.row];
        
        BOOL exists = false;
        for( User *suser in self.recentSearches){
            if ([suser.username isEqualToString:user.username]){
                exists = true;
            }
        }
        if (!exists){
            [self.recentSearches insertObject:user atIndex:0];
        }
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        
        if (standardUserDefaults) {
            for (int i=0; i< 3; i++){
                if (i < [self.recentSearches count]){
                    User *ruser = [self.recentSearches objectAtIndex:i];
                    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
                    [jsonDict setValue:ruser.username forKey:@"username"];
                    [jsonDict setValue:ruser.userDescription forKey:@"description"];
                    [jsonDict setValue:ruser.profilePic.thumbUrl forKey:@"thumb_url"];
                    [standardUserDefaults setObject:jsonDict forKey:[NSString stringWithFormat:@"recent_search_%i", i]];
                    [jsonDict release];                    
                }
            }
            
            [standardUserDefaults synchronize];
        }
        
    } else if (tableView.numberOfSections ==2 && indexPath.section == 0){        
        user = [self.recentSearches objectAtIndex:indexPath.row];
    } else{// if (tableView.numberOfSections ==2 && indexPath.section == 1){        
        user = [self.suggestedUsers objectAtIndex:indexPath.row];
    }
    
    MemberProfileViewController *memberProfileViewController = [[MemberProfileViewController alloc] init];
    memberProfileViewController.user = user;
    [self.navigationController pushViewController:memberProfileViewController animated:YES];
    [memberProfileViewController release];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
