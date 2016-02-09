//
//  AdPopUpLaunchViewController.h
//  Flyers
//
//  Created by Infosys on 24/11/14.
//  Copyright (c) 2014 Infy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "AdViewController.h"
@interface AdPopUpLaunchViewController : UIViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIView *containerView;

- (IBAction)btnSaveClicked:(id)sender;

@property (nonatomic, strong) UITapGestureRecognizer *recognizer;
@property (nonatomic, strong) NSArray *adFeeds;
@property (nonatomic, strong) UIPageViewController *pageController;
@property (nonatomic, strong) UIPageControl *myPageControl;
@property (nonatomic, strong) AdViewController *boxChildViewController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeightConstraint;


@end
