//
//  AdPopUpLaunchViewController.m
//  Flyers
//
//  Created by Infosys on 24/11/14.
//  Copyright (c) 2014 Infy. All rights reserved.
//

#import "AdPopUpLaunchViewController.h"
//#import "SourceUrlViewController.h"

CGRect originalFrame;
@interface AdPopUpLaunchViewController ()

@end

@implementation AdPopUpLaunchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //    appDelegate=[[UIApplication sharedApplication] delegate];
    //self.viewHeightConstraint.constant+=200;
    self.containerView.layer.borderColor = [UIColor clearColor].CGColor;
    self.containerView.layer.borderWidth = 2.0f;
    self.containerView.layer.cornerRadius = 4.0f;
    
    originalFrame = self.view.frame;
    
    self.recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOutside:)];
    
    [self.recognizer setNumberOfTapsRequired:1];
    self.recognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
    [self.view addGestureRecognizer:self.recognizer];
    self.recognizer.delegate = self;
    
    [self initPageController];
}

- (void)handleTapOutside:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:self.containerView];
        
        if (![self.containerView pointInside:location withEvent:nil]) {
            [self.view removeGestureRecognizer:self.recognizer];
            [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) initPageController {
    
    self.pageController = [[UIPageViewController alloc]
                           initWithTransitionStyle: UIPageViewControllerTransitionStyleScroll
                           navigationOrientation:   UIPageViewControllerNavigationOrientationHorizontal
                           options:nil];
    
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    
    UIViewController *initialViewController = [self viewControllerAtIndex:0];
    [[self.pageController view] setFrame:CGRectMake(0, 0, self.containerView.frame.size.width,self.containerView.frame.size.height)];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    [self.pageController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self containerView] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    if (self.adFeeds.count>1)
    {
        self.myPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.containerView.frame.size.height - 10, self.containerView.frame.size.width, 10)];
        self.myPageControl.numberOfPages = self.adFeeds.count;
        self.myPageControl.currentPage = 0;
        self.myPageControl.enabled = false;
        self.myPageControl.pageIndicatorTintColor = [UIColor grayColor];
        self.myPageControl.currentPageIndicatorTintColor = [UIColor blackColor];
        self.myPageControl.backgroundColor = [UIColor clearColor];
        [[self containerView] addSubview:self.myPageControl];

    }
    
}


- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    if (index == 0 || index == self.adFeeds.count)
    {
        self.boxChildViewController = [[AdViewController alloc] initWithNibName:@"AdViewController" bundle:nil];
        self.boxChildViewController.index = 0;
        self.boxChildViewController.fromParent = [self.adFeeds objectAtIndex:0];
        self.boxChildViewController.viewHeightConstraint=self.viewHeightConstraint;
        return self.boxChildViewController;
    }
    else if (index == self.adFeeds.count-1 || index == -1)
    {
        self.boxChildViewController = [[AdViewController alloc] initWithNibName:@"AdViewController" bundle:nil];
        self.boxChildViewController.index = index;
        self.boxChildViewController.fromParent = [self.adFeeds objectAtIndex:self.adFeeds.count-1];
         self.boxChildViewController.viewHeightConstraint=self.viewHeightConstraint;
        return self.boxChildViewController;
    }
    else
    {
        for (int i=1; i<self.adFeeds.count-1; i++)
        {
            if (index == i)
            {
                self.boxChildViewController = [[AdViewController alloc] initWithNibName:@"AdViewController" bundle:nil];
                self.boxChildViewController.index = index;
                self.boxChildViewController.fromParent = [self.adFeeds objectAtIndex:index];
                 self.boxChildViewController.viewHeightConstraint=self.viewHeightConstraint;                return self.boxChildViewController;
            }            
        }
    }
    return nil;
}

#pragma mark - pageViewController Delegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index;
    UIViewController *currentView = [pageViewController.viewControllers objectAtIndex:0];
    
    if (pageViewController == self.pageController) {
        
        if ([currentView isKindOfClass:[AdViewController class]]) {
            
            index = [(AdViewController *)viewController index];
        }
//        else if([currentView isKindOfClass:[BoxScorePageViewController class]]){
//            
//            index = [(BoxScorePageViewController *)viewController index];
//        }
        
        /*if (index == 0) {
         return nil;
         }*/
        if (index/100>0) {
            index=self.adFeeds.count-2;
        }
        else
        {
            index--;
        }
        if (self.adFeeds.count>1)
        {
            return [self viewControllerAtIndex:index];
        }
        
        
    }
    
    return nil;
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {

    if (!completed){return;}
    /*
     // Find index of current page
     BoxScorePageViewController *currentViewController = (BoxScorePageViewController *)[self.pageController.viewControllers lastObject];
     NSUInteger indexOfCurrentPage = currentViewController.index;
     self.myPageControl.currentPage = indexOfCurrentPage;*/
    
    UIViewController *currentView = [pageViewController.viewControllers objectAtIndex:0];
    
    if (pageViewController == self.pageController) {
        
        if ([currentView isKindOfClass:[AdViewController class]]) {
            
            if ([(AdViewController *)currentView index] == -1)
            {
                self.myPageControl.currentPage = self.adFeeds.count-1;
            }
            else
            {
                self.myPageControl.currentPage = [(AdViewController *)currentView index];
            }
            
        }
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index;
    UIViewController *currentView = [pageViewController.viewControllers objectAtIndex:0];
    
    if (pageViewController == self.pageController) {
        
        if ([currentView isKindOfClass:[AdViewController class]]) {
            
            index = [(AdViewController *)viewController index];
        }
        
//        else if([currentView isKindOfClass:[BoxScorePageViewController class]]){
//            
//            index = [(BoxScorePageViewController *)viewController index];
//        }
        
        index++;
        
        /*if (index == 5) {
         return nil;
         }*/
        
        if (self.adFeeds.count>1)
        {
            return [self viewControllerAtIndex:index];
        }
        
        
    }
    return nil;
    
}


#pragma mark - UIGestureRecognizer Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

//- (IBAction)btnMoreClicked:(id)sender
//{
//    SourceUrlViewController *sourceVC = [[SourceUrlViewController alloc]initWithNibName:@"SourceUrlViewController" bundle:nil];
//    sourceVC.sourceWebUrl = [[self.adFeeds objectAtIndex:self.myPageControl.currentPage] objectForKey:@"sourceUrl"];
//    [[sourceVC view] setFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
//    [self.navigationController pushViewController:sourceVC animated:YES];
//}

- (IBAction)btnSaveClicked:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}
@end
