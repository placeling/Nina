//
//  PictureViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-09-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PictureViewController.h"
#import "ASIDownloadCache.h"

@implementation PictureViewController

@synthesize imageView;
@synthesize photo;
@synthesize progressView;


#pragma mark -ActionSheet 

-(IBAction)showAccountSheet{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Photo" otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        DLog(@"Deleting Photo:%@", self.photo.thumb_url);
        Perspective *perspective = self.photo.perspective;
        
        NSString *urlText = [NSString stringWithFormat:@"%@/v1/places/%@/perspectives/photos/%@", [NinaHelper getHostname], perspective.place.place_id, self.photo.photo_id];        
        NSURL *url = [NSURL URLWithString:urlText];        
        ASIHTTPRequest  *request =  [[[ASIHTTPRequest  alloc]  initWithURL:url] autorelease];

        [perspective.photos removeObject:self.photo];
        perspective.modified = TRUE;
        
        [request setRequestMethod:@"DELETE"];
        
        [request setCompletionBlock:^{
            // Use when fetching text data
            NSString *responseString = [request responseString];
            DLog(@"%@", responseString); 
        }];
        [request setFailedBlock:^{
            [NinaHelper handleBadRequest:request sender:nil];
        }];
        
        [NinaHelper signRequest:request];
        [request startAsynchronous];
        
        [self.navigationController popViewControllerAnimated:TRUE];
        
    }
    
}



#pragma mark - View lifecycle

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	self.navigationController.navigationBar.translucent = YES;	
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
	self.navigationController.navigationBar.translucent = NO;    
}

//Displays image, but we need to download it, as displayData only has url initially -iMack
- (void)viewDidLoad {
	[super viewDidLoad];

	NSURL *url = [NSURL URLWithString:photo.iphone_url];
        
    if ( photo.mine ){
        UIBarButtonItem *shareButton =  [[UIBarButtonItem  alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showAccountSheet)];
        self.navigationItem.rightBarButtonItem = shareButton;
        [shareButton release];
    }
    
	
	_request =  [[ASIHTTPRequest  alloc]  initWithURL:url];
	[self becomeFirstResponder];
	
	imageView.hidden = TRUE;
    [_request setDownloadCache:[ASIDownloadCache sharedCache]];
	[_request setDownloadProgressDelegate:progressView];
	[_request setDelegate:self];
	[_request startAsynchronous];
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)requestFailed:(ASIHTTPRequest *)request{
	[NinaHelper handleBadRequest:request sender:self];
}

- (void)requestFinished:(ASIHTTPRequest *)request{

    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.progressView.hidden = TRUE;
    if ([request responseStatusCode] != 200){
        [NinaHelper handleBadRequest:request sender:self];
    } else {
        self.imageView.image = [UIImage imageWithData:[request responseData]]; 
        self.imageView.hidden = FALSE;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	if ([self.navigationController isNavigationBarHidden]){
		[self.navigationController setNavigationBarHidden:NO animated:YES];
	}else{
		[self.navigationController setNavigationBarHidden:YES animated:YES];
	}
}

-(BOOL) userInteractionEnabled{
	return YES;
}

-(BOOL) canBecomeFirstResponder{
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)dealloc {
    [_request cancel];
    _request.delegate = nil;
    [_request release];
	[imageView release];
	[photo release];
	[progressView release];
	[super dealloc];
}

@end
