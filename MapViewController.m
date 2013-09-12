/*
 
 File: MapViewController.m
 Abstract: Controller class for the "main" view (visible at app start).
 
 */

	// Shorthand for getting localized strings, used in formats below for readability
#define LocStr(key) [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]

#import <Foundation/Foundation.h>

#import "MapViewController.h"

#import "Bus.h"
#import "BusAnnotationView.h"

#import "BusDetailViewController.h"

#import "Model.h"
#import "Route.h"
#import "NSUserDefaults+MKCoordinateRegion.h"

extern NSObject<Model>* g_Model;

NSString* MapViewCoordinateRegionKey = @"mapviewcoordinateregion";

@interface ClassPredicate : NSPredicate
{
	Class m_class;
}

- (id)initWithClass:(Class)k;
- (BOOL)evaluateWithObject:(id)object;

@end

@implementation ClassPredicate

- (id)initWithClass:(Class)k
{
	if ( self = [self init] )
	{
		m_class = k;
	}
	return self;
}

- (BOOL)evaluateWithObject:(id)object
{
	return [object isKindOfClass:m_class];
}

@end


@interface MapViewController (PrivateMethods)

-(void)registerInterestInBuses:(NSSet*)setOfBuses;
-(void)loseInterestInBuses:(NSSet*)setOfBuses;

-(void)registerInterestInRoutes:(NSSet*)routes;
-(void)loseInterestInRoutes:(NSSet*)routes;

-(void)forceRedrawOfAnnotation:(Annotation*)ann;
-(void)shiftAnnotationAttributeDueToChange:(NSDictionary*)change;

-(void)repositionBus:(Bus*)b;
-(void)changeRouteVisibility:(Route*)route;
-(void)handleAdditionToBusesList:(NSSet*)insertions;
-(void)handleAdditionToRoutesList:(NSSet*)insertions;

@end

#pragma mark Controller

@implementation MapViewController

