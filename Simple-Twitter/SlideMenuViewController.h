//
//  SlideMenuViewController.h
//  Simple-Twitter
//
//  Created by Li Jiao on 2/15/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SlideMenuItemProfile = 0,
    SlideMenuItemTimeline = 1,
    SlideMenuItemMetions = 2,
    SlideMenuItemLogout = 3
} SlideMenuItem;

@protocol SlideMenuDelegate
- (void)didSelectMenu:(SlideMenuItem)menuItem;
@end

@interface SlideMenuViewController : UIViewController
@property (nonatomic, strong) id<SlideMenuDelegate> delegate;
@end
