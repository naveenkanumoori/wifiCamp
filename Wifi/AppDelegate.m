//
//  AppDelegate.m
//  Wifi
//
//  Created by admin on 8/27/15.
//  Copyright (c) 2015 admin. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <NetworkExtension/NetworkExtension.h>

#import "ProximitySDK.h"
#import "Constants.h"
#import "KeychainItemWrapper.h"
#import "AdPopUpLaunchViewController.h"
#import <CommonCrypto/CommonDigest.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#define CACHED_IMAGES_COUNT 25

@interface AppDelegate ()

@property (nonatomic, strong) AdPopUpLaunchViewController *modalVC;
 
@end






@implementation AppDelegate
@synthesize infosysSDK,entryType,secCount;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.wifiInfo=[[NSDictionary alloc]init];
    self.backUpWifiInfo=[[NSDictionary alloc]init];
    self.wifiReachability=[[NSString alloc]init];
    self.bssidNew=[[NSString alloc]init];
    self.bssidOld=[[NSString alloc]init];
    self.ipAddress=[[NSString alloc]init];
    self.macAddress=[[NSString alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil ];
        wifiReach = [Reachability reachabilityForLocalWiFi];
    
    [wifiReach startNotifier];
    [self showAlertOfInternetConncetion: wifiReach];
    secCount=0;
    entryType=[[NSString alloc]init];
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive || state == UIApplicationStateActive)
    {
        
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(getNetworkName) userInfo:nil repeats:YES];
        
    }
    
    return YES;
}

- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self showAlertOfInternetConncetion: curReach];
}

- (void)showAlertOfInternetConncetion : (Reachability*) curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
        {
            secCount=0;
            [self initilizeProximitySDK];
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"ReachableVia WWAN");
            break;
        }
        case ReachableViaWiFi:
        {
            [self initilizeProximitySDK];
            NSLog(@"ReachableVia WiFi");
            self.wifiReachability=@"wifi";
            break;
        }
            
    }
}

- (void)getNetworkName {
    // Does not work on the simulator.
    secCount=secCount+1;
    NSDictionary *info = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
    info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        //        if (info[@"SSID"]) {
        //            ssid = info[@"SSID"];
        //        }
        
    }
    
  //  NSLog(@"%@",info);
   self.wifiInfo=info;
    if (secCount==2 && self.wifiInfo!=nil) {
        self.backUpWifiInfo=nil;
        self.backUpWifiInfo=info;
    }
    
    if (!([[self.backUpWifiInfo objectForKey:@"BSSID"]isEqualToString:[self.wifiInfo objectForKey:@"BSSID"]])) {
        secCount=1;
    }

    
    //ip address
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                 
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                   // NSLog(@"%s",inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr));
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    
    
    
    self.ipAddress=address;
    
    
    //mac address of iPhone
    
    int mgmtInfoBase[6];
    char *msgBuffer = NULL;
    NSString *errorFlag = NULL;
    size_t length;
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET; // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE; // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK; // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST; // Request all configured interfaces
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    // Get the size of the data available (store in len)
    else if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
        errorFlag = @"sysctl mgmtInfoBase failure";
    // Alloc memory based on above call
    else if ((msgBuffer = malloc(length)) == NULL)
        errorFlag = @"buffer allocation failure";
    // Get system information, store in buffer
    else if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0) {
        free(msgBuffer);
        errorFlag = @"sysctl msgBuffer failure";
    } else {
        // Map msgbuffer to interface message structure
        struct if_msghdr *interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
        // Map to link-level socket structure
        struct sockaddr_dl *socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
        // Copy link layer address data in socket structure to an array
        unsigned char macAddress[6];
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        // Read from char array into a string object, into traditional Mac address format
        NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                      macAddress[0], macAddress[1], macAddress[2], macAddress[3], macAddress[4], macAddress[5]];

        free(msgBuffer);
 
        self.macAddress=macAddressString;
    }
  
    
    if (self.wifiInfo!=nil && secCount<=30) {
        
        entryType=[NSString stringWithFormat:@"Entered into Wifi region with SSID %@",[info objectForKey:@"SSID"]];
    }
    else if(self.wifiInfo!=nil && secCount>30)
    {
        entryType=[NSString stringWithFormat:@"Still Present in Wifi region with SSID %@",[self.wifiInfo objectForKey:@"SSID"]];
    }
    else if (self.wifiInfo==nil)
    {
        entryType=[NSString stringWithFormat:@"Exited from wifi with SSID %@",[self.backUpWifiInfo objectForKey:@"SSID"]];
        secCount=0;
        self.bssidOld=[self.backUpWifiInfo objectForKey:@"BSSID"];
        
    }
    
    if (self.viewController) {
        [self.viewController displayValue];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        exit(0);
    }
}

