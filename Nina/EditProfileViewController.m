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

@interface EditProfileViewController(Private)
-(IBAction)showActionSheet;
@end


@implementation EditProfileViewController
@synthesize user, lat, lng, delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)showActionSheet{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Choose From Library", nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex == 0){
        UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imgPicker.delegate = self;
        [self presentModalViewController:imgPicker animated:YES];
        [imgPicker release];
 
    } else if (buttonIndex == 1){
        UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imgPicker.delegate = self;
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
    
    cell.imageView.image = img;
    
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
    
    locationCell.textLabel.text = [NSString stringWithFormat:@"Your home location is near: %@,%@", self.lat, self.lng];
    
    [locationCell setNeedsDisplay];
    
}

-(IBAction)saveUser{
    NSString *urlText = [NSString stringWithFormat:@"%@/v1/users/%@", [NinaHelper getHostname], self.user.username];
    
    NSURL *url = [NSURL URLWithString:urlText];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    NSString *email = ((EditableTableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]).textField.text;
    NSString *user_url = ((EditableTableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]]).textField.text;
    NSString *description = ((EditableTableCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]]).textField.text;
    
    //[request setPostValue:self.memoTextView.text forKey:@"avatar"];
    
    [request setPostValue:description forKey:@"description"];
    [request setPostValue:email forKey:@"email"];
    [request setPostValue:user_url forKey:@"url"];
    
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
    
    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // Set determinate mode
    hud.labelText = @"Saving...";
    [hud retain];
    //[self.navigationController popViewControllerAnimated:YES];
}


-(void)requestFailed:(ASIHTTPRequest *)request{
    [NinaHelper handleBadRequest:request sender:self];
}

- (void)requestFinished:(ASIHTTPRequest *)request{    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [hud release];
    
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
    
    UIBarButtonItem *saveButton =  [[UIBarButtonItem  alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveUser)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if (section == 0){
        return 1;
    } else if (section == 1){
        return 3;
    } else{
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *photoCellIdentifier = @"photoCell";
    static NSString *CellIdentifier = @"Cell";
    static NSString *homeCellIdentifier = @"HomeCell";
    static NSString *locationCellIdentifier = @"LocationCell";
    
    UITableViewCell *cell;
    
    if (indexPath.section ==0){
        cell = [tableView dequeueReusableCellWithIdentifier:photoCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:photoCellIdentifier] autorelease];
        }
        
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.imageView.image = [UIImage imageNamed:@"default_profile_image.png"];
        
        AsyncImageView *aImageView = [[AsyncImageView alloc] initWithPhoto:user.profilePic];
        aImageView.frame = cell.imageView.frame;
        aImageView.populate = cell.imageView;
        [aImageView loadImage];
        [cell addSubview:aImageView]; //mostly to handle de-allocation
        [aImageView release];
        
        cell.textLabel.text = @"Profile Picture";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    } else if (indexPath.section == 1){
        EditableTableCell *eCell;
        
        eCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (eCell == nil) {
            eCell = [[[EditableTableCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];   
        }

        eCell.textField.text = @"";

        if (indexPath.row == 0){
            eCell.textLabel.text = @"Email";
            eCell.textField.text = self.user.email;
            eCell.textField.enabled = FALSE;
        } else if (indexPath.row == 1){
            eCell.textLabel.text = @"Url";
            eCell.textField.text = self.user.url;
        }else if (indexPath.row == 2){
            eCell.textLabel.text = @"description";
            eCell.textField.text = self.user.description;
        }
        
        cell = eCell;
    } else {
        if (indexPath.row ==0){
            cell = [tableView dequeueReusableCellWithIdentifier:homeCellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:homeCellIdentifier] autorelease];
            }   
            [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:11]];
            
            cell.textLabel.text = [NSString stringWithFormat:@"Your home location is near: %@,%@", self.lat,self.lng];
            
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:locationCellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:locationCellIdentifier] autorelease]; 
            }
            [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:11]];
            
            cell.textLabel.text = @"click here to set current approximate location as home";
        }
    }
    
    // Configure the cell...
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    if (indexPath.section == 0 && indexPath.row == 0){
        [self showActionSheet];
    } else if (indexPath.section == 2 && indexPath.row == 1){
        [self updateHomeLocation];
    }
}

@end
