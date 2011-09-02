//
//  GenericWebViewController.h
//  Nina
//
//  Created by Ian MacKinnon on 11-09-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NinaHelper.h"

@interface GenericWebViewController : UIViewController<UIWebViewDelegate, UIActionSheetDelegate>{
    IBOutlet UIWebView *webView;
    NSString *_url;
}

@property(nonatomic, retain) IBOutlet UIWebView *webView;
@property(nonatomic, retain) NSString *url;

- (id)initWithUrl:(NSString *)url;

@end
