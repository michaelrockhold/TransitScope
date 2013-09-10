//
//  LiveTransit_SeattleAppDelegate.m
//  LiveTransit_Seattle
//
//  Created by Michael Rockhold on 7/9/09.
//  Copyright The Rockhold Company 2009. All rights reserved.
//

#import "SeattleLiveTransitAppDelegate.h"
#import <MapKit/MKPlacemark.h>

#import "Bus.h"
#import "Route.h"

#import "MapViewController.h"
#import "BusInfoCollector.h"
#import "Utils.h"

NSObject<Model>* g_Model = nil;

BOOL s_dieAlready = NO;

@interface SeattleLiveTransitAppDelegate (PrivateMethods)

-(void)cleanUpStaleBuses:(id)dummy;
-(void)centerOfMapChanged:(NSNotification*)notification;
-(NSString*)pathToSavedData;
-(void)followBusByID:(NSString*)busID;

-(void)busDownloaderThread:(id)dummy;

-(void)addRoute:(int)routeIDNum;

@end

NSInteger routeSorter(id r1, id r2, void* context)
{
		// NSOrderedAscending if the first element is smaller than the second, 
		// NSOrderedDescending if the first element is larger than the second, 
		// and NSOrderedSame otherwise
	return NSOrderedSame;
}

@interface NSNull (RouteMethods)

-(void)recalculateScore;

-(NSComparisonResult)compareByScore:(id)other;

@property (nonatomic, readonly)			NSUInteger score;

@end

@implementation NSNull (RouteMethods)

-(void)recalculateScore { }

-(NSComparisonResult)compareByScore:(id)other 
{
	return NSOrderedDescending;
}

-(NSUInteger)score
{
	return 0;
}

@end


@implementation SeattleLiveTransitAppDelegate

@synthesize window = m_window;
@synthesize mapViewController = m_mapViewController, rootTabBarController = m_rootTabBarController;
@synthesize currentLocation = m_currentLocation, centerOfMap = m_centerOfMap, followedBus = m_followedBus;
@synthesize buses = m_buses, allPossibleRoutes = m_allPossibleRoutes;

- (id)init
{
	if ( self = [super init] )
	{
		m_outOfService = nil;
		m_mapViewController = nil;
		m_locationManager = [[CLLocationManager alloc] init];
		m_locationManager.delegate = self; // Tells the location manager to send updates to this object
		
		m_currentLocation = nil;
		m_centerOfMap = nil;
		m_followedBus = nil;
				
		m_buses = [[NSMutableSet setWithCapacity:300] retain];
		
		m_knownRoutePredicate = [[NSPredicate predicateWithFormat:@"known == TRUE"] retain];
		
		m_allPossibleRoutes = [[NSMutableDictionary dictionaryWithCapacity:300] retain];
		for (int r = 1; r < 600; r++)
			[self addRoute:r];
		for (int r = 900; r < 1000; r++)
			[self addRoute:r];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(centerOfMapChanged:)
													 name:MapViewCoordinateRegionKey object:nil];
		
		g_Model = self;
	}
	return self;
}

- (void)dealloc
{
    [m_rootTabBarController release];
    [m_window release];
	[m_mapViewController release];
	[m_locationManager release];

	[m_outOfService release];
	[m_currentLocation release];
	[m_centerOfMap release];
	[m_followedBus release];
	
	[m_buses release];
	[m_allPossibleRoutes release];
	[m_knownRoutePredicate release];
	
	[super dealloc];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self restore];
	
	[self cleanUpStaleBuses:nil];

    // Add the tab bar controller's current view as a subview of the window
    [m_window addSubview:m_rootTabBarController.view];
	[m_window makeKeyAndVisible];
	
	if ( !m_locationManager.locationServicesEnabled )
    {
			//[self addTextToLog:NSLocalizedString(@"NoLocationServices", @"User disabled location services")];
    }
    else
    {
		[m_locationManager startUpdatingLocation];
    }
		
	[NSThread detachNewThreadSelector:@selector(busDownloaderThread:) toTarget:self withObject:nil];
	
	return YES;
}

