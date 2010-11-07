//
//  TouchesDelegate.h
//  BookViewer
//
//  Created by Karatsu Naoya on 10/11/03.
//  Copyright 2010 ajapax. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TouchesDelegate

@optional
- (void)view:(UIView*)view touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)view:(UIView*)view touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)view:(UIView*)view touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)view:(UIView*)view touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event;

@end
