//
//  SLTMapView.h
//  SeattleLiveTransit
//
//  Created by Michael Rockhold on 10/14/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import <MapKit/MKMapView.h>


@interface SLTMapView : MKMapView <MKMapViewDelegate>
{
	NSObject* m_realDelegate;
	SEL m_mapViewRegionDidChangeAnimatedSelector;
}

@property (nonatomic, strong) IBOutlet NSObject* realDelegate;

@end