- (void)applicationWillTerminate:(UIApplication*)application
{
	s_dieAlready = YES;
	[self save];
}

-(void)addRoute:(int)routeIDNum
{
	NSString* routeID = [NSString stringWithFormat:@"%d", routeIDNum];
	Route* route = [[Route alloc] initWithRouteID:routeID];
	[m_allPossibleRoutes setObject:route forKey:routeID];
	[route release];
}

-(void)busDownloaderThread:(id)dummy
{
	NSAutoreleasePool* localPool = [[NSAutoreleasePool alloc] init];	
	BusInfoCollector* busInfoCollector = [[BusInfoCollector alloc] initWithCollectionOwner:self routeIDs:nil];
	int i = 0;
	
	while ( !s_dieAlready )
	{
		NSAutoreleasePool* innerPool = [[NSAutoreleasePool alloc] init];
		NSMutableArray* routes = [[[m_allPossibleRoutes allValues] mutableCopy] autorelease];
		[routes makeObjectsPerformSelector:@selector(recalculateScore)];
		[routes sortUsingSelector:@selector(compareByScore:)];
		
		if ( routes && routes.count )
		{			
			Route* r = [routes objectAtIndex:routes.count-1];
			
			[busInfoCollector queueRoute:[NSNumber numberWithInt:[r.ID intValue]]];
			r.lastQueryTimestamp = [NSDate date];
		}
		i++;
		if ( i == 16 )
		{
			[self performSelectorOnMainThread:@selector(cleanUpStaleBuses:) withObject:nil waitUntilDone:NO];
			i = 0;
		}
		[innerPool release];
	}
	[busInfoCollector release];
	[localPool release];
}

-(void)followBusByID:(NSString*)busID
{
	NSSet* matchingBuses = [m_buses filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"ID == %@", busID]];
	if ( !matchingBuses )
		return;
	
	if ( matchingBuses.count > 0 )
	{
		if ( matchingBuses.count > 1 )
			NSLog(@"WARNING in updateBusInfo: more than one bus with ID == %@\n", busID);
		self.followedBus = [matchingBuses anyObject];
	}
}

-(void)centerOfMapChanged:(NSNotification*)notification
{
	self.centerOfMap = [notification object];
}

-(BOOL)hideNewRoutesByDefault
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"SLT_ShowNewRoutesByDefaultKey"];
}

-(void)setHideNewRoutesByDefault:(BOOL)hideByDefault
{
	[[NSUserDefaults standardUserDefaults] setBool:hideByDefault forKey:@"SLT_ShowNewRoutesByDefaultKey"];
}

#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString*)applicationSupportDirectory
{	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(NSString*)pathToSavedData
{
	return [[self applicationSupportDirectory] stringByAppendingPathComponent:@"saved.dat"];
}

-(void)save
{
	NSMutableData* data = [NSMutableData data];
	NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:m_centerOfMap forKey:@"CenterOfMap"];
	if ( m_followedBus )
		[archiver encodeObject:m_followedBus forKey:@"FollowedBus"];
	[archiver encodeObject:m_allPossibleRoutes forKey:@"AllPossibleRoutes"];
	[archiver finishEncoding];
	[data writeToFile:[self pathToSavedData] atomically:YES];
	[archiver release];
}

-(void)restore
{
	NSData* saved = [NSData dataWithContentsOfFile:[self pathToSavedData]];
	if ( saved )
	{
		NSLog(@"previously saved data");
		NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:saved];
		CLLocation* centerOfMap = [unarchiver decodeObjectForKey:@"CenterOfMap"];
		Bus* followedBus = [unarchiver decodeObjectForKey:@"FollowedBus"];
		NSDictionary* oldRoutes = [unarchiver decodeObjectForKey:@"AllPossibleRoutes"];
		[unarchiver release];
		
		if ( centerOfMap )
		{
			self.centerOfMap = centerOfMap;
		}
		
		if ( followedBus )
		{
			NSSet* matchingBuses = [m_buses filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"ID == %@", followedBus.ID]];
			if ( !matchingBuses )
				return;
			
			if ( matchingBuses.count > 0 )
			{
				if ( matchingBuses.count > 1 )
					NSLog(@"WARNING in updateBusInfo: more than one bus with ID == %@\n", followedBus.ID);
				self.followedBus = [matchingBuses anyObject];
			}
			else 
			{
				[m_buses addObject:followedBus];
				self.followedBus = followedBus;
			}
		}
		
		if ( oldRoutes && oldRoutes.count )
		{
			[m_allPossibleRoutes release];
			m_allPossibleRoutes = [oldRoutes retain];
		}		
	}
	else
	{
		NSLog(@"no previously saved data");
	}
}

