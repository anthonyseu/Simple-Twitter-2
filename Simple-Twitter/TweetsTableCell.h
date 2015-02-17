//
//  TweetsTableCell.h
//  Simple-Twitter
//
//  Created by Li Jiao on 2/8/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@protocol TweetsTableViewCellDelegate <NSObject>
- (void)didTapProfileImageForUser:(User *)user;
@end

@interface TweetsTableCell : UITableViewCell
@property (nonatomic, strong) Tweet *tweet;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (nonatomic, weak) id<TweetsTableViewCellDelegate> delegate;
@end
