//
//  AppDelegate.h
//  Wifi
//
//  Created by admin on 8/27/15.
//  Copyright (c) 2015 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ViewController.h"
#import "Reachability.h"
#import "ProximitySDK.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    Reachability* wifiReach;
     NSMutableDictionary *cachedImages;
    dispatch_queue_t serialWriteQueue;
    
    NSTimer *timer;
    
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(strong, nonatomic) ViewController *viewController;
@property(strong, nonatomic) UINavigationController *navCon;
@property(strong,nonatomic) NSDictionary *wifiInfo,*backUpWifiInfo;
@property (nonatomic, strong) ProximitySDK *infosysSDK;
@property (strong,nonatomic) NSString *wifiReachability,*entryType,*bssidOld,*bssidNew,*ipAddress,*macAddress;
@property  NSInteger secCount;




- (NSString *)MD5String :(NSString*)str;
-(UIImage*)getCachedImages:(NSString*)md5edStr;
-(void)writeImageToDisc:(UIImage *)img withFilePath : (NSString *)file_path;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

