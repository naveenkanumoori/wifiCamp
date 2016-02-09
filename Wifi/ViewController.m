//
//  ViewController.m
//  Wifi
//
//  Created by admin on 8/27/15.
//  Copyright (c) 2015 admin. All rights reserved.
//

#import "ViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "AppDelegate.h"


@interface ViewController ()
{
    AppDelegate *appDelegate;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.viewController = self;
  //  [self displayValue];
   
    
}



-(void)displayValue{
    self.wifiInfo=appDelegate.wifiInfo;
   
    if (!(appDelegate.wifiInfo==nil) || [appDelegate.wifiInfo isEqual:[NSNull null]]) {
        self.ssidLabel.hidden=NO;
        self.ssidDataLabel.hidden=NO;
        self.secondsLabel.hidden=NO;
        self.macAddress.hidden=NO;

        self.bssidLabel.text=[NSString stringWithFormat:@"BSSID : %@",[self.wifiInfo objectForKey:@"BSSID"]];
        self.ssidLabel.text=[NSString stringWithFormat:@"SSID : %@",[self.wifiInfo objectForKey:@"SSID"]];
        self.ssidDataLabel.text=[NSString stringWithFormat:@"%@",appDelegate.entryType];
        
        self.secondsLabel.text=[NSString stringWithFormat:@"%ld seconds",(long)appDelegate.secCount];
      
       
      //  NSLog(@"%@",appDelegate.ipAddress);
        self.macAddress.text=[NSString stringWithFormat:@"IP Address : %@  \n\n MAC Address : %@",appDelegate.ipAddress,appDelegate.macAddress];


    }
    else{
        if ((appDelegate.bssidOld==nil) || [appDelegate.bssidOld isEqual:[NSNull null]]){
           
            self.bssidLabel.text=@"Device not connected to Wifi";
            self.ssidLabel.hidden=YES;
            self.ssidDataLabel.hidden=YES;
            self.secondsLabel.hidden=YES;
            self.macAddress.hidden=YES;
 
            
        }
        else{
      
        self.bssidLabel.text=[NSString stringWithFormat:@"%@",appDelegate.entryType];
        self.ssidLabel.hidden=YES;
        self.ssidDataLabel.hidden=YES;
            self.secondsLabel.hidden=YES;
            self.macAddress.hidden=YES;
       // self.ssidDataLabel.hidden=YES;
    }

}
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
