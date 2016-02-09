//
//  ProximitySDK.m
//  ProximitySDK
//
//  Created by Arunkavi on 03/03/15.
//  Copyright (c) 2015 com.infosys. All rights reserved.
//

#import "ProximitySDK.h"
#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
//#import <CoreBluetooth/CoreBluetooth.h>
//#import <CoreLocation/CoreLocation.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#define SERVERFAILMESSAGE @"Server Failed Temporarly"
#define STRINGSUCCESS @"success"
#define STRINGSTATUS @"status"
#define STRINGFAIL @"fail"
#define STRINGDESCRIPTION @"description"
#define STRINGEMPTYKEY @"Key/Secret is empty"
#define STRINGSEARCHING @"Searching for iBeacons..."
#define STRINGINVALIDKEY @"Invalid key/secret"
#define BEACON_IDENTIFIER @"BeaconRegion"



@interface ProximitySDK ()<NSURLConnectionDelegate>

{
    
@private
    
    NSString *localFlag;
    NSArray *savedUuidList;
    NSDictionary *savedUuidMajorList;
    NSURLConnection *connect;
    NSMutableData *responseData;
    NSString *statusCode;
    BOOL secondPost;
    NSString *descriptionMessage;
    NSString *authenticationMesasge;
    BOOL authorized;
    NSString *vmdspid;
    NSString *scanType;
    NSString *appId;
    NSString *deviceName;
    //Not Checked
    NSMutableDictionary *postData;
    NSMutableDictionary *postKeySecret;
    NSMutableDictionary *postHeader;
    
    NSDictionary *wifiInfo;
    NSString *bssid;
    int secCount;
    int count_beacon_detect_frequency;
    int count_beacon_remove_frequency;
//    CLBeacon  *beacon_waiting_for_consistency;
    
}

@property (nonatomic,strong) NSString *savedKey;
@property (nonatomic,strong) NSString *savedSecret;
@property (nonatomic,strong) NSString *savedImei;
@property (nonatomic,strong) NSString *entryType;
//@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
//@property (strong, nonatomic) CLLocationManager *locationManager;
//@property (nonatomic,strong) CBCentralManager *bluetoothManager;
@property (nonatomic, strong) NSArray *beaconsArray;
@property (nonatomic, strong) NSDate  *sentTime;
//@property (nonatomic, strong) CLBeacon *beacon_old;
//@property (nonatomic, strong) CLBeaconRegion *beacon_old_region;
@property (nonatomic, strong) NSString *beacon_current;
@property (nonatomic,strong) NSDictionary *savedCampDetails;
@property (nonatomic,strong) NSMutableDictionary *campaignPolicy;
@property (nonatomic,strong) NSMutableDictionary *lastShownCampaignDetails;
@property (nonatomic,strong) NSMutableArray *lastShownCampaignIds;
@property (nonatomic,strong) NSMutableDictionary *lastShownTicketDetails;
@property (nonatomic,strong) NSData *currentRequestToServer;

//save initilized beacon regions for uuid/major level in array so that it would be easy to unmoniter
@property (nonatomic,strong) NSMutableArray *uuidBeaconRegions;
@property (nonatomic,strong) NSMutableArray *majorBeaconRegions;

//Not checked
@property (nonatomic,strong) NSDictionary *uuidMinorMajorDictionary;
@property (nonatomic,strong) NSString *uuidMinorMajor;

//Server Call
-(void)connectToAuthenticationServer:(NSString *)key :(NSString *)secret;
-(void)connectToLocationServer:(NSData *)data;

//Parsing
-(void)parseAuthenticateResponse:(NSData *)data;
-(void)parseLocationResponse:(NSData *)data;

//Beacon
-(void)initRegion :(NSString *)uuid :(NSString *)name;
-(void)initMajorLevelRegion :(NSString *)uuid :(NSString *)major :(NSString *)name;

//Encryption
-(NSString *)hmac:(NSString *)key withData:(NSString *)data;
-(NSString *)md5:(NSString *) input;
-(NSString *)sha256:(NSString *) input;

@end

@implementation ProximitySDK
@synthesize savedKey,savedSecret,uuidMinorMajor,savedImei,entryType,beacon_current,sentTime,campaignPolicy;

int CONSISTENCY_COUNT = 3;
int CONSISTENCY_COUNT_REMOVAL = 2;
int PRESENCE_INTERVAL=60;

