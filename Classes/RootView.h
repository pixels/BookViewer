//
//  RootView.h
//  BookViewer
//
//  Created by Karatsu Naoya on 10/11/03.
//  Copyright 2010 ajapax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchesDelegate.h"


@interface RootView : UIView {
	id<TouchesDelegate> delegate;
}

@property (nonatomic, retain) id delegate;

@end
