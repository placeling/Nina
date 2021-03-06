//
//  PostSignupViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 12-05-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PostSignupViewController.h"
#import "UIImage+Resize.h"
#import "UIImageView+WebCache.h"
#import "SBJSON.h"
#import "UserManager.h"


@interface PostSignupViewController(Private)
-(IBAction)showActionSheet;
-(void)close;
@end


@implementation PostSignupViewController
@synthesize delegate, username, user, uploadingImage, textView, profileImageView, scrollView, HUD, changeImageButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    UIBarButtonItem *saveButton =  [[UIBarButtonItem  alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveUser)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];
    
    UIBarButtonItem *skipButton =  [[UIBarButtonItem  alloc]initWithTitle:@"Skip" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    self.navigationItem.leftBarButtonItem = skipButton;
    [skipButton release];
    
    // Call url to get profile details                
    RKObjectManager* objectManager = [RKObjectManager sharedManager];   
    NSString *targetURL = [NSString stringWithFormat:@"/v1/users/me"];
    
    
    if ( !self.user ){
        [objectManager loadObjectsAtResourcePath:targetURL  usingBlock:^(RKObjectLoader* loader) {
            RKObjectMapping *userMapping = [User getObjectMapping];
            loader.objectMapping = userMapping;
            loader.delegate = self;
            loader.userData = [NSNumber numberWithInt:110]; //use as a tag
        }];
        self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        // Set determinate mode
        self.HUD.labelText = @"Retrieving Your Profile...";
    } else {
        self.textView.text = self.user.userDescription;
        [self.profileImageView setImageWithURL:[NSURL URLWithString:self.user.profilePic.thumbUrl] placeholderImage:[UIImage imageNamed:@"DefaultUserPhoto.png"]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillBeHidden:)
												 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [StyleHelper styleBackgroundView:self.view];
    [profileImageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [profileImageView.layer setBorderWidth: 5.0];
    self.profileImageView.layer.masksToBounds = YES; 
    self.navigationItem.title = @"Welcome";
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] 
     registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeAlert | 
      UIRemoteNotificationTypeBadge | 
      UIRemoteNotificationTypeSound)];
}

-(IBAction)saveUser{
    NSString *urlText = [NSString stringWithFormat:@"/v1/users/%@", self.user.username];    
    
    if (self.uploadingImage){
        Photo *photo = [[Photo alloc] init];
        photo.thumb_image = uploadingImage;
        self.user.profilePic = photo;
        [photo release];
    }
    
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:urlText usingBlock:^(RKObjectLoader* loader) {
        loader.method = RKRequestMethodPUT;
        RKParams* params = [RKParams params];
        if (self.uploadingImage){
            NSData* imgData = UIImageJPEGRepresentation(uploadingImage, 0.5);
            [params setData:imgData MIMEType:@"image/jpeg" fileName:@"image.jpg" forParam:@"image"];
        }
        [params setValue:self.textView.text forParam:@"description"];
        
        loader.params = params;
        loader.delegate = self;
        loader.userData = [NSNumber numberWithInt:90];
    }];

    
    [self.textView resignFirstResponder];
    
    if ( [self.textView.text length] > 0){
        [Flurry logEvent:@"NEW_USER_ADDED_DESCRIPTION"];
    } else {
        [Flurry logEvent:@"NEW_USER_SKIPPED_DESCRIPTION"];
    }
    
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // Set determinate mode
    self.HUD.labelText = @"Saving...";
}


#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    [self.HUD hide:TRUE];
    
    if ( [(NSNumber*)objectLoader.userData intValue] == 110){
        User* newUser = [objects objectAtIndex:0];
        DLog(@"Loaded User: %@", newUser.username);        
        self.user = newUser;
        
        self.textView.text = self.user.userDescription;
        [self.profileImageView setImageWithURL:[NSURL URLWithString:self.user.profilePic.thumbUrl]];
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 90){
        [UserManager setUser:[objects objectAtIndex:0]];
        self.user = [objects objectAtIndex:0];
        
        [self.delegate loadContent];
        [self.navigationController dismissModalViewControllerAnimated:TRUE];
    }
    
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    //objectLoader.response.
    [self.HUD hide:TRUE];
    [NinaHelper handleBadRKRequest:objectLoader.response sender:self];
    DLog(@"Encountered an error: %@", error);
}

-(void)close{
    [self.delegate loadContent];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)hudWasHidden{
    
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissModalViewControllerAnimated:YES];
    UIImage *img = [[info objectForKey:UIImagePickerControllerEditedImage] retain];
    
    if (img.size.width > 960 || img.size.height > 960){
        img = [img
               resizedImageWithContentMode:UIViewContentModeScaleAspectFit
               bounds:CGSizeMake(960, 960)
               interpolationQuality:kCGInterpolationHigh];
    } 
    
    self.uploadingImage = img;
    [self.profileImageView setImage:img];
    [img release];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissModalViewControllerAnimated:YES];
    DLog(@"Cancelled image picking");
}


// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    
	//keyboard could cover poll options, need to shift up enough -iMack
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
	UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
    
	CGFloat keyboardOffset;
	if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
		keyboardOffset = kbSize.height;
        
	} else {
		keyboardOffset = kbSize.width;
	}
    
	CGFloat paddingNeeded = (self.textView.frame.origin.y + self.textView.frame.size.height + keyboardOffset + 5) - (self.view.frame.size.height);
    
	if (paddingNeeded > 0) {
        self.scrollView.contentSize = CGSizeMake(scrollView.frame.size.width , scrollView.frame.size.height + paddingNeeded);
        [self.scrollView setContentOffset:CGPointMake(0, scrollView.contentSize.height - self.scrollView.bounds.size.height) animated:TRUE];
	}
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void) dealloc{
    [[[[RKObjectManager sharedManager] client] requestQueue] cancelRequestsWithDelegate:self];   
    [user release];
    [username release];
    [uploadingImage release];
    [scrollView release];
    [textView release];
    [profileImageView release];
    [HUD release];
    [changeImageButton release];
    [super dealloc];
}


@end
