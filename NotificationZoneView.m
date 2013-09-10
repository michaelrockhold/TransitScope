//
//  CrosshairsView.m
//  LiveTransit-Seattle
//
//  Created by Michael Rockhold on 8/17/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import "NotificationZoneView.h"

@implementation NotificationZoneView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
	{
		float circleDiameter = frame.size.width * 0.3;
		m_notificationZoneRect = CGRectMake(frame.origin.x + frame.size.width/2 - circleDiameter/2, frame.origin.y + frame.size.height/2 - circleDiameter/2, circleDiameter, circleDiameter);
    }
    return self;
}

-(CGRect)notificationZoneRect
{
	return m_notificationZoneRect;
}

-(void)setNotificationZoneRect:(CGRect)rect
{
	m_notificationZoneRect = rect;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef myContext = UIGraphicsGetCurrentContext();
	CGContextSaveGState(myContext);
	CGContextClearRect(myContext, rect);
	
	CGContextAddEllipseInRect(myContext, m_notificationZoneRect);
	
	CGContextSetLineWidth(myContext, 3);
	CGContextSetGrayStrokeColor(myContext, 0, 0.2);
	CGContextDrawPath(myContext, kCGPathStroke);
	CGContextRestoreGState(myContext);
}

@end
