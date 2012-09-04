//
//  CommentViewController.m
//  Nina
//
//  Created by Ian MacKinnon on 12-08-09.
//
//

#import "CommentViewController.h"
#import "CommentTableViewCell.h"

@interface CommentViewController ()
-(void) loadComments;
@end

@implementation CommentViewController

@synthesize perspective, tableView=_tableView, containerView, comments, textView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
    
    // self.view.backgroundColor = [UIColor colorWithRed:219.0f/255.0f green:226.0f/255.0f blue:237.0f/255.0f alpha:1];
    
    self.comments = [[[NSMutableArray alloc] init] autorelease];
    
	self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 240, 40)];
    self.textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	self.textView.minNumberOfLines = 1;
	self.textView.maxNumberOfLines = 6;
	self.textView.returnKeyType = UIReturnKeyGo; //just as an example
	self.textView.font = [UIFont systemFontOfSize:15.0f];
	self.textView.delegate = self;
    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.textView.backgroundColor = [UIColor whiteColor];
    
    // textView.text = @"test\n\ntest";
	// textView.animateHeightChange = NO; //turns off animation
	
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, 248, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [self.containerView addSubview:imageView];
    [imageView release];
    [self.containerView addSubview:self.textView];
    [self.containerView addSubview:entryImageView];    
    
    UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
	doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(self.containerView.frame.size.width - 69, 8, 63, 27);
    doneButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[doneButton setTitle:@"Post" forState:UIControlStateNormal];
    
    [doneButton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneButton.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[doneButton addTarget:self action:@selector(submitComment) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    [doneButton setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
	[self.containerView addSubview:doneButton];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    dataLoaded = false;
    [self loadComments];
    
    self.navigationItem.title = @"Comments";
    
}

-(void)loadComments{
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    
    NSString *targetURL = [NSString stringWithFormat:@"/v1/perspectives/%@/placemark_comments", self.perspective.perspectiveId];
    
    [objectManager.mappingProvider setMapping:[PlacemarkComment getObjectMapping] forKeyPath:@"placemark_comments"];
    [objectManager loadObjectsAtResourcePath:targetURL usingBlock:^(RKObjectLoader* loader) {
        loader.userData = [NSNumber numberWithInt:130]; //use as a tag
        loader.delegate = self;
    }];
    
    loadingMore = true;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [StyleHelper styleBackgroundView:self.tableView];
}

-(IBAction)submitComment{
    DLog(@"Posting comment: %@", self.textView.text);
    
    PlacemarkComment *comment = [PlacemarkComment new];
    comment.perspectiveId = self.perspective.perspectiveId;
    comment.comment = self.textView.text;
    
    [doneButton setEnabled:false];
    [self.textView resignFirstResponder];
    
     [[RKObjectManager sharedManager] postObject:comment usingBlock:^(RKObjectLoader *loader){
        loader.delegate = self;
        loader.userData = [NSNumber numberWithInt:131]; //use as a tag
     }];
    [comment release];
}


#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    loadingMore = false;
    dataLoaded = true;
    [doneButton setEnabled:true];
    
    if ( [(NSNumber*)objectLoader.userData intValue] == 130){
        [self.comments removeAllObjects];
        for (PlacemarkComment *comment in objects){
            [self.comments addObject:comment];
        }
        [self.tableView reloadData];
    } else if ( [(NSNumber*)objectLoader.userData intValue] == 131){
        [self.comments addObjectsFromArray:objects]; //should just be one
        self.textView.text = @"";
        [self.tableView reloadData];
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: [self.comments count]-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    //objectLoader.response.
    loadingMore = false;
    [doneButton setEnabled:true];
    dataLoaded = true;
    [NinaHelper handleBadRKRequest:objectLoader.response sender:self];
    DLog(@"Encountered an error: %@", error);
}



//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	containerView.frame = containerFrame;
    
    CGSize kbSize = [[[note userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
	[UIView commitAnimations];
    
    NSIndexPath* ipath = [NSIndexPath indexPathForRow:[self.comments count]-1 inSection:0];
    [self.tableView scrollToRowAtIndexPath: ipath atScrollPosition:UITableViewScrollPositionBottom animated: YES];

}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	containerView.frame = containerFrame;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
	
	// commit animations
	[UIView commitAnimations];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	containerView.frame = r;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // [self.textView resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return MAX([[self comments] count], 1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     if (indexPath.row >= [[self comments] count]){
        return 70;
    } else {
        PlacemarkComment *comment = [comments objectAtIndex:indexPath.row];
        return [CommentTableViewCell cellHeightForComment:comment];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *commentCellIdentifier = @"CommentCell";
    static NSString *infoCellIdentifier = @"infoCell";
    
    PlacemarkComment *comment;
    UITableViewCell *cell;
    
    if (indexPath.row ==0 && !dataLoaded){
        //spinner wait, don't actually recycle
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SpinnerTableCell" owner:self options:nil];
        
        for(id item in objects){
            if ( [item isKindOfClass:[UITableViewCell class]]){
                cell = item;
                break;
            }
        }
        
    } else if (dataLoaded && [[self comments] count] ==0){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:infoCellIdentifier] autorelease];
        
        UITextView *loginText = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 90)];
        
        loginText.text = @"Add the first comment";
        loginText.textAlignment = UITextAlignmentCenter;
        
        loginText.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        loginText.textColor = [UIColor grayColor];
        loginText.tag = 778;
        [loginText setBackgroundColor:[UIColor clearColor]];
        [loginText setUserInteractionEnabled:FALSE];
        
        [cell addSubview:loginText];
        [loginText release];
        [cell setUserInteractionEnabled:YES];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell setUserInteractionEnabled:true];
        return cell;
    } else {
        comment = [[self comments] objectAtIndex:indexPath.row];
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CommentTableViewCell" owner:self options:nil];
        
        for(id item in objects){
            if ( [item isKindOfClass:[UITableViewCell class]]){
                CommentTableViewCell *pcell = (CommentTableViewCell *)item;
                [CommentTableViewCell setupCell:pcell forComment:comment];
                cell = pcell;
                break;
            }
        }
        [cell setUserInteractionEnabled:false];
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.textView becomeFirstResponder];
}

-(void)dealloc{
    [[[[RKObjectManager sharedManager] client] requestQueue] cancelRequestsWithDelegate:self];

    [perspective release];
    [_tableView release];
    [containerView release];
    
    [textView release];
    [comments release];
    
    [super dealloc];
}

@end
