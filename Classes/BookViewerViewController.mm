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

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)FromInterfaceOrientation {  
  NSLog(@"orientation!!!");
    if(FromInterfaceOrientation == UIInterfaceOrientationPortrait){  
        // 横向き  
    } else {  
        // 縦向き  
    }  
} 

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)dealloc {
    [super dealloc];
}

@end
