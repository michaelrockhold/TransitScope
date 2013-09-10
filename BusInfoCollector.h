#import <Foundation/Foundation.h>
#import "Model.h"
#import <XPathQuery.h>

@protocol BusInfoCollectionOwner;

@interface BusInfoCollector : NSOperation <XPathNodeHandler>
{
	NSObject<BusInfoCollectionOwner>* m_collectionOwner;
	NSSet* m_routeIDs;
}

+ (void)initialize;
- (id)initWithCollectionOwner:(NSObject<BusInfoCollectionOwner>*)owner routeIDs:(NSSet*)routeIDs;
- (void)queueRoute:(NSNumber*)routeID;
- (void)main;

@end
