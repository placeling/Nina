//
//  ProfileDetailBadge.m
//  Nina
//
//  Created by Ian MacKinnon on 11-09-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileDetailBadge.h"
#import <QuartzCore/QuartzCore.h>

@interface ProfileDetailBadge ()

- (void)commonInit;
@end


@implementation ProfileDetailBadge
@synthesize numberLabel, detailLabel;
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
		return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (!self) {
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (void)commonInit {
    
    UIColor *maroon = [UIColor colorWithRed:128/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];
    UIColor *bottomBack = [UIColor colorWithRed:146/255.0 green:143/255.0 blue:125/255.0 alpha:1.0];
    UIColor *topBack = [UIColor colorWithRed:234/255.0 green:228/255.0 blue:209/255.0 alpha:1.0];
    
    self.detailLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 28, 64, 21)]autorelease];
    self.numberLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64, 28)] autorelease];
    
    self.detailLabel.font = [UIFont fontWithName:@"Helvetica" size:11];
    [self.detailLabel setTextColor:[UIColor whiteColor]];
    [self.detailLabel setBackgroundColor:bottomBack];
    
    self.detailLabel.textAlignment =  UITextAlignmentCenter;
    
    self.numberLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:19];
    self.numberLabel.textAlignment =  UITextAlignmentCenter;
    
    self.detailLabel.text = @"";
    self.numberLabel.text = @"-";
    
    [self.numberLabel setTextColor:maroon];
    [self.numberLabel setBackgroundColor:topBack];
    
    
    self.layer.cornerRadius = 4.0f;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = bottomBack.CGColor;
    self.layer.masksToBounds = YES;
    
    [self addSubview:self.detailLabel];
    [self addSubview:self.numberLabel];
}

-(void) dealloc{
    [detailLabel release];
    [numberLabel release];
    
    [super dealloc];
}


@end
