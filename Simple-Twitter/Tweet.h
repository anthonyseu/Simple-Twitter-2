//
//  Tweet.h
//  Simple-Twitter
//
//  Created by Li Jiao on 2/7/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject
@property (nonatomic, strong) NSString *idStr;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, assign) NSInteger *retweetCount;
@property (nonatomic, assign) NSInteger *favoriteCount;
@property (nonatomic, assign) BOOL favoriteOn;
@property (nonatomic, assign) BOOL retweetOn;
@property (nonatomic, strong) User *user;

-(id)initWithDicionay:(NSDictionary *)dictionary;

+ (NSArray *)tweetsWithArray:(NSArray *)array;

@end
