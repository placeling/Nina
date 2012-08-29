//
//  NPSPopupWindow.m
//  Nina
//
//  Created by Ian MacKinnon on 12-08-22.
//
//

#import "NPSPopupWindow.h"

#define kShadeViewTag 1000

@interface NPSPopupWindow(Private)
- (id)initWithSuperview:(UIView*)sview;
-(void)doTransitionWithContentFile:(NSString*)fName;
@end

@implementation NPSPopupWindow


+(void)showWindowInsideView:(UIView*)view{
   [[NPSPopupWindow alloc] initWithSuperview:view]; 
}

/**
 * Initializes the class instance, gets a view where the window will pop up in
 * and a file name/ URL
 */

- (id)initWithSuperview:(UIView*)sview{
    
    self = [super init];
    if (self) {
        // Initialization code here.
        bgView = [[[UIView alloc] initWithFrame: sview.bounds] autorelease];
        [sview addSubview: bgView];
        
        // proceed with animation after the bgView was added
        [self performSelector:@selector(doTransitionWithContentFile:) withObject:@"" afterDelay:0.1];
        
        [bgView addSubview:defaultPickerView];
    }
    
    return self;
    
}


#pragma mark - AFPickerViewDataSource

- (NSInteger)numberOfRowsInPickerView:(AFPickerView *)pickerView{
    return 11;
}

- (NSString *)pickerView:(AFPickerView *)pickerView titleForRow:(NSInteger)row{    
    return [NSString stringWithFormat:@"%i", row ];
}

#pragma mark - AFPickerViewDelegate

- (void)pickerView:(AFPickerView *)pickerView didSelectRow:(NSInteger)row{
    //[NSString stringWithFormat:@"%i", row + 1];
}


/**
 * Afrer the window background is added to the UI the window can animate in
 * and load the UIWebView
 */
-(void)doTransitionWithContentFile:(NSString*)fName
{
    //faux view
    UIView* fauxView = [[[UIView alloc] initWithFrame: CGRectMake(10, 10, 200, 200)] autorelease];
    [bgView addSubview: fauxView];
    
    //the new panel
    bigPanelView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, bgView.frame.size.width, bgView.frame.size.height)] autorelease];
    bigPanelView.center = CGPointMake( bgView.frame.size.width/2, bgView.frame.size.height/2);
    
    //add the window background
    UIImageView* background = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popupWindowBack.png"]] autorelease];
    background.center = CGPointMake(bigPanelView.frame.size.width/2, bigPanelView.frame.size.height/2);
    [bigPanelView addSubview: background];
    
    defaultPickerView = [[AFPickerView alloc] initWithFrame:CGRectMake(30.0, 30.0, 126.0, 197.0)];
    defaultPickerView.dataSource = self;
    defaultPickerView.delegate = self;
    [defaultPickerView reloadData];
    
    [bigPanelView addSubview: defaultPickerView];
    
    //add the close button
    int closeBtnOffset = 10;
    UIImage* closeBtnImg = [UIImage imageNamed:@"popupCloseBtn.png"];
    UIButton* closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:closeBtnImg forState:UIControlStateNormal];
    [closeBtn setFrame:CGRectMake( background.frame.origin.x + background.frame.size.width - closeBtnImg.size.width - closeBtnOffset,
                                  background.frame.origin.y ,
                                  closeBtnImg.size.width + closeBtnOffset,
                                  closeBtnImg.size.height + closeBtnOffset)];
    [closeBtn addTarget:self action:@selector(closePopupWindow) forControlEvents:UIControlEventTouchUpInside];
    [bigPanelView addSubview: closeBtn];
    
    //animation options
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionFlipFromRight |
    UIViewAnimationOptionAllowUserInteraction    |
    UIViewAnimationOptionBeginFromCurrentState;
    
    //run the animation
    [UIView transitionFromView:fauxView toView:bigPanelView duration:0.5 options:options completion: ^(BOOL finished) {
        
        //dim the contents behind the popup window
        UIView* shadeView = [[[UIView alloc] initWithFrame:bigPanelView.frame] autorelease];
        shadeView.backgroundColor = [UIColor blackColor];
        shadeView.alpha = 0.3;
        shadeView.tag = kShadeViewTag;
        [bigPanelView addSubview: shadeView];
        [bigPanelView sendSubviewToBack: shadeView];
    }];
}

/**
 * Removes the window background and calls the animation of the window
 */
-(void)closePopupWindow
{
    //remove the shade
    [[bigPanelView viewWithTag: kShadeViewTag] removeFromSuperview];
    [self performSelector:@selector(closePopupWindowAnimate) withObject:nil afterDelay:0.1];
    
}

/**
 * Animates the window and when done removes all views from the view hierarchy
 * since they are all only retained by their superview this also deallocates them
 * finally deallocate the class instance
 */
-(void)closePopupWindowAnimate
{
    
    //faux view
    __block UIView* fauxView = [[UIView alloc] initWithFrame: CGRectMake(10, 10, 200, 200)];
    [bgView addSubview: fauxView];
    
    //run the animation
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionFlipFromLeft |
    UIViewAnimationOptionAllowUserInteraction    |
    UIViewAnimationOptionBeginFromCurrentState;
    
    //hold to the bigPanelView, because it'll be removed during the animation
    [bigPanelView retain];
    
    [UIView transitionFromView:bigPanelView toView:fauxView duration:0.5 options:options completion:^(BOOL finished) {
        
        //when popup is closed, remove all the views
        for (UIView* child in bigPanelView.subviews) {
            [child removeFromSuperview];
        }
        for (UIView* child in bgView.subviews) {
            [child removeFromSuperview];
        }
        [bigPanelView release];
        [bgView removeFromSuperview];
        
        [self release];
    }];
}

@end
