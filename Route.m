// 
//  Route.m
//  SeattleLiveTransit
//
//  Created by Michael Rockhold on 10/6/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import "Route.h"
#import "Bus.h"
#import "Model.h"

extern NSObject<Model>* g_Model;

@implementation Route 
@synthesize ID = m_ID, known = m_known, visible = m_fShowOnMap, score = m_score, lastQueryTimestamp = m_lastQueryTimestamp, buses = m_buses;

-(id)initWithRouteID:(NSString*)routeID
			   known:(BOOL)fKnown
		     visible:(BOOL)fVisible
		 lastQueried:(NSDate*)lastQueried
{
	if ( self = [self init] )
	{
		m_ID = routeID;
		m_known = fKnown;
		m_fShowOnMap = fVisible;
		m_lastQueryTimestamp = lastQueried;
		m_buses = [NSMutableSet setWithCapacity:1];
	}
	return self;
}

-(id)initWithRouteID:(NSString*)routeID
			   known:(BOOL)fKnown
		     visible:(BOOL)fVisible
{
	return [self initWithRouteID:routeID known:fKnown visible:fVisible lastQueried:nil];
}

-(id)initWithRouteID:(NSString*)routeID
{
	return [self initWithRouteID:routeID known:NO visible:NO lastQueried:nil];
}


- (id)initWithCoder:(NSCoder *)coder
{
	return [self initWithRouteID:[coder decodeObjectForKey:@"RouteID"]
						   known:[coder decodeBoolForKey:@"Known"]
						 visible:[coder decodeBoolForKey:@"ShowOnMap"]
					 lastQueried:[coder decodeObjectForKey:@"LastQueryTimestamp"]
			];
}


- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:m_ID forKey:@"RouteID"];
	[coder encodeBool:m_known forKey:@"Known"];
    [coder encodeBool:m_fShowOnMap forKey:@"ShowOnMap"];
	[coder encodeObject:m_lastQueryTimestamp forKey:@"LastQueryTimestamp"];
}

-(BOOL)isEqual:(id)object
{
	return [object isKindOfClass:[Route class]] && [self.ID isEqual:((Route*)object).ID];
}

- (void)addBus:(Bus*)value
{
	if ( [m_buses containsObject:value] )
		return;
	
	NSSet* newAddition = [NSSet setWithObject:value];
	[self willChangeValueForKey:@"buses" 
				withSetMutation:NSKeyValueUnionSetMutation
				   usingObjects:newAddition];

	[m_buses addObject:value];
	value.route = self;
	
	[self didChangeValueForKey:@"buses" 
				withSetMutation:NSKeyValueUnionSetMutation
				   usingObjects:newAddition];
}

- (void)removeBus:(Bus*)value
{
	if ( ![m_buses containsObject:value] )
		return;
	
	NSSet* newAddition = [NSSet setWithObject:value];
	[self willChangeValueForKey:@"buses" 
				withSetMutation:NSKeyValueMinusSetMutation
				   usingObjects:newAddition];

	[m_buses removeObject:value];
	value.route = nil;
	
	[self didChangeValueForKey:@"buses" 
			   withSetMutation:NSKeyValueMinusSetMutation
				  usingObjects:newAddition];
}

#pragma mark -
#pragma mark Scoring

-(void)recalculateScore
{
	m_score = 0;
	
	if ( self.known )
		m_score += 1;
	
	if ( self.visible )
		m_score += 1;
	
	NSSet* buses = [self.buses copyWithZone:nil];
	for (Bus* b in buses)
	{
		if ( b.visibleInMainMap )
			m_score += 1;
		
		if ( b.closeToCurrentLocation )
			m_score += 1;
	}

	if ( self.lastQueryTimestamp == nil )
	{
			// if this route has never been queried at all yet, make sure it is soon
		m_score += 9999999;
	}
	else
	{
		NSTimeInterval secondsSince = -[self.lastQueryTimestamp timeIntervalSinceNow];
		if ( secondsSince > 0 )
		{
			m_score += (secondsSince * 1000);
		}
	}
}

-(NSComparisonResult)compareByScore:(Route*)other 
{
	return self.score == other.score 
		? NSOrderedSame
		: self.score > other.score 
			? NSOrderedDescending 
			: NSOrderedAscending;
}

@end
