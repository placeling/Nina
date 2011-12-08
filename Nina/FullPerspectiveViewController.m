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
#import "LoginController.h"
#import "PlacePageViewController.h"
#import "GenericWebViewController.h"
#import "UIImageView+WebCache.h"
#import "asyncimageview.h"

@implementation FullPerspectiveViewController

@synthesize perspective, userImage, upvoteButton, memoText,titleLabel, scrollView;
@synthesize tapGesture, flagLabel, flagTap, moreOnWeb;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



-(IBAction) goToWeb{
    
    if (perspective.url && [perspective.url length] > 0){
        GenericWebViewController *genericWebViewController = [[GenericWebViewController alloc] initWithUrl:perspective.url];
        
        //genericWebViewController.title = @"Terms & Conditions";
        [self.navigationController pushViewController:genericWebViewController animated:true];
        
        [genericWebViewController release];
    }
}

-(void) mainContentLoad {
    self.perspective = perspective;
    self.memoText.text = perspective.notes;
    BOOL hasContent = false;
    
    if ([perspective.notes length] > 0){
        hasContent = true;
    }
    
    self.titleLabel.text = perspective.user.username;
    
    self.titleLabel.userInteractionEnabled = YES;
    self.tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAuthoringUser)] autorelease];
    [self.titleLabel addGestureRecognizer:self.tapGesture];
    
    NSString *currentUser = [NinaHelper getUsername];
    
    // Here we use the new provided setImageWithURL: method to load the web image
    [self.userImage setImageWithURL:[NSURL URLWithString:perspective.user.profilePic.thumb_url]
                   placeholderImage:[UIImage imageNamed:@"default_profile_image.png"]];
    
    self.memoText.backgroundColor = [UIColor clearColor];
    
    if(perspective.photos && perspective.photos.count > 0){
        hasContent = true;
        CGFloat cx = 2;
        for ( Photo* photo in [perspective.photos reverseObjectEnumerator] ){
            
            CGRect rect = CGRectMake(cx, 3, 152, 152);
            AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:rect];
            [imageView setPhoto:photo]; 
            [imageView loadImageFromPhoto:photo]; 
            imageView.userInteractionEnabled = TRUE;
            
            [imageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
            [imageView.layer setBorderWidth: 5.0];
            
            [self.scrollView addSubview:imageView];
            
            cx += imageView.frame.size.width+2;
            
            [imageView release];
        }
        
        
        [self.scrollView setContentSize:CGSizeMake(cx, [self.scrollView bounds].size.height)];
    }else{
        self.scrollView.hidden = TRUE; //remove from view
    }
    
    
    if (perspective.mine){
        //can't star own perspective
        [self.upvoteButton setHidden:true];
        // Manually check if belongs to newly logged in user
    } else if (currentUser && currentUser.length >0 && [currentUser isEqualToString:self.perspective.user.username]) {
        [self.upvoteButton setHidden:true];
    } else {
        [self.upvoteButton setHidden:false];
        if(perspective.starred){
            [self.upvoteButton setImage:[UIImage imageNamed:@"ReMark.png"] forState:UIControlStateNormal];
        } else {
            [self.upvoteButton setImage:[UIImage imageNamed:@"UnReMark.png"] forState:UIControlStateNormal];
        }
    }
    
    if (hasContent && self.perspective.mine == false){
        self.flagTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flagPerspective)] autorelease];
        [self.flagLabel addGestureRecognizer:self.flagTap];
        self.flagLabel.userInteractionEnabled = TRUE;

    } else {
        self.flagLabel.hidden = TRUE;
    }

    
}

-(void) viewDidLoad{
    [self mainContentLoad];
}

-(void) viewWillAppear:(BOOL)animated{
    [StyleHelper styleBackgroundView:self.view];
    [StyleHelper styleNavigationBar:self.navigationController.navigationBar];

    self.userImage.layer.cornerRadius = 8.0f;
    self.userImage.layer.borderWidth = 1.0f;
    self.userImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.userImage.layer.masksToBounds = YES;
    
    if (perspective.url && [perspective.url length] > 0){
        self.moreOnWeb.hidden = FALSE;
    }else {
        self.moreOnWeb.hidden = TRUE;
    }
    
    if ([self.perspective.photos count] == 0){
        //extend text all the way down if no photos
        self.scrollView.hidden = true;
        [self.memoText setFrame:CGRectMake(self.memoText.frame.origin.x, self.memoText.frame.origin.y, self.memoText.frame.size.width, self.view.frame.size.height - self.memoText.frame.origin.y - self.moreOnWeb.frame.size.height)];
        [self.moreOnWeb setFrame:CGRectMake(self.moreOnWeb.frame.origin.x, self.memoText.frame.origin.y + self.memoText.frame.size.height, self.moreOnWeb.frame.size.width, self.moreOnWeb.frame.size.height)];
    } else {
        [self.scrollView setCanCancelContentTouches:NO];
        
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.clipsToBounds = NO;
        self.scrollView.scrollEnabled = YES;
        self.scrollView.pagingEnabled = YES;
    }
    [self.memoText flashScrollIndicators];

}

