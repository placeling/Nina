//
//  EditPerspectiveViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-08-29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditPerspectiveViewController.h"
#import "NinaAppDelegate.h"
#import "UIImage+Resize.h"
#import "ASIFormDataRequest+OAuth.h"
#import "ASIHTTPRequest+OAuth.h"
#import "Photo.h"
#import "asyncimageview.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "UserManager.h"


@interface EditPerspectiveViewController()
-(NSNumber*) uploadImageAndReturnTag:(UIImage*)mainImage;
-(void) refreshImages;
-(void) close;
-(void) updateDelayed;
-(void) showDelayPopup;
@end

@implementation EditPerspectiveViewController
@synthesize perspective=_perspective, updatedMemo;
@synthesize memoTextView, scrollView;
@synthesize photoButton;
@synthesize delegate, queue;
@synthesize existingButton;
@synthesize takeButton, uploadingPics, facebookButton, delayButton, twitterButton;

- (id) initWithPerspective:(Perspective *)perspective{
    self = [super init];
    if (self) {
        self.perspective = perspective;
    }
    
    if (!self.queue) {
        NSOperationQueue *initQueue =[[NSOperationQueue alloc] init];
        self.queue = initQueue;
        [initQueue release];
    }
    NSMutableDictionary *uploadingPicsInit = [[NSMutableDictionary alloc] init];
    self.uploadingPics = uploadingPicsInit;
    [uploadingPicsInit release];
    
    return self;
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)close{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}


-(void)updateDelayed{
    if (delayedPost){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ( ![defaults objectForKey:@"delay_perspective_tip"] || [defaults objectForKey:@"delay_perspective_tip"] == false){
            CMPopTipView *delayTip = [[CMPopTipView alloc] initWithMessage:@"For privacy, the timer will delay sharing, since you are nearby this place"];
            delayTip.backgroundColor = [UIColor colorWithRed:185/255.0 green:43/255.0 blue:52/255.0 alpha:1.0];
            //delayTip.delegate = self;
            [delayTip presentPointingAtView:self.delayButton inView:self.memoTextView animated:true];
            [delayTip release];
        }
        [self.delayButton setImage:[UIImage imageNamed:@"DelayPost_selected.png"] forState:UIControlStateNormal];
        [defaults setObject:[NSNumber numberWithBool:true] forKey:@"delay_perspective_tip"];
        [defaults synchronize];
    } else {
        [self.delayButton setImage:[UIImage imageNamed:@"DelayPost_unselected.png"] forState:UIControlStateNormal]; 
    }    
}


-(IBAction)toggleDelayedAction{
    delayedPost = !delayedPost; 
    
    if (delayedPost){
        //show timer popup
        [self showDelayPopup];        
    }
    
    [self updateDelayed];
}


