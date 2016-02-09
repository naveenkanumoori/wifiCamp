//
//  ViewController.h
//  Wifi
//
//  Created by admin on 8/27/15.
//  Copyright (c) 2015 admin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ViewController : UIViewController


@property (weak, nonatomic) IBOutlet UILabel *bssidLabel;
@property (weak, nonatomic) IBOutlet UILabel *ssidLabel;

@property (weak, nonatomic) IBOutlet UILabel *ssidDataLabel;
@property(strong,nonatomic) NSDictionary *wifiInfo;
@property (weak, nonatomic) IBOutlet UILabel *secondsLabel;
@property (weak, nonatomic) IBOutlet UILabel *macAddress;

-(void)displayValue;

@end
 
