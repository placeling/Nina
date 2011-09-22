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
//#import "OAuthCore.h"



@interface EditPerspectiveViewController()
-(void) uploadImage:(UIImage*)image;
@end

@implementation EditPerspectiveViewController
@synthesize perspective=_perspective;
@synthesize memoTextView, scrollView;
@synthesize photoButton;
@synthesize delegate, queue;
@synthesize existingButton;
@synthesize takeButton;

- (id) initWithPerspective:(Perspective *)perspective{
    self = [super init];
    if (self) {
        self.perspective = perspective;
    }
    
    if (![self queue]) {
        [self setQueue:[[NSOperationQueue alloc] init]];
    }
    
    return self;
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
 
    NSString *placeName = self.perspective.place.name;
    self.navigationItem.title = placeName;
    self.memoTextView.text = self.perspective.notes;
    
    UIBarButtonItem *saveButton =  [[UIBarButtonItem  alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(savePerspective)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];
    
    uploadedPics = [[NSMutableArray alloc] initWithCapacity:1];
    
    [self.memoTextView becomeFirstResponder];
    
}


-(void)requestFailed:(ASIHTTPRequest *)request{
    [NinaHelper handleBadRequest:request sender:self];
}


- (void)requestFinished:(ASIHTTPRequest *)request{    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (200 != [request responseStatusCode]){
		[NinaHelper handleBadRequest:request sender:self];
	} else {
        
        switch( [request tag] ){
            case 70:{
                //perspective picture return
                NSString *responseString = [request responseString];        
                DLog(@"%@", responseString);
                
                break;
            }
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
    
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(IBAction)existingImage{
	UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
	imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imgPicker.delegate = self;
	[self presentModalViewController:imgPicker animated:YES];
	[imgPicker release];
}

-(IBAction)takeImage{
	UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
	imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imgPicker.delegate = self;
	[self presentModalViewController:imgPicker animated:YES];
	[imgPicker release];
}

-(void) refreshImages{
    
    //[self.scrollView setBackgroundColor:[UIColor blackColor]];
    [self.scrollView setCanCancelContentTouches:NO];
    
    scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    scrollView.clipsToBounds = NO;
    scrollView.scrollEnabled = YES;
    scrollView.pagingEnabled = YES;

    CGFloat cx = 0;
    
    for (UIImage* image in uploadedPics){
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        
        CGRect rect = imageView.frame;
        rect.size.height = 64;
        rect.size.width = 64;
        rect.origin.x = cx;
        rect.origin.y = 0;
        
        imageView.frame = rect;
        
        [scrollView addSubview:imageView];
        
        cx += imageView.frame.size.width+5;
        
        [imageView release];
        
    }
    
    [scrollView setContentSize:CGSizeMake(cx, [scrollView bounds].size.height)];
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
	
	UIImage *image = img;
    
    UIImage *thumbImage = [image thumbnailImage:64
                transparentBorder:2
                cornerRadius:2
                interpolationQuality:kCGInterpolationHigh ];
    
    NSData* imgData = UIImageJPEGRepresentation(thumbImage, 0.9);
    DLog(@"Got image, shrank thumb to: %i", [imgData length]);
    [uploadedPics addObject:thumbImage];
    
    [self uploadImage:image];
    
    //create an image for upload, bounded by 960, since that's the max the thing will take anyway
    [self refreshImages];
    [self dismissModalViewControllerAnimated:YES];
}


-(void) uploadImage:(UIImage*)image{
    UIImage *mainImage = [image
                          resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                          bounds:CGSizeMake(960, 960)
                          interpolationQuality:kCGInterpolationHigh];
    
    NSData* imgData = UIImageJPEGRepresentation(mainImage, 0.6);
    DLog(@"Got image, shrank main to: %i", [imgData length]); 
    
    NSString *urlText = [NSString stringWithFormat:@"%@/v1/places/%@/perspectives/photos", [NinaHelper getHostname], self.perspective.place.pid];
    
    NSURL *url = [NSURL URLWithString:urlText];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setRequestMethod:@"POST"];
    [request setDelegate:self]; 
    [request setTag:70];     
    [request setTimeOutSeconds:60];
    
    [request setData:imgData withFileName:@"image.jpg" andContentType:@"image/jpeg"  forKey:@"image"];
    
    [NinaHelper signRequest:request];
    
    //[request startAsynchronous];
    
    //[request setUploadProgressDelegate:hud];
    
    [[self queue] addOperation:request]; 
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
    [NinaHelper clearActiveRequests:70];
    [queue release];
    [memoTextView release];
    [photoButton release];
    [_perspective release];
    [existingButton release];
    [takeButton release];
    [scrollView release];
    
    [uploadedPics release];
    
    [super dealloc];
}

@end