-(void)initilizeProximitySDK
{
    infosysSDK=[[ProximitySDK alloc]init];
    infosysSDK.delegate=self;
    NSMutableDictionary *campaignPolicy=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"YES",@"multipleAds",@"NO",@"rotateAds",@"YES",@"presentOnReentry",@"10",@"reentryTimer",@"NO",@"presentOnPresence",@"30",@"presenceTimer",@"2",@"waitForConsistency",@"NO",@"CampIdRePresent", nil];
    [infosysSDK setUserCampaignPolicy:campaignPolicy];
    [infosysSDK initilizeSDK:KEYSTRING :SECRETSTRING];
}
    
    
-(void)didInitilizedSDK:(NSData *)data
{
    //Parse the data
    NSError *myError = nil;
    NSMutableDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    
    if (myError==nil)
    {
        NSString * result= [resultDictionary objectForKey:@"status"];
        
        if([result isEqualToString:@"success"])
        {
            KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"TestUDID" accessGroup:nil];
            NSString *idfv=[[NSString alloc]init];
            idfv=[keychain objectForKey:(__bridge id)(kSecAttrAccount)];
            if(![idfv isEqualToString:@""])
            {
                idfv=[keychain objectForKey:(__bridge id)(kSecAttrAccount)];
            }
            else{
                idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                if(![idfv isEqualToString:@""])
                {
                    [keychain setObject:idfv forKey:(__bridge id)(kSecAttrAccount)];
                }
            }
            
            NSString *vmdspid = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"dbSavedLoggedUser"]];
            if (vmdspid.length==0 || vmdspid==nil || [vmdspid isEqualToString:@"(null)"])
            {
                vmdspid = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"dbSavedAnonymousUser"]];
            }
            
            NSDictionary *inputDictionary=[[NSDictionary alloc]initWithObjectsAndKeys:KEYSTRING,@"key",SECRETSTRING,@"secret",idfv,@"imei",vmdspid,@"vmdspid",self.wifiReachability,@"wifiConnnected",nil ];
            
            [infosysSDK startScan:inputDictionary];
            
        }
        else
        {
            
            
        }
        
    }
    else
    {
        
        
        
    }
    
}

-(void)didStartedScanning:(NSData *)data :(NSString *)type
{
    //Parse the data
    NSError *myError = nil;
    NSMutableDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    
    if (myError==nil)
    {
        NSString * result= [resultDictionary objectForKey:@"status"];
        
        if([result isEqualToString:@"success"])
        {
            //do nothing
        }
        else
        {
            //debug the problem
        }
        
    }
    else
    {
        //debug the problem
    }
}

-(void)didGetCampaign:(NSData *)data
{
    //Parse the data
    NSError *myError = nil;
    NSMutableDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];

    if (myError==nil)
    {
        NSString * result= [resultDictionary objectForKey:@"status"];
        
        if([result isEqualToString:@"success"])
        {
                    NSArray *array= [resultDictionary objectForKey:@"description"];
                    if ([self.viewController isKindOfClass:[AdPopUpLaunchViewController class]])
                    {
                        //Pop is still in there
                    }
                    else
                    {
                        self.modalVC = [[AdPopUpLaunchViewController alloc] initWithNibName:@"AdPopUpLaunchViewController" bundle:nil];
                        self.modalVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                        self.modalVC.adFeeds=array;
                        
                        if (array.count==1)
                        {
                            NSString *type=[[array objectAtIndex:0] objectForKey:@"cType"];
                            if ([type caseInsensitiveCompare:@"MultiPoint"]==NSOrderedSame)
                            {
                                NSString *vmdspid = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"dbSavedLoggedUser"]];
                                if (vmdspid.length==0 || vmdspid==nil || [vmdspid isEqualToString:@"(null)"])
                                {
                                    vmdspid = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"dbSavedAnonymousUser"]];
                                    if (vmdspid.length==0 || vmdspid==nil || [vmdspid isEqualToString:@"(null)"])
                                    {
                                        //vmdsipid Not Available
                                    }
                                    else
                                    {
                                        [self.viewController presentViewController:self.modalVC animated:YES completion:NULL];
                                    }
                                }
                                else
                                {
                                    [self.viewController presentViewController:self.modalVC animated:YES completion:NULL];
                                }
                                
                            }
                            else
                            {
                                [self.viewController presentViewController:self.modalVC animated:YES completion:NULL];
                            }
                        }
                        else
                        {
                            [self.viewController presentViewController:self.modalVC animated:YES completion:NULL];
                        }
                        
                    }
                }
                
                
            }
        }


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.infosys.ScrollTrial.Wifi" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Wifi" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Wifi.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
       NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