@synthesize mapView = m_mapView;


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationItem.leftBarButtonItem.enabled = NO;
	self.navigationItem.leftBarButtonItem.target = self;
	
	self.navigationItem.rightBarButtonItem.enabled = YES;
	self.navigationItem.rightBarButtonItem.target = self;
	self.navigationItem.rightBarButtonItem.action = @selector(newFavorite:);		
	
	m_rightBusCalloutButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

	[self.mapView setRegion:[[NSUserDefaults standardUserDefaults] coordinateRegionForKey:MapViewCoordinateRegionKey] animated:TRUE];
	CLLocationCoordinate2D center = self.mapView.centerCoordinate;
	CLLocation* centerOfMap = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
	[[NSNotificationQueue defaultQueue]
	 enqueueNotification:[NSNotification notificationWithName:MapViewCoordinateRegionKey object:centerOfMap]
	 postingStyle:NSPostWhenIdle
	 coalesceMask:NSNotificationNoCoalescing
	 forModes:nil];
	
	[m_changeLocationButton setEnabled:(g_Model.currentLocation != nil)];
	if ( g_Model.followedBus )
	{
		self.mapView.centerCoordinate = g_Model.followedBus.coordinate;
	}	

	[g_Model addObserver:self forKeyPath:@"followedBus" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
	[g_Model addObserver:self forKeyPath:@"currentLocation" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
	[g_Model addObserver:self forKeyPath:@"routes" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
	
	[self registerInterestInRoutes:g_Model.routes];	
}

-(void)viewDidUnload
{
	[g_Model removeObserver:self forKeyPath:@"currentLocation"];
	[g_Model removeObserver:self forKeyPath:@"followedBus"];
	[g_Model removeObserver:self forKeyPath:@"routes"];
	
	[self loseInterestInRoutes:g_Model.routes];
	[super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)changeLocationButtonHandler:(id)sender
{
	[self.mapView setCenterCoordinate:g_Model.currentLocation.coordinate animated:YES];
}

-(void)registerInterestInBuses:(NSSet*)setOfBuses
{
	for (Bus* b in setOfBuses)
	{
		[b addObserver:self forKeyPath:@"position" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
		if ( b.route.visible )
		{
			[self.mapView addAnnotation:b];
		}
	}
}

-(void)loseInterestInBuses:(NSSet*)setOfBuses
{
	for (Bus* b in setOfBuses)
	{
		@try {
			[b removeObserver:self forKeyPath:@"position"];
			[self.mapView removeAnnotation:b];
		}
		@catch (NSException * e) {
			NSLog(@"Exception in MapViewController::loseInterestInBuses:, %@\n", e);
		}		
	}
}

-(void)registerInterestInRoutes:(NSSet*)routes
{
	for ( Route* route in routes )
	{
		[self registerInterestInBuses:route.buses];
		[route addObserver:self forKeyPath:@"visible" options:NSKeyValueObservingOptionNew context:NULL];
		[route addObserver:self forKeyPath:@"buses" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
	}
}

-(void)loseInterestInRoutes:(NSSet*)routes
{
	for ( Route* route in routes )
	{
		[route removeObserver:self forKeyPath:@"visible"];
		[route removeObserver:self forKeyPath:@"buses"];
		[self loseInterestInBuses:route.buses];
		[self.mapView removeAnnotations:[route.buses allObjects]];
	}
}

-(void)forceRedrawOfAnnotation:(Annotation*)ann
{
	if ( ann && ![ann isEqual:[NSNull null]] )
	{
		[self.mapView removeAnnotation:ann];
		[self.mapView addAnnotation:ann];
	}
}

-(void)shiftAnnotationAttributeDueToChange:(NSDictionary*)change
{
	NSNumber* kindOfChange = change[NSKeyValueChangeKindKey];
	if ( [kindOfChange intValue] == NSKeyValueChangeSetting )
	{
		id previousAnn = change[NSKeyValueChangeOldKey];
		id newAnn = change[NSKeyValueChangeNewKey];
		
		[self forceRedrawOfAnnotation:previousAnn];
		[self forceRedrawOfAnnotation:newAnn];
	}
}

-(void)repositionBus:(Bus*)b
{
	@try {
		if ( b.route.visible )
		{
			[self forceRedrawOfAnnotation:b];
			if ( [b isEqual:g_Model.followedBus] )
			{
				self.mapView.centerCoordinate = b.coordinate;
			}
		}
		
	}
	@catch (NSException * e) {
		NSLog(@"Exception in MapViewController::repositionBus: %@", e);
	}
}

-(void)changeRouteVisibility:(Route*)route
{
	NSArray* buses = [route.buses allObjects];
	if ( route.visible )
	{
		[self.mapView addAnnotations:buses];
	}
	else
	{
		[self.mapView removeAnnotations:buses];
	}
}

-(void)handleAdditionToBusesList:(NSSet*)insertions
{
	[self registerInterestInBuses:insertions];
}

-(void)handleAdditionToRoutesList:(NSSet*)insertions
{
	[self registerInterestInRoutes:insertions];
}

- (void)observeValueForKeyPath:(NSString*)keyPath
					  ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void *)context
{
	if ( [object isEqual:g_Model] )
	{
		if ( [keyPath isEqualToString:@"followedBus"] )
		{
			[self performSelectorOnMainThread:@selector(shiftAnnotationAttributeDueToChange:) withObject:change waitUntilDone:NO];
		}
		else if ( [keyPath isEqualToString:@"currentLocation"] )
		{
			[m_changeLocationButton setEnabled:(g_Model.currentLocation != nil)];
		}
		else if ( [keyPath isEqualToString:@"routes"] )
		{
			NSNumber* changeKindKeyNumber = change[NSKeyValueChangeKindKey];
			switch ( [changeKindKeyNumber intValue] ) {
					
				case NSKeyValueChangeInsertion:
					[self performSelectorOnMainThread:@selector(handleAdditionToRoutesList:) withObject:change[NSKeyValueChangeNewKey] waitUntilDone:NO];
					break;
					
				case NSKeyValueChangeRemoval:
					[self loseInterestInRoutes:change[NSKeyValueChangeOldKey]];
					break;
					
				default:
					break;
			}
		}
	}
	else if ( [object isKindOfClass:[Bus class]] )
	{
		id newValue = change[NSKeyValueChangeNewKey];
		
		if ( [keyPath isEqualToString:@"position"] && newValue && ![newValue isEqual:[NSNull null]] )
		{
			[self repositionBus:(Bus*)object];
		}
	}
	else if ( [object isKindOfClass:[Route class]] )
	{
		if ( [keyPath isEqualToString:@"visible"] )
		{
			[self performSelectorOnMainThread:@selector(changeRouteVisibility:) withObject:object waitUntilDone:NO];
		}
		else if ( [keyPath isEqualToString:@"buses"] )
		{
			NSNumber* changeKindKeyNumber = change[NSKeyValueChangeKindKey];
			switch ( [changeKindKeyNumber intValue] ) {
					
				case NSKeyValueChangeInsertion:
					[self performSelectorOnMainThread:@selector(handleAdditionToBusesList:) withObject:change[NSKeyValueChangeNewKey] waitUntilDone:NO];
					break;
					
				case NSKeyValueChangeRemoval:
					[self loseInterestInBuses:change[NSKeyValueChangeOldKey]];
					break;
					
				default:
					break;
			}
		}
	}
}

-(id<Model>)model
{
	return (id<Model>)[UIApplication sharedApplication].delegate;
}

#pragma mark -
#pragma mark MKMapViewDelegate/SLTMapViewDelegate methods

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
	NSLog(@"- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView");
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
	NSLog(@"- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView");
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
	NSLog(@"- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:%@", error);
}

	// Is this lightweight enough? If not, we'll just save this when we're notified of app-end
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimatedIfNotNil:(NSObject*)animated
{
	[[NSUserDefaults standardUserDefaults] setCoordinateRegion:self.mapView.region forKey:MapViewCoordinateRegionKey];
	CLLocationCoordinate2D center = self.mapView.centerCoordinate;
	CLLocation* centerOfMap = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
	[[NSNotificationQueue defaultQueue]
	 enqueueNotification:[NSNotification notificationWithName:MapViewCoordinateRegionKey object:centerOfMap]
	 postingStyle:NSPostASAP
	 coalesceMask:NSNotificationNoCoalescing
	 forModes:nil];
}

#pragma mark Bus Annotation Handlers

- (MKAnnotationView*)annotationViewForBus:(Bus*)bus inMapView:(MKMapView*)mapView
{
	BusAnnotationView* bav = (BusAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:[BusAnnotationView reuseIdentifierForAnnotation:bus]];
    if ( bav == nil )
		bav = [[BusAnnotationView alloc] initWithController:self bus:bus];
	
	return bav;
}

- (void)mapView:(MKMapView*)mapView annotationView:(MKAnnotationView*)view calloutAccessoryControlTapped:(UIControl*)control forBus:(Bus*)bus
{
	BusDetailViewController* busDetailViewController = [[BusDetailViewController alloc] initWithBus:bus];
	[self.navigationController pushViewController:busDetailViewController animated:YES];
}

- (NSNumber*)canShowCalloutForBus:(Bus*)bus
{
	return @YES;
}

- (UIView*)rightCalloutAccessoryViewForBus:(Bus*)bus 
{
	return m_rightBusCalloutButton;
}

@end
