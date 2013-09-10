//
//  NSUserDefaults+MKCoordinateRegion.h
//  Live Traffic: Seattle
//
//  Created by Michael Rockhold on 7/30/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import <Foundation/NSUserDefaults.h>
#import <MapKit/MKGeometry.h>

@interface NSUserDefaults(MKCoordinateRegion)

- (void)setCoordinateRegion:(MKCoordinateRegion)cr forKey:(NSString*)k;

- (MKCoordinateRegion)coordinateRegionForKey:(NSString*)k;

@end
