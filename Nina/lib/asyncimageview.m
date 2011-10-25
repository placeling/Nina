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

@synthesize photo=_photo, populate;


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
            return;
        }
        if (_request!=nil) { [_request release]; } //in case we are downloading a 2nd image
        
        DLog(@"Downloading photo for %@", self.photo.photo_id);
        
        NSString *urlText;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && self.photo.iphone_url) {
            urlText = [NSString stringWithFormat:@"%@", self.photo.iphone_url];
        } else {
            urlText = [NSString stringWithFormat:@"%@", self.photo.thumb_url];
        }
        
        NSURL *url = [NSURL URLWithString:urlText];
        if ([url host] == nil) return;
        
        _request = [[ASIHTTPRequest alloc] initWithURL:url];
        
        _request.delegate = self;
        [_request setDownloadCache:[ASIDownloadCache sharedCache]];
        
        [_request startAsynchronous];
        
        if (populate){
            picture = populate.image;
        } else {
            picture = [UIImage imageNamed:@"default_profile_image.png"];
        }
        
        self.photo.thumb_image = picture; //holder for now
        
    }
    
    for (UIView *subView in self.subviews){
        [subView removeFromSuperview];
    }
    
    //make sizing choices based on your needs, experiment with these. maybe not all the calls below are needed.
    self.contentMode = UIViewContentModeScaleAspectFit;
    
    CGSize size =self.frame.size;
    if (size.width == 0 || size.height == 0){
        size.height = 57; //most likely table cases
        size.width = 57;
    }
    
    if (picture.size.width != picture.size.height){
        picture = [picture
                  thumbnailImage:MIN(picture.size.width, picture.size.height)
                  transparentBorder:1
                  cornerRadius:1
                  interpolationQuality:kCGInterpolationHigh ];
    }
        
    self.image = picture;
    
    if (populate){
        populate.image = picture;
        self.hidden = TRUE;
    } else {
        self.hidden = FALSE;
    }
    
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
