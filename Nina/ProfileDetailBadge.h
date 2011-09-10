//
//  ProfileDetailBadge.h
//  Nina
//
//  Created by Ian MacKinnon on 11-09-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileDetailBadge : UIControl{
    IBOutlet UILabel *numberLabel;
    IBOutlet UILabel *detailLabel;
    
}

@property(nonatomic,retain) IBOutlet UILabel *numberLabel;
@property(nonatomic,retain) IBOutlet UILabel *detailLabel;

@end
