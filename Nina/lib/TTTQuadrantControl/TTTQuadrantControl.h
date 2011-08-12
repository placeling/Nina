// TTTQuadrantControl.h
//
// Copyright (c) 2010 Mattt Thompson
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
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
// SOFTWARE.

#import <UIKit/UIKit.h>

typedef enum {
    TopRightLocation    = 1,
	TopLeftLocation     = 2,
	BottomLeftLocation  = 3,
	BottomRightLocation = 4,
} TTTQuadrantLocation;

@class TTTQuadrantView;

@interface TTTQuadrantControl : UIControl {
	id _delegate;
	
	TTTQuadrantLocation _activeLocation;
	
	TTTQuadrantView *_topLeftQuadrantView;
	TTTQuadrantView *_topRightQuadrantView;
	TTTQuadrantView *_bottomLeftQuadrantView;
	TTTQuadrantView *_bottomRightQuadrantView;
}

@property (nonatomic, assign) id delegate;

- (void)setNumber:(NSNumber *)number 
		  caption:(NSString *)caption 
		   action:(SEL)action
	  forLocation:(TTTQuadrantLocation)location;
- (TTTQuadrantView *)quadrantViewAtLocation:(TTTQuadrantLocation)location;
- (TTTQuadrantLocation)locationAtPoint:(CGPoint)point;

@end

#pragma mark -

@interface TTTQuadrantView : UIView {
	NSNumber *_number;
	NSString *_caption;
	SEL _action;
}

@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, assign, getter = isHighlighted) BOOL highlighted;
@property (nonatomic, assign) SEL action;

@end
