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
#import "NSString+SBJSON.h"
#import "SuggestUserViewController.h"

@implementation SignupController


@synthesize fbDict, accessKey, accessSecret;

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
    NSString *email = ((EditableTableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).textField.text;
    NSString *password = ((EditableTableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]]).textField.text;
    
    CLLocationManager *manager = [LocationManagerManager sharedCLLocationManager];
    CLLocation *location = [manager location];
	
	NSString *targetURL = [NSString stringWithFormat:@"%@/v1/users", [NinaHelper getHostname]];
    
    NSString* lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString* lng = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:targetURL]];
                
    [request setPostValue:username forKey:@"username"];
    [request setPostValue:email forKey:@"email"];
    [request setPostValue:password forKey:@"password"];
    
    if (fbDict){
        NinaAppDelegate *appDelegate = (NinaAppDelegate*)[[UIApplication sharedApplication] delegate];
        Facebook *facebook = appDelegate.facebook;
        [request setPostValue:facebook.accessToken forKey:@"facebook_access_token"];
        [request setPostValue:[fbDict objectForKey:@"id"] forKey:@"facebook_id"];
    }else{
        NSString * passwordConfirm = ((EditableTableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]]).textField.text;
        
        if (![password isEqualToString:passwordConfirm]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Passwords dont match" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [alert release];	
            return;
        }
        
        [request setPostValue:passwordConfirm forKey:@"password_confirm"];
    }
                                   
    [request setPostValue:lat forKey:@"lat"];
    [request setPostValue:lng forKey:@"long"];                                   
    
    [request setRequestMethod:@"POST"];
    [request setDelegate:self]; //whatever called this should handle it
    [request setTag:60];
    
    [NinaHelper signRequest:request];
    
    [request startAsynchronous];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
}


-(void)requestFailed:(ASIHTTPRequest *)request{
    
    int statusCode = [request responseStatusCode];
    NSError *error = [request error];
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error: %i", statusCode] message:errorMessage
                                                   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];	
}


- (void)requestFinished:(ASIHTTPRequest *)request{    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];    
    
    if (request.responseStatusCode != 200){
        int statusCode = [request responseStatusCode];
        NSError *error = [request error];
        NSString *errorMessage = [error localizedDescription];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error: %i", statusCode] message:errorMessage
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    NSString *responseString = [request responseString];        
    DLog(@"%@", responseString);
    
    NSDictionary *jsonDict = [responseString JSONValue];  
    
    if ( [@"success" isEqualToString:(NSString*)[jsonDict objectForKey:@"status"] ]){
        NSArray *tokens = [[jsonDict objectForKey:@"token"] componentsSeparatedByString:@"&"];
        
        for (NSString* token in tokens){
            NSArray *component = [token componentsSeparatedByString:@"="];
            if ( [[NSString stringWithString:@"oauth_token"] isEqualToString:[component objectAtIndex:0]] ){
                [NinaHelper setAccessToken:[component objectAtIndex:1]];
            } else if ( [[NSString stringWithString:@"oauth_token_secret"] isEqualToString:[component objectAtIndex:0]] ){
                [NinaHelper setAccessTokenSecret:[component objectAtIndex:1]];
            }
        } 
        
        [NinaHelper setUsername:((EditableTableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).textField.text];
        
        
        SuggestUserViewController *suggestUserViewController = [[SuggestUserViewController alloc] init];
        
        UINavigationController *navController = self.navigationController;
        
        // retain ourselves so that the controller will still exist once it's popped off
        [[self retain] autorelease];
        
        // Pop this controller and replace with another
        [navController popViewControllerAnimated:NO];
        [navController pushViewController:suggestUserViewController animated:NO];
        [suggestUserViewController release];
  
    } else {
        NSDictionary *errors = [jsonDict objectForKey:@"message"];
        DLog(@"Signup Error: %@",errors );        
        
        NSString *errorMessage = @"";
        NSEnumerator *enumerator = [errors keyEnumerator];
        NSString *key;
        while ((key = [enumerator nextObject])) {
            NSString *tmp = [errors objectForKey:key];
            errorMessage = [NSString stringWithFormat:@"%@%@ %@\n", errorMessage, key, tmp];
        }
        [jsonDict objectForKey:@"message"];
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    }
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"Signup";

    UIBarButtonItem *signupButton =  [[UIBarButtonItem  alloc]initWithTitle:@"Signup" style:UIBarButtonItemStylePlain target:self action:@selector(signup)];
    self.navigationItem.rightBarButtonItem = signupButton;
    [signupButton release];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)dealloc{
    [NinaHelper clearActiveRequests:60];
    [fbDict release];
    [accessKey release];
    [accessSecret release];
    [super dealloc];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (fbDict){
        return 3;
    }else {
        return 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {

        EditableTableCell *eCell = [[[EditableTableCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];   
        eCell.textField.text = @"";
        
        if(fbDict){
            if (indexPath.row == 0){
                eCell.textLabel.text = @"Username";
                if ([fbDict objectForKey:@"username"]){
                    NSString *username = [fbDict objectForKey:@"username"];
                    
                    NSCharacterSet *charactersToRemove =
                    [[ NSCharacterSet alphanumericCharacterSet ] invertedSet ];
                    
                    username =
                    [[ username componentsSeparatedByCharactersInSet:charactersToRemove ]
                     componentsJoinedByString:@"" ];
                    
                    
                    eCell.textField.text = username;
                }
            } else if (indexPath.row == 1){
                eCell.textLabel.text = @"Email";
                eCell.textField.text = [fbDict objectForKey:@"email"];
                eCell.textField.enabled = false;
                eCell.textField.textColor = [UIColor grayColor];
            }else if (indexPath.row == 2){
                eCell.textLabel.text = @"Password";
                eCell.textField.secureTextEntry = true;
                [eCell.textField becomeFirstResponder];
            }
        } else {
            if (indexPath.row == 0){
                eCell.textLabel.text = @"Username";
                [eCell.textField becomeFirstResponder];
            } else if (indexPath.row == 1){
                eCell.textLabel.text = @"Email";
            }else if (indexPath.row == 2){
                eCell.textLabel.text = @"Password";
                eCell.textField.secureTextEntry = true;
                
            }else if (indexPath.row == 3){
                eCell.textLabel.text = @"Confirm Password";
                eCell.textField.secureTextEntry = true;
            }
        }

        cell = eCell;
    }
    
    // Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (fbDict && indexPath.row == 1){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Signup" message:@"This is a validated email from Facebook, you can change it later on if you wish."
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];	
    }
}

@end
