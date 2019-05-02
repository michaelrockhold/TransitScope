//
//  SLTMapView.m
//  SeattleLiveTransit
//
//  Created by Michael Rockhold on 10/14/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import "SLTMapView.h"
#import "Annotation.h"
#import "SLTAnnotationView.h"

extern const char * class_getName(Class cls);

@implementation SLTMapView
@synthesize realDelegate = m_realDelegate;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
	{
		self.delegate = self;
		m_mapViewRegionDidChangeAnimatedSelector = NSSelectorFromString( @"mapView:regionDidChangeAnimatedIfNotNil:" );
    }
    return self;
}


- (void)dealloc
{
	[m_realDelegate release];
    [super dealloc];
}

-(void)awakeFromNib
{
	self.delegate = self;
	m_mapViewRegionDidChangeAnimatedSelector = NSSelectorFromString( @"mapView:regionDidChangeAnimatedIfNotNil:" );
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)ann
{
	const char* derivedClassName = class_getName([ann class]);
	SEL annotationViewForWhateverInMapViewSelector = NSSelectorFromString( [NSString stringWithFormat:@"annotationViewFor%s:inMapView:", derivedClassName] );
	return ( annotationViewForWhateverInMapViewSelector && [self.realDelegate respondsToSelector:annotationViewForWhateverInMapViewSelector] )
	? [self.realDelegate performSelector:annotationViewForWhateverInMapViewSelector withObject:ann withObject:mapView]
	: nil;
}

- (void)mapView:(MKMapView*)mapView annotationView:(MKAnnotationView*)view calloutAccessoryControlTapped:(UIControl*)control
{
		// - (void)mapView:(MKMapView*)mapView annotationView:(MKAnnotationView*)view calloutAccessoryControlTapped:(UIControl*)control forBus:(Bus*)bus
	
	const char* derivedClassName = class_getName([view.annotation class]);
	SEL selector = NSSelectorFromString( [NSString stringWithFormat:@"mapView:annotationView:calloutAccessoryControlTapped:for%s:", derivedClassName] );
	NSMethodSignature* sig = [self.realDelegate methodSignatureForSelector:selector];
	if ( sig )
	{
		NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
		[invocation setTarget:self.realDelegate];
		[invocation setSelector:selector];
		[invocation setArgument:&mapView atIndex:2];
		[invocation setArgument:&view atIndex:3];
		[invocation setArgument:&control atIndex:4];
		id ann = view.annotation;
		[invocation setArgument:&ann atIndex:5];
		
		[invocation invoke];
	}
	
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	if ( m_mapViewRegionDidChangeAnimatedSelector && [self.realDelegate respondsToSelector:m_mapViewRegionDidChangeAnimatedSelector] )
		[self.realDelegate performSelector:m_mapViewRegionDidChangeAnimatedSelector withObject:mapView withObject:(animated?self:nil)];
}

	// unimplemented MapViewDelegate methods that we don't seem to need anywhere in SLT

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
}

	// mapView:didAddAnnotationViews: is called after the annotation views have been added and positioned in the map.
	// The delegate can implement this method to animate the adding of the annotations views.
	// Use the current positions of the annotation views as the destinations of the animation.
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
}

@end
