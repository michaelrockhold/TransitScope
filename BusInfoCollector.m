
#import "BusInfoCollector.h"
#import "BusInfoCollectionOwner.h"
#import <SoapFunction.h>

SoapFunction* s_currentBusesOnRouteFn = nil;

@interface BusInfoCollector (PrivateMethods)

-(void)handleBusInfo:(id)di;

@end

@implementation BusInfoCollector

+ (void)initialize
{
	if ( self == [BusInfoCollector class] )
	{
		s_currentBusesOnRouteFn = [[SoapFunction alloc] initWithUrl:@"http://ws.its.washington.edu:9090/transit/avl/services/AvlService"
															 Method:@"getLatestByRoute"
														  Namespace:@"http://avl.transit.ws.its.washington.edu"
														 SoapAction:@"getLatestByRoute"
														 ParamOrder:[NSArray arrayWithObjects:@"in0", @"in1", nil]									
													  ResponseQuery:@"//multiRef"
													 ResponsePrefix:nil
												  ResponseNamespace:nil];
	}
}

- (id)initWithCollectionOwner:(NSObject<BusInfoCollectionOwner>*)owner routeIDs:(NSSet*)routeIDs
{
	if ( self = [self init] )
	{
		m_collectionOwner = [owner retain];
		m_routeIDs = [routeIDs retain];
	}
	return self;
}

- (void)dealloc
{
	[m_routeIDs release];
	[m_collectionOwner release];
	[super dealloc];
}

-(void)handleBusInfo:(id)di 
{
	NSDictionary* busDi = (NSDictionary*)di;
		
	NSString* vID = [busDi objectForKey:@"vehicleID"];
	NSString* rID = [busDi objectForKey:@"routeID"];
	
	double latitude = [[busDi valueForKey:@"latitude"] doubleValue];
	if ( latitude < 1.0 )
	{
		NSLog(@"WARNING bogus latitude %lf for bus %@ on route %@\n", latitude, vID, rID);
	}
	else
	{
		NSDate* timestamp = [NSDate dateWithTimeIntervalSince1970:[[busDi objectForKey:@"absoluteTime"] doubleValue]/1000];
		if ( [timestamp timeIntervalSinceNow] < -(7 * 60) )
		{
			NSLog(@"Stale data freshly downloaded: %@\n", timestamp);
		}
		else
		{
			[m_collectionOwner busInfoCollector:self 
								  updateBusInfo:vID
										  route:rID
									   latitude:latitude
									  longitude:[[busDi valueForKey:@"longitude"] doubleValue]
										heading:[[busDi objectForKey:@"heading"] floatValue]
									  timestamp:[NSDate dateWithTimeIntervalSince1970:[[busDi objectForKey:@"absoluteTime"] doubleValue]/1000]
			 ];
		}
	}
}
		 
-(void)handleNode:(XPathNode*)node
{
	[self performSelectorOnMainThread:@selector(handleBusInfo:) withObject:node.childrenAsDictionary waitUntilDone:NO];
}

-(void)queueRoute:(NSNumber*)routeID
{
	NSError* error = nil;
	[s_currentBusesOnRouteFn Invoke:[NSDictionary dictionaryWithObjectsAndKeys:@"http://transit.metrokc.gov", @"in0", routeID, @"in1", nil] 
						nodeHandler:self 
							timeout:3.0
							  error:&error];
}

-(void)main
{
	[m_collectionOwner performSelectorOnMainThread:@selector(busInfoCollectorStartingCollectionPass:) withObject:self waitUntilDone:NO];
	for (NSNumber* routeID in m_routeIDs)
	{
		NSAutoreleasePool* localPool = [[NSAutoreleasePool alloc] init];
		[self queueRoute:routeID];		
		[localPool release];
	}
	[m_collectionOwner performSelectorOnMainThread:@selector(busInfoCollectorEndCollectionPass:) withObject:self waitUntilDone:NO];
}

@end
