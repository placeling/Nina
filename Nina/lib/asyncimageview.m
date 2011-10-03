//
//  AsyncImageView.m
//  Postcard
//
//  Created by markj on 2/18/09.
//  Copyright 2009 Mark Johnson. You have permission to copy parts of this code into your own projects for any use.
//  www.markj.net
//

#import "AsyncImageView.h"
#import "ASIDownloadCache.h"
#import "UIImage+Resize.h"
#import "PictureViewController.h"

@implementation AsyncImageView

@synthesize photo=_photo;


- (id) initWithPhoto:(Photo *)photo{
    if(self = [super init]){
        self.photo = photo;        
	}
	return self;    
}

- (void)dealloc {
	[_request cancel];
    _request.delegate = nil;
	[_request release];
	[data release]; 
    [_photo release];
    [super dealloc];
}

-(void) loadImage{
    UIImage *picture;
    if (self.photo.thumb_image){
        picture = self.photo.thumb_image;
    } else {
        
        if (self.photo.thumb_url == nil){
            
        }
        if (_request!=nil) { [_request release]; } //in case we are downloading a 2nd image
        
        DLog(@"Downloading photo for %@", self.photo.photo_id);
        
        NSString *urlText = [NSString stringWithFormat:@"%@", self.photo.thumb_url];
        
        NSURL *url = [[NSURL alloc]initWithString:urlText];
        
        _request = [[ASIHTTPRequest alloc] initWithURL:url];
        
        [url release];
        _request.delegate = self;
        [_request setDownloadCache:[ASIDownloadCache sharedCache]];
        
        [_request startAsynchronous];
        
        picture = [UIImage imageWithContentsOfFile:@"86-camera.png"];
        self.photo.thumb_image = picture; //holder for now
        
    }
    
    for (UIView *subView in self.subviews){
        [subView removeFromSuperview];
    }
    
    //make sizing choices based on your needs, experiment with these. maybe not all the calls below are needed.
    self.contentMode = UIViewContentModeScaleAspectFit;
    
    CGSize size = self.frame.size;
    
    
    self.image = [picture
                  thumbnailImage:MIN(size.width, size.height)
                  transparentBorder:1
                  cornerRadius:1
                  interpolationQuality:kCGInterpolationHigh ];
                  
    [self setNeedsLayout]; 
}


- (void)loadImageFromPhoto:(Photo*)photo{
    self.photo = photo;
    [self loadImage];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    if ([touch view] == self){
        DLog(@"TOUCH ON IMAGEVIEW"); 
        
        PictureViewController *pictureViewController = [[PictureViewController alloc] init];
        pictureViewController.photo = self.photo;
        
        id nextResponder = [self nextResponder];
        while (nextResponder != nil){
            if ([nextResponder isKindOfClass:[UIViewController class]]) {
                [[(UIViewController*)nextResponder navigationController] pushViewController:pictureViewController animated:TRUE];
            }
            nextResponder = [nextResponder nextResponder];
        }
        
        [pictureViewController release];
        
    }
    
}

#pragma mark ASIhttprequest

- (void)requestFailed:(ASIHTTPRequest *)request{
	[NinaHelper handleBadRequest:request sender:nil];
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    
	if (200 != [request responseStatusCode]){
		[NinaHelper handleBadRequest:request sender:nil];
	} else {
		// Store incoming data into a string
		NSData *responseData = [request responseData];
        
        DLog(@"receive image of size: %i", [responseData length])
        
        //make an image view for the image
        UIImage *picture = [UIImage imageWithData:responseData];
        
        self.photo.thumb_image = picture;
        
        [self loadImage];
	}
    
}


@end
