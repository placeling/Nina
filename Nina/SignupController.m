//
//  SignupController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-09-06.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SignupController.h"
#import "NinaAppDelegate.h"
#import "EditableTableCell.h"
#import "SBJSON.h"
#import "GenericWebViewController.h"
#import "LoginController.h"
#import "PostSignupViewController.h"
#import "UserManager.h"

@implementation SignupController


@synthesize fbDict, accessKey, accessSecret, tableFooterView, tableHeaderView, termsButton, privacyButton, urlLabel, HUD, delegate;

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


-(IBAction)signup{
    DLog(@"Sending signup info");

    NSString *username = ((EditableTableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).textField.text;
    
    NSString *email;
    NSString *password;
    NSString * passwordConfirm;
    
    if (fbDict) {
        email = [fbDict objectForKey:@"email"];
    } else {
        email = ((EditableTableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).textField.text;
        password = ((EditableTableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]]).textField.text;
        passwordConfirm = ((EditableTableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]]).textField.text;
        
        if (![password isEqualToString:passwordConfirm]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Your passwords don't match" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
    }
    
    
    CLLocationManager *manager = [LocationManagerManager sharedCLLocationManager];
    CLLocation *location = [manager location];
	
    NSString* lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString* lng = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    
    
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/v1/users" usingBlock:^(RKObjectLoader* loader) {
        loader.method = RKRequestMethodPOST;
        RKParams* params = [RKParams params];
        [params setValue:username forParam:@"username"];
        [params setValue:email forParam:@"email"];
        [params setValue:lat forParam:@"lat"];
        [params setValue:lng forParam:@"lng"];
        if (fbDict){
            [params setValue:[FBSession.activeSession accessToken] forParam:@"facebook_access_token"];
            [params setValue:[FBSession.activeSession expirationDate] forParam:@"facebook_expiry_date"];
            [params setValue:[fbDict objectForKey:@"id"] forParam:@"facebook_id"];
        }else{
            [params setValue:password forParam:@"password"];
            [params setValue:passwordConfirm forParam:@"password_confirm"];
        }
        
        
        loader.params = params;
        loader.delegate = self;
        loader.userData = [NSNumber numberWithInt:60];
    }];
                                                             
    DLog(@"Sending request");
    [self.view endEditing:TRUE];
    
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.labelText = @"Signing Up...";
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
}


- (void)usernameChanged:(id)sender {
    NSString *username = ((UITextField*)sender).text;
    
    self.urlLabel.text = [NSString stringWithFormat:@"placeling.com/%@", username];
}


#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    [self.HUD hide:true];
    
    
    NSDictionary *jsonDict = [objectLoader.response.bodyAsString JSONValue];
    
    if ( [@"success" isEqualToString:(NSString*)[jsonDict objectForKey:@"status"] ]){
        NSArray *tokens = [[jsonDict objectForKey:@"token"] componentsSeparatedByString:@"&"];
        
        for (NSString* token in tokens){
            NSArray *component = [token componentsSeparatedByString:@"="];
            if ( [@"oauth_token" isEqualToString:[component objectAtIndex:0]] ){
                [NinaHelper setAccessToken:[component objectAtIndex:1]];
            } else if ( [@"oauth_token_secret" isEqualToString:[component objectAtIndex:0]] ){
                [NinaHelper setAccessTokenSecret:[component objectAtIndex:1]];
            }
        }
        
        User *user = [objects objectAtIndex:0];
        
        NSString *userName = user.username;
        [NinaHelper setUsername:userName];
        [UserManager setUser:user];
        
        PostSignupViewController *postSignupViewController = [[PostSignupViewController alloc] init];
        postSignupViewController.username = userName;
        postSignupViewController.user = user;
        postSignupViewController.delegate = self.delegate;
        
        NSArray * newViewControllers = [NSArray arrayWithObjects:postSignupViewController,nil];
        [self.navigationController setViewControllers:newViewControllers];
        
    } 

}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [self.HUD hide:true];
    [NinaHelper handleBadRKRequest:objectLoader.response sender:self];
    
    NSDictionary *jsonDict = [objectLoader.response.bodyAsString JSONValue];
    
    NSDictionary *errors = [jsonDict objectForKey:@"message"];
    DLog(@"Signup Error: %@",errors );
    
    NSString *errorMessage = @"";
    NSEnumerator *enumerator = [errors keyEnumerator];
    NSString *key;
    while ((key = [enumerator nextObject])) {
        NSArray *keyErrors = [errors objectForKey:key];
        
        for (NSString *failure in keyErrors){
            errorMessage = [NSString stringWithFormat:@"%@%@ %@\n", errorMessage, key, failure];
        }
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSBundle mainBundle] loadNibNamed:@"SignupFooterView" owner:self options:nil];
    self.tableView.tableFooterView = self.tableFooterView;
    self.tableView.tableFooterView.userInteractionEnabled = TRUE;
    
    [[NSBundle mainBundle] loadNibNamed:@"SignupHeaderView" owner:self options:nil];
    self.tableView.tableHeaderView = self.tableHeaderView;
    self.tableView.tableHeaderView.userInteractionEnabled = TRUE;
    
    [self.tableFooterView setAutoresizingMask:UIViewAutoresizingNone];
    [self.tableHeaderView setAutoresizingMask:UIViewAutoresizingNone];
    
    self.navigationItem.title = @"Signup";
    
    // Background image
    self.tableView.opaque = NO;
    self.tableView.backgroundView = nil;
    UIImage *image = [UIImage imageNamed:@"CanvasBG.png"];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:image];
    
    self.tableView.tableFooterView = self.tableFooterView;
    
    UIBarButtonItem *signupButton =  [[UIBarButtonItem  alloc]initWithTitle:@"Signup" style:UIBarButtonItemStylePlain target:self action:@selector(signup)];
    self.navigationItem.rightBarButtonItem = signupButton;
    [signupButton release];
}


