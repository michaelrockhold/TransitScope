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
@class SLTMapView;
@class MKAnnotationView;

@interface BusDetailViewController : UITableViewController
{
	Bus* m_bus;
	UISwitch* m_followThisBusSwitch;
	SLTMapView* m_mapview;
	NSTimer* m_updatePositionUpdateTimer;
}

-(id)initWithBus:(Bus*)bus;

- (void)updatePositionUpdateTime:(NSDictionary*)userInfo;
- (void)followingBusSwitchToggled:(id)sender;
- (void)recenterMap;

@property (nonatomic, retain, readonly) SLTMapView* mapView;

- (MKAnnotationView*)annotationViewForBus:(Bus*)bus inMapView:(MKMapView*)mapView;

@end
