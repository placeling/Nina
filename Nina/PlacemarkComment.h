//
//  PlacemarkComment.h
//  Nina
//
//  Created by Ian MacKinnon on 12-08-09.
//
//

#import <Foundation/Foundation.h>

#import "User.h"
#import "NinaHelper.h"

@interface PlacemarkComment : NSObject {
    NSString *commentId;
    NSString *comment;
    NSDate *createdAt;
    User *user;
}

@property (nonatomic, retain) NSString *commentId;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) User *user;

+(RKObjectMapping*)getObjectMapping;

@end
