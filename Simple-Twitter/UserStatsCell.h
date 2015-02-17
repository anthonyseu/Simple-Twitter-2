//
//  UserStatsCell.h
//  Simple-Twitter
//
//  Created by Li Jiao on 2/16/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserStatsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *tweetsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@end
