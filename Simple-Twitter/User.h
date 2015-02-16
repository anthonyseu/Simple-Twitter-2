//
//  User.h
//  Simple-Twitter
//
//  Created by Li Jiao on 2/7/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString * const UserDidLoginNotification;
extern NSString * const UserDidLogoutNotification;

@interface User : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screenname;
@property (nonatomic, strong) NSString *profileImageUrl;
@property (nonatomic, strong) NSString *tagline; 

- (id)initWithDictionay:(NSDictionary *)dictionary;

+ (User *)currentUser;

+ (void)setCurrentUser:(User *)currentUser;

+ (void)logout;

@end
