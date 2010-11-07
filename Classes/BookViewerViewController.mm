//
//  BookViewerViewController.m
//  BookViewer
//
//  Created by Karatsu Naoya on 10/11/02.
//  Copyright 2010 ajapax. All rights reserved.
//

#import "BookViewerViewController.h"
#import "TBookViewDefinition.h"
#import "TBookViewCtrl.h"
#import "RootView.h"

@implementation BookViewerViewController

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = [[RootView alloc] initWithFrame:CGRectMake(0, 0, WINDOW_W, WINDOW_H)];
    [self.view setDelegate:self];

    ctrl = [[TBookViewCtrl alloc] init];
    [self.view addSubview:ctrl.view];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)dealloc {
    [super dealloc];
}

/* TouchesDelegate */

- (void)view:(UIView*)view touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  NSLog(@"delegate touchesBegan");
  for (UITouch *touch in touches) {
    startPoint = [touch locationInView:self.view];
    break;
  }
}

- (void)view:(UIView*)view touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
  NSLog(@"delegate touchesMoved");
  for (UITouch *touch in touches) {
    endPoint = [touch locationInView:self.view];
    [ctrl curlPageWithVector:CGPointMake(endPoint.x - startPoint.x, endPoint.y - startPoint.y)];
    break;
  }
}

- (void)view:(UIView*)view touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
  NSLog(@"delegate touchesEnded");
  for (UITouch *touch in touches) {
    endPoint = [touch locationInView:self.view];
    [ctrl curlPageWithVector:CGPointMake(0, 0)];
    break;
  }
}

- (void)view:(UIView*)view touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
  NSLog(@"delegate touchesCancelled");
}

@end
