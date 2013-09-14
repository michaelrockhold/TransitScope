//
//  LTBusAnnotationView.m
//  Seattle Live Transit
//
//  Created by Michael Rockhold on 7/29/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>
#import <MapKit/MKAnnotationView.h>
#import <math.h>
#import "BusAnnotationView.h"
#import "MapViewController.h"
#import "Bus.h"
#import "Route.h"
#import "Model.h"

extern NSObject<Model>* g_Model;

static UIFont*		s_textFont;
static CGRect		s_textRect;
static CGSize		s_frameSize;

static UIImage*		s_image;
static UIImage*		s_image_highlit;
static CGRect		s_image_rect;

@implementation BusAnnotationView

+(void)initialize
{
	if (self == [BusAnnotationView class])
	{
		s_textFont =  [UIFont boldSystemFontOfSize:10];
		
		CGSize textSize = [@"888" sizeWithFont:s_textFont];
		s_textRect = CGRectMake(-textSize.width/2, -textSize.width/2, textSize.width, textSize.width);				
		s_textRect.origin.y += 2; // just looks a bit better
		
		s_image = [UIImage imageNamed:@"BusOnMap.png"];
		s_image_highlit = [UIImage imageNamed:@"BusOnMap_highlit.png"];
		
		CGSize image_size = [s_image size];
		
		double view_diameter = textSize.width+16;
		double image_diameter = sqrt(pow(image_size.height, 2) + pow(image_size.width,2));
		double w = view_diameter * image_size.width / image_diameter;
		double h = view_diameter * image_size.height / image_diameter;
		
		s_image_rect = CGRectMake(-w/2, -h/2, w, h);
		
		s_frameSize = CGSizeMake(view_diameter, view_diameter);
	}
}

- (id)initWithController:(MapViewController*)controller bus:(Bus*)bus {
    
	if ( self = [self initWithAnnotation:bus reuseIdentifier:[BusAnnotationView reuseIdentifierForAnnotation:bus]] )
	{
		_controller = controller;
		self.opaque = NO;
		self.enabled = YES;
		self.userInteractionEnabled = YES;
		[self setFrame:CGRectMake(0, 0, s_frameSize.width, s_frameSize.height)];
	}
	return self;
}

- (BOOL)canShowCallout {
    
    return [self.annotation isKindOfClass:[Bus class]];
}

-(UIView*)leftCalloutAccessoryView {
    
    return nil;
}

- (UIView*)rightCalloutAccessoryView {
    
    return [self.controller rightCalloutAccessoryViewForBus:(Bus*)self.annotation];
}

+ (NSString*)reuseIdentifierForAnnotation:(Bus*)bus {
    
	return [NSString stringWithFormat:@"SLT_RID:Bus:f%c:rt%@:hd%f",
            ([bus isEqual:g_Model.followedBus] ? 'y' : 'n'), bus.route.ID, bus.heading];
}

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180 / M_PI;};

- (void)drawRect:(CGRect)rect
{
	Bus* thisBus = (Bus*)self.annotation;
	
		//BOOL fOld = ( NSOrderedAscending == [thisBus.timestamp compare:[NSDate dateWithTimeIntervalSinceNow:-(7 * 60)]] );

	NSString* tag = [NSString stringWithFormat:@"%@", thisBus.route.ID];
	float heading = thisBus.heading;
	if ( heading < 0 || heading >= 360 ) heading = 0;
	
	CGContextRef myContext = UIGraphicsGetCurrentContext();
	CGContextSaveGState(myContext);
	CGContextTranslateCTM(myContext, s_frameSize.width/2, s_frameSize.height/2);
	
	//CGRect dot = CGRectMake(-s_frameSize.width/2, -s_frameSize.width/2, s_frameSize.width, s_frameSize.height);
	
	CGContextSaveGState(myContext);
	CGContextRotateCTM(myContext, DegreesToRadians(heading+180));
	//CGContextFillEllipseInRect(myContext, dot);
	UIImage* image = ([thisBus isEqual:g_Model.followedBus]) ? s_image_highlit : s_image;
	CGContextDrawImage(myContext, s_image_rect, image.CGImage);
	CGContextRestoreGState(myContext);

	[[UIColor blackColor] set];		
	[tag drawInRect:s_textRect withFont:s_textFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
	CGContextRestoreGState(myContext);
}

@end