-(id)init
{
    bssid=[[NSString alloc]init];
    savedKey=[[NSString alloc]init];
    savedSecret=[[NSString alloc]init];
    savedUuidList=[[NSArray alloc]init];
    savedUuidList=nil;
    self.uuidMinorMajorDictionary=[[NSDictionary alloc]init];
    savedUuidMajorList=[[NSDictionary alloc]init];
    savedUuidMajorList=nil;
    self.savedCampDetails=[[NSDictionary alloc] init];
    self.savedCampDetails=nil;
    self.currentRequestToServer=[[NSData alloc]init];
    self.currentRequestToServer=nil;
    connect =[[NSURLConnection alloc]init];
    connect=nil;
    statusCode=[[NSString alloc]init];
    localFlag=[[NSString alloc]init];
    localFlag=nil;
    secondPost=NO;
    descriptionMessage=[[NSString alloc]init];
    authenticationMesasge=[[NSString alloc]init];
    descriptionMessage=nil;
    authenticationMesasge=nil;
    authorized=NO;
    entryType=[[NSString alloc]init];
    entryType=nil;
    vmdspid=[[NSString alloc]init];
    savedImei=[[NSString alloc]init];
    savedImei=@"Unknown";
    scanType=[[NSString alloc]init];
    scanType=@"Unknown";
    self.beaconsArray=[[NSArray alloc]init];
    appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    deviceName =[[UIDevice currentDevice]name];
    
    self.uuidBeaconRegions=[[NSMutableArray alloc]init];
    self.majorBeaconRegions=[[NSMutableArray alloc]init];
    
    count_beacon_detect_frequency=0;
    count_beacon_remove_frequency=0;
    secCount=1;
    //
    postData=[[NSMutableDictionary alloc]init];
    postHeader=[[NSMutableDictionary alloc]init];
    postKeySecret=[[NSMutableDictionary alloc]init];
    self.lastShownCampaignDetails=[[NSMutableDictionary alloc]init];
    self.lastShownCampaignIds=[[NSMutableArray alloc]init];
    self.lastShownTicketDetails=[[NSMutableDictionary alloc]init];
    wifiInfo=[[NSDictionary alloc]init];
    uuidMinorMajor=[[NSString alloc]init];
    
    beacon_current = [[NSString alloc]init];
    sentTime = [NSDate date];
    beacon_current=nil;
    campaignPolicy=[[NSMutableDictionary alloc]initWithObjectsAndKeys:@"NO",@"multipleAds",@"NO",@"rotateAds",@"YES",@"presentOnReentry",@"10",@"reentryTimer",@"NO",@"presentOnPresence",@"30",@"presenceTimer",@"2",@"waitForConsistency",@"NO",@"CampIdRePresent", nil];

    return self;
}

-(void)setUserCampaignPolicy:(NSMutableDictionary *)policy
{
    campaignPolicy=[policy mutableCopy];
}
-(void)initilizeSDK:(NSString *)key :(NSString *)secret
{
    if (key.length==0 || secret.length==0 || (key == nil) || (secret == nil))
    {
        if([self.delegate respondsToSelector:@selector(didInitilizedSDK:)])
        {
            authenticationMesasge=STRINGFAIL;
            descriptionMessage=STRINGEMPTYKEY;
            NSMutableDictionary *localResponseMessage=[[NSMutableDictionary alloc]initWithObjectsAndKeys:STRINGFAIL,STRINGSTATUS,STRINGEMPTYKEY,STRINGDESCRIPTION, nil ];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:localResponseMessage options:kNilOptions error:nil];
            [self.delegate didInitilizedSDK:jsonData];
        }
        
    }
    else
    {
        
        localFlag=@"Location";
        savedKey=key;
        savedSecret=secret;
        
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
            if (state == UIApplicationStateBackground || state == UIApplicationStateInactive || state == UIApplicationStateActive)
            {
        
      [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(getNetworkName) userInfo:nil repeats:YES];
            }
   
    }
}
-(void)startScan:(NSDictionary *)input
{
    NSString *localKey=[input objectForKey:@"key"];
    NSString *localSecret=[input objectForKey:@"secret"];
    NSString *localImei=[input objectForKey:@"imei"];
    NSString *localVmdspid=[input objectForKey:@"vmdspid"];
    
    if (localKey.length==0 || localSecret.length==0 || localImei.length==0  || (localKey==nil) || (localSecret == nil) || (localImei == nil) || localVmdspid.length==0)
    {
        authenticationMesasge=@"filter";
        descriptionMessage=@"Key/Secret/imei/vmdspid is empty";
        
        if([self.delegate respondsToSelector:@selector(didStartedScanning::)])
        {
            NSMutableDictionary *localResponseMessage=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:localResponseMessage options:kNilOptions error:nil];
            [self.delegate didStartedScanning:jsonData:@"Not Found"];
        }
        
    }
    else{
        
        if (authorized)
        {
            //NSLog(@"!!! started scanning and Auth success");
            savedImei=[input objectForKey:@"imei"];
            savedKey=[input objectForKey:@"key"];
            savedSecret=[input objectForKey:@"secret"];
            vmdspid=[input objectForKey:@"vmdspid"];
            if ([[input objectForKey:@"wifiConnnected"] isEqual:@"wifi"]) {
                [self getNetworkName];
            }
            //[self checkUuidList];
        }
        
        
        else
        {
            
            authenticationMesasge=@"filter";
            descriptionMessage=@"You are not authorized";
            
            if([self.delegate respondsToSelector:@selector(didStartedScanning::)])
            {
                NSMutableDictionary *localResponseMessage=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:localResponseMessage options:kNilOptions error:nil];
                [self.delegate didStartedScanning:jsonData:entryType];
            }
        }
        
        
    }
    
}

