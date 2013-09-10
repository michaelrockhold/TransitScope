//
//  SLTAnnotationView.m
//  Seattle Live Transit
//
//  Created by Michael Rockhold on 7/2/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SLTAnnotationView.h"
#import "Model.h"

extern const char * class_getName(Class cls);

@implementation SLTAnnotationView

@synthesize controller = m_controller;

- (id)initWithController:(NSObject*)controller annotation:(id <MKAnnotation>)ann
{
	if ( self = [self initWithAnnotation:ann reuseIdentifier:[SLTAnnotationView reuseIdentifierForAnnotation:ann]] )
	{
		m_controller = [controller retain];
		self.opaque = NO;
		self.enabled = YES;
		self.userInteractionEnabled = YES;
	}
	return self;
}

- (void)dealloc
{
	[m_controller release];
	[super dealloc];
}

+ (NSString*)reuseIdentifierForAnnotation:(id<MKAnnotation>)ann
{
	return @"SLT_RID:Annotation";
}

/* - (void)calloutAccessoryControlTapped:(UIControl*)control forMapView:(MKMapView*)mapView
{
}
 */
- (BOOL)canShowCallout
{
	const char* derivedClassName = class_getName([self.annotation class]);
	SEL canShowCalloutForSelector = NSSelectorFromString( [NSString stringWithFormat:@"canShowCalloutFor%s:", derivedClassName] );
	return ( canShowCalloutForSelector && [m_controller respondsToSelector:canShowCalloutForSelector] )
	? [[m_controller performSelector:canShowCalloutForSelector withObject:self.annotation] boolValue]
	: NO;
}

- (UIView*)leftCalloutAccessoryView
{
	const char* derivedClassName = class_getName([self.annotation class]);
	SEL leftCalloutAccessoryViewForSelector = NSSelectorFromString( [NSString stringWithFormat:@"leftCalloutAccessoryViewFor%s:", derivedClassName] );
	return ( leftCalloutAccessoryViewForSelector && [m_controller respondsToSelector:leftCalloutAccessoryViewForSelector] )
	? [m_controller performSelector:leftCalloutAccessoryViewForSelector withObject:self.annotation]
	: nil;
}

- (UIView*)rightCalloutAccessoryView
{
	const char* derivedClassName = class_getName([self.annotation class]);
	SEL rightCalloutAccessoryViewForSelector = NSSelectorFromString( [NSString stringWithFormat:@"rightCalloutAccessoryViewFor%s:", derivedClassName] );
	return ( rightCalloutAccessoryViewForSelector && [m_controller respondsToSelector:rightCalloutAccessoryViewForSelector] )
	? [m_controller performSelector:rightCalloutAccessoryViewForSelector withObject:self.annotation]
	: nil;
}

@end
