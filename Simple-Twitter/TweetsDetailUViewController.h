//
//  TweetsDetailUViewController.h
//  Simple-Twitter
//
//  Created by Li Jiao on 2/8/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "User.h"

@protocol TweetsDetailDelegate <NSObject>
- (void)didFavoriteTweet:(Tweet *)tweet;
- (void)didRetweet:(Tweet *)tweet;
@end

@interface TweetsDetailUViewController : UIViewController
@property (nonatomic, strong) Tweet *tweet;
@property (nonatomic, strong) User *user;
@property (nonatomic, weak) id<TweetsDetailDelegate> delegate;
@end