-(IBAction) showAuthoringUser{
    MemberProfileViewController *memberProfileViewController = [[MemberProfileViewController alloc] init];
    
    memberProfileViewController.user = self.perspective.user;
    
    [self.navigationController pushViewController:memberProfileViewController animated:TRUE];

    [memberProfileViewController release];
}

-(IBAction)toggleStarred{
    NSString *currentUser = [NinaHelper getUsername];
    
    if (!currentUser || currentUser.length == 0) {
        UIAlertView *baseAlert;
        NSString *alertMessage = @"Sign up or log in and you can star people's notes & photos";
        baseAlert = [[UIAlertView alloc] 
                     initWithTitle:nil message:alertMessage 
                     delegate:self cancelButtonTitle:@"Not Now" 
                     otherButtonTitles:@"Let's Go", nil];
        baseAlert.tag = 778;        
        [baseAlert show];
        [baseAlert release];
    } else {
        NSString *urlText;
        
        if (self.perspective.starred){
            [self.perspective unstar];
            urlText = [NSString stringWithFormat:@"%@/v1/perspectives/%@/unstar", [NinaHelper getHostname], self.perspective.perspectiveId];
            [self.upvoteButton setImage:[UIImage imageNamed:@"UnReMark.png"] forState:UIControlStateNormal];
            self.perspective.starred = false;
        } else {
            [self.perspective star];
            urlText = [NSString stringWithFormat:@"%@/v1/perspectives/%@/star", [NinaHelper getHostname], self.perspective.perspectiveId];
            [self.upvoteButton setImage:[UIImage imageNamed:@"ReMark.png"] forState:UIControlStateNormal];
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
}


-(void) dealloc{
    [perspective release];
    [userImage release];
    [upvoteButton release];
    [memoText release];
    [titleLabel release];
    [scrollView release];
    [tapGesture release];
    [flagLabel  release];
    [flagTap release];
    
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

#pragma mark -
#pragma mark LoginController Delegate Methods
-(void) loadContent {
    // Go back through navigation stack
    for (int i=[[[self navigationController] viewControllers] count] - 2; i > 0; i--) {
        NSObject *parentController = [[[self navigationController] viewControllers] objectAtIndex:i];
        
        if ([parentController isKindOfClass:[MemberProfileViewController class]]) {
            MemberProfileViewController *profile = (MemberProfileViewController *)[[[self navigationController] viewControllers] objectAtIndex:i];
            [profile mainContentLoad];
        } else if ([parentController isKindOfClass:[PlacePageViewController class]]) {
            PlacePageViewController *place = (PlacePageViewController *)[[[self navigationController] viewControllers] objectAtIndex:i];
            [place mainContentLoad];
        } else if ([parentController isKindOfClass:[FullPerspectiveViewController class]]) {
            FullPerspectiveViewController *existingPerspective = (FullPerspectiveViewController *)[[[self navigationController] viewControllers] objectAtIndex:i];
            [existingPerspective mainContentLoad];
        }
    }
    
    [self mainContentLoad];
}


-(void) flagPerspective{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flag For Moderation" 
                                                    message:[NSString stringWithFormat: @"Are you sure you want to flag\nthis as inappropriate?", self.perspective.user.username] 
                                                   delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
    [alert release];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 778) {
        if (buttonIndex == 1) {
            LoginController *loginController = [[LoginController alloc] init];
            loginController.delegate = self;
            
            UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:loginController];
            [self.navigationController presentModalViewController:navBar animated:YES];
            [navBar release];
            
            [loginController release];
        }
    } else {
        if (buttonIndex == 0){
            DLog(@"Cancel flaggin");
        } else {
            DLog(@"Flagging %@'s perspective", self.perspective.user.username);
            
            NSString *urlText = [NSString stringWithFormat:@"%@/v1/perspectives/%@/flag", [NinaHelper getHostname], self.perspective.perspectiveId];
            self.flagLabel.userInteractionEnabled = FALSE;
            self.flagLabel.textColor = [UIColor blackColor];
            self.flagLabel.text = @"Flagged";
            
            NSURL *url = [NSURL URLWithString:urlText];
            
            ASIFormDataRequest  *request =  [[[ASIFormDataRequest  alloc]  initWithURL:url] autorelease];
            
            request.delegate = self;
            request.tag = 7;
            
            [request setRequestMethod:@"POST"];
            [NinaHelper signRequest:request];
            [request startAsynchronous];
        }
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
