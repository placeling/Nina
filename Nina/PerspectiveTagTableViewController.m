//
//  PerspectiveTagTableViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 12-05-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PerspectiveTagTableViewController.h"
#import "Place.h"
#import "User.h"
#import "Perspective.h"
#import "NinaHelper.h"
#import "UIImageView+WebCache.h"
#import "TDBadgedCell.h"


@interface PerspectiveTagTableViewController()
-(void) close;
@end

@implementation PerspectiveTagTableViewController

@synthesize places=_places, tags, perspectiveTally, delegate;

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
    [delegate setTagFilter:nil];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}


-(void) dealloc{
    [perspectiveTally release];
    [_places release];
    [super dealloc];
}


#pragma mark - View lifecycle
-(void) refreshTable{
    NSMutableArray *unsortedTags = [[[NSMutableArray alloc] init] autorelease];
    self.perspectiveTally = [[[NSMutableDictionary alloc] init] autorelease];
    
    for (Place *place in self.places){
        for (Perspective *perspective in place.placemarks){
            if (perspective.hidden == true){ continue; }
            
            for (NSString *tag in perspective.tags){
                DLog(@"checking tag %@", tag);
                
                bool found = false;
                
                for (NSString *prevTag in unsortedTags){
                    if ( [tag isEqualToString:prevTag] ){
                        found = true;
                        break;
                    }
                }
                
                if (!found){
                    [unsortedTags addObject:tag];
                    [self.perspectiveTally setObject:[NSNumber numberWithInt:1] forKey:tag];
                } else {
                    NSNumber *tally = [self.perspectiveTally objectForKey:tag];
                    tally = [NSNumber numberWithInt:[tally intValue]+ 1];
                    [self.perspectiveTally setObject:tally forKey:tag];
                }
            }
        }
    }
    
    self.tags = [unsortedTags sortedArrayUsingComparator :^(id a, id b) {
        NSString *first = (NSString*)a;
        NSString *second = (NSString*)b;
        NSNumber *firstTally = [self.perspectiveTally objectForKey:first];
        NSNumber *secondTally = [self.perspectiveTally objectForKey:second];
        
        int tally = [secondTally compare:firstTally];
        
        if (tally == 0){
            //same count, so go alphabetical
            tally = [first.lowercaseString compare:second.lowercaseString];
        }
        return tally;
    }];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad{
    [super viewDidLoad];    
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
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
    
    self.navigationItem.title = @"Filter by Tags";
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
    return MAX([self.tags count], 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;    
    static NSString *CellIdentifier = @"Cell";
    static NSString *textCellIdentifier = @"infoCell";
    
    if ( [self.tags count] == 0){
        UITableViewCell *pCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (pCell == nil) {
            pCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:textCellIdentifier] autorelease];
        }
        [pCell.textLabel setFont:[UIFont systemFontOfSize:12]];
        pCell.textLabel.textAlignment = UITextAlignmentCenter;
        pCell.textLabel.text = @"No places around here have a #hashtag yet";
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
        NSString* tag = [tags objectAtIndex:indexPath.row];
        
        pCell.textLabel.text = [NSString stringWithFormat:@"#%@", tag];
        pCell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        
        pCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSNumber *tally = [self.perspectiveTally objectForKey:tag];
        pCell.badgeString = [tally stringValue];
        
        pCell.imageView.contentMode = UIViewContentModeScaleToFill;
        // Here we use the new provided setImageWithURL: method to load the web image
        
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
    
    [delegate setTagFilter: [self.tags objectAtIndex:indexPath.row] ];
    
    [self dismissModalViewControllerAnimated:TRUE];
}
@end
