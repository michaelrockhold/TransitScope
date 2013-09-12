// 
//  Annotation.m
//  SeattleLiveTransit
//
//  Created by Michael Rockhold on 11/17/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import "Annotation.h"
#import "Model.h"

extern NSObject<Model>* g_Model;

@implementation Annotation 
@synthesize position = m_position;

-(id)initWithLocation:(CLLocation*)location
{
	if ( self = [self init] )
	{
		self.position = location;
	}
	return self;
}


- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
	self.position  = [coder decodeObjectForKey:@"Position"];
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:self.position forKey:@"Position"];
}

-(CLLocationCoordinate2D)coordinate
{
	return self.position.coordinate;
}

-(BOOL)visibleInMainMap
{	
	return [g_Model isVisibleInMainMap:self];
}

-(BOOL)closeToCurrentLocation
{
	return [g_Model isCloseToCurrentLocation:self];
}

-(NSString*)title
{
	return @"";
}

-(NSString*)subtitle
{
	return @"";
}

@end
