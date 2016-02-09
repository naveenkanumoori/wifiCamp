//
//  ProximitySDK.h
//  ProximitySDK
//
//  Created by Arunkavi on 03/03/15.
//  Copyright (c) 2015 com.infosys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class ProximitySDK;

/**
 
 WebserviceDelegate defines InfosysSDK connection delegate methods. Eg. didInitilizedSDK: method can be invoked without previous action.
 
 */
@protocol WebserviceDelegate <NSObject>

@required

/**
 * Delegate method that indicates Initializtion done.
 *
 * @param data reference to success or error
 * @return void
 */
-(void)didInitilizedSDK:(NSData *) data;
/**
 * Delegate method that indicates Scanning started.
 *
 * @param data reference to success or error
 * @return void
 */
-(void)didStartedScanning:(NSData *) data : (NSString *)type;
/**
 * Delegate method that indicates Campaign Available.
 *
 * @param data reference to success or error
 * @return void
 */
-(void)didGetCampaign:(NSData *) data;
/**
 * Delegate method that indicates Tickets Available.
 *
 * @param data reference to success or error
 * @return void
 */
-(void)didGetTicketDetails:(NSData *) data;

@end

@interface ProximitySDK : NSObject

/** delegate
 *
 * Primary delegate for the InfosysSDK.
 *
 */
@property (nonatomic, weak) id <WebserviceDelegate> delegate;

/** CampaignPolicy
 *
 * Set Campaign Throtling policy
 *
 */
-(void)setUserCampaignPolicy:(NSDictionary *)policy;

/** initilizeSDK
 *
 * Check for Authorized use of SDK and Initialize
 *
 */
-(void)initilizeSDK:(NSString *)key :(NSString *)secret;

/** startScan
 *
 * Start searching for iBeacons.
 *
 */
-(void)startScan:(NSDictionary *)input;

/** stopScan
 *
 * Stop searching for iBeacons.
 *
 */
-(void)stopScan;

@end
