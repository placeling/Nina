//
//  AsyncImageView.m
//  Postcard
//
//  Created by markj on 2/18/09.
//  Copyright 2009 Mark Johnson. You have permission to copy parts of this code into your own projects for any use.
//  www.markj.net
//

#import "AsyncImageView.h"
#import "UIImageView+WebCache.h"
#import "FGalleryViewController.h"
#import "UserManager.h"

@implementation AsyncImageView

@synthesize photo=_photo, networkGallery;


- (id) initWithPhoto:(Photo *)photo{
    if(self = [super init]){
        self.photo = photo;        
	}
	return self;    
}

- (void)dealloc {
	[data release];
    [networkGallery release];
    [_photo release];
    [super dealloc];
}

-(void) loadImage{
    if (self.photo.thumb_image){
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = true;
        [self setImage:self.photo.thumb_image];
    } else {
        
        if (self.photo.thumbUrl == nil){
            return;
        }
        
        DLog(@"Downloading photo for %@", self.photo.photoId);
        
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = true;
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && self.photo.iphoneUrl) {
            [self setImageWithURL:[NSURL URLWithString:self.photo.iphoneUrl] placeholderImage:[UIImage imageNamed:@"DefaultPhoto.png"]];
        } else {
            [self setImageWithURL:[NSURL URLWithString:self.photo.thumbUrl] placeholderImage:[UIImage imageNamed:@"DefaultPhoto.png"]];
        }
    }
}


- (void)loadImageFromPhoto:(Photo*)photo{
    self.photo = photo;
    [self loadImage];
}

-(void) handleTrashButtonTouch:(id)sender{    
    
    UIAlertView *baseAlert;
    NSString *alertMessage = @"Are you sure you want to delete this photo?";
    baseAlert = [[UIAlertView alloc]
                 initWithTitle:nil message:alertMessage
                 delegate:self cancelButtonTitle:@"No"
                 otherButtonTitles:@"Yes", nil];
    
    [baseAlert show];
    [baseAlert release];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1){
        Photo *photo = [self.photo.perspective.photos objectAtIndex:[self.photo.perspective.photos count] - (self.networkGallery.currentIndex +1)];
        [self.photo.perspective.photos removeObject:photo];
        self.photo.perspective.modified = true;
        
        [UserManager updatePerspective:self.photo.perspective];
        
        [self.networkGallery.navigationController popViewControllerAnimated:true];
        
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        [objectManager deleteObject:photo usingBlock:^(RKObjectLoader *loader) {
            
        }];
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if ([touch view] == self){
        DLog(@"TOUCH ON IMAGEVIEW"); 
        
        //FGalleryViewController *networkGallery;
        
        if ( self.photo.perspective.mine ){
            UIImage *trashIcon = [UIImage imageNamed:@"photo-gallery-trashcan.png"];
            
            UIBarButtonItem *trashButton = [[[UIBarButtonItem alloc] initWithImage:trashIcon style:UIBarButtonItemStylePlain target:self action:@selector(handleTrashButtonTouch:)] autorelease];
            NSArray *barItems = [NSArray arrayWithObjects:trashButton, nil];            
            
            self.networkGallery = [[FGalleryViewController alloc] initWithPhotoSource:self.photo.perspective barItems:barItems];
        } else {
            self.networkGallery = [[FGalleryViewController alloc] initWithPhotoSource:self.photo.perspective];
        }

        self.networkGallery.startingIndex = [self.photo.perspective.photos count] - [self.photo.perspective.photos indexOfObject:self.photo] -1;
        id nextResponder = [self nextResponder];
        while (nextResponder != nil){
            if ([nextResponder isKindOfClass:[UIViewController class]]) {
                [[(UIViewController*)nextResponder navigationController] pushViewController:networkGallery animated:TRUE];
            }
            nextResponder = [nextResponder nextResponder];
        }
        
        [networkGallery release];
    }    
}

@end
