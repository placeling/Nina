//
//  PictureViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-09-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "NinaHelper.h"
#import "Photo.h"
#import "Perspective.h"

@interface PictureViewController : UIViewController<UIActionSheetDelegate>{
    IBOutlet UIImageView *imageView;
    IBOutlet UIProgressView *progressView;
    UIImage *image;
    Photo *photo;
    ASIHTTPRequest  *_request;
}

@property(nonatomic,retain) Photo *photo;

@property(nonatomic,retain) IBOutlet UIImageView *imageView;
@property(nonatomic,retain) IBOutlet UIProgressView *progressView;


@end
