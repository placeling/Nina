//
//  AsyncImageView.h
//  Postcard
//
//  Created by markj on 2/18/09.
//  Copyright 2009 Mark Johnson. You have permission to copy parts of this code into your own projects for any use.
//  www.markj.net
//

#import <UIKit/UIKit.h>
#import "NinaHelper.h"
#import "ASIHTTPRequestDelegate.h"
#import "ASIHTTPRequest.h"
#import "Photo.h"


@interface AsyncImageView : UIImageView<ASIHTTPRequestDelegate> {
	//could instead be a subclass of UIImageView instead of UIView, depending on what other features you want to to build into this class?

	ASIHTTPRequest *_request; 	
    NSMutableData* data; 
    Photo *_photo;
	
}

@property(nonatomic, retain) Photo *photo;

- (void)loadImageFromPhoto:(Photo*)photo;

@end
