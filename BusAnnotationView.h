//
//  LTBusAnnotationView.h
//  Live Transit:Seattle
//
//  Created by Michael Rockhold on 7/29/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLTAnnotationView.h"

@class Bus;

@interface BusAnnotationView : SLTAnnotationView
{

}

- (id)initWithController:(NSObject*)controller bus:(Bus*)bus;

@end