-(void)dealloc{
    [[[[RKObjectManager sharedManager] client] requestQueue] cancelRequestsWithDelegate:self];    
    [fbDict release];
    [accessKey release];
    [accessSecret release];
    [tableFooterView release];
    [termsButton release];
    [privacyButton release];
    [HUD release];
    [super dealloc];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void) textFieldDidBeginEditing:(UITextField *)textField{
    if (textField.tag > 1 && [self.tableView numberOfRowsInSection:0] > 2){
        [[self tableView] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    int tag = theTextField.tag;
    
    if (tag == 4 || (fbDict && tag ==3)) {
        [theTextField resignFirstResponder];
        [self performSelector:@selector(signup)];
    } else if (tag == 1 || tag == 2 || tag == 3) {
        [theTextField resignFirstResponder];
        UITextField *nextField = (UITextField *)[self.view viewWithTag:(tag + 1)];
        [nextField becomeFirstResponder];
    } 
    
    return YES;
}

-(IBAction) showTerms {
    GenericWebViewController *genericWebViewController = [[GenericWebViewController alloc] initWithUrl:[NSString stringWithFormat:@"%@/terms_of_service", [NinaHelper getHostname]]];
    
    genericWebViewController.title = @"Terms & Conditions";
    [self.navigationController pushViewController:genericWebViewController animated:true];
    
    [genericWebViewController release];
}

-(IBAction) showPrivacy {
    GenericWebViewController *genericWebViewController = [[GenericWebViewController alloc] initWithUrl:[NSString stringWithFormat:@"%@/privacy_policy", [NinaHelper getHostname]]];
    
    genericWebViewController.title = @"Privacy Policy";
    [self.navigationController pushViewController:genericWebViewController animated:true];
    
    [genericWebViewController release];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (fbDict){
        return 1;
    }else {
        return 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    EditableTableCell *eCell = [[[EditableTableCell alloc] initWithReuseIdentifier:@"Cell"] autorelease];
    eCell.textField.text = @"";
    eCell.userInteractionEnabled = true;
    
    if(fbDict){
        if (indexPath.row == 0){
            eCell.textLabel.text = @"username";
            eCell.textField.returnKeyType = UIReturnKeyDefault;
            eCell.textField.delegate = self;
            eCell.textField.tag = 1;
            
            [eCell.textField addTarget:self action:@selector(usernameChanged:) forControlEvents:UIControlEventEditingChanged];
            
            if ([fbDict objectForKey:@"username"]){
                NSString *username = [fbDict objectForKey:@"username"];
                
                NSCharacterSet *charactersToRemove =
                [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
                
                username =
                [[ username componentsSeparatedByCharactersInSet:charactersToRemove ]
                 componentsJoinedByString:@"" ];
                
                eCell.textField.text = username;
                eCell.textField.returnKeyType = UIReturnKeyGo;
                eCell.textField.delegate = self;
                self.urlLabel.text = [NSString stringWithFormat:@"placeling.com/%@", username];
            }
        } 
        
    } else {
        if (indexPath.row == 0){
            eCell.textLabel.text = @"username";
            eCell.textField.returnKeyType = UIReturnKeyDefault;
            eCell.textField.delegate = self;
            eCell.textField.tag = 1;
            [eCell.textField addTarget:self action:@selector(usernameChanged:) forControlEvents:UIControlEventEditingChanged];
            
            [eCell.textField becomeFirstResponder];
        } else if (indexPath.row == 1){
            eCell.textLabel.text = @"email";
            eCell.textField.returnKeyType = UIReturnKeyDefault;
            eCell.textField.delegate = self;
            eCell.textField.tag = 2;
            eCell.textField.keyboardType = UIKeyboardTypeEmailAddress;
        }else if (indexPath.row == 2){
            eCell.textLabel.text = @"password";
            eCell.textField.secureTextEntry = true;
            eCell.textField.returnKeyType = UIReturnKeyDefault;
            eCell.textField.delegate = self;
            eCell.textField.tag = 3;
        }else if (indexPath.row == 3){
            eCell.textLabel.text = @"confirm";
            eCell.textField.secureTextEntry = true;
            eCell.textField.tag = 4;
            eCell.textField.delegate = self;
            eCell.textField.returnKeyType = UIReturnKeyGo;
        }
    }

    
    // Configure the cell...
    eCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return eCell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DLog(@"Click on the indexpath row %i", indexPath.row);
    
    EditableTableCell *eCell = (EditableTableCell*)[tableView cellForRowAtIndexPath:indexPath];
    [eCell.textField becomeFirstResponder];
}

@end
