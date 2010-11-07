//
//  BookViewerAppDelegate.h
//  BookViewer
//
//  Created by Karatsu Naoya on 10/11/02.
//  Copyright 2010 ajapax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BookViewerViewController;

@interface BookViewerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    BookViewerViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BookViewerViewController *viewController;

@end

