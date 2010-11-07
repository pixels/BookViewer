//
//  TBookViewCtrl.h
//  BookViewer
//
//  Created by Karatsu Naoya on 10/11/02.
//  Copyright 2010 ajapax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPageCurlView.h"
#import "TBookViewDefinition.h"
#import "TPageLoader.h"
#import "MathUtil.h"


@interface TBookViewCtrl : UIViewController {
  TPageCurlView* page_curl_view;
  UIImageView* main_pages[2];
  TPageLoader* loader;
  BOOL animating;
  BOOL displayLinkSupported;
  int animationFrameInterval;

  GLuint texture[2];
  GLuint tex;

  CGPoint pre_vector;
  CGPoint vector;
  CGPoint base_point;
  CGPoint pivot_point;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;

-(void) drawLeftPage;
-(void) drawRightPage;
-(void) drawLeftFullPage;
-(void) drawRightFullPage;
-(void) drawRightCurlPage;
-(void) drawCurlingRightPageWithVector:(CGPoint)v start:(float)start_rad delta:(float)delta_rad startTan:(float)start_tan endTan:(float)end_tan;
-(void) drawLackedRightPageWithVector:(CGPoint)v A:(float)a B:(float)b;
- (void) curlPageWithVector:(CGPoint)point;

@end
