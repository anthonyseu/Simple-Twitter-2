//
//  ProfileHeaderCell.h
//  Simple-Twitter
//
//  Created by Li Jiao on 2/16/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ProfileHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userScreenNameLabel;
@end