-(void) showDelayPopup{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delay sharing for how long?" 
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    UIDatePicker *pickerView = [[UIDatePicker alloc] initWithFrame:pickerFrame];
    [pickerView setDatePickerMode:UIDatePickerModeCountDownTimer];
    [pickerView setCountDownDuration:delayTime*60 ];
    [pickerView setTag:1];
    
    [actionSheet addSubview:pickerView];
    [pickerView release];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Close"]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventValueChanged];
    [actionSheet addSubview:closeButton];
    [closeButton release];
    
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    
    [actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
    [actionSheet release];
}

// returns the # of rows in each component..
-(void) updateValue:(id)sender {
    UISegmentedControl *closeButton = (UISegmentedControl*)sender;
    UIActionSheet *actionSheet = (UIActionSheet*)[closeButton superview];
    
    UIDatePicker *pickerView;
    for (UIView *view in actionSheet.subviews){        
        if (view.tag == 1){
            pickerView = (UIDatePicker *)view;
            delayTime = pickerView.countDownDuration/60;  
            break;
        }
        
    }
      
    [actionSheet dismissWithClickedButtonIndex:0 animated:true];
}


#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
 
    NSString *placeName = self.perspective.place.name;
    self.navigationItem.title = placeName;
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close)];
    //button.tintColor = [UIColor blackColor];
    
    self.navigationItem.leftBarButtonItem = button;
    [button release];
    
    requestCount = 0;
    
    if (updatedMemo){ //handles case where this is called again after init (from taking photo)
        self.memoTextView.text = self.updatedMemo;
    } else {
        if (self.perspective.memo && [self.perspective.memo length] > 0){
            self.memoTextView.text = self.perspective.memo;
        }else {
            self.memoTextView.placeholder = @"Use #hashtags in your notes to add another way to explore your places.";
        }
    }
    
    // Test to see if camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        self.takeButton.enabled = NO;
        self.takeButton.titleLabel.textColor = [UIColor grayColor];
    }
    
    UIBarButtonItem *saveButton =  [[UIBarButtonItem  alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(savePerspective)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];
    
    [self.memoTextView becomeFirstResponder];
    
    CLLocationManager* locationManager = [LocationManagerManager sharedCLLocationManager];
    CLLocation *currentLocation = locationManager.location;
    float distance = [self.perspective.place.location distanceFromLocation:currentLocation];
    float accuracy = currentLocation.horizontalAccuracy;
    
    if (accuracy +100 > distance){        
        delayedPost = true;
    } else {
        delayedPost = false;
    }
    delayTime = 120; //default minutes to delay a delayed post
    
    facebookEnabled = false;
    twitterEnabled = false;
    
    if (FBSession.activeSession.isOpen) {
        [self facebookToggle];
    }

    User *user = [UserManager sharedMeUser];
    
    if ( user.twitter ){
        [self twitterToggle];
    }
    
    [self refreshImages];
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [StyleHelper styleNavigationBar:self.navigationController.navigationBar];
    [StyleHelper styleBackgroundView:self.view];
    [StyleHelper styleSubmitTypeButton:self.takeButton];
    [StyleHelper styleSubmitTypeButton:self.existingButton];
    [self refreshImages];
    
    [self updateDelayed];
}


-(void)requestFailed:(ASIHTTPRequest *)request{
    [NinaHelper handleBadRequest:request sender:self];
}


- (void)requestFinished:(ASIHTTPRequest *)request{    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (200 != [request responseStatusCode]){
		[NinaHelper handleBadRequest:request sender:self];
	} else {
        if ([request tag] >= 1000){
            if ([uploadingPics objectForKey:[NSNumber numberWithInt:request.tag]]){
                //perspective picture return
                NSString *responseString = [request responseString];
                DLog(@"%@", responseString);
                
                Photo *photo = [uploadingPics objectForKey:[NSNumber numberWithInt:request.tag]];
                [photo updateFromJsonDict:[responseString JSONValue]];
                
                [uploadingPics removeObjectForKey:[NSNumber numberWithInt:request.tag]];
                
            } else {
                DLog(@"WARNING: request handled with no uploading tag");
            }
            [self refreshImages];
        }
	}
}



-(IBAction)savePerspective{
    
    self.perspective.memo = self.memoTextView.text;
    self.perspective.mine = true;

    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
    
    //we have to set this because doing the loader.param thing overwrites the reverse object mapping
    [paramDict setObject:self.memoTextView.text forKey:@"memo"];
    [paramDict setObject:@"true" forKey:@"newpost"];
    
    if (facebookEnabled){
        [paramDict setObject:@"true" forKey:@"fb_post"];
    }
    
    if (twitterEnabled){
        [paramDict setObject:@"true" forKey:@"twitter_post"];
    }
    
    if ( delayedPost ){
        [paramDict setObject:[[NSNumber numberWithInt:delayTime] stringValue] forKey:@"post_delay"];
    }
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager postObject:self.perspective usingBlock:^(RKObjectLoader* loader) {
        loader.method = RKRequestMethodPOST;
        loader.params = paramDict;
        loader.delegate = delegate;
        loader.userData = [NSNumber numberWithInt:9]; //use as a tag
    }];
    
    [paramDict release];
    
    [delegate updatePerspective:self.perspective];
    [UserManager updatePerspective:self.perspective];
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
}