-(void)cleanUpStaleBuses:(id)dummy
{
	NSDate* deadline = [NSDate dateWithTimeIntervalSinceNow:-(10 * 60)];
	NSPredicate* predicate = [NSPredicate predicateWithFormat:@"timestamp < %@", deadline];

	for ( Bus* b in [m_buses filteredSetUsingPredicate:predicate] ) 
	{
		[b.route removeBus:b];
		b.route = self.outOfService;
		[self.outOfService addBus:b];
	}	
}


-(void)getCountsOfBuses:(NSUInteger*)pBusCount routes:(NSUInteger*)pRouteCount
{
	*pBusCount = m_buses.count;
	*pRouteCount = self.routes.count;
}



-(Route*)outOfService
{
	if ( m_outOfService == nil )
	{
		m_outOfService = [[Route alloc] initWithRouteID:@"OOFS"];
		if ( !m_outOfService )
		{
			NSLog(@"ERROR creating new route OOFS in updateBusInfo\n");
		}
		m_outOfService.visible = NO;
	}
	return m_outOfService;
}

#pragma mark Routes

-(NSSet*)routes
{
	return [NSSet setWithArray:[[m_allPossibleRoutes allValues] filteredArrayUsingPredicate:m_knownRoutePredicate]];
}

-(void)revealAllRoutes
{
	self.hideNewRoutesByDefault = NO;
	
	for (Route* r in [m_allPossibleRoutes allValues])
	{
		r.visible = YES;
	}
}

-(void)hideAllRoutes
{
	self.hideNewRoutesByDefault = YES;
	
	for (Route* r in [m_allPossibleRoutes allValues])
	{
		r.visible = NO;
	}
}

#pragma mark -
#pragma mark Following

- (void)switchToMapViewForAnnotation:(Annotation*)ann
{
	self.followedBus = nil;
	m_rootTabBarController.selectedIndex = 0;
	[m_mapViewController.mapView setCenterCoordinate:ann.coordinate animated:YES];
	[m_mapViewController.mapView selectAnnotation:ann animated:YES];
}

-(BOOL)isVisibleInMainMap:(Annotation*)ann
{
	return CoordinateWithinRegion(ann.coordinate, m_mapViewController.mapView.region);
}

- (BOOL)isCloseToCurrentLocation:(Annotation*)ann
{
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, 1000, 1000);
	return CoordinateWithinRegion(ann.coordinate, region);
}

#pragma mark Methods relating to collecting bus location information

- (void)busInfoCollectorStartingCollectionPass:(BusInfoCollector*)collector
{
}

- (void)busInfoCollectorEndCollectionPass:(BusInfoCollector*)collector
{
	[self cleanUpStaleBuses:nil];
}

