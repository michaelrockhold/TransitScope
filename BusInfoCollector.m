
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
														 ParamOrder:@[@"in0", @"in1"]									
													  ResponseQuery:@"//multiRef"
													 ResponsePrefix:nil
												  ResponseNamespace:nil];
	}
}

- (id)initWithCollectionOwner:(NSObject<BusInfoCollectionOwner>*)owner routeIDs:(NSSet*)routeIDs
{
	if ( self = [self init] )
	{
		m_collectionOwner = owner;
		m_routeIDs = routeIDs;
	}
	return self;
}


-(void)handleBusInfo:(id)di 
{
	NSDictionary* busDi = (NSDictionary*)di;
		
	NSString* vID = busDi[@"vehicleID"];
	NSString* rID = busDi[@"routeID"];
	
	double latitude = [[busDi valueForKey:@"latitude"] doubleValue];
	if ( latitude < 1.0 )
	{
		NSLog(@"WARNING bogus latitude %lf for bus %@ on route %@\n", latitude, vID, rID);
	}
	else
	{
		NSDate* timestamp = [NSDate dateWithTimeIntervalSince1970:[busDi[@"absoluteTime"] doubleValue]/1000];
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
										heading:[busDi[@"heading"] floatValue]
									  timestamp:[NSDate dateWithTimeIntervalSince1970:[busDi[@"absoluteTime"] doubleValue]/1000]
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
	[s_currentBusesOnRouteFn Invoke:@{@"in0": @"http://transit.metrokc.gov", @"in1": routeID} 
						nodeHandler:self 
							timeout:3.0
							  error:&error];
}

-(void)main
{
	[m_collectionOwner performSelectorOnMainThread:@selector(busInfoCollectorStartingCollectionPass:) withObject:self waitUntilDone:NO];
	for (NSNumber* routeID in m_routeIDs)
	{
		@autoreleasepool {
			[self queueRoute:routeID];		
		}
	}
	[m_collectionOwner performSelectorOnMainThread:@selector(busInfoCollectorEndCollectionPass:) withObject:self waitUntilDone:NO];
}

@end
