//
//  QuestionListViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 12-08-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuestionListViewController.h"

@interface QuestionListViewController ()
-(void)findNearbyQuestions;
@end

@implementation QuestionListViewController

@synthesize tableView=_tableView, questions, dataLoaded, origin;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.questions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self findNearbyQuestions];
    self.navigationItem.title = @"Questions";
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [StyleHelper styleNavigationBar:self.navigationController.navigationBar];
    [StyleHelper styleBackgroundView:self.tableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) loadContent{
    [self findNearbyQuestions];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)findNearbyQuestions {
    
    if ( origin.latitude == 0.0 && origin.longitude == 0.0 ){
        CLLocationManager *manager = [LocationManagerManager sharedCLLocationManager];
        CLLocation *location = manager.location;
        
        if (![CLLocationManager  locationServicesEnabled] || !location){
            self.dataLoaded = true;
            
            DLog(@"UNABLE TO GET CURRENT LOCATION FOR NEARBY");
            return;
        }
        
        self.origin = location.coordinate;
    }       
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    NSString *requestUrl = [NSString stringWithFormat:@"/v1/questions?lat=%f&lng=%f", origin.latitude, origin.longitude];
    
    self.dataLoaded = false;
    
    [objectManager loadObjectsAtResourcePath:requestUrl usingBlock:^(RKObjectLoader* loader) {
        loader.userData = [NSNumber numberWithInt:120];
        loader.delegate = self;
    }];
}


#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    self.dataLoaded = true;
    if ( [(NSNumber*)objectLoader.userData intValue] == 120 ){
        [self.questions removeAllObjects];
        for (NSObject* object in objects){
            [self.questions addObject:object];
        }
    } 
    [self.tableView reloadData];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    self.dataLoaded = true;
    [NinaHelper handleBadRKRequest:objectLoader.response sender:self];
    DLog(@"Encountered an error: %@", error); 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ( dataLoaded ){
        return [[self questions] count];
    } else {
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{    
    return 70;        
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *questionCellIdentifier = @"QuestionCell";
    
    Question *question;
    UITableViewCell *cell;
    
    if (indexPath.row ==0 && ![self dataLoaded]){
        //spinner wait, don't actually recycle
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SpinnerTableCell" owner:self options:nil];
        
        for(id item in objects){
            if ( [item isKindOfClass:[UITableViewCell class]]){
                cell = item;
                break;
            }
        }    
        
    } else {
        UITableViewCell *pCell;
        pCell = [tableView dequeueReusableCellWithIdentifier:questionCellIdentifier];
        if (pCell == nil){
            pCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:questionCellIdentifier] autorelease];
        }
        question = [[self questions] objectAtIndex:indexPath.row];

        [pCell.imageView setImage:[UIImage imageNamed:@"QuestionLightbulb.png"]];
        
        
        pCell.textLabel.text = question.title;
        //pCell.addressLabel.text = question.description;
        //[StyleHelper styleQuickPickCell:pCell]; 
        
        cell = pCell;
    }   
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
}



-(void) dealloc{
    [[[[RKObjectManager sharedManager] client] requestQueue] cancelRequestsWithDelegate:self];
    [questions release];
    [_tableView release];
    
    [super dealloc];
}


@end
