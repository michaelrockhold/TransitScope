//
//  NSUserDefaults+MKCoordinateRegion.m
//  Seattle Live Transit
//
//  Created by Michael Rockhold on 7/30/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import "NSUserDefaults+MKCoordinateRegion.h"


@implementation NSUserDefaults(MKCoordinateRegion)

- (void)setCoordinateRegion:(MKCoordinateRegion)cr forKey:(NSString*)k
{	
	NSMutableDictionary* rgnDict = [NSMutableDictionary dictionary];
	
	rgnDict[@"latitude"] = @(cr.center.latitude);
	rgnDict[@"longitude"] = @(cr.center.longitude);
	rgnDict[@"latitudeDelta"] = @(cr.span.latitudeDelta);
	rgnDict[@"longitudeDelta"] = @(cr.span.longitudeDelta);

    [self setObject:rgnDict forKey:k];
}

- (MKCoordinateRegion)coordinateRegionForKey:(NSString*)k
{
	// create hard-coded fallback default
	CLLocationCoordinate2D center;
	center.latitude = 47.606056;
	center.longitude = -122.332695;
	MKCoordinateRegion rgn = MKCoordinateRegionMakeWithDistance(center, 300.0, 300.0);

	NSDictionary* rgnDict = [self dictionaryForKey:k];
	
	if ( rgnDict != nil )
	{
		center.latitude = [rgnDict[@"latitude"] doubleValue];
		center.longitude = [rgnDict[@"longitude"] doubleValue];
		
		rgn = MKCoordinateRegionMake(center, MKCoordinateSpanMake([rgnDict[@"latitudeDelta"] doubleValue], [rgnDict[@"longitudeDelta"] doubleValue]));
	}
    return rgn;
}

@end