//
//  SlideMenuViewController.m
//  Simple-Twitter
//
//  Created by Li Jiao on 2/15/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import "SlideMenuViewController.h"
#import "UIImageView+AFNetworking.h"
#import "User.h"

@interface SlideMenuViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabelView;
@property (weak, nonatomic) IBOutlet UILabel *userScreenNameLabelView;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;

@end

@implementation SlideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // menu table view
    self.menuTableView.delegate = self;
    self.menuTableView.dataSource = self;
    self.menuTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    // display current user info
    User *currentUser = [User currentUser];
    if (currentUser) {
        [self.userProfileImageView setImageWithURL:[NSURL URLWithString:currentUser.profileImageUrl]];
        self.userNameLabelView.text = currentUser.name;
        self.userScreenNameLabelView.text = [NSString stringWithFormat:@"@%@", currentUser.screenname];
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //make cell background clear; need to do it here because tableView won't do clear cells in cellForRowAtIndexPath
    cell.backgroundColor = [UIColor clearColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
        case SlideMenuItemProfile:
            cell.textLabel.text = @"Profile";
            break;
        case SlideMenuItemTimeline:
            cell.textLabel.text = @"Timeline";
            break;
        case SlideMenuItemMetions:
            cell.textLabel.text = @"Mentions";
            break;
        case SlideMenuItemLogout:
            cell.textLabel.text = @"Logout";
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate didSelectMenu:(SlideMenuItem)indexPath.row];
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
