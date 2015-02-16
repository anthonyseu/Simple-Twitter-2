//
//  TwitterClient.h
//  Simple-Twitter
//
//  Created by Li Jiao on 2/7/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "User.h" 
#import "Tweet.h"

@interface TwitterClient : BDBOAuth1RequestOperationManager

+ (TwitterClient *)sharedInstance;

- (void)loginWithCompletion:(void (^)(User *user, NSError *error))completion;

- (void)openURL:(NSURL *)url;

- (void)homeTimeLineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion;

- (void)postTweet:(NSDictionary *)params success:(void (^)(AFHTTPRequestOperation *operation, Tweet *tweet))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)favoriteTweet:(NSDictionary *)params success:(void (^)(AFHTTPRequestOperation *operation, Tweet *tweet))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)destroyFavoriteTweet:(NSDictionary *)params success:(void (^)(AFHTTPRequestOperation *operation, Tweet *tweet))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)retweet:(NSDictionary *)params success:(void (^)(AFHTTPRequestOperation *operation, Tweet *tweet))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)undoRetweet:(NSDictionary *)params success:(void (^)(AFHTTPRequestOperation *operation, Tweet *tweet))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
