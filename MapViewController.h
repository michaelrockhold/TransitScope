/*
 MapViewController.h
 Controller class for the map view, as you may have guessed.
 
 Copyright 2009, The Rockhold Company. All rights reserved.
 */

#import "SeattleLiveTransitAppDelegate.h"

@class Bus;

@interface MapViewController : UIViewController
{
	MKMapView*			m_mapView;
	IBOutlet UIBarButtonItem*  m_changeLocationButton;
	UIButton*			m_rightBusCalloutButton;
}

-(IBAction)changeLocationButtonHandler:(id)sender;

// Bus annotation support
-(void)mapView:(MKMapView*)mapView annotationView:(MKAnnotationView*)view calloutAccessoryControlTapped:(UIControl*)control forBus:(Bus*)bus;
-(MKAnnotationView*)annotationViewForBus:(Bus*)bus inMapView:(MKMapView*)mapView;
-(NSNumber*)canShowCalloutForBus:(Bus*)bus;
-(UIView*)rightCalloutAccessoryViewForBus:(Bus*)bus;

@property (nonatomic, strong) IBOutlet MKMapView* mapView;
@property (nonatomic, strong, readonly) SeattleLiveTransitAppDelegate* model;

@end

extern NSString* MapViewCoordinateRegionKey;