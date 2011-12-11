//
//  EditProfileViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-10-05.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EditProfileViewController.h"
#import "EditableTableCell.h"
#import "NinaHelper.h"
#import "NSString+SBJSON.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "NinaAppDelegate.h"
#import "FlurryAnalytics.h"

@interface EditProfileViewController(Private)
-(IBAction)showActionSheet;
-(void)close;
@end


@implementation EditProfileViewController
@synthesize user, lat, lng, delegate, currentLocation;



-(void)close{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)showActionSheet{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"New Profile Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
        [actionSheet showInView:self.view];
        [actionSheet release];
    }
    else { // No camera, probably a touch or iPad 1
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        picker.allowsEditing = YES;
        [self presentModalViewController:picker animated:YES];
    }    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex == 0){
        UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imgPicker.delegate = self;
        imgPicker.allowsEditing = YES;
        [self presentModalViewController:imgPicker animated:YES];
        [imgPicker release];
 
    } else if (buttonIndex == 1){
        UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imgPicker.delegate = self;
        imgPicker.allowsEditing = YES;
        [self presentModalViewController:imgPicker animated:YES];
        [imgPicker release];
        
    }else if (buttonIndex == 2) {
        //cancel
    }

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editingInfo{
    [picker dismissModalViewControllerAnimated:YES];
    
    if (img.size.width > 960 || img.size.height > 960){
        img = [img
                 resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                 bounds:CGSizeMake(960, 960)
                 interpolationQuality:kCGInterpolationHigh];
    } 
    
    uploadingImage = img;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    UIImageView *myImageView = (UIImageView*)[cell viewWithTag:1];
    myImageView.image = img;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];    
    // Release any cached data, images, etc that aren't in use.
}



-(IBAction)updateHomeLocation{
    CLLocationManager *locationManager = [LocationManagerManager sharedCLLocationManager];
    CLLocation *location =  locationManager.location;

    self.lat = [NSNumber numberWithFloat:location.coordinate.latitude];
    self.lng = [NSNumber numberWithFloat:location.coordinate.longitude];
    
    
    UITableViewCell *locationCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    
    locationCell.textLabel.text = [NSString stringWithFormat:@"Your map is centered right here."];
    
    [locationCell setNeedsDisplay];
    
}

-(IBAction)saveUser{
    EditableTableCell *cell = (EditableTableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
    if (cell.textField.isFirstResponder) {
        [cell.textField resignFirstResponder];
    }
    cell = (EditableTableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    if (cell.textField.isFirstResponder) {
        [cell.textField resignFirstResponder];
    }
    
    NSString *urlText = [NSString stringWithFormat:@"%@/v1/users/%@", [NinaHelper getHostname], self.user.username];
    
    NSURL *url = [NSURL URLWithString:urlText];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    NSString *user_url = ((EditableTableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]).textField.text;
    NSString *description = ((EditableTableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]]).textField.text;
    
    //[request setPostValue:self.memoTextView.text forKey:@"avatar"];
    
    [request setPostValue:description forKey:@"description"];
    [request setPostValue:user_url forKey:@"url"];
    
    self.user.description = description;
    self.user.url = user_url;
    
    if (uploadingImage){
        Photo *photo = [[Photo alloc] init];
        photo.thumb_image = uploadingImage;
        self.user.profilePic = photo;
        [photo release];
        NSData* imgData = UIImageJPEGRepresentation(uploadingImage, 0.5);
        [request setData:imgData withFileName:@"image.jpg" andContentType:@"image/jpeg"  forKey:@"image"];
    }
    [request setTimeOutSeconds:120];
    [request setPostValue:[NSString stringWithFormat:@"%@", self.lat] forKey:@"user_lat"];
    [request setPostValue:[NSString stringWithFormat:@"%@", self.lng] forKey:@"user_lng"]; //non-standard key to not conflict with signing tag
    
    [request setRequestMethod:@"PUT"];
    request.delegate = self;
    [request setTag:90]; //this is the bookmark request tag from placepageviewcontroller -iMack
    
    [NinaHelper signRequest:request];
    
    [request startAsynchronous];
    
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // Set determinate mode
    HUD.labelText = @"Saving...";
    [HUD retain];
    
    self.user.modified = true;
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}


-(void)requestFailed:(ASIHTTPRequest *)request{
    [NinaHelper handleBadRequest:request sender:self];
}

- (void)requestFinished:(ASIHTTPRequest *)request{    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [HUD release];
    
    if (200 != [request responseStatusCode]){
		[NinaHelper handleBadRequest:request sender:self];
	} else {
        //perspective modified return
        NSString *responseString = [request responseString];        
        DLog(@"%@", responseString);
        NSDictionary *userDict = [responseString JSONValue];
        
        [self.user updateFromJsonDict:[userDict objectForKey:@"user"]];

        [self.delegate loadData];
        [self.navigationController popViewControllerAnimated:TRUE];
	}
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if (self.user.location && [self.user.location objectAtIndex:0] != nil && [self.user.location objectAtIndex:1] != nil){
        self.lat = [self.user.location objectAtIndex:0];
        self.lng = [self.user.location objectAtIndex:1];
    } else {
        self.lat = [NSNumber numberWithInt:0];
        self.lng = [NSNumber numberWithInt:0];
    }
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close)];
    //button.tintColor = [UIColor blackColor];
    
    self.navigationItem.leftBarButtonItem = button;
    [button release];
    
    UIBarButtonItem *saveButton =  [[UIBarButtonItem  alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveUser)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];
    
    // Create button at bottom of table
    // Could do as section footer, but couldn't make button work inside it so table footer instead - lw
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 50.0)] autorelease];
    
    UIButton *update = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [update addTarget:self action:@selector(updateHomeLocation) forControlEvents:UIControlEventTouchUpInside];
    [update setTitle:@"Center Map Here" forState:UIControlStateNormal];
    update.enabled = YES;
    
    update.frame = CGRectMake(10.0, 0.0, screenRect.size.width - 20.0, 40.0);
    
    [footerView addSubview:update];

    self.tableView.tableFooterView = footerView;
    
    CLLocationManager *locationManager = [LocationManagerManager sharedCLLocationManager];
    self.currentLocation = locationManager.location;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
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


