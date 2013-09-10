//
//  BusInfoCollectionOwner.h
//  SeattleLiveTransit
//
//  Created by Michael Rockhold on 10/15/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BusInfoCollector;

@protocol BusInfoCollectionOwner

- (void)busInfoCollectorStartingCollectionPass:(BusInfoCollector*)collector;

- (void)busInfoCollectorEndCollectionPass:(BusInfoCollector*)collector;

- (void)busInfoCollector:(BusInfoCollector*)collector 
		   updateBusInfo:(NSString*)vehicleID
				   route:(NSString*)routeID
				latitude:(double)latitude
			   longitude:(double)longitude
				 heading:(float)heading
			   timestamp:(NSDate*)timestamp;

@property (nonatomic, retain, readonly)	NSDictionary* allPossibleRoutes;

@end
