//
//  TweetsDetailUViewController.h
//  Simple-Twitter
//
//  Created by Li Jiao on 2/8/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@protocol TweetsDetailDelegate <NSObject>
- (void)didFavoriteTweet:(Tweet *)tweet;
- (void)didRetweet:(Tweet *)tweet;
@end

@interface TweetsDetailUViewController : UIViewController
@property (nonatomic, strong) Tweet *tweet;
@property (nonatomic, weak) id<TweetsDetailDelegate> delegate;
@end
