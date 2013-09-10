//
//  Model.h
//  LiveTransit-Seattle
//
//  Created by Michael Rockhold on 8/11/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class Annotation;
@class Bus;
@class Route;

@class CLLocation;
@class UITabBarController;

@protocol Model < NSObject >

@property (nonatomic, retain, readonly)	NSSet* routes;
@property (nonatomic) BOOL					hideNewRoutesByDefault;
@property (nonatomic, retain) CLLocation*	currentLocation;
@property (nonatomic, retain) CLLocation*	centerOfMap;
@property (nonatomic, retain) Bus*			followedBus;

- (void)switchToMapViewForAnnotation:(Annotation*)ann;
- (BOOL)isVisibleInMainMap:(Annotation*)ann;
- (BOOL)isCloseToCurrentLocation:(Annotation*)ann;

-(void)getCountsOfBuses:(NSUInteger*)pBusCount routes:(NSUInteger*)pRouteCount;

-(void)revealAllRoutes;
-(void)hideAllRoutes;

-(void)save;

@end
