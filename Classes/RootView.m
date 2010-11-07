//
//  RootView.m
//  BookViewer
//
//  Created by Karatsu Naoya on 10/11/03.
//  Copyright 2010 ajapax. All rights reserved.
//

#import "RootView.h"


@implementation RootView
@synthesize delegate;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


/* touch */

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"touchesBegan");
	[delegate view:self touchesBegan:touches withEvent:event];
}

- (void)touchesMoved: (NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"touchesMoved");
	[delegate view:self touchesMoved:touches withEvent:event];
}

- (void)touchesEnded: (NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"touchesEnded");
	[delegate view:self touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"touchesCancelled");
	[delegate view:self touchesCancelled:touches withEvent:event];
}


- (void)dealloc {
    [super dealloc];
}


@end

