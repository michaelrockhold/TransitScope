//
//  Route.h
//  SeattleLiveTransit
//
//  Created by Michael Rockhold on 10/6/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Bus;

@interface Route :  NSObject < NSCoding >
{
	NSString* m_ID;
	BOOL m_fShowOnMap;
	BOOL m_known;
	NSDate* m_lastQueryTimestamp;
	NSUInteger m_score;
	NSMutableSet* m_buses;
}

@property (nonatomic, retain, readonly) NSString* ID;
@property (nonatomic)					BOOL known;
@property (nonatomic)					BOOL visible;
@property (nonatomic, retain)			NSDate* lastQueryTimestamp;
@property (nonatomic, readonly)			NSUInteger score;
@property (nonatomic, retain, readonly) NSSet* buses;

-(id)initWithRouteID:(NSString*)routeID;

-(id)initWithRouteID:(NSString*)routeID
			   known:(BOOL)fKnown
		     visible:(BOOL)fVisible
		 lastQueried:(NSDate*)lastQueried;

-(id)initWithRouteID:(NSString*)routeID
			   known:(BOOL)fKnown
		     visible:(BOOL)fVisible;

- (void)addBus:(Bus*)value;
- (void)removeBus:(Bus*)value;

-(void)recalculateScore;
-(NSComparisonResult)compareByScore:(Route*)other;

@end