-(IBAction)existingImage{
    self.updatedMemo = self.memoTextView.text;
    
	UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
	imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imgPicker.delegate = self;
	[self presentModalViewController:imgPicker animated:YES];
	[imgPicker release];
}

-(IBAction)takeImage{
    self.updatedMemo = self.memoTextView.text;  
    
	UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
	imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imgPicker.delegate = self;
	[self presentModalViewController:imgPicker animated:YES];
	[imgPicker release];
}


-(void)handleTwitterCredentials:(NSDictionary *)creds{
    [super handleTwitterCredentials:creds];
    twitterEnabled = true;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.twitterButton setImage:[UIImage imageNamed:@"twitter_selected.png"] forState:UIControlStateNormal];
    });    
}

-(IBAction) twitterToggle{
    
    if (twitterEnabled){
        twitterEnabled = false;
        [self.twitterButton setImage:[UIImage imageNamed:@"twitter_unselected.png"] forState:UIControlStateNormal];
        
    } else {        
        if ( [NinaHelper twitterEnabled] ){
            twitterEnabled = true;
            [self.twitterButton setImage:[UIImage imageNamed:@"twitter_selected.png"] forState:UIControlStateNormal];
        } else {
            [self authorizeTwitter];
        }
    }
    
}


-(IBAction)facebookToggle{    
    if (facebookEnabled){
        facebookEnabled = false;
        [self.facebookButton setImage:[UIImage imageNamed:@"facebook_unselected.png"] forState:UIControlStateNormal];
        
    } else {

        if (FBSession.activeSession.isOpen) {
            facebookEnabled = true;
            [self.facebookButton setImage:[UIImage imageNamed:@"facebook_selected.png"] forState:UIControlStateNormal];
        } else {
            [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObjects:@"email", @"publish_actions", nil] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:TRUE completionHandler:^(FBSession *session,
                                                                                                                                                                                                                  FBSessionState state, NSError *error) {
                facebookEnabled = false; //will be forced to true
                [self facebookToggle];
                User *user = [UserManager sharedMeUser];
                [NinaHelper updateFacebookCredentials:session forUser:user];
            }];
        }
    }
    
}
        
