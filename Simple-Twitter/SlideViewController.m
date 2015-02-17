//
//  SlideViewController.m
//  Simple-Twitter
//
//  Created by Li Jiao on 2/15/15.
//  Copyright (c) 2015 Li Jiao. All rights reserved.
//

#import "SlideViewController.h"

static CGFloat kSlideMenuViewWidth = 245.0;

@interface SlideViewController ()
@property (nonatomic) BOOL isMenuShowing;
@end

@implementation SlideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // pan gesture recoginzer
    [self.view addSubview:self.mainViewController.view];
    self.mainViewController.view.frame = self.view.bounds;
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.mainViewController.view.userInteractionEnabled = YES;
    [self.mainViewController.view addGestureRecognizer:panRecognizer];
    
    if (self.slideMenuController) {
        CGRect frame = self.view.bounds;
        frame.size.width = kSlideMenuViewWidth;
        self.slideMenuController.view.frame = frame;
        [self.view insertSubview:self.slideMenuController.view belowSubview:self.mainViewController.view];
    }
    
    self.isMenuShowing = NO;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - interface menu
- (void)toggleMenu {
    if (self.isMenuShowing) {
        [self dismissMenu];
    } else {
        [self showMenu];
    }
}

- (void)showMenu {
    if (!self.slideMenuController) {
        return;
    }
    [self disableViewsForDragging];
    self.isMenuShowing = YES;
    
    [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:0 animations:^{
        self.mainViewController.view.frame = CGRectMake(kSlideMenuViewWidth, self.mainViewController.view.frame.origin.y, self.mainViewController.view.frame.size.width, self.mainViewController.view.frame.size.height );
    } completion:^(BOOL completed) {
//        [self.slideMenuController.view removeFromSuperview];
        [self enableViewsForDragging];
    }];
}

- (void)dismissMenu {
    if (!self.slideMenuController) {
        return;
    }
    [self disableViewsForDragging];
    self.isMenuShowing = NO;
    
    [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:0 animations:^{
        self.mainViewController.view.frame = CGRectMake(0.0, self.mainViewController.view.frame.origin.y, self.mainViewController.view.frame.size.width, self.mainViewController.view.frame.size.height );
    } completion:^(BOOL completed) {
//        [self.slideMenuController.view removeFromSuperview];
        [self enableViewsForDragging];
    }];
}

- (void)disableViewsForDragging {
    self.mainViewController.view.userInteractionEnabled = NO;
    self.slideMenuController.view.userInteractionEnabled = NO;
}

- (void)enableViewsForDragging {
    self.mainViewController.view.userInteractionEnabled = YES;
    self.slideMenuController.view.userInteractionEnabled = YES;
}


#pragma mark - event handler

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.view];
    CGFloat velocity = [sender velocityInView:self.view].x;
    
    if (self.isMenuShowing) {
        if (translation.x < 0) {
            // set new position exactly
            CGFloat left = self.mainViewController.view.frame.origin.x + translation.x;
            if (left >= 0) {
                self.mainViewController.view.frame = CGRectMake(self.mainViewController.view.frame.origin.x + translation.x, self.mainViewController.view.frame.origin.y, self.mainViewController.view.frame.size.width, self.mainViewController.view.frame.size.height );
            }
        }
        if (sender.state == UIGestureRecognizerStateEnded) {
            if (velocity < 0) {
                self.mainViewController.view.frame = CGRectMake(0.0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height );
                self.isMenuShowing = NO;
            }
        }
    } else {
        if (translation.x > 0) {
            CGFloat left = self.mainViewController.view.frame.origin.x + translation.x;
            if (left <= kSlideMenuViewWidth) {
                // set new position exactly
                self.mainViewController.view.frame = CGRectMake(left, self.mainViewController.view.frame.origin.y, self.mainViewController.view.frame.size.width, self.mainViewController.view.frame.size.height );
            }
        }
        if (sender.state == UIGestureRecognizerStateEnded) {
            if (velocity > 0) {
                self.mainViewController.view.frame = CGRectMake(kSlideMenuViewWidth, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height );
                self.isMenuShowing = YES;
            }
        }
    }
    [sender setTranslation:CGPointMake(0, 0) inView:self.mainViewController.view];

}

- (void)setMainViewController:(UIViewController *)mainViewController {
    UIViewController *oldMainViewController = _mainViewController;
    _mainViewController = mainViewController;
    
    [oldMainViewController willMoveToParentViewController:nil];
    [oldMainViewController.view removeFromSuperview];
    [oldMainViewController removeFromParentViewController];
    
    if (mainViewController) {
        [self addChildViewController:mainViewController];
        [mainViewController didMoveToParentViewController:self];
    }
}

- (void)setSlideMenuController:(UIViewController *)slideMenuController {
    UIViewController *oldSlideMenuController = _slideMenuController;
    _slideMenuController = slideMenuController;
    
    [oldSlideMenuController willMoveToParentViewController:nil];
    [oldSlideMenuController.view removeFromSuperview];
    [oldSlideMenuController removeFromParentViewController];
    
    if (slideMenuController) {
        [self addChildViewController:slideMenuController];
        [slideMenuController didMoveToParentViewController:self];
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
