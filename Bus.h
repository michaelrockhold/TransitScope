//
//  Bus.h
//  SeattleLiveTransit
//
//  Created by Michael Rockhold on 11/17/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Annotation.h"

@class Route;

@interface Bus :  Annotation < NSCoding >
{
	NSString* m_ID;
	double m_speed;
	float m_heading;
	NSDate* m_timestamp;
	Route* m_route;
}

-(id)initWithVehicleID:(NSString*)ID
			  route:(Route*)route
		   location:(CLLocation*)location
			heading:(float)heading
		  timestamp:(NSDate*)timestamp;

@property (nonatomic, retain) NSString*		ID;
@property (nonatomic) double				speed;
@property (nonatomic) float					heading;
@property (nonatomic, retain) NSDate*		timestamp;
@property (nonatomic, retain) Route*		route;

@end


