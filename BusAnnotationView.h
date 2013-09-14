//
//  LTBusAnnotationView.h
//  Live Transit:Seattle
//
//  Created by Michael Rockhold on 7/29/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKMapView.h>
#import <MapKit/MKAnnotationView.h>

@protocol Model;
@class Bus;
@class MapViewController;

@interface BusAnnotationView : MKAnnotationView

+(NSString*)reuseIdentifierForAnnotation:(Bus*)ann;

-(id)initWithController:(MapViewController*)controller bus:(Bus*)bus;

@property (nonatomic, strong) MapViewController* controller;
@end
