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
#import "JSON.h"
#import "UIImageView+WebCache.h"

@interface FriendFindController ()
-(BOOL) searchResults;
@end


@implementation FriendFindController
@synthesize searchUsers, suggestedUsers, recentSearches;
@synthesize searchBar=_searchBar, tableView=_tableView;



-(BOOL) searchResults{
    return (showSearchResults);
}

-(void) dealloc {
    [searchUsers release];
    [suggestedUsers release];
    [NinaHelper clearActiveRequests:100];
    [_searchBar release];
    [_tableView release];
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
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    for (int i=0; i< 3; i++){
        if ([prefs dictionaryForKey:[NSString stringWithFormat:@"recent_search_%i", i]]){
            NSDictionary *jsonDict = [prefs dictionaryForKey:[NSString stringWithFormat:@"recent_search_%i", i]];
            User *user = [[User alloc] initFromJsonDict:jsonDict];
            [self.recentSearches addObject:user];
            [user release];
        }
    }

    CLLocationManager *manager = [LocationManagerManager sharedCLLocationManager];
    CLLocationCoordinate2D location = [manager location].coordinate;
	
	NSString *targetURL = [NSString stringWithFormat:@"%@/v1/users/suggested?lat=%f&lng=%f", [NinaHelper getHostname], location.latitude, location.longitude];
    
    NSURL *url = [NSURL URLWithString:targetURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [NinaHelper signRequest:request];
    [request setTag:100];
    [request setDelegate:self];
    [request startAsynchronous];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
}

-(void) viewWillAppear:(BOOL)animated{
    [StyleHelper styleSearchBar:self.searchBar];
    [super viewWillAppear:animated];
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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *targetURL = [NSString stringWithFormat:@"%@/v1/users/search?q=%@", [NinaHelper getHostname], searchBar.text];
    
    NSURL *url = [NSURL URLWithString:targetURL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [NinaHelper signRequest:request];
    [request setTag:101];
    [request setDelegate:self];
    [request startAsynchronous];
    
    [searchBar resignFirstResponder];
    
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ( [self.searchBar.text length] >= 2){
        showSearchResults = true;
        NSString *targetURL = [NSString stringWithFormat:@"%@/v1/users/search?q=%@", [NinaHelper getHostname], [NinaHelper encodeForUrl:searchText]];
        
        NSURL *url = [NSURL URLWithString:targetURL];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [NinaHelper signRequest:request];
        [request setTag:101];
        [request setDelegate:self];
        [request startAsynchronous];
    } else {
        showSearchResults = false;
        [self.tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
	[searchBar setShowsCancelButton:TRUE animated:true];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
	[searchBar setShowsCancelButton:FALSE animated:true];
}

- (void)requestFailed:(ASIHTTPRequest *)request{
	[NinaHelper handleBadRequest:request sender:self];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (200 != [request responseStatusCode]){
		[NinaHelper handleBadRequest:request sender:self];
	} else {
        switch( [request tag] ){
            case 100:{                
                NSString *responseString = [request responseString];
                DLog(@"%@", responseString);

                NSArray *rawUsers = [[responseString JSONValue] objectForKey:@"suggested"];
                [self.suggestedUsers removeAllObjects];
                for (NSDictionary* rawUser in rawUsers){
                    User *user = [[User alloc] initFromJsonDict:rawUser];
                    [self.suggestedUsers addObject:user];
                    [user release];
                }
                [self.tableView reloadData];                
                break;
            }
            case 101:{
                NSString *responseString = [request responseString];
                DLog(@"%@", responseString);
                
                NSArray *rawUsers = [[responseString JSONValue] objectForKey:@"users"];
                [self.searchUsers removeAllObjects];
                
                for (NSDictionary* rawUser in rawUsers){
                    User *user = [[User alloc] initFromJsonDict:rawUser];
                    [self.searchUsers addObject:user];
                    [user release];
                }
                
                [self.tableView reloadData];                
                break;
            }
        }
	}
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
            return [self.suggestedUsers count];
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
        cell.detailTextLabel.text = user.description;
        
        cell.accessoryView.tag = indexPath.row;
        
        cell.imageView.contentMode = UIViewContentModeScaleToFill;
        // Here we use the new provided setImageWithURL: method to load the web image
        [cell.imageView setImageWithURL:[NSURL URLWithString:user.profilePic.thumb_url]
                       placeholderImage:[UIImage imageNamed:@"profile.png"]];
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
            cell.textLabel.text = [NSString stringWithFormat:@"No user called %@", self.searchBar.text];
            [cell setUserInteractionEnabled:NO];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {    
            User *user = [members objectAtIndex:indexPath.row];
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.textLabel.text = user.username;
            cell.detailTextLabel.text = user.description;
            
            cell.accessoryView.tag = indexPath.row;
            
            cell.imageView.contentMode = UIViewContentModeScaleToFill;
            // Here we use the new provided setImageWithURL: method to load the web image
            [cell.imageView setImageWithURL:[NSURL URLWithString:user.profilePic.thumb_url]
                           placeholderImage:[UIImage imageNamed:@"profile.png"]];
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    User *user;
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
                    [jsonDict setValue:ruser.description forKey:@"description"];
                    [jsonDict setValue:ruser.profilePic.thumb_url forKey:@"thumb_url"];
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
