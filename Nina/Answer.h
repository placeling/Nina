//
//  Answer.h
//  Nina
//
//  Created by Ian MacKinnon on 12-08-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NinaHelper.h"
#import "Question.h"
#import "Place.h"

@interface Answer : NSObject{
    
    Place *place;
    NSString *answerId;
    NSNumber *upvotes;
    NSDate *createdAt;
    
    NSMutableArray *comments;
}


+(RKObjectMapping*)getObjectMapping;


@property (nonatomic, retain) Place *place;
@property (nonatomic, retain) NSString *answerId;
@property (nonatomic, retain) NSNumber *upvotes;
@property (nonatomic, retain) NSDate *createdAt;

@property (nonatomic, retain) NSMutableArray *comments;

@end
