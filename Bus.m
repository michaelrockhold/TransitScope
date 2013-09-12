// 
//  Bus.m
//  SeattleLiveTransit
//
//  Created by Michael Rockhold on 11/17/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import "Bus.h"

#import "Route.h"


char* compassHeadings[] = 
{
	"North",
	"NNE",
	"NE",
	"ENE",
	"East",
	"ESE",
	"SE",
	"SSE",
	"South",
	"SSW",
	"SW",
	"WSW",
	"West",
	"WNW",
	"NW",
	"NNW",
	"North"
};

@interface Bus (PrivateMethods)

- (const char*)compassHeading;

@end


@implementation Bus 

@synthesize ID = m_ID, speed = m_speed, heading = m_heading, timestamp = m_timestamp;

-(id)initWithVehicleID:(NSString*)vehicleID
			   route:(Route*)route
			location:(CLLocation*)location
			 heading:(float)heading
		   timestamp:(NSDate*)timestamp
{
	if ( self = [super initWithLocation:location] )
	{
		self.ID = vehicleID;
		self.heading= heading;
		self.timestamp = timestamp;
		self.speed = 0;
		self.route = route;
	}
	return self;
}

-(void)dealloc
{
	self.route = nil;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
	m_ID  = [coder decodeObjectForKey:@"VehicleID"];
	m_speed = [coder decodeDoubleForKey:@"Speed"];
	m_heading = [coder decodeFloatForKey:@"Heading"];
	m_timestamp = [coder decodeObjectForKey:@"Timestamp"];
	m_route = nil;
    return self;
}


- (void)encodeWithCoder:(NSCoder*)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:m_ID forKey:@"VehicleID"];
    [coder encodeDouble:m_speed forKey:@"Speed"];
    [coder encodeFloat:m_heading forKey:@"Heading"];
    [coder encodeObject:m_timestamp forKey:@"Timestamp"];
}

-(NSString*)title
{
	NSString* t = @"--";
	@try {
		Route* r = self.route;
		NSString* n = r.ID;
		t = [NSString stringWithFormat:@"Route %@", n];
	}
	@catch (NSException * e) {
		NSLog(@"Exception in Bus.title: %@", e);
	}
	return t;
}

-(NSString*)subtitle
{
	NSString* st = nil;
	double speed = self.speed;
	if ( isnan(speed) || speed < 0.001 )
	{
		st = [NSString stringWithFormat:@"#%@, heading %s", self.ID, [self compassHeading]];
	}
	else
	{
		speed = speed * 60 * 60 / 1000;
		st = [NSString stringWithFormat:@"#%@, %s at %3.1lf km/hr", self.ID, [self compassHeading], speed];
	}
	return st;
}

- (const char*)compassHeading
{
	float h = self.heading;
	if (h >= 360 || h < 0) h = 0;
	return compassHeadings[(int)(trunc((h+11.25)/22.5))];
}

-(Route*)route
{
	return m_route;
}

-(void)setRoute:(Route*)route
{
	[self willChangeValueForKey:@"route"];
	
	if ( m_route && ![m_route isEqual:route] )
	{
		[m_route removeBus:self];
		m_route = nil;
	}
	
	if ( route )
	{
		m_route = route;
		[route addBus:self];
	}
	
	[self didChangeValueForKey:@"route"];
}

@end
