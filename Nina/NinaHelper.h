//
//  NinaHelper.h
//  Nina
//
//  Created by Ian MacKinnon on 11-07-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//single place to define debugging or not -iMack
#define DEBUG 

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#import <Foundation/Foundation.h>


@interface NinaHelper : NSObject {
    
}

@end
