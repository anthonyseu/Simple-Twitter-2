//
//  TweetsViewController.m
//  Simple-Twitter
//
//  Created by Li Jiao on 2/7/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import "TweetsViewController.h"
#import "TwitterClient.h"
#import "Tweet.h"
#import "User.h"
#import "TweetsTableCell.h"
#import "ComposeTweetViewController.h"
#import "TweetsDetailUViewController.h"

@interface TweetsViewController () <ComposeTweetViewControllerDelegate, TweetsDetailDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tweetsTableView;
@property (strong, nonatomic) NSMutableArray *tweetsArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation TweetsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // navigation bar
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log out" style:UIBarButtonItemStylePlain target:self action:@selector(onLogoutButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Compose" style:UIBarButtonItemStylePlain target:self action:@selector(onComposeButton)];
    self.navigationItem.title = @"Tweets";

    // table view
    self.tweetsTableView.dataSource = self;
    self.tweetsTableView.delegate = self;
    [self.tweetsTableView registerNib:[UINib nibWithNibName:@"TweetsTableCell" bundle:nil] forCellReuseIdentifier:@"TweetsTableCell"];
    self.tweetsTableView.rowHeight = UITableViewAutomaticDimension;
    
    // pull refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tweetsTableView insertSubview:self.refreshControl atIndex:0];
    
    [[TwitterClient sharedInstance] homeTimeLineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
        self.tweetsArray = [[NSMutableArray alloc] initWithArray:tweets];
        [self.tweetsTableView reloadData];
    }];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLogoutButton {
    [User logout];
}

- (void)onComposeButton {
    ComposeTweetViewController *vc = [[ComposeTweetViewController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onRefresh {
    [[TwitterClient sharedInstance] homeTimeLineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
        self.tweetsArray = [[NSMutableArray alloc] initWithArray:tweets];
        [self.tweetsTableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (IBAction)onCellReplyButton:(UIButton *)sender {
    Tweet *tweet = [self.tweetsArray objectAtIndex:sender.tag];
    ComposeTweetViewController *vc = [[ComposeTweetViewController alloc] init];
    vc.replyTo = tweet;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onCellFavoriteButton:(UIButton *)sender {
    Tweet *tweet = [self.tweetsArray objectAtIndex:sender.tag];
    NSDictionary *params = @{@"id": tweet.idStr};
    
    void (^failure)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        // TODO: show network error view
    };
    
    void (^success)(AFHTTPRequestOperation *operation, Tweet *tweet) = ^(AFHTTPRequestOperation *operation, Tweet *tweet) {
        if (tweet.favoriteOn) {
            [sender setImage:[UIImage imageNamed:@"favorite_on.png"] forState:nil];
        } else {
            [sender setImage:[UIImage imageNamed:@"favorite.png"] forState:nil];
        }
        [self didFavoriteTweet:tweet];
    };
    
    if (tweet.favoriteOn) {
        [[TwitterClient sharedInstance] destroyFavoriteTweet:params success:success failure:failure];
    } else {
        [[TwitterClient sharedInstance] favoriteTweet:params success:success failure:failure];
    }

}

- (IBAction)onCellRetweetButton:(UIButton *)sender {
    Tweet *tweet = [self.tweetsArray objectAtIndex:sender.tag];
    
    NSDictionary *params = @{@"id": tweet.idStr};
    
    void (^failure)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        // TODO: show network error view
    };
    
    void (^success)(AFHTTPRequestOperation *operation, Tweet *tweet) = ^(AFHTTPRequestOperation *operation, Tweet *tweet) {
        if (tweet.retweetOn) {
            [sender setImage:[UIImage imageNamed:@"retweet_on.png"] forState:nil];
        } else {
            [sender setImage:[UIImage imageNamed:@"retweet.png"] forState:nil];
        }
        [self didRetweet:tweet];
    };
    
    if (tweet.retweetOn) {
        [[TwitterClient sharedInstance] undoRetweet:params success:success failure:failure];
    } else {
        [[TwitterClient sharedInstance] retweet:params success:success failure:failure];
    }
}

- (void)didPostTweet:(Tweet *)tweet {
    [self.tweetsArray insertObject:tweet atIndex:0];
    [self.tweetsTableView reloadData];
}

- (void)didFavoriteTweet:(Tweet *)newTweet {
    for (NSUInteger i = 0; i <self.tweetsArray.count; i++) {
        Tweet *tweet = [self.tweetsArray objectAtIndex:i];
        if ([tweet.idStr isEqualToString:newTweet.idStr]) {
            tweet.favoriteOn = newTweet.favoriteOn;
            tweet.favoriteCount = newTweet.favoriteCount;
        }
    }
    [self.tweetsTableView reloadData];
}

- (void)didRetweet:(Tweet *)newTweet {
    for (NSUInteger i = 0; i <self.tweetsArray.count; i++) {
        Tweet *tweet = [self.tweetsArray objectAtIndex:i];
        if ([tweet.idStr isEqualToString:newTweet.idStr]) {
            tweet.retweetOn = newTweet.retweetOn;
            tweet.retweetCount = newTweet.retweetCount;
        }
    }
    [self.tweetsTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweetsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetsTableCell"];
    Tweet *tweet = self.tweetsArray[indexPath.row];
    cell.tweet = tweet;

    // cell buttons
    cell.replyButton.tag = indexPath.row;
    [cell.replyButton addTarget:self action:@selector(onCellReplyButton:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.favoriteButton.tag = indexPath.row;
    [cell.favoriteButton addTarget:self action:@selector(onCellFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
    if (tweet.favoriteOn) {
        [cell.favoriteButton setImage:[UIImage imageNamed:@"favorite_on.png"] forState:nil];
    } else {
        [cell.favoriteButton setImage:[UIImage imageNamed:@"favorite.png"] forState:nil];
    }
    
    cell.retweetButton.tag = indexPath.row;
    [cell.retweetButton addTarget:self action:@selector(onCellRetweetButton:) forControlEvents:UIControlEventTouchUpInside];
    if (tweet.retweetOn) {
        [cell.retweetButton setImage:[UIImage imageNamed:@"retweet_on.png"] forState:nil];
    } else {
        [cell.retweetButton setImage:[UIImage imageNamed:@"retweet.png"] forState:nil];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *tweet = self.tweetsArray[indexPath.row];
    TweetsDetailUViewController *vc = [[TweetsDetailUViewController alloc] init];
    vc.tweet = tweet;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
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
