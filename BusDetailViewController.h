//
//  BusDetailViewController.h
//  LiveTransit-Seattle
//
//  Created by Michael Rockhold on 8/14/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import "Foundation/Foundation.h"

@class Bus;
@protocol Model;
@class MKMapView;
@class MKAnnotationView;

@interface BusDetailViewController : UITableViewController
{
	Bus* m_bus;
	UISwitch* m_followThisBusSwitch;
	MKMapView* m_mapview;
	NSTimer* m_updatePositionUpdateTimer;
}

-(id)initWithBus:(Bus*)bus;

- (void)updatePositionUpdateTime:(NSDictionary*)userInfo;
- (void)followingBusSwitchToggled:(id)sender;
- (void)recenterMap;

@property (nonatomic, strong, readonly) MKMapView* mapView;

@end