-(void) dealloc{
    [NinaHelper clearActiveRequests:90];
    [user release];
    [lat release];
    [lng release];
    [super dealloc];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if (section == 0){
        return 1;
    } else if (section == 1){
        return 2;
    } else if (section ==2){
        return 1;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
		return 70;
	} else {
		return 44;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *photoCellIdentifier = @"photoCell";
    static NSString *CellIdentifier = @"Cell";
    static NSString *homeCellIdentifier = @"HomeCell";
    static NSString *authCellIdentifier = @"AuthCell";
    
    UITableViewCell *cell;
    
    if (indexPath.section ==0){
        cell = [tableView dequeueReusableCellWithIdentifier:photoCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:photoCellIdentifier] autorelease];
        }
        
        CGRect myImageRect = CGRectMake(20, 10, 50, 50);
        UIImageView *myImage = [[UIImageView alloc] initWithFrame:myImageRect];
        
        // Here we use the new provided setImageWithURL: method to load the web image
        [myImage setImageWithURL:[NSURL URLWithString:user.profilePic.thumb_url]
                       placeholderImage:[UIImage imageNamed:@"default_profile_image.png"]];
        myImage.tag = 1;
        
        [[myImage layer] setCornerRadius:1.0f];
        [[myImage layer] setMasksToBounds:YES];
        [[myImage layer] setBorderWidth:1.0f];
        [[myImage layer] setBorderColor: [UIColor lightGrayColor].CGColor];
        
        [cell addSubview:myImage];
        [myImage release];
        
        UILabel *headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(84, 13, 200, 40)] autorelease];
        headerLabel.text = @"profile picture";
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.font = [UIFont systemFontOfSize:17];
        [cell.contentView addSubview:headerLabel];

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    } else if (indexPath.section == 1){
        EditableTableCell *eCell;
        
        eCell = (EditableTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (eCell == nil) {
            eCell = [[[EditableTableCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];   
        }

        eCell.textField.text = @"";

        if (indexPath.row == 0){
            eCell.textLabel.text = @"url";
            eCell.textField.text = self.user.url;
            eCell.textField.delegate = self;
        }else if (indexPath.row == 1){
            eCell.textLabel.text = @"description";
            eCell.textField.text = self.user.description;
            eCell.textField.delegate = self;
        }
        
        cell = eCell;
    } else if (indexPath.section == 3){
        cell = [tableView dequeueReusableCellWithIdentifier:homeCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:homeCellIdentifier] autorelease];
        }   
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        
        CLLocationDegrees homeLat = [self.lat doubleValue];
        CLLocationDegrees homeLng = [self.lng doubleValue];
        CLLocation *homeLocation = [[CLLocation alloc] initWithLatitude:homeLat longitude:homeLng];        
        
        CLLocationDistance distance = [self.currentLocation distanceFromLocation:homeLocation];
        DLog(@"%f", distance);
        cell.textLabel.text = [NSString stringWithFormat:@"Your map is centered %@ from here.", [NinaHelper metersToLocalizedDistance:distance]];
        
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [homeLocation release];
    } else{ // if (indexPath.section == 2){
        //if (indexPath.row == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:authCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:authCellIdentifier] autorelease];
        }   
        
        cell.textLabel.text = @"Facebook";
        
        if (user.facebook){
            [cell.imageView setImage:[UIImage imageNamed:@"facebook_icon.png"]];
            [cell.detailTextLabel setText: @"You are connected via Facebook"];
        } else {
            [cell.imageView setImage:[UIImage imageNamed:@"facebook_icon_bw.png"]];
            [cell.detailTextLabel setText: @"Click to connect with Facebook"];
        }
    }
    
    return cell;
}


