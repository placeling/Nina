//
//  BookmarkTableViewCell.m
//  Nina
//
//  Created by Ian MacKinnon on 11-08-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookmarkTableViewCell.h"

@implementation BookmarkTableViewCell

@synthesize place, bookmarkButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void) dealloc{
    [place release];
    [bookmarkButton release];
    [super dealloc];
}

-(IBAction) bookmark {
    NSString *urlText = [NSString stringWithFormat:@"%@/v1/places/%@/perspectives", [NinaHelper getHostname], self.place.pid];
    
    NSURL *url = [NSURL URLWithString:urlText];
    
    CLLocationManager *locationManager = [LocationManagerManager sharedCLLocationManager];
    CLLocation *location =  locationManager.location;
    
    NSString* lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString* lng = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    float accuracy = pow(location.horizontalAccuracy,2)  + pow(location.verticalAccuracy,2);
    accuracy = sqrt( accuracy ); //take accuracy as single vector, rather than 2 values -iMack
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:lat forKey:@"lat"];
    [request setPostValue:lng forKey:@"long"];
    [request setPostValue:[NSString stringWithFormat:@"%f", accuracy] forKey:@"accuracy"];
    
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(bookmarkFinished:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    
    [NinaHelper signRequest:request];
    [request startAsynchronous];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

#pragma mark - View lifecycle


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
