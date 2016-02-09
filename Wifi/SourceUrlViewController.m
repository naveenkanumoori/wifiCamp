//
//  SourceUrlViewController.m
//  POCpageViewerInAlertView
//
//  Created by Ashirvad on 14/04/15.
//  Copyright (c) 2015 Ashirvad. All rights reserved.
//

#import "SourceUrlViewController.h"
#import "AppDelegate.h"

@interface SourceUrlViewController ()

@end

@implementation SourceUrlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
      [self.cmxtLoadingView startAnimating];
     self.navbar=[[UIView alloc]init];
    self.navbar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 65);
    AppDelegate *appDelegate = (id)[[UIApplication sharedApplication]delegate];
    self.navbar.backgroundColor = [UIColor colorWithRed:255.0/255.0f green:50.0/255.0f blue:0.0/255.0f alpha:1.0];
   // self.view.backgroundColor=[appDelegate.clientConfigurator.themeColorDictionary objectForKey:@"backgroundColor"];
        UIImage *whiteButtonImage = [UIImage imageNamed:@"bigBack.png"];
    
    UIButton *redButton = [UIButton buttonWithType:UIButtonTypeCustom];
    redButton.frame = CGRectMake(0.0, 22.0, 35.0, 35.0);
    [redButton setBackgroundImage:whiteButtonImage forState:UIControlStateNormal];
    //[redButton addTarget:self action:@selector(backTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *backTitle = [[UILabel alloc]init];
    backTitle.frame = CGRectMake(30, 19, 60, 40);
    backTitle.textColor = [UIColor whiteColor];
    backTitle.text = @"BACK";
    [backTitle setFont: [backTitle.font fontWithSize: 22]];
   
    UILabel *fdTitle = [[UILabel alloc]init];
    fdTitle.frame = CGRectMake(backTitle.frame.origin.x+backTitle.frame.size.width, 19,[UIScreen mainScreen].bounds.size.width-(backTitle.frame.origin.x+backTitle.frame.size.width), 40);
    fdTitle.textColor = [UIColor whiteColor];
    if([self.objectFromParent objectForKey:@"cTitle"]==nil || [self.objectFromParent objectForKey:@"cTitle"]==(id)[NSNull null])
    {
        fdTitle.text=@"";
    }
    else{

    fdTitle.text =[NSString stringWithFormat:@"%@",[self.objectFromParent objectForKey:@"cTitle"]];
         fdTitle.adjustsFontSizeToFitWidth = YES;
    }
    [fdTitle setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:22]];
   
    [fdTitle setTextAlignment:NSTextAlignmentCenter];
       UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0.0, 22.0, backTitle.frame.size.width+redButton.frame.size.width, 35.0);
    [backButton addTarget:self action:@selector(backTappedInCampaign) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.navbar];
    [self.view addSubview:redButton];
    [self.view addSubview:fdTitle];
    [self.view addSubview:backButton];
    [self.view addSubview:backTitle];

  
    NSURL *url = [NSURL URLWithString:[self.objectFromParent objectForKey:@"webAddress"]];
    self.request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
    [self.webView loadRequest:self.request];
     [self.cmxtLoadingView stopAnimating];
}
-(void)backTappedInCampaign
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Webview Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.cmxtLoadingView stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
   [self.cmxtLoadingView stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible= NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.cmxtLoadingView stopAnimating];
    if (error.code!=204)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Parity Plus App"
                              message:@"It is taking longer to access this content than expected. Please try agin later."
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        
        [alert show];
        [UIApplication sharedApplication].networkActivityIndicatorVisible= NO;
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.cmxtLoadingView stopAnimating];
    [self.webView stopLoading];
    self.request=nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible= NO;
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
