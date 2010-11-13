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
#import "TPageHolder.h"
#import "MathUtil.h"

enum {
  NONE,
  AUTO_PAGE_CURLING,
  CONTINUE_PAGE_CURLING,
  REVERSE_PAGE_CURLING,
  MANUAL_PAGE_CURLING
};

enum {
  CURLING_RIGHT_TO_LEFT,
  CURLING_RIGHT_TO_RIGHT,
  CURLING_LEFT_TO_LEFT,
  CURLING_LEFT_TO_RIGHT
};

@interface TBookViewCtrl : UIViewController {
  TPageCurlView* page_curl_view;
  UIView* main_pages[6];
  UIView* left_view;
  UIView* right_view;

  TPageHolder* holder;

  NSTimer* timer;

  BOOL animating;
  BOOL displayLinkSupported;
  int animationFrameInterval;

  int page_num;

  int direction;
  int state;
  int curl_direction;
  CGPoint startPoint, endPoint;

  GLuint texture[6];
  GLuint tex;

  CGPoint pre_vector;
  CGPoint vector;
  CGPoint base_point;
  CGPoint pivot_point;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;

-(void)loadTextures;
-(void) setMainPages;
-(void) changeRightPage;
-(void) returnRightPage;
-(void) changeLeftPage;
-(void) returnLeftPage;
-(void) drawPage;
-(void) drawLeftFullPage;
-(void) drawRightFullPage;
-(void) drawCurlPage;
-(void) drawCurlingPageWithVector:(CGPoint)v start:(float)start_rad delta:(float)delta_rad startTan:(float)start_tan endTan:(float)end_tan xRef:(int)x_ref yRef:(int)y_ref;
-(void) drawCurlingPageWithXline:(float)x1 X2:(float)x2 xRef:(int)x_ref yRef:(int)y_ref;
-(void) drawLackedPageWithXLine:(float)x xRef:(int)x_ref yRef:(int)y_ref;
-(void) drawLackedPageWithVector:(CGPoint)v A:(float)a B:(float)b xRef:(int)x_ref yRef:(int)y_ref;
- (void) curlPageWithVector:(CGPoint)point;

GLfloat* getFlippedVertices(GLfloat* vertices, int n);

@end
