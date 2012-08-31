//
//  CustomSegmentedControl.m
//  CustomSegmentedControls
//
//  Created by Peter Boctor on 12/10/10.
//
// Copyright (c) 2011 Peter Boctor
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE
//

#import "CustomSegmentedControl.h"

@implementation CustomSegmentedControl
@synthesize buttons, selectedSegmentIndex;

- (id) initWithSegmentCount:(NSUInteger)segmentCount segmentsize:(CGSize)segmentsize dividerImage:(UIImage*)dividerImage tag:(NSInteger)objectTag delegate:(NSObject <CustomSegmentedControlDelegate>*)customSegmentedControlDelegate
{
  if (self = [super init])
  {
    // The tag allows callers withe multiple controls to distinguish between them
    self.tag = objectTag;
    
    // Set the delegate
    delegate = customSegmentedControlDelegate;

    // Adjust our width based on the number of segments & the width of each segment and the sepearator
    self.frame = CGRectMake(0, 0, (segmentsize.width * segmentCount), segmentsize.height);

    // Initalize the array we use to store our buttons
      NSMutableArray *initButtons = [[NSMutableArray alloc] initWithCapacity:segmentCount];
    self.buttons = initButtons;
    [initButtons release];

    // horizontalOffset tracks the proper x value as we add buttons as subviews
    CGFloat horizontalOffset = 0;
    
    // Iterate through each segment
    for (NSUInteger i = 0 ; i < segmentCount ; i++)
    {
      // Ask the delegate to create a button
      UIButton* button = [delegate buttonFor:self atIndex:i];

      // Register for touch events
      [button addTarget:self action:@selector(touchDownAction:) forControlEvents:UIControlEventTouchDown];
      [button addTarget:self action:@selector(touchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
      [button addTarget:self action:@selector(otherTouchesAction:) forControlEvents:UIControlEventTouchUpOutside];
      [button addTarget:self action:@selector(otherTouchesAction:) forControlEvents:UIControlEventTouchDragOutside];
      [button addTarget:self action:@selector(otherTouchesAction:) forControlEvents:UIControlEventTouchDragInside];
      
      // Add the button to our buttons array
      [buttons addObject:button];

      // Set the button's x offset
      button.frame = CGRectMake(horizontalOffset, 0.0, button.frame.size.width, button.frame.size.height);

      // Add the button as our subview
      [self addSubview:button];

      // Add the divider unless we are at the last segment
        if (false)//(i != segmentCount - 1)
      {
        UIImageView* divider = [[[UIImageView alloc] initWithImage:dividerImage] autorelease];
        divider.frame = CGRectMake(horizontalOffset + segmentsize.width, 0.0, dividerImage.size.width, dividerImage.size.height);
        [self addSubview:divider];
      }

      // Advance the horizontal offset
        horizontalOffset = horizontalOffset + segmentsize.width;// + dividerImage.size.width;
    }
  }

  self.selectedSegmentIndex = 0;
  return self;
}

-(void) dimAllButtonsExcept:(UIButton*)selectedButton
{
  for (UIButton* button in buttons)
  {
    if (button == selectedButton)
    {
      button.selected = YES;
      button.highlighted = button.selected ? NO : YES;
        
        
        if ( [buttons indexOfObject:button] == 0 ){
            UIImageView *iconView = (UIImageView*)[button viewWithTag:26];
            [iconView setImage:[UIImage imageNamed:@"SelectedMeIcon.png"]];
        } else if ( [buttons indexOfObject:button] == 1 ){
            UIImageView *iconView = (UIImageView*)[button viewWithTag:26];
            [iconView setImage:[UIImage imageNamed:@"SelectedNetworkIcon.png"]];            
        } else if ( [buttons indexOfObject:button] == 2 ){
            UIImageView *iconView = (UIImageView*)[button viewWithTag:26];
            [iconView setImage:[UIImage imageNamed:@"SelectedEveryoneIcon.png"]];
        }
    }
    else
    {
      button.selected = NO;
      button.highlighted = NO;
        if ( [buttons indexOfObject:button] == 0 ){
            UIImageView *iconView = (UIImageView*)[button viewWithTag:26];
            [iconView setImage:[UIImage imageNamed:@"UnselectedMeIcon.png"]];
        } else if ( [buttons indexOfObject:button] == 1 ){
            UIImageView *iconView = (UIImageView*)[button viewWithTag:26];
            [iconView setImage:[UIImage imageNamed:@"UnselectedNetworkIcon.png"]];
        } else if ( [buttons indexOfObject:button] == 2 ){
            UIImageView *iconView = (UIImageView*)[button viewWithTag:26];
            [iconView setImage:[UIImage imageNamed:@"UnselectedEveryoneIcon.png"]];
        }
    }
  }
}

- (void)touchDownAction:(UIButton*)button
{
  [self dimAllButtonsExcept:button];
  
  if ([delegate respondsToSelector:@selector(touchDownAtSegmentIndex:)])
    [delegate touchDownAtSegmentIndex:[buttons indexOfObject:button]];
}

- (void)touchUpInsideAction:(UIButton*)button
{
  [self dimAllButtonsExcept:button];

  if ([delegate respondsToSelector:@selector(touchUpInsideSegmentIndex:)])
    [delegate touchUpInsideSegmentIndex:[buttons indexOfObject:button]];
    selectedSegmentIndex = [buttons indexOfObject:button];
}

- (void)otherTouchesAction:(UIButton*)button
{
  [self dimAllButtonsExcept:button];
}

- (void)dealloc
{
  [super dealloc];
  [buttons release];
}


@end
