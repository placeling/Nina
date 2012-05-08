//
//  NewPlaceController.h
//  Nina
//
//  Created by Ian MacKinnon on 12-05-08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewPlaceController : UIViewController{
    NSString *_placeName;
}

@property(nonatomic,retain) NSString *placeName;

- (id)initWithName:(NSString *)placeName;
    
@end
