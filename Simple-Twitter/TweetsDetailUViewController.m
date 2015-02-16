//
//  TweetsDetailUViewController.m
//  Simple-Twitter
//
//  Created by Li Jiao on 2/8/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import "TweetsDetailUViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ComposeTweetViewController.h"
#import "TwitterClient.h"

@interface TweetsDetailUViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabelView;
@property (weak, nonatomic) IBOutlet UILabel *userScreenNameLabelView;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabelView;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabelView;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabelView;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabelView;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@end

@implementation TweetsDetailUViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // layout adjustment
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // navigation bar item
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reply" style:UIBarButtonItemStylePlain target:self action:@selector(onReply)];
    
    // set the initial view
    User *tweetUser = self.tweet.user;;
    [self.userProfileImageView setImageWithURL:[NSURL URLWithString:tweetUser.profileImageUrl]];
    self.userNameLabelView.text = tweetUser.name;
    self.userScreenNameLabelView.text = tweetUser.screenname;
    self.tweetTextLabelView.text = self.tweet.text;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yy, HH:mm a"];
    NSString *dateString = [formatter stringFromDate:self.tweet.createdAt];
    self.createdAtLabelView.text = dateString;
    
    self.retweetCountLabelView.text = [NSString stringWithFormat:@"%d",self.tweet.retweetCount];
    self.favoriteCountLabelView.text = [NSString stringWithFormat:@"%d", self.tweet.favoriteCount];
    
    if (self.tweet.favoriteOn) {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_on.png"] forState:nil];
    }
    
    if (self.tweet.retweetOn) {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_on.png"] forState:nil];
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onReplyButton:(id)sender {
    [self onReply];
}

- (IBAction)onRetweetButton:(id)sender {
    NSDictionary *params = @{@"id": self.tweet.idStr};

    void (^failure)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        // TODO: show network error view
    };
    
    void (^success)(AFHTTPRequestOperation *operation, Tweet *tweet) = ^(AFHTTPRequestOperation *operation, Tweet *tweet) {
        self.tweet.retweetOn = tweet.retweetOn;
        self.tweet.retweetCount = tweet.retweetCount;
        self.retweetCountLabelView.text = [NSString stringWithFormat:@"%d", self.tweet.retweetCount];
        
        if (self.tweet.retweetOn) {
            [self.retweetButton setImage:[UIImage imageNamed:@"retweet_on.png"] forState:nil];
        } else {
            [self.retweetButton setImage:[UIImage imageNamed:@"retweet.png"] forState:nil];
        }
        
        if (self.delegate) {
            [self.delegate didRetweet:self.tweet];
        }
    };
    
    if (self.tweet.retweetOn) {
        [[TwitterClient sharedInstance] undoRetweet:params success:success failure:failure];
    } else {
        [[TwitterClient sharedInstance] retweet:params success:success failure:failure];
    }
}

- (IBAction)onFavoriteButton:(id)sender {
    NSDictionary *params = @{@"id": self.tweet.idStr};

    void (^failure)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        // TODO: show network error view
    };
    
    void (^success)(AFHTTPRequestOperation *operation, Tweet *tweet) = ^(AFHTTPRequestOperation *operation, Tweet *tweet) {
        self.tweet = tweet;
        self.favoriteCountLabelView.text = [NSString stringWithFormat:@"%d", self.tweet.favoriteCount];
        if (self.tweet.favoriteOn) {
            [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_on.png"] forState:nil];
        } else {
            [self.favoriteButton setImage:[UIImage imageNamed:@"favorite.png"] forState:nil];
        }
        
        if (self.delegate != nil) {
            [self.delegate didFavoriteTweet:tweet];
        }
    };
    
    if (self.tweet.favoriteOn) {
        [[TwitterClient sharedInstance] destroyFavoriteTweet:params success:success failure:failure];
    } else {
        [[TwitterClient sharedInstance] favoriteTweet:params success:success failure:failure];
    }
}

- (void)onReply {
    ComposeTweetViewController *vc = [[ComposeTweetViewController alloc] init];
    vc.replyTo = self.tweet;
    NSArray *viewControllers = self.navigationController.viewControllers;
    UIViewController *rootViewController = [viewControllers objectAtIndex:viewControllers.count - 2];
    vc.delegate = rootViewController;
    [self.navigationController pushViewController:vc animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
