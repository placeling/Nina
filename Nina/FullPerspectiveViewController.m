//
//  FullPerspectiveViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-10-12.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FullPerspectiveViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MemberProfileViewController.h"
#import "NinaHelper.h"

@implementation FullPerspectiveViewController

@synthesize perspective, userImage, upvoteButton, memoText,titleLabel, scrollView;
@synthesize tapGesture;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidLoad{
    CGFloat verticalCursor = self.memoText.frame.origin.y;;
    self.perspective = perspective;
    self.memoText.text = perspective.notes;
    
    self.titleLabel.text = perspective.user.username;
    
    self.titleLabel.userInteractionEnabled = YES;
    self.tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAuthoringUser)] autorelease];
    [self.titleLabel addGestureRecognizer:self.tapGesture];
    
    //cell.memoText.backgroundColor = [UIColor grayColor];
    
    if (perspective.mine){
        //can't star own perspective
        [self.upvoteButton setHidden:true];
    } else {
        [self.upvoteButton setHidden:false];
        if(perspective.starred){
            [self.upvoteButton setImage:[UIImage imageNamed:@"starred.png"] forState:UIControlStateNormal];
        } else {
            [self.upvoteButton setImage:[UIImage imageNamed:@"unstarred.png"] forState:UIControlStateNormal];
        }
    }
    
    self.userImage.photo = perspective.user.profilePic;
    [self.userImage loadImage];
    
    self.memoText.backgroundColor = [UIColor clearColor];
    
    if(perspective.photos && perspective.photos.count > 0){
        //CGRect scrollFrame = self.scrollView.frame;
        
        //[self.scrollView setFrame:CGRectMake(scrollFrame.origin.x, verticalCursor, scrollFrame.size.width, 160)];
        
        CGFloat cx = 2;
        for ( Photo* photo in [perspective.photos reverseObjectEnumerator] ){
            
            CGRect rect = CGRectMake(cx, 3, 152, 152);
            AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:rect];
            [imageView setPhoto:photo]; 
            [imageView loadImageFromPhoto:photo]; 
            imageView.userInteractionEnabled = TRUE;
            
            [self.scrollView addSubview:imageView];
            
            cx += imageView.frame.size.width+2;
            
            [imageView release];
        }
        
        //more then 2 photos means a scroll, otherwise click should go to page
        /*
         if ([perspective.photos count] > 2){
         cell.scrollView.userInteractionEnabled = true;
         } else {
         cell.scrollView.userInteractionEnabled = false;
         }*/
        
        [self.scrollView setContentSize:CGSizeMake(cx, [self.scrollView bounds].size.height)];
    }else{
        self.scrollView.hidden = TRUE; //remove from view
    }
}

-(void) viewWillAppear:(BOOL)animated{
    [StyleHelper styleBackgroundView:self.view];
    [StyleHelper styleNavigationBar:self.navigationController.navigationBar];

    self.userImage.layer.cornerRadius = 8.0f;
    self.userImage.layer.borderWidth = 1.0f;
    self.userImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.userImage.layer.masksToBounds = YES;
    
    
    [self.scrollView setCanCancelContentTouches:NO];
    
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.pagingEnabled = YES;
}

-(IBAction) showAuthoringUser{
    MemberProfileViewController *memberProfileViewController = [[MemberProfileViewController alloc] init];
    
    memberProfileViewController.user = self.perspective.user;
    
    [self.navigationController pushViewController:memberProfileViewController animated:TRUE];

    [memberProfileViewController release];
}

-(IBAction)toggleStarred{
    
    NSString *urlText;
    
    if (self.perspective.starred){
        urlText = [NSString stringWithFormat:@"%@/v1/perspectives/%@/unstar", [NinaHelper getHostname], self.perspective.perspectiveId];
        [self.upvoteButton setImage:[UIImage imageNamed:@"unstarred.png"] forState:UIControlStateNormal];
        self.perspective.starred = false;
    } else {
        urlText = [NSString stringWithFormat:@"%@/v1/perspectives/%@/star", [NinaHelper getHostname], self.perspective.perspectiveId];
        [self.upvoteButton setImage:[UIImage imageNamed:@"starred.png"] forState:UIControlStateNormal];
        self.perspective.starred = true;
    }
    
    NSURL *url = [NSURL URLWithString:urlText];
    
    ASIFormDataRequest  *request =  [[[ASIFormDataRequest  alloc]  initWithURL:url] autorelease];
    
    request.delegate = self;
    request.tag = 5;
    
    [request setRequestMethod:@"POST"];
    [NinaHelper signRequest:request];
    [request startAsynchronous];
}


-(void) dealloc{
    [perspective release];
    [userImage release];
    [upvoteButton release];
    [memoText release];
    [titleLabel release];
    [scrollView release];
    [tapGesture release];
    [super dealloc];
}

-(void)requestFailed:(ASIHTTPRequest *)request{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [NinaHelper handleBadRequest:request sender:self];
}


- (void)requestFinished:(ASIHTTPRequest *)request{    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (200 != [request responseStatusCode]){
		[NinaHelper handleBadRequest:request sender:self];
	} else {
        NSString *responseString = [request responseString];
        DLog(@"%@", responseString);
    }

}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
