//
//  testView.m
//  sc
//
//  Created by xcc on 09/08/15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "testView.h"


@implementation testView


- (id)initWithFrame:(CGRect)frame Str:(NSString*)s{
    if (self = [super initWithFrame:frame]) {
        // Initialization code
	str = s;
	[self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
	UIFont *font = [UIFont systemFontOfSize:20]; 
	CGPoint origin = self.frame.origin;
	double left = self.bounds.origin.x;
	double top = self.bounds.origin.y;
	double right = left + self.bounds.size.width;
	double bottom = top + self.bounds.size.height;
	for (double v = top; v < bottom; v += 100.0) {
		for (double h = left; h < right; h += 100.0) {
			// NSString* str = [NSString stringWithFormat:@"[%.0lf, %.0lf]", h + origin.x, v + origin.y];
			[str drawAtPoint:CGPointMake(h, v) withFont:font]; 
		}
	}
	for (double v = top; v < bottom; v += 100.0) {
		CGContextMoveToPoint(context, left, v);
		CGContextAddLineToPoint(context, right, v);
		CGContextStrokePath(context);	
	}
	for (double h = left; h < right; h += 100.0) {
		CGContextMoveToPoint(context, h, top);
		CGContextAddLineToPoint(context, h, bottom);
		CGContextStrokePath(context);	
	}
}


- (void)dealloc {
    [super dealloc];
}


@end
