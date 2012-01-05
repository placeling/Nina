//
//  EditPerspectiveViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-08-29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditPerspectiveViewController.h"
#import "UIImage+Resize.h"
#import "ASIFormDataRequest+OAuth.h"
#import "ASIHTTPRequest+OAuth.h"
#import "Photo.h"
#import "NSString+SBJSON.h"
#import "asyncimageview.h"
#import <QuartzCore/QuartzCore.h>

@interface EditPerspectiveViewController()
-(NSNumber*) uploadImageAndReturnTag:(UIImage*)mainImage;
-(void) refreshImages;
-(void) close;
@end

@implementation EditPerspectiveViewController
@synthesize perspective=_perspective, updatedMemo;
@synthesize memoTextView, scrollView;
@synthesize photoButton;
@synthesize delegate, queue;
@synthesize existingButton;
@synthesize takeButton, uploadingPics;

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
        self.memoTextView.text = self.perspective.notes;
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
    
    [self refreshImages];
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [StyleHelper styleNavigationBar:self.navigationController.navigationBar];
    [StyleHelper styleBackgroundView:self.view];
    [StyleHelper styleSubmitTypeButton:self.takeButton];
    [StyleHelper styleSubmitTypeButton:self.existingButton];
    [self refreshImages];
    
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
    NSString *urlText = [NSString stringWithFormat:@"%@/v1/places/%@/perspectives", [NinaHelper getHostname], self.perspective.place.pid];
    
    NSURL *url = [NSURL URLWithString:urlText];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:self.memoTextView.text forKey:@"memo"];
    
    [request setRequestMethod:@"POST"];
    [request setDelegate:delegate]; //whatever called this should handle it
    [request setTag:4]; //this is the bookmark request tag from placepageviewcontroller -iMack
    
    [NinaHelper signRequest:request];
    [request setUploadProgressDelegate:hud];
    
    [request startAsynchronous];
    
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

/*
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissModalViewControllerAnimated:YES];
    [picker release];
    
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    // AND the original image works great
    
    if (!img){
        img = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    
    if (!img){
        DLog(@"ERROR:Null pic returned");
        return;
    }

    NSNumber *tag = [self uploadImageAndReturnTag:img];
    
    Photo *photo = [[Photo alloc] init];
    photo.thumb_image = img;
    
    [uploadingPics setObject:photo forKey:tag];
    
    [self.perspective.photos addObject:photo];
    [photo release];
    
    //create an image for upload, bounded by 960, since that's the max the thing will take anyway
    [self refreshImages];
}
 */

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editingInfo{
    [picker dismissModalViewControllerAnimated:YES];
    
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

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    
    [super dealloc];
}

@end
