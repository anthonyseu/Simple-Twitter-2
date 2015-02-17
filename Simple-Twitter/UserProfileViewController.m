//
//  UserProfileViewController.m
//  Simple-Twitter
//
//  Created by Li Jiao on 2/16/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import "UserProfileViewController.h"
#import "TweetsTableCell.h"
#import "UserStatsCell.h"
#import "TwitterClient.h"
#import "UIImageView+AFNetworking.h"
#import "ComposeTweetViewController.h"
#import "TweetsDetailUViewController.h"
#import "Tweet.h"
#import "User.h"

@interface UserProfileViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tweetsTableView;
@property (strong, nonatomic) NSMutableArray *tweetsArray;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *bannerImageView;
@property (nonatomic, strong) UIImage *bannerImage;
@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // title
    self.navigationItem.title = @"Profile";
    
    // set table view
    self.tweetsTableView.delegate = self;
    self.tweetsTableView.dataSource = self;
    self.tweetsTableView.rowHeight = UITableViewAutomaticDimension;
    [self.tweetsTableView registerNib:[UINib nibWithNibName:@"TweetsTableCell" bundle:nil] forCellReuseIdentifier:@"TweetsTableCell"];
    [self.tweetsTableView registerNib:[UINib nibWithNibName:@"UserStatsCell" bundle:nil] forCellReuseIdentifier:@"UserStatsCell"];
    [self.tweetsTableView registerNib:[UINib nibWithNibName:@"ProfileHeaderCell" bundle:nil] forCellReuseIdentifier:@"ProfileHeaderCell"];

    // init the header views
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
    self.bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
    self.bannerImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.headerView addSubview:self.bannerImageView];
    UIView *profileImageContainer = [[UIView alloc] initWithFrame:CGRectMake(128, 20, 64, 64)];
    profileImageContainer.backgroundColor = [UIColor whiteColor];
    profileImageContainer.layer.cornerRadius = 5;
    [self.headerView addSubview:profileImageContainer];
    UIImageView *profileImage = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 56, 56)];
    profileImage.layer.cornerRadius = 3;
    profileImage.clipsToBounds = YES;
    [profileImageContainer addSubview:profileImage];
    UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, 320, 20)];
    userNameLabel.textColor = [UIColor whiteColor];
    userNameLabel.font = [UIFont boldSystemFontOfSize:16];
    userNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.headerView addSubview:userNameLabel];
    UILabel *userScreenNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 108, 320, 20)];
    userScreenNameLabel.textColor = [UIColor whiteColor];
    userScreenNameLabel.font = [UIFont systemFontOfSize:13];
    userScreenNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.headerView addSubview:userScreenNameLabel];
    
    // populate the header views
    UIImageView *bannerImageView = self.bannerImageView;
    [bannerImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.user.backgroundImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.bannerImage = image;
        self.bannerImageView.image = image;
    } failure:nil];
    [profileImage setImageWithURL:[NSURL URLWithString:self.user.profileImageUrl]];
    userNameLabel.text = self.user.name;
    userScreenNameLabel.text = [NSString stringWithFormat:@"@%@", self.user.screenname];
    self.tweetsTableView.tableHeaderView = self.headerView;
    
    // get initial home time line tweets
    NSDictionary *params = @{@"screen_name": self.user.screenname};
    [[TwitterClient sharedInstance] userTimeLineWithParams:params completion:^(NSArray *tweets, NSError *error) {
        self.tweetsArray = [[NSMutableArray alloc] initWithArray:tweets];
        [self.tweetsTableView reloadData];
    }];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return self.tweetsArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0){
        UserStatsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserStatsCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tweetsCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.user.tweetsCount];
        cell.followersCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.user.followerCount];
        cell.followingCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.user.followingCount];
        return cell;
    } else {
        TweetsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetsTableCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        Tweet *tweet = self.tweetsArray[indexPath.row];
        cell.tweet = self.tweetsArray[indexPath.row];
        
        cell.replyButton.tag = indexPath.row;
        [cell.replyButton addTarget:self action:@selector(onCellReplyButton:) forControlEvents:UIControlEventTouchUpInside];

        if ([self.user isEqual:[User currentUser]]) {
            [cell.retweetButton setEnabled:NO];
        } else {
            cell.retweetButton.tag = indexPath.row;
            [cell.retweetButton addTarget:self action:@selector(onCellRetweetButton:) forControlEvents:UIControlEventTouchUpInside];
            if (tweet.retweetOn) {
                [cell.retweetButton setImage:[UIImage imageNamed:@"retweet_on.png"] forState:nil];
            } else {
                [cell.retweetButton setImage:[UIImage imageNamed:@"retweet.png"] forState:nil];
            }
        }
        
        cell.favoriteButton.tag = indexPath.row;
        [cell.favoriteButton addTarget:self action:@selector(onCellFavoriteButton:) forControlEvents:UIControlEventTouchUpInside];
        if (tweet.favoriteOn) {
            [cell.favoriteButton setImage:[UIImage imageNamed:@"favorite_on.png"] forState:nil];
        } else {
            [cell.favoriteButton setImage:[UIImage imageNamed:@"favorite.png"] forState:nil];
        }
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *tweet = self.tweetsArray[indexPath.row];
    TweetsDetailUViewController *vc = [[TweetsDetailUViewController alloc] init];
    vc.tweet = tweet;
    vc.user = self.user;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = self.tweetsTableView.contentOffset.y;
    if (offset < 0) {
        // enlarge and blur the header image
        self.headerView.frame = CGRectMake(0, offset, 320, 150 - offset);
        self.bannerImageView.frame = CGRectMake(0, offset, 320, 150 - offset);
    } else {
        // restore the header to normal
        self.headerView.frame = CGRectMake(0, 0, 320, 150);
        self.bannerImageView.frame = CGRectMake(0, 0, 320, 150);
        self.bannerImageView.image = self.bannerImage;
    }
}

#pragma mark - event handler
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

#pragma mark - Tweet detail view delegate
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
