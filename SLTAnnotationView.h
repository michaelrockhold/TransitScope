//
//  SLTAnnotationView.h
//  Seattle Live Transit
//
//  Created by Michael Rockhold on 7/2/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//
#import <MapKit/MKMapView.h>
#import <MapKit/MKAnnotationView.h>

@protocol Model;

@interface SLTAnnotationView : MKAnnotationView
{
	NSObject* m_controller;
}

+(NSString*)reuseIdentifierForAnnotation:(id <MKAnnotation>)ann;

-(id)initWithController:(NSObject*)controller annotation:(id <MKAnnotation>)ann;

@property (nonatomic, strong) NSObject* controller;
@end
