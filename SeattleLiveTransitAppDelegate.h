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

@property (weak, nonatomic, readonly)			NSString*		applicationSupportDirectory;

@property (nonatomic, strong) IBOutlet	UIWindow*		window;
@property (nonatomic, strong) IBOutlet	UITabBarController* rootTabBarController;

@property (nonatomic)					BOOL			hideNewRoutesByDefault;
@property (nonatomic, strong)			CLLocation*		currentLocation;
@property (nonatomic, strong)			CLLocation*		centerOfMap;
@property (nonatomic, strong)			Bus*			followedBus;
@property (nonatomic, strong, readonly)	Route*			outOfService;

@property (nonatomic, strong, readonly)	NSSet*			routes;
@property (nonatomic, strong)			NSSet*			buses;
@property (nonatomic, strong, readonly)	NSDictionary*	allPossibleRoutes;

@property (nonatomic, strong) IBOutlet	MapViewController* mapViewController;

@end
