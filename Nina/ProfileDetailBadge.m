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
    
    self.detailLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 28, 64, 21)]autorelease];
    self.numberLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64, 28)] autorelease];
    
    self.detailLabel.font = [UIFont fontWithName:@"Helvetica" size:11];
    self.detailLabel.textAlignment =  UITextAlignmentCenter;
    self.numberLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:19];
    self.numberLabel.textAlignment =  UITextAlignmentCenter;
    
    self.detailLabel.text = @"";
    self.numberLabel.text = @"-";
    
    [self addSubview:self.detailLabel];
    [self addSubview:self.numberLabel];
    
    self.layer.cornerRadius = 8.0f;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.layer.masksToBounds = YES;
}

-(void) dealloc{
    [detailLabel release];
    [numberLabel release];
    
    [super dealloc];
}


@end