-(void) refreshImages{
    
    //[self.scrollView setBackgroundColor:[UIColor blackColor]];
    [self.scrollView setCanCancelContentTouches:NO];
    
    for (UIView *subView in scrollView.subviews){
        [subView removeFromSuperview];
    }
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.clipsToBounds = NO;
    scrollView.scrollEnabled = YES;
    scrollView.pagingEnabled = YES;

    CGFloat cx = 5;
    
    for ( Photo* photo in [self.perspective.photos reverseObjectEnumerator] ){
        photo.mine = true;
        photo.perspective = self.perspective;
        UIImageView *imageView;
        CGRect rect = CGRectMake(cx, 0, 64, 64);
        
        if (photo.photoId){
            imageView = [[AsyncImageView alloc] initWithFrame:rect];
            [(AsyncImageView*)imageView loadImageFromPhoto:photo]; 
            imageView.alpha = 1.0;
            imageView.userInteractionEnabled = true;
        } else {
            if (photo.thumb_image){
                //have thumb, but is currently being uploaded
                
                imageView = [[UIImageView alloc] initWithFrame:rect];
                [imageView setImage:photo.thumb_image];
                
                imageView.alpha = 0.5; //Alpha runs from 0.0 to 1.0
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.clipsToBounds = true;
                UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                
                [spinner setFrame:CGRectMake((imageView.frame.size.height-spinner.frame.size.height)/2, (imageView.frame.size.width-spinner.frame.size.width)/2, spinner.frame.size.width, spinner.frame.size.height) ];
                
                [imageView addSubview:spinner];
                [spinner startAnimating];
                [spinner release]; 
            } else {
                imageView = [[UIImageView alloc] initWithFrame:rect];
                DLog(@"ERROR: Got photo with no ID or image");
            }
        }
        
        [imageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [imageView.layer setBorderWidth: 3.0];
        
        [scrollView addSubview:imageView];
        
        cx += imageView.frame.size.width+5;
        
        [imageView release];
        
    }
    
    [scrollView setContentSize:CGSizeMake(cx, [scrollView bounds].size.height)];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissModalViewControllerAnimated:YES];
    DLog(@"Cancelled image picking");
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissModalViewControllerAnimated:YES];
    UIImage *img = [[info objectForKey:UIImagePickerControllerOriginalImage] retain];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera){
        ALAssetsLibrary *library = [[[ALAssetsLibrary alloc] init] autorelease];
        [library writeImageToSavedPhotosAlbum:[img CGImage] metadata:[info objectForKey:UIImagePickerControllerMediaMetadata]  completionBlock:nil];
    }
    
    NSNumber *tag = [self uploadImageAndReturnTag:img];
    
    UIImage *thumbImage;
    //scale down image, since we dont' need the whole thing for the app
    if (img.size.width > 160 || img.size.height > 160){
        thumbImage = [img
                      thumbnailImage:160
                   transparentBorder:1
                   cornerRadius:1
                   interpolationQuality:kCGInterpolationHigh ];
    } else {
        thumbImage = img;
    }
    
    
    Photo *photo = [[Photo alloc] init];
    photo.thumb_image = thumbImage;
    photo.mine = true;
    photo.perspective = self.perspective;
    
    [uploadingPics setObject:photo forKey:tag];
    
    [self.perspective.photos addObject:photo];
    self.perspective.modified = TRUE;
    [photo release];
    [img release];
    
    //create an image for upload, bounded by 960, since that's the max the thing will take anyway
    [self refreshImages];
}


-(NSNumber*) uploadImageAndReturnTag:(UIImage*)image{
    
    if (image.size.width > 960 || image.size.height > 960){
        image = [image
                              resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                              bounds:CGSizeMake(960, 960)
                              interpolationQuality:kCGInterpolationHigh];
    } 
    
    NSData* imgData = UIImageJPEGRepresentation(image, 0.5);
    
    DLog(@"Got image, shrank main to: %i", [imgData length]); 
    
    NSString *urlText = [NSString stringWithFormat:@"%@/v1/places/%@/perspectives/photos", [NinaHelper getHostname], self.perspective.place.pid];
    
    NSURL *url = [NSURL URLWithString:urlText];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setRequestMethod:@"POST"];
    [request setDelegate:self]; 
    [request setTimeOutSeconds:120];
    
    [request setTag:(1000+requestCount++)];     
    
    [request setData:imgData withFileName:@"image.jpg" andContentType:@"image/jpeg"  forKey:@"image"];
    
    //[NinaHelper signRequest:request];
    [request signRequestWithClientIdentifier:[NinaHelper getConsumerKey] secret:[NinaHelper getConsumerSecret]
                             tokenIdentifier:[NinaHelper getAccessToken] secret:[NinaHelper getAccessTokenSecret]
                                 usingMethod:ASIOAuthHMAC_SHA1SignatureMethod];    
    [[self queue] addOperation:request]; 
    
    return [NSNumber numberWithInt:request.tag];
}

- (void)imagePickerControllerDidCancel{
	//nothing, really, we just ignore -iMack
}


-(IBAction)showPhotos{
    [self.memoTextView resignFirstResponder];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)dealloc{
    if (queue){
        for (ASIHTTPRequest *request in queue.operations){
            [request cancel];
            request.delegate = nil;
        }
    }
    
    [queue release];
    [memoTextView release];
    [photoButton release];
    [_perspective release];
    [existingButton release];
    [takeButton release];
    [scrollView release];
    [uploadingPics release];
    [updatedMemo release];
    [facebookButton release];
    [delayButton release];
    [twitterButton release];
    
    [super dealloc];
}

@end
