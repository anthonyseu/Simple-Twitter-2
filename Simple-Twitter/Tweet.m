//
//  Tweet.m
//  Simple-Twitter
//
//  Created by Li Jiao on 2/7/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

-(id)initWithDicionay:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.user = [[User alloc] initWithDictionay:dictionary[@"user"]];
        self.text = dictionary[@"text"];
        NSString *createAtString = dictionary[@"created_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        self.createdAt = [formatter dateFromString:createAtString];
        self.retweetCount = (NSInteger *)[dictionary[@"retweet_count"] integerValue];
        self.favoriteCount = (NSInteger *)[dictionary[@"favorite_count"] integerValue];
        self.idStr = dictionary[@"id_str"];
        if ([dictionary[@"favorited"] integerValue] == 0) {
            self.favoriteOn = NO;
        } else {
            self.favoriteOn = YES;
        }
        if ([dictionary[@"retweeted"] integerValue] == 0) {
            self.retweetOn = NO;
        } else {
            self.retweetOn = YES;
        }
    }
    return self;
}

+ (NSArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [NSMutableArray array];
    for (NSDictionary *dictonary in array) {
        [tweets addObject:[[Tweet alloc] initWithDicionay:dictonary]];
    }
    return tweets;
}
@end
