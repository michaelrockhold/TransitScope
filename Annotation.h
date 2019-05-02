//
//  Annotation.h
//  SeattleLiveTransit
//
//  Created by Michael Rockhold on 11/17/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MapKit/MKAnnotation.h>

@class CLLocation;

@interface Annotation :  NSObject  < MKAnnotation, NSCoding >
{
	CLLocation* m_position;
}

-(id)initWithLocation:(CLLocation*)location;

@property (nonatomic, retain)			CLLocation* position;
@property (nonatomic, retain, readonly) NSString* title;
@property (nonatomic, retain, readonly) NSString* subtitle;
@property (nonatomic, readonly)			BOOL visibleInMainMap;
@property (nonatomic, readonly)			BOOL closeToCurrentLocation;

@end


