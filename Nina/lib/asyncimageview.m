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
#import "PictureViewController.h"
#import "UIImageView+WebCache.h"

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
    if (self.photo.thumb_image){
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = true;
        [self setImage:self.photo.thumb_image];
    } else {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = true;
        
        if (self.photo.thumb_url == nil){
            return;
        }
        if (_request!=nil) { [_request release]; } //in case we are downloading a 2nd image
        
        DLog(@"Downloading photo for %@", self.photo.photo_id);
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && self.photo.iphone_url) {
            [self setImageWithURL:[NSURL URLWithString:self.photo.iphone_url] placeholderImage:[UIImage imageNamed:@"DefaultPhoto@2x.png"]];
        } else {
            [self setImageWithURL:[NSURL URLWithString:self.photo.thumb_url] placeholderImage:[UIImage imageNamed:@"DefaultPhoto.png"]];
        }
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
