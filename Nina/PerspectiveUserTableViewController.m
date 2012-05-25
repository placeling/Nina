//
//  PerspectiveUserTableViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 12-01-15.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PerspectiveUserTableViewController.h"
#import "Place.h"
#import "User.h"
#import "Perspective.h"
#import "NinaHelper.h"
#import "UIImageView+WebCache.h"
#import "TDBadgedCell.h"

@interface PerspectiveUserTableViewController()
-(void) close;
@end

@implementation PerspectiveUserTableViewController

@synthesize places=_places, users, perspectiveTally, delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithPlaces:(NSMutableArray*)newPlaces
{
    self = [super init];
    if (self) {
        self.places = newPlaces;
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


-(void)close{
    [delegate setUserFilter:nil];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}


-(void) dealloc{
    [perspectiveTally release];
    [_places release];
    [super dealloc];
}


#pragma mark - View lifecycle


-(void) refreshTable{
    NSMutableArray *unsortedUsers = [[[NSMutableArray alloc] init] autorelease];
    self.perspectiveTally = [[[NSMutableDictionary alloc] init] autorelease];
    
    for (Place *place in self.places){
        for (Perspective *perspective in place.placemarks){
            if (perspective.hidden == true){ continue; }
            
            DLog(@"%@", perspective.user.username);
            
            bool found = false;
            
            for (User *user in unsortedUsers){
                if ([user.userId isEqualToString:perspective.user.userId]){
                    found = true;
                    break;
                }
            }
            
            if (!found){
                [unsortedUsers addObject:perspective.user];
                [self.perspectiveTally setObject:[NSNumber numberWithInt:1] forKey:perspective.user.userId];
            } else {
                NSNumber *tally = [self.perspectiveTally objectForKey:perspective.user.userId];
                tally = [NSNumber numberWithInt:[tally intValue]+ 1];
                [self.perspectiveTally setObject:tally forKey:perspective.user.userId];
            }
            
        }
    }
    
    
    self.users = [unsortedUsers sortedArrayUsingComparator :^(id a, id b) {
        NSString *firstId = [(User*)a userId];
        NSString *secondId = [(User*)b userId];
        NSNumber *firstTally = [self.perspectiveTally objectForKey:firstId];
        NSNumber *secondTally = [self.perspectiveTally objectForKey:secondId];
        
        
        int tally = [secondTally compare:firstTally];
        
        if (tally == 0){
            //same count, so go alphabetical
            tally = [((User*)a).username.lowercaseString compare:((User*)b).username.lowercaseString];
        }
        return tally;
    }];
    
    [self.tableView reloadData];

}

- (void)viewDidLoad{
    [super viewDidLoad];    
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
    self.navigationItem.leftBarButtonItem = button;
    [button release];
    
    [self refreshTable];
    
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Filter by User";
    [StyleHelper styleBackgroundView:self.tableView];
    [StyleHelper styleNavigationBar:self.navigationController.navigationBar];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return MAX([self.users count], 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;    
    static NSString *CellIdentifier = @"Cell";
    static NSString *textCellIdentifier = @"infoCell";
    
    if ( [self.users count] == 0){
        UITableViewCell *pCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (pCell == nil) {
            pCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:textCellIdentifier] autorelease];
        }
        [pCell.textLabel setFont:[UIFont systemFontOfSize:12]];
        pCell.textLabel.textAlignment = UITextAlignmentCenter;
        pCell.textLabel.text = @"No one has placemarked a location around here yet";
        [StyleHelper styleGenericTableCell:pCell];
        pCell.userInteractionEnabled = false;
        self.tableView.userInteractionEnabled = false;
        cell = pCell;
    } else {        
        TDBadgedCell *pCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (pCell == nil) {
            pCell = [[[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        self.tableView.userInteractionEnabled = true;
        User* user = [users objectAtIndex:indexPath.row];
        
        pCell.textLabel.text = user.username;
        pCell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        
        pCell.detailTextLabel.text = user.userDescription;
        pCell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        
        pCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSNumber *tally = [self.perspectiveTally objectForKey:user.userId];
        pCell.badgeString = [tally stringValue];

        pCell.imageView.contentMode = UIViewContentModeScaleToFill;
        // Here we use the new provided setImageWithURL: method to load the web image
        [pCell.imageView setImageWithURL:[NSURL URLWithString:user.profilePic.thumbUrl]
                       placeholderImage:[UIImage imageNamed:@"profile.png"]];
        
        [pCell.imageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [pCell.imageView.layer setBorderWidth: 2.0];
        
        [StyleHelper styleGenericTableCell:pCell];
        cell = pCell;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    User *user = [self.users objectAtIndex:indexPath.row];
    [delegate setUserFilter:user.username];
    
    [self dismissModalViewControllerAnimated:TRUE];
}
@end