- (void)getNetworkName {
    secCount=secCount+1;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        wifiInfo = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
    }

    if (wifiInfo!=nil && secCount>1 && secCount<=30) {
        entryType=@"ENTRY";
    }
    else if(wifiInfo!=nil && secCount>30)
    {
        entryType=@"PRESENCE";
    }
    else if (wifiInfo==nil)
    {
        entryType=@"EXIT";
        secCount=1;
    }

    
}



#pragma mark - Parsing
-(void)parseCapmResponse:(NSData *)data
{
    //Parse the data
    NSError *myError = nil;
    NSMutableDictionary *dictinaryFromData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    
  
    
    NSString *availableMessage=[[dictinaryFromData objectForKey:@"data"] objectForKey:@"message"];
 //   NSLog(@"!!! Version available %@",availableMessage);
    
    if (self.savedCampDetails.count>0)
    {
        if ([availableMessage caseInsensitiveCompare:@"yes"]==NSOrderedSame)
        {
            self.savedCampDetails=[dictinaryFromData objectForKey:@"data"];
            [[NSUserDefaults standardUserDefaults] setObject:data  forKey:@"SAVEDCAMPVERSION"];
            [[NSUserDefaults standardUserDefaults] synchronize];
          
            NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[dictinaryFromData objectForKey:@"data"] objectForKey:@"eventType"],@"entry",[[dictinaryFromData objectForKey:@"data"] objectForKey:@"uuid"],@"uuid",[[dictinaryFromData objectForKey:@"data"] objectForKey:@"major"],@"major",[[dictinaryFromData objectForKey:@"data"] objectForKey:@"minor"],@"minor",nil ];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tempDictionary options:kNilOptions error:nil];

                [self checkCampaignForwifi:jsonData];
            
        }
        else
        {
            NSData *dataStored=[[NSUserDefaults standardUserDefaults] objectForKey:@"SAVEDCAMPVERSION"];
            //Parse the data
            NSError *myError = nil;
            NSMutableDictionary *dictinaryFromData = [NSJSONSerialization JSONObjectWithData:dataStored options:NSJSONReadingMutableLeaves error:&myError];
            if (dictinaryFromData!=nil && dictinaryFromData.count>0)
            {
                self.savedCampDetails = [dictinaryFromData objectForKey:@"data"];;
            }
            
        }
    }
    else
    {
        if ([availableMessage caseInsensitiveCompare:@"yes"]==NSOrderedSame)
        {
            NSDictionary *checkBeforeAdding=[dictinaryFromData objectForKey:@"data"];
            if (checkBeforeAdding!=nil && checkBeforeAdding.count>0)
            {
                self.savedCampDetails=[dictinaryFromData objectForKey:@"data"];
                
                [[NSUserDefaults standardUserDefaults] setObject:data  forKey:@"SAVEDCAMPVERSION"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSDictionary *tempDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[[dictinaryFromData objectForKey:@"data"]  objectForKey:@"eventType"],@"entry",[[dictinaryFromData objectForKey:@"data"] objectForKey:@"uuid"],@"uuid",[[dictinaryFromData objectForKey:@"data"] objectForKey:@"major"],@"major",[[dictinaryFromData objectForKey:@"data"] objectForKey:@"minor"],@"minor",nil ];
                
                NSData *tempJsonData = [NSJSONSerialization dataWithJSONObject:tempDictionary options:kNilOptions error:nil];
                [self checkCampaignForwifi:tempJsonData];

                
            }
            
            
            
        }
        else
        {
            
            NSData *dataStored=[[NSUserDefaults standardUserDefaults] objectForKey:@"SAVEDCAMPVERSION"];
            //Parse the data
            NSError *myError = nil;
            NSMutableDictionary *dictinaryFromData = [NSJSONSerialization JSONObjectWithData:dataStored options:NSJSONReadingMutableLeaves error:&myError];
            if (dictinaryFromData!=nil && dictinaryFromData.count>0)
            {
                self.savedCampDetails = [dictinaryFromData objectForKey:@"data"];
            }
            
            
        }
    
    }
    
}
-(void)parseAuthenticateResponse:(NSData *)data
{
    //Parse the data
    NSError *myError = nil;
    NSMutableDictionary *dictinaryFromData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
  //  NSLog(@"%@",dictinaryFromData);
    if (myError==nil)
    {
        NSString * resultString= [dictinaryFromData objectForKey:@"statusMsg"];
        
        if([resultString isEqualToString:@"success"])
        {
            NSString *type=[[dictinaryFromData objectForKey:@"data"] objectForKey:@"type"];
            if ([type caseInsensitiveCompare:@"venue"]==NSOrderedSame)
            {
                savedUuidList=[[dictinaryFromData objectForKey:@"data"] objectForKey:@"venuedetails"];
                
                scanType=@"UUID";
                authorized=YES;
            }
            else if ([type caseInsensitiveCompare:@"geofence"]==NSOrderedSame)
            {
                NSDictionary *venueUuid = [[dictinaryFromData objectForKey:@"data"] objectForKey:@"venuedetails"];
                NSArray *majorLevel= [[dictinaryFromData objectForKey:@"data"] objectForKey:@"majordetails"];
                
                savedUuidMajorList=[[NSDictionary alloc]initWithObjectsAndKeys:venueUuid,@"uuid",majorLevel,@"majorDetails", nil];
                
                scanType=@"MAJOR";
                authorized=YES;
                
            }
            
            if(savedUuidList.count==0)
            {
                authenticationMesasge=STRINGFAIL;
                descriptionMessage=@"Update iBeacon type in portal";
                
            }
            else
            {
                authenticationMesasge=STRINGSUCCESS;
                descriptionMessage=STRINGSEARCHING;
            }
            
            
        }
        else if([resultString isEqualToString:@"filter"])
        {
            authenticationMesasge=STRINGFAIL;
            descriptionMessage=STRINGINVALIDKEY;
        }
        else
        {
            authenticationMesasge=STRINGFAIL;
            descriptionMessage=SERVERFAILMESSAGE;
        }
        
    }
    else
    {
        authenticationMesasge=STRINGFAIL;
        descriptionMessage=SERVERFAILMESSAGE;
        
    }
    
    //Call delegate method to return values
    if([self.delegate respondsToSelector:@selector(didInitilizedSDK:)])
    {
        
        NSMutableDictionary *localResponseMessage=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:localResponseMessage options:kNilOptions error:nil];
        [self.delegate didInitilizedSDK:jsonData];
    }
    
}
-(void)parseLocationResponse:(NSData *)data
{
    //Parse the data
    NSError *myError = nil;
    NSMutableDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    
    //NSLog(@"!!! Response from the server %@",res);
    
    NSMutableDictionary *tempLocationDict=[[NSMutableDictionary alloc]init];
    NSData *jsonData = [[NSData alloc]init];
    
    if (myError==nil)
    {
        NSString * result= [res objectForKey:@"statusMsg"];
        
        if([result isEqualToString:@"filter"])
        {
            
            authenticationMesasge=@"filter";
            descriptionMessage=@"Invalid key/secret";
            tempLocationDict=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
            jsonData = [NSJSONSerialization dataWithJSONObject:tempLocationDict options:kNilOptions error:nil];
        }
        else if([result isEqualToString:@"serviceError"])
        {
            authenticationMesasge=@"fail";
            descriptionMessage=@"Server Failed";
            tempLocationDict=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
            jsonData = [NSJSONSerialization dataWithJSONObject:tempLocationDict options:kNilOptions error:nil];
        }
        else
        {
            authenticationMesasge=@"success";
            descriptionMessage=@"Users loaction reported to server";
            tempLocationDict=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
            jsonData = [NSJSONSerialization dataWithJSONObject:tempLocationDict options:kNilOptions error:nil];
            [self parseCapmResponse:data];
        }
        
    }
    else
    {
        authenticationMesasge=@"fail";
        descriptionMessage=@"Server Failed";
        tempLocationDict=[[NSMutableDictionary alloc]initWithObjectsAndKeys:authenticationMesasge,@"status",descriptionMessage,@"description", nil ];
        jsonData = [NSJSONSerialization dataWithJSONObject:tempLocationDict options:kNilOptions error:nil];
    }

    if([self.delegate respondsToSelector:@selector(didStartedScanning::)])
    {

    }
    
}

