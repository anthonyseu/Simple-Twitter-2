//
//  ComposeTweetViewController.h
//  Simple-Twitter
//
//  Created by Li Jiao on 2/8/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@protocol ComposeTweetViewControllerDelegate <NSObject>
- (void)didPostTweet:(Tweet *)tweet;
@end

@interface ComposeTweetViewController : UIViewController <UITextViewDelegate>
@property (nonatomic, weak) id<ComposeTweetViewControllerDelegate> delegate;
@property (nonatomic, strong) Tweet *replyTo;
@end
