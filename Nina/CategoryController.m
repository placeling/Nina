//
//  CategoryController.m
//  Nina
//
//  Created by Ian MacKinnon on 12-05-09.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CategoryController.h"

@implementation CategoryController
@synthesize categories, delegate, sortedKeys, selectedCategory, newPlaceController;

-(id)initWithCategory:(NSDictionary*)category {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.categories = category;
    }
    return self;
}

-(void)dealloc{
    [categories release];
    [sortedKeys release];
    [selectedCategory release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.sortedKeys = [[self.categories allKeys] sortedArrayUsingSelector:@selector(compare:)];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [StyleHelper styleInfoView:self.view];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) updateCategory:(NSString *)category{
    if (self.selectedCategory){
       [self.delegate updateCategory:[NSString stringWithFormat:@"%@ - %@", self.selectedCategory, category]]; 
    } else {
        [self.delegate updateCategory:category];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if ( [[self.categories objectForKey:[self.sortedKeys objectAtIndex:0]] isKindOfClass:[NSString class] ] ){
        return @"Pick Sub-Category";
    } else {
        return @"Pick Category";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    [StyleHelper styleGenericTableCell:cell];
    cell.textLabel.text = [self.sortedKeys objectAtIndex:indexPath.row]; 
    
    if ( ![[self.categories objectForKey:[self.sortedKeys objectAtIndex:indexPath.row]] isKindOfClass:[NSString class] ] ){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    if ( [[self.categories objectForKey:[self.sortedKeys objectAtIndex:indexPath.row]] isKindOfClass:[NSString class] ] ){
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.delegate updateCategory:[self.sortedKeys objectAtIndex:indexPath.row]];
        [self.navigationController popToViewController:newPlaceController animated:true];
        
    } else {
        self.selectedCategory = [self.sortedKeys objectAtIndex:indexPath.row];
        CategoryController *categoryController = [[CategoryController alloc] initWithCategory:[self.categories objectForKey:[self.sortedKeys objectAtIndex:indexPath.row]]];
        categoryController.delegate = self;
        categoryController.newPlaceController = self.newPlaceController;
        [self.navigationController pushViewController:categoryController animated:true];
        [categoryController release];    
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
}

@end