- (void)request:(FBRequest *)request didFailWithError:(NSError *)error{
    [HUD hide:TRUE];
    DLog(@"got facebook response: %@", [error localizedDescription]);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSDictionary *details = [error userInfo];
    
    [FlurryAnalytics logEvent:@"UNKNOWN_FB_FAIL" withParameters:details];
    
    NinaAppDelegate *appDelegate = (NinaAppDelegate*)[[UIApplication sharedApplication] delegate];
    Facebook *facebook = appDelegate.facebook;
    
    facebook.expirationDate = nil;
    facebook.accessToken = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" 
                                                    message:@"Facebook returned a credential error, try again" 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    
}
- (void)request:(FBRequest *)fbRequest didLoad:(id)result{
    DLog(@"got facebook response: %@", result);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSDictionary *fbDict = (NSDictionary*)result;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/v1/auth/facebook/add", [NinaHelper getHostname]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIFormDataRequest *request =  [[[ASIFormDataRequest  alloc]  initWithURL:url] autorelease];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [request setPostValue:[defaults objectForKey:@"FBAccessTokenKey"] forKey:@"token" ];
    [request setPostValue:[defaults objectForKey:@"FBExpirationDateKey"] forKey:@"expiry" ];
    [request setPostValue:[fbDict objectForKey:@"id"] forKey:@"uid"];
    
    [NinaHelper signRequest:request];
    
    [request startSynchronous];
    
    if ([request responseStatusCode] != 200 && [request responseStatusCode] != 400){
        [NinaHelper handleBadRequest:request sender:self];
    } else if ([request responseStatusCode] == 400){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" 
                                                        message:[request responseString] 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else {
        NSString *body = [request responseString];
        NSDictionary *jsonDict =  [body JSONValue];
        
        if ([jsonDict objectForKey:@"user"]){
            [self.user updateFromJsonDict:[jsonDict objectForKey:@"user"]];
        }
        [self.tableView reloadData];
    }
    [HUD hide:TRUE];    
}

- (void)fbDidLogin {
    NinaAppDelegate *appDelegate = (NinaAppDelegate*)[[UIApplication sharedApplication] delegate];
    Facebook *facebook = appDelegate.facebook;
    facebook.sessionDelegate = appDelegate; //put back where found
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    HUD.delegate = self;
    HUD.labelText = @"Authenticating";
    HUD.detailsLabelText = @"Getting Facebook Stuff";
    
    [HUD show:TRUE];
    
    [facebook requestWithGraphPath:@"me" andDelegate:self];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)fbDidNotLogin:(BOOL)cancelled{
    NinaAppDelegate *appDelegate = (NinaAppDelegate*)[[UIApplication sharedApplication] delegate];
    Facebook *facebook = appDelegate.facebook;
    facebook.sessionDelegate = appDelegate; //put back where found
    [FlurryAnalytics logEvent:@"REJECTED_PERMISSIONS"];
} 

- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
	HUD = nil;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    if (indexPath.section == 0 && indexPath.row == 0){
        [self showActionSheet];
    } else if (indexPath.section == 3 && indexPath.row == 1){
        [self updateHomeLocation];
    } else if (indexPath.section == 2 && indexPath.row == 0){
        
        if (self.user.facebook == nil){
            NinaAppDelegate *appDelegate = (NinaAppDelegate*)[[UIApplication sharedApplication] delegate];
            Facebook *facebook = appDelegate.facebook;
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults objectForKey:@"FBAccessTokenKey"] 
                && [defaults objectForKey:@"FBExpirationDateKey"]) {
                facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
                facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
            }
            
            if (![facebook isSessionValid]) {
                NSArray* permissions =  [[NSArray arrayWithObjects:
                                          @"email", @"publish_stream",@"offline_access", nil] retain];
                
                facebook.sessionDelegate = self;
                [facebook authorize:permissions];
                
                [permissions release];
            } else {
                [self fbDidLogin]; // for some reason, already have credentials
            }
        }
        
    }
}

@end
