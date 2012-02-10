//
//  Authentication.h
//  Nina
//
//  Created by Ian MacKinnon on 12-02-10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "NinaHelper.h"

@interface Authentication : NSObject{
    NSString *provider;
    NSString *uid;
    NSString *token;
    NSString *expiry;
}

@property (nonatomic, retain) NSString *provider; 
@property (nonatomic, retain) NSString *uid; 
@property (nonatomic, retain) NSString *token; 
@property (nonatomic, retain) NSString *expiry; 

+(RKObjectMapping*)getObjectMapping;
@end



