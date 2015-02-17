//
//  SlideViewController.h
//  Simple-Twitter
//
//  Created by Li Jiao on 2/15/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlideViewController : UIViewController
@property (nonatomic, strong) UIViewController *slideMenuController;
@property (nonatomic, strong) UIViewController *mainViewController;

- (void)toggleMenu;
- (void)showMenu;
- (void)dismissMenu;
@end
