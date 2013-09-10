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
	
	[rgnDict setObject:[NSNumber numberWithDouble:cr.center.latitude] forKey:@"latitude"];
	[rgnDict setObject:[NSNumber numberWithDouble:cr.center.longitude] forKey:@"longitude"];
	[rgnDict setObject:[NSNumber numberWithDouble:cr.span.latitudeDelta] forKey:@"latitudeDelta"];
	[rgnDict setObject:[NSNumber numberWithDouble:cr.span.longitudeDelta] forKey:@"longitudeDelta"];

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
		center.latitude = [[rgnDict objectForKey:@"latitude"] doubleValue];
		center.longitude = [[rgnDict objectForKey:@"longitude"] doubleValue];
		
		rgn = MKCoordinateRegionMake(center, MKCoordinateSpanMake([[rgnDict objectForKey:@"latitudeDelta"] doubleValue], [[rgnDict objectForKey:@"longitudeDelta"] doubleValue]));
	}
    return rgn;
}

@end