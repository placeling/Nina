//
//  CreateSuggestionViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 12-08-15.
//
//

#import "CreateSuggestionViewController.h"
#import "UIImageView+WebCache.h"

@interface CreateSuggestionViewController ()
-(void)close;
-(void)send;

@end

@implementation CreateSuggestionViewController

@synthesize place, tableView=_tableView, textView, textField=_textField, suggestedUsers, user=_user, cancelButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.suggestedUsers = [[[NSMutableArray alloc]init]autorelease];
        loading = false;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableView setHidden:true];
    [self.view setHidden:false];
    
    [self.textField becomeFirstResponder];
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.textView setPlaceholder:@"Why do you suggest this place?"];
    
    self.navigationItem.title = self.place.name;
    
    UIBarButtonItem *button =  [[UIBarButtonItem  alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    self.navigationItem.leftBarButtonItem = button;
    [button release];
    
    UIBarButtonItem *sendButton =  [[UIBarButtonItem  alloc]initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(send)];
    self.navigationItem.rightBarButtonItem = sendButton;
    [sendButton release];
    
    [self.cancelButton setHidden:true];
    
    [StyleHelper styleBackgroundView:self.view];
    
}


-(IBAction)clearUser{
    self.user = nil;
    [self.textField setEnabled:true];
    [self.textField setBackgroundColor:[UIColor whiteColor]];
    self.textField.text = @"";
    [self.textField becomeFirstResponder];
    [self.cancelButton setHidden:true];
}

-(void)close{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)send{
    if ( self.user ){
        //sending the place
        [self.textField resignFirstResponder];
        [self.textView resignFirstResponder];
        
        Suggestion *suggestion = [[Suggestion alloc] init];
        
        suggestion.message = self.textView.text;
        suggestion.receiver = self.user;
        suggestion.place = self.place;
        
        [[RKObjectManager sharedManager] postObject:suggestion usingBlock:^(RKObjectLoader *loader){
            loader.delegate = self;
            loader.userData = [NSNumber numberWithInt:141]; //use as a tag
        }];
        
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        // Set determinate mode
        HUD.labelText = @"Sending...";
        [HUD retain];
        [suggestion release];
        
        
    } else {
        //validation tells user to give a damn recipient
        UIAlertView *baseAlert;
        NSString *alertMessage =  @"Please select a user to send suggestion to";
        
        baseAlert = [[UIAlertView alloc]
                     initWithTitle:nil message:alertMessage
                     delegate:self cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
        
        [baseAlert show];
        [baseAlert release];
    }
    
}

-(void)hudWasHidden{
    [HUD release];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [StyleHelper styleBackgroundView:self.view];
    [StyleHelper styleBackgroundView:self.tableView];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldDidChange:(UITextField *)textfield{
    if ( [textfield.text length] >= 2){
        [self.tableView setHidden:false];
        RKObjectManager* objectManager = [RKObjectManager sharedManager];
        
        NSString *targetURL = [NSString stringWithFormat:@"/v1/suggestions/user_search?query=%@", textfield.text];
        
        [objectManager loadObjectsAtResourcePath:targetURL usingBlock:^(RKObjectLoader* loader) {
            loader.cacheTimeoutInterval = 60*5;
            loader.userData = [NSNumber numberWithInt:140]; //use as a tag
            loader.delegate = self;
        }];
        loading = true;
    } else {
        [self.tableView setHidden:true];
        [self.tableView  performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:TRUE];
    }
    return true;
}


#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    loading = false;
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    if ( [(NSNumber*)objectLoader.userData intValue] == 140 ){
        [self.suggestedUsers removeAllObjects];
        for (NSObject* object in objects){
            [self.suggestedUsers addObject:object];
        }
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 141 ){
        [self close];
    }
    [self.tableView reloadData];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [NinaHelper handleBadRKRequest:objectLoader.response sender:self];
    DLog(@"Encountered an error: %@", error);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return MAX([self.suggestedUsers count], 1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
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
        
    }else if ( [self.suggestedUsers count] ==0 ){
        
        cell = [tableView dequeueReusableCellWithIdentifier:InfoCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:InfoCellIdentifier] autorelease];
        }
        
        cell.textLabel.textColor = [UIColor grayColor];
        if ([self.textField.text length] > 0){
            cell.textLabel.text = [NSString stringWithFormat:@"No user called %@", self.textField.text];
        } else {
            cell.textLabel.text = @"No locals yet";
        }
        [cell setUserInteractionEnabled:NO];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        User *user = [self.suggestedUsers objectAtIndex:indexPath.row];
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
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    if ([self.suggestedUsers count] > indexPath.row){
        User *user = [self.suggestedUsers objectAtIndex:indexPath.row];
        self.user = user;
        self.textField.text = user.username;
        [self.textField setBackgroundColor:[UIColor clearColor]];
        self.textField.enabled = false;
        [self.cancelButton setHidden:false];
        [self.tableView setHidden:true];
        [self.textView becomeFirstResponder];
        
    }
    
}


-(void)dealloc{
    [[[[RKObjectManager sharedManager] client] requestQueue] cancelRequestsWithDelegate:self];
    [place release];
    [_tableView release];
    [textView release];
    [_textField release];
    [_user release];
    [suggestedUsers release];
    [cancelButton release];
    
    [super dealloc];
}

@end
