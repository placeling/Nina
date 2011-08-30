//
//  EditPerspectiveViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 11-08-29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditPerspectiveViewController.h"

@implementation EditPerspectiveViewController
@synthesize perspective=_perspective;
@synthesize memoTextView;
@synthesize photoButton;

- (id) initWithPerspective:(Perspective *)perspective{
    self = [super init];
    if (self) {
        self.perspective = perspective;
    }
    return self;
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
 
    NSString *placeName = self.perspective.place.name;
    self.navigationItem.title = placeName;
    self.memoTextView.text = self.perspective.notes;
    
    UIBarButtonItem *saveButton =  [[UIBarButtonItem  alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(savePerspective)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];
    
    [self.memoTextView becomeFirstResponder];
    
}

-(IBAction)savePerspective{
    
}

-(IBAction)showPhotos{
    [self.memoTextView resignFirstResponder];
    
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)dealloc{
    [memoTextView release];
    [photoButton release];
    [Perspective release];
    
    [super dealloc];
}

@end
