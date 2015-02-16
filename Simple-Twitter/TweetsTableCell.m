//
//  TweetsTableCell.m
//  Simple-Twitter
//
//  Created by Li Jiao on 2/8/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import "TweetsTableCell.h"
#import "TweetsDetailUViewController.h"
#import "UIImageView+AFNetworking.h"
#import <NSDate+DateTools.h>

@interface TweetsTableCell ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabelView;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabelView;
@property (weak, nonatomic) IBOutlet UILabel *userScreenNameLabelView;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabelView;
@end

@implementation TweetsTableCell

- (void)awakeFromNib {
    // Initialization code
    self.tweetTextLabelView.preferredMaxLayoutWidth = self.tweetTextLabelView.frame.size.width;
    if (self.tweet.favoriteOn) {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_on.png"] forState:nil];
    }
    
    if (self.tweet.retweetOn) {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_on.png"] forState:nil];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTweet:(Tweet *)tweet{
    [self.profileImageView setImageWithURL:[NSURL URLWithString:tweet.user.profileImageUrl]];
    self.userNameLabelView.text = tweet.user.name;
    self.userScreenNameLabelView.text = [NSString stringWithFormat:@"@%@", tweet.user.screenname];
    self.tweetTextLabelView.text = tweet.text;
    self.createdAtLabelView.text = tweet.createdAt.shortTimeAgoSinceNow;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView layoutIfNeeded];
    self.tweetTextLabelView.preferredMaxLayoutWidth = self.tweetTextLabelView.frame.size.width;
}
@end
