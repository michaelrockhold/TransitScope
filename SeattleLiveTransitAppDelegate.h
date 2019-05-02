//
//  LiveTransit_SeattleAppDelegate.h
//  LiveTransit_Seattle
//
//  Created by Michael Rockhold on 7/9/09.
//  Copyright The Rockhold Company 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MapKit/MKReverseGeocoder.h>
#import "Model.h"
#import "BusInfoCollector.h"
#import "BusInfoCollectionOwner.h"

@class Bus;
@class Route;

@class MapViewController;

@interface SeattleLiveTransitAppDelegate : NSObject <Model, BusInfoCollectionOwner, UIApplicationDelegate, UITabBarControllerDelegate, CLLocationManagerDelegate>
{
    UIWindow*				m_window;
    UITabBarController*		m_rootTabBarController;
		
	MapViewController*		m_mapViewController;
	CLLocationManager*		m_locationManager;

	CLLocation*				m_currentLocation;
	CLLocation*				m_centerOfMap;
	Bus*					m_followedBus;
	Route*					m_outOfService;
	
	NSMutableSet*			m_buses;
	NSMutableDictionary*	m_allPossibleRoutes;
	NSPredicate*			m_knownRoutePredicate;
}

-(void)getCountsOfBuses:(NSUInteger*)pBusCount routes:(NSUInteger*)pRouteCount;

-(void)revealAllRoutes;
-(void)hideAllRoutes;

-(void)save;
-(void)restore;

-(void)switchToMapViewForAnnotation:(Annotation*)ann;
-(BOOL)isVisibleInMainMap:(Annotation*)ann;
-(BOOL)isCloseToCurrentLocation:(Annotation*)ann;

@property (nonatomic, readonly)			NSString*		applicationSupportDirectory;

@property (nonatomic, retain) IBOutlet	UIWindow*		window;
@property (nonatomic, retain) IBOutlet	UITabBarController* rootTabBarController;

@property (nonatomic)					BOOL			hideNewRoutesByDefault;
@property (nonatomic, retain)			CLLocation*		currentLocation;
@property (nonatomic, retain)			CLLocation*		centerOfMap;
@property (nonatomic, retain)			Bus*			followedBus;
@property (nonatomic, retain, readonly)	Route*			outOfService;

@property (nonatomic, retain, readonly)	NSSet*			routes;
@property (nonatomic, retain)			NSSet*			buses;
@property (nonatomic, retain, readonly)	NSDictionary*	allPossibleRoutes;

@property (nonatomic, retain) IBOutlet	MapViewController* mapViewController;

@end