- (void)busInfoCollector:(BusInfoCollector*)collector 
		   updateBusInfo:(NSString*)vehicleID
				   route:(NSString*)routeID
				latitude:(double)latitude
			   longitude:(double)longitude
				 heading:(float)heading
			   timestamp:(NSDate*)timestamp
{
	NSTimeInterval interval = [timestamp timeIntervalSinceNow];
	if ( interval < 0 )
	{
			//NSLog(@"   timestamp is %lf seconds in the past\n", -interval);
	}
	else 
	{
		NSLog(@"   INFO: timestamp is %lf seconds in the future\n", interval);
	}
		
	Route* route = [m_allPossibleRoutes objectForKey:routeID];
	if ( route == nil )
	{
		NSLog(@"ERROR: update for non-existent route object with ID = %@", routeID);
		return;
	}
	
	if ( !route.known )
	{
		NSSet* newbie = [NSSet setWithObject:route];
		[self willChangeValueForKey:@"routes" withSetMutation:NSKeyValueUnionSetMutation usingObjects:newbie];
		route.known = YES;
		[self didChangeValueForKey:@"routes" withSetMutation:NSKeyValueUnionSetMutation usingObjects:newbie];
		route.visible = !self.hideNewRoutesByDefault;
	}
	
	CLLocation* location = [[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] autorelease];
	Bus* bus = nil;
	NSSet* matchingBuses = [m_buses filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"ID == %@", vehicleID]];
	if ( matchingBuses.count > 0 )
	{
		if ( matchingBuses.count > 1 )
			NSLog(@"WARNING in updateBusInfo: more than one bus with ID == %@\n", vehicleID);
		bus = [matchingBuses anyObject];
		CLLocationDistance distanceTraveled = [bus.position getDistanceFrom:location];
		NSTimeInterval timePassed = [timestamp timeIntervalSinceDate:bus.timestamp];
		double speed = distanceTraveled/timePassed;
		if ( isnan(speed) ) speed = 0;		

		bus.speed = speed;
		bus.heading = heading;
		bus.timestamp = timestamp;
		bus.position = location;
		bus.route = route;
	}
	else 
	{
			//NSLog(@"updateBusInfo creating new bus object for ID = %@ at %@\n", vehicleID, location);
		bus = [[[Bus alloc] initWithVehicleID:vehicleID
										 route:route
									  location:location
									   heading:heading
									 timestamp:timestamp] autorelease];
		if ( !bus )
		{
			NSLog(@"ERROR creating new bus %@ in updateBusInfo\n", vehicleID);
			return;
		}
		[[self mutableSetValueForKey:@"buses"] addObject:bus];
	}
}


	// Called when the location is updated
- (void)locationManager:(CLLocationManager*)manager
	didUpdateToLocation:(CLLocation*)newLocation
		   fromLocation:(CLLocation*)oldLocation
{
	self.currentLocation = newLocation;
}

	// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager*)manager
	   didFailWithError:(NSError*)error
{
	NSMutableString* errorString = [[[NSMutableString alloc] init] autorelease];
    
	if ([error domain] == kCLErrorDomain)
    {
			// We handle CoreLocation-related errors here
        
		switch ([error code])
        {
					// This error code is usually returned whenever user taps "Don't Allow" in response to
					// being told your app wants to access the current location. Once this happens, you cannot
					// attempt to get the location again until the app has quit and relaunched.
					//
					// "Don't Allow" on two successive app launches is the same as saying "never allow". The user
					// can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
					//
			case kCLErrorDenied:
				[errorString appendFormat:@"%@\n", NSLocalizedString(@"LocationDenied", nil)];
				break;
                
					// This error code is usually returned whenever the device has no data or WiFi connectivity,
					// or when the location cannot be determined for some other reason.
					//
					// CoreLocation will keep trying, so you can keep waiting, or prompt the user.
					//
			case kCLErrorLocationUnknown:
				[errorString appendFormat:@"%@\n", NSLocalizedString(@"LocationUnknown", nil)];
				break;
                
					// We shouldn't ever get an unknown error code, but just in case...
					//
			default:
				[errorString appendFormat:@"%@ %d\n", NSLocalizedString(@"GenericLocationError", nil), [error code]];
				break;
		}
	}
    else
    {
			// We handle all non-CoreLocation errors here
			// (we depend on localizedDescription for localization)
		[errorString appendFormat:@"Error domain: \"%@\"  Error code: %d\n", [error domain], [error code]];
		[errorString appendFormat:@"Description: \"%@\"\n", [error localizedDescription]];
	}
    
		// Display the update
	NSLog(@"CLLocationManager error: %@\n", errorString);
}
					
@end

