//
//  ComposeTweetViewController.m
//  Simple-Twitter
//
//  Created by Li Jiao on 2/8/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import "ComposeTweetViewController.h"
#import "TwitterClient.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"

@interface ComposeTweetViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabelView;
@property (weak, nonatomic) IBOutlet UILabel *userScreenNameLabelView;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (weak, nonatomic) IBOutlet UILabel *countLabelView;
@property (assign, nonatomic) BOOL isEditing;
@end

@implementation ComposeTweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // layout adjustment
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // navigation bar item
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweetButton)];
    
    // set current user info
    User *currentUser = [User currentUser];
    if (currentUser != nil) {
        [self.userProfileImageView setImageWithURL:[NSURL URLWithString:currentUser.profileImageUrl]];
        self.userNameLabelView.text = currentUser.name;
        self.userScreenNameLabelView.text = [NSString stringWithFormat:@"@%@", currentUser.screenname];
    }
    
    // set placeholder
    if (self.replyTo != nil) {
        self.tweetTextView.text = [NSString stringWithFormat:@"@%@", self.replyTo.user.screenname];
        NSUInteger *leftCount = (NSUInteger *)(140 - self.tweetTextView.text.length);
        self.countLabelView.text = [NSString stringWithFormat:@"%d", leftCount];
    } else {
        self.tweetTextView.textColor = [UIColor lightGrayColor];
        self.tweetTextView.text = @"What happened?";
        self.countLabelView.text = @"140";
    }
    self.tweetTextView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onTweetButton {
    NSString *statusString = self.tweetTextView.text;
    NSDictionary *params = @{@"status" : statusString};
    NSMutableDictionary *allParams = [params mutableCopy];
    if (self.replyTo != nil) {
        [allParams setValue:self.replyTo.idStr forKey:@"in_reply_to_status_id"];
    }
    
    void (^success)(AFHTTPRequestOperation *operation, Tweet *tweet) = ^(AFHTTPRequestOperation *operation, Tweet *tweet) {
        if (self.delegate != nil) {
            [self.delegate didPostTweet:tweet];
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    };
    void (^failure)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        // TODO: show network error view
    };
    
    [[TwitterClient sharedInstance] postTweet:allParams success:success failure:failure];
    
}

- (void)onCancelButton {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.replyTo == nil) {
        self.tweetTextView.text = @"";
        self.tweetTextView.textColor = [UIColor blackColor];
        self.isEditing = YES;
        self.countLabelView.text = @"140";
    }
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if(self.tweetTextView.text.length == 0){
        self.tweetTextView.textColor = [UIColor lightGrayColor];
        self.tweetTextView.text = @"What happened?";
        self.isEditing = false;
        self.countLabelView.text = @"140";
        [self.tweetTextView resignFirstResponder];
    } else {
        NSUInteger *leftCount = (NSUInteger *)(140 - self.tweetTextView.text.length);
        self.countLabelView.text = [NSString stringWithFormat:@"%d", leftCount];
    }
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