#pragma mark - Encryption

-(NSString *)hmac:(NSString *)key withData:(NSString *)data
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMACData = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];
    NSString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];
    for (int i = 0; i < HMACData.length; ++i)
        HMAC = [HMAC stringByAppendingFormat:@"%02lx", (unsigned long)buffer[i]];
    
    return HMAC;
    
}
- (NSString *)shuffledAlphabet
{
    NSUInteger NUMBER_OF_CHARS = 7;
    char data[NUMBER_OF_CHARS];
    for (int x=0;x<NUMBER_OF_CHARS;data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:NUMBER_OF_CHARS encoding:NSUTF8StringEncoding];
}
- (NSString *) md5:(NSString *) input
{
    
    // Now create the MD5 hashs
    const char *ptr = [input UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}
- (NSString *)sha256:(NSString *) input
{
    const char *s=[input cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(keyData.bytes, (CC_LONG)keyData.length, digest);
    NSData *out=[NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash=[out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
}


#pragma mark - Native Api

-(void)reportEntryOrPresenceInRegion:(CLRegion *)region{
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateActive)
    {
        
   
    }
    if (state == UIApplicationStateInactive||state == UIApplicationStateActive)
    {
        NSMutableDictionary *serverMessage = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"ENTRY",@"entry",nil,@"uuid",nil,@"major",nil,@"minor",nil ];
        self.uuidMinorMajorDictionary=serverMessage;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:serverMessage options:kNilOptions error:nil];
        self.currentRequestToServer=jsonData;
        localFlag=@"Location";
        
        //Connect to Server
        
        if ((!self.savedCampDetails.count>0))
        {
            // [self checkCampaignForBeacons:jsonData];
            [self connectToLocationServer :jsonData];
        }
        
        else{
            [self parseLocationResponse:responseData];
        }

    }
}


-(void)checkCampaignForwifi :(NSData *) input
{
    //Parse the data
    NSError *myError = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:input options:NSJSONReadingMutableLeaves error:&myError];

    
    NSString *campaignId=[[NSString alloc]init];
     NSMutableArray *finalCamp=[[NSMutableArray alloc]init];
    if (myError==nil)
    {

            if (self.savedCampDetails.count>0)
            {
                NSLog(@"%@",self.savedCampDetails);
                NSArray *accessPointDetails=[[self.savedCampDetails objectForKey:@"campaigns"] objectForKey:@"APdetails"];
                
                for (int i=0; i<accessPointDetails.count; i++) {
                    NSString *wifiBssid=[[accessPointDetails objectAtIndex:i]objectForKey:@"BSSID"];
                   // NSLog(@"hhhh %@",wifiBssid);
                    if ([[wifiInfo objectForKey:@"BSSID"] isEqualToString:wifiBssid]) {
                        
                        
                        
                        NSArray *campaigns=[[accessPointDetails objectAtIndex:i]objectForKey:@"campaigns"];
                        if(campaigns.count>0)
                        {
                            
                            campaignId=[[campaigns objectAtIndex:0]objectForKey:@"campaignId"];
                        }
                    }
                }
                if (campaignId!=nil) {
                    
                
                            NSArray *wifiCampaignDetails=[[self.savedCampDetails objectForKey:@"campaigns"]objectForKey:@"campaigndetails"];
                            for (int i=0; i<wifiCampaignDetails.count; i++) {
                                NSString *checkCampaignId=[[wifiCampaignDetails objectAtIndex:i]objectForKey:@"campaignId"];
                                
                                if ([checkCampaignId isEqualToString:campaignId]) {
                                    [finalCamp addObject:[wifiCampaignDetails objectAtIndex:i]];
                                }
                                
                    }
                }
                
                            [self sendCampDetailsToApplication :finalCamp :input];
                            
                        }
                        else
                        {
                            //NSLog(@"No campaign found for current venue");
                        }
                    }

                    
                }
                





-(void)sendCampDetailsToApplication :(NSMutableArray *)input : (NSData *)beaconDetails
{
    //Parse the data
    
        //Call delegate method to return values
        if([self.delegate respondsToSelector:@selector(didGetCampaign:)]) 
        {
            NSMutableDictionary *localResponseMessage=[[NSMutableDictionary alloc]initWithObjectsAndKeys:STRINGSUCCESS,@"status",input,@"description",input,@"AllCampaigns", nil];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:localResponseMessage options:kNilOptions error:nil];
            [self.delegate didGetCampaign:jsonData];
        }
        
    }
//}

@end
