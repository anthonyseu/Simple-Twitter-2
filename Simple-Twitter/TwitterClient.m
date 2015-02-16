//
//  TwitterClient.m
//  Simple-Twitter
//
//  Created by Li Jiao on 2/7/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import "TwitterClient.h"
#import "Tweet.h"

NSString * const kTwitterConsumerKey = @"UuDAaSaBZc1jTQnhOliV0Japy";
NSString * const kTwitterConsumerSecret = @"FpfMDCT9MKFSkSpi8mbzzsgjw5WUfHuFvIfrZC7dgeqKr8VNjU";
NSString * const kTwitterBaseUrl = @"https://api.twitter.com";

@interface TwitterClient()
@property (nonatomic, strong) void (^loginCompletion)(User *user, NSError *error);
@end

@implementation TwitterClient

+ (TwitterClient *)sharedInstance {
    static TwitterClient *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[TwitterClient alloc] initWithBaseURL:[NSURL URLWithString:kTwitterBaseUrl] consumerKey:kTwitterConsumerKey consumerSecret:kTwitterConsumerSecret];
        }
    });
    
    return instance;
}

- (void)loginWithCompletion:(void (^)(User *user, NSError *error))completion {
    self.loginCompletion = completion;
    [self.requestSerializer removeAccessToken];
    [self fetchRequestTokenWithPath:@"/oauth/request_token" method:@"GET" callbackURL:[NSURL URLWithString:@"codepath://oauth"] scope:nil success:^(BDBOAuth1Credential *requestToken) {
        NSLog(@"got request token");
        NSURL *authUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token]];
        [[UIApplication sharedApplication] openURL:authUrl];
    } failure:^(NSError *error) {
        NSLog(@"fail to get request token: %@", [error localizedDescription]);
        self.loginCompletion(nil, error);
    }];
}

- (void)openURL:(NSURL *)url {
    [self fetchAccessTokenWithPath:@"oauth/access_token" method:@"POST" requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query] success:^(BDBOAuth1Credential *accessToken) {
        NSLog(@"get access token");
        [self.requestSerializer saveAccessToken:accessToken];
        
        [self GET:@"1.1/account/verify_credentials.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            User *user = [[User alloc] initWithDictionay:responseObject];
            [User setCurrentUser:user];
            self.loginCompletion(user, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", [error localizedDescription]);
            self.loginCompletion(nil, error);
        }];
    } failure:^(NSError *error) {
        NSLog(@"fail to get access token");
    }];
}

- (void)homeTimeLineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion {
    [self GET:@"1.1/statuses/home_timeline.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tweets = [Tweet tweetsWithArray:responseObject];
        NSLog(@"Result %@", responseObject);
        completion(tweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)postTweet:(NSDictionary *)params success:(void (^)(AFHTTPRequestOperation *operation, Tweet *tweet))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [self POST:@"1.1/statuses/update.json" parameters:params constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success post");
        Tweet *tweet = [[Tweet alloc] initWithDicionay:responseObject];
        success(operation, tweet);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fail to post");
    }];
}

- (void)favoriteTweet:(NSDictionary *)params success:(void (^)(AFHTTPRequestOperation *operation, Tweet *tweet))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [self POST:@"1.1/favorites/create.json" parameters:params constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success favorite");
        Tweet *tweet = [[Tweet alloc] initWithDicionay:responseObject];
        success(operation, tweet);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fail to favorite");
    }];
}

- (void)destroyFavoriteTweet:(NSDictionary *)params success:(void (^)(AFHTTPRequestOperation *operation, Tweet *tweet))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [self POST:@"1.1/favorites/destroy.json" parameters:params constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success favorite");
        Tweet *tweet = [[Tweet alloc] initWithDicionay:responseObject];
        success(operation, tweet);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fail to favorite");
    }];
}

- (void)retweet:(NSDictionary *)params success:(void (^)(AFHTTPRequestOperation *operation, Tweet *tweet))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSString *postUrl = [NSString stringWithFormat:@"1.1/statuses/retweet/%@.json", [params objectForKey:@"id"]];
    [self POST:postUrl parameters:nil constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success retweet");
        NSLog(@"Result %@", responseObject);
        Tweet *tweet = [[Tweet alloc] initWithDicionay:responseObject];
        success(operation, tweet);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fail to retweet: %@",error.localizedDescription);
    }];
}

- (void)undoRetweet:(NSDictionary *)params success:(void (^)(AFHTTPRequestOperation *operation, Tweet *tweet))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSString *postUrl = [NSString stringWithFormat:@"1.1/statuses/destroy/%@.json", [params objectForKey:@"id"]];
    [self POST:postUrl parameters:nil constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success undo retweet");
        Tweet *tweet = [[Tweet alloc] initWithDicionay:responseObject];
        success(operation, tweet);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fail to undo retweet: %@",error.localizedDescription);
    }];
}


@end
