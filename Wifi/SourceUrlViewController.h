//
//  SourceUrlViewController.h
//  POCpageViewerInAlertView
//
//  Created by Ashirvad on 14/04/15.
//  Copyright (c) 2015 Ashirvad. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface SourceUrlViewController : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property(strong,nonatomic) NSURLRequest *request;
@property(strong,nonatomic) NSDictionary *objectFromParent;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *cmxtLoadingView;
@property (strong, nonatomic) UIView *navbar;

@end
