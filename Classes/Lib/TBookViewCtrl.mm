    //
//  TBookViewCtrl.mm
//  BookViewer
//
//  Created by Karatsu Naoya on 10/11/02.
//  Copyright 2010 ajapax. All rights reserved.
//

#import "TBookViewCtrl.h"
#import "graphicUtil.h"
#import "RootView.h"

@interface TBookViewCtrl ()
@property (nonatomic, retain) EAGLContext *context;
@end

@implementation TBookViewCtrl

@synthesize animating, context;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
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
  page_num = 0;

  direction = DIRECTION_RIGHT;

  [super viewDidLoad];
  //[self.view setBackgroundColor:[UIColor redColor]];
  self.view = [[RootView alloc] initWithFrame:CGRectMake(0, 0, WINDOW_W, WINDOW_H)];
  [(RootView*)self.view setDelegate:self];
  self.view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
  self.view.frame = CGRectMake(0, 0, WINDOW_W, WINDOW_H);

  loader = [[TPageLoader alloc] init];
  pre_vector = CGPointMake(0, 0);
  vector = CGPointMake(0, 0);
  base_point = CGPointMake(0, 0);
  pivot_point = CGPointMake(0, 0);

  for (int i = 0; i < 6; i++) {
    main_pages[i] = [loader getImageViewWithNumber:i];
    main_pages[i].frame = CGRectMake(0, 0, self.view.frame.size.width / 2, self.view.frame.size.height);
  }

  left_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width / 2, self.view.frame.size.height)];
  [self.view addSubview:left_view];

  right_view = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2, 0, self.view.frame.size.width / 2, self.view.frame.size.height)];
  [self.view addSubview:right_view];

  [self initPageCurlView];

  [self setMainPages];

  [self loadTextures];

  [self drawFrame];
}

-(void) setMainPages {
  for (int i = 0; i < 6; i ++) {
    [main_pages[i] removeFromSuperview];
  }
  if ( direction == DIRECTION_RIGHT ) {
      [left_view addSubview:main_pages[2]];
      [right_view addSubview:main_pages[3]];
  } else {
      [right_view addSubview:main_pages[2]];
      [left_view addSubview:main_pages[3]];
  }
}

-(void) changeRightPage {
  if ( direction == DIRECTION_RIGHT ) {
    [main_pages[3] removeFromSuperview];
    [right_view addSubview:main_pages[5]];
  } else {
    [main_pages[2] removeFromSuperview];
    [right_view addSubview:main_pages[0]];
  }
}

- (void) returnRightPage {
  if ( direction == DIRECTION_RIGHT ) {
    [main_pages[5] removeFromSuperview];
    [right_view addSubview:main_pages[3]];
  } else {
    [main_pages[0] removeFromSuperview];
    [right_view addSubview:main_pages[2]];
  }
}

-(void) changeLeftPage {
  if ( direction == DIRECTION_RIGHT ) {
    [main_pages[2] removeFromSuperview];
    [left_view addSubview:main_pages[0]];
  } else {
    [main_pages[3] removeFromSuperview];
    [left_view addSubview:main_pages[5]];
  }
}

- (void) returnLeftPage {
  if ( direction == DIRECTION_RIGHT ) {
    [main_pages[0] removeFromSuperview];
    [left_view addSubview:main_pages[2]];
  } else {
    [main_pages[5] removeFromSuperview];
    [left_view addSubview:main_pages[3]];
  }
}


-(void) loadTextures {
  for ( int i = 0; i < 6; i++ ) texture[i] = loadTextureFromUIView(main_pages[i]);
}

-(void) initPageCurlView {
  page_curl_view = [[TPageCurlView alloc] initWithFrame:CGRectMake(0, 0, WINDOW_W, WINDOW_H)];
  page_curl_view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
  EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];

  if (!aContext)
    NSLog(@"Failed to create ES context");
  else if (![EAGLContext setCurrentContext:aContext])
    NSLog(@"Failed to set ES context current");

  self.context = aContext;
  [aContext release];

  [(TPageCurlView *)page_curl_view setContext:self.context];
  [(TPageCurlView *)page_curl_view setFramebuffer];

  animating = FALSE;
  displayLinkSupported = FALSE;
  animationFrameInterval = 1;

  // Use of CADisplayLink requires iOS version 3.1 or greater.
  // The NSTimer object is used as fallback when it isn't available.
  NSString *reqSysVer = @"3.1";
  NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
  if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
    displayLinkSupported = TRUE;
  }

  srand(time(NULL));

  [self.view addSubview:page_curl_view];
}

- (void) setPrimaryPoints {
  pivot_point = CGPointMake(0.0f, 1.5f);
  base_point = CGPointMake(2.0f, 1.5f);
}

- (void)drawFrame
{
  [(TPageCurlView *)page_curl_view setFramebuffer];

  GLfloat lightPos[] = {
    0.0f, 0.0f, 3.0f, 0.0f
  };

  GLfloat lightDirection[] = {
    0.0f, 0.0f, -1.0f
  };

  GLfloat lightColor[] = {
    1.0f, 0.0f, 0.0f, 1.0f
  };

  GLfloat lightAmbient[] = {
    0.5f, 0.5f, 0.5f, 1.0f
  };

  GLfloat diffuse[] = {
    1.0f, 0.0f, 0.0f, 1.0f
  };

  GLfloat ambient[] = {
    0.5f, 0.5f, 0.5f, 1.0f
  };

  glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
  glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  // ライトを当ててみる
  // glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glLightfv(GL_LIGHT0, GL_POSITION, lightPos);
  glLightfv(GL_LIGHT0, GL_SPOT_DIRECTION, lightDirection);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, lightColor);
  glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, diffuse);
  glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, ambient);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrthof(-2.0f, 2.0f, -1.5f, 1.5f, -10.0f, 10.0f);
  //glFrustumf(-2.0f, 2.0f, -1.5f, 1.5f, -10.0f, 10.0f);

  glMatrixMode(GL_MODELVIEW);
  glTranslatef(0.0, 0.0, -7.0);
  glPushMatrix();

  glLoadIdentity();
  // int rad = (int)(vector.x * 50);
  // glRotatef(rad, 0, 1, 0);
  // [self drawBox];
  [self drawPage];
  glPopMatrix();

  // glDisable(GL_LIGHT0);
  // glDisable(GL_LIGHTING);
  // drawTexture(1.0, 1.0, 0.5, 0.5, texture[0], 255, 255, 255, 255);

  if([(TPageCurlView *)page_curl_view presentFramebuffer]) {
#ifdef DEBUG
    NSLog(@"success to present");
#endif
  }
}

-(void) drawBox {
  GLfloat vertices[] = {
    -0.5, -0.5,  -0.5,
    +0.5, -0.5,  -0.5,
    -0.5, +0.5,  -0.5,

    -0.5, +0.5,  -0.5,
    +0.5, -0.5,  -0.5,
    +0.5, +0.5,  -0.5,

    -0.5, -0.5,  +0.5,
    +0.5, -0.5,  +0.5,
    -0.5, +0.5,  +0.5,

    -0.5, +0.5,  +0.5,
    +0.5, -0.5,  +0.5,
    +0.5, +0.5,  +0.5,
  };

  GLubyte colors[] = {
    155, 155, 155, 155,
    155, 155, 155, 155,
    155, 155, 155, 155,

    155, 155, 155, 155,
    155, 155, 155, 155,
    155, 155, 155, 155,

    155, 155, 155, 155,
    155, 155, 155, 155,
    155, 155, 155, 155,

    155, 155, 155, 155,
    155, 155, 155, 155,
    155, 155, 155, 155,
  };

  GLfloat norms[] = {
    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,

    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,

    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,

    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,
  };


  // GLfloat* norms = (GLfloat*)[self getNormVectorsFromVertices:vertices Num:12];

  // glEnable(GL_TEXTURE_2D); // テクスチャ機能を有効にする

  glVertexPointer(3, GL_FLOAT, 0, vertices);
  glEnableClientState(GL_VERTEX_ARRAY);
  glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
  glEnableClientState(GL_COLOR_ARRAY);

  glNormalPointer(GL_FLOAT, 0, norms);
  glEnableClientState(GL_NORMAL_ARRAY);

  // glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
  // glEnableClientState(GL_TEXTURE_COORD_ARRAY);

  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

  glDrawArrays(GL_TRIANGLES, 0, 12);

  // glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_VERTEX_ARRAY);
  glDisable(GL_TEXTURE_2D); // テクスチャ機能を有効にする

}
- (void) drawPage {
  if (vector.x > 0) {
    [self drawCurlPage];
  } else if (vector.x < 0){
    [self drawCurlPage];
  }   
}

-(void) drawLeftFullPage {
  GLfloat verticesLeft[] = {
    -2.0f, -1.5f, 0.0f,
    -2.0f, 1.5f, 0.0f,
    0.0f, -1.5f, 0.0f,

    0.0f, -1.5f, 0.0f,
    -2.0f, 1.5f, 0.0f,
    0.0f, 1.5f, 0.0f
  };

  GLfloat norms[] = {
    0.0f, 0.0f, 1.0f,
    0.0f, 0.0f, 1.0f,
    0.0f, 0.0f, 1.0f,

    0.0f, 0.0f, 1.0f,
    0.0f, 0.0f, 1.0f,
    0.0f, 0.0f, 1.0f,
  };

  GLubyte colors[] = {
    255, 255, 255, 255,
    255, 255, 255, 255,
    255, 255, 255, 255,

    255, 255, 255, 255,
    255, 255, 255, 255,
    255, 255, 255, 255
  };

  GLfloat texCoords[] = {
    0.0, 0.0+1.0,
    0.0, 0.0,
    0.0+1.0, 0.0+1.0,

    0.0+1.0, 0.0+1.0,
    0.0, 0.0,
    0.0+1.0, 0.0
  };

  glEnable(GL_TEXTURE_2D); // テクスチャ機能を有効にする

  glVertexPointer(3, GL_FLOAT, 0, verticesLeft);
  glEnableClientState(GL_VERTEX_ARRAY);
  glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
  glEnableClientState(GL_COLOR_ARRAY);

  glNormalPointer(GL_FLOAT, 0, norms);
  glEnableClientState(GL_NORMAL_ARRAY);

  glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);

  glBindTexture(GL_TEXTURE_2D, texture[1]);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

  glDrawArrays(GL_TRIANGLES, 0, 6);

  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_VERTEX_ARRAY);
  glDisable(GL_TEXTURE_2D); // テクスチャ機能を有効にする
}

-(void) drawRightFullPage {
  GLfloat verticesRight[] = {
    0.0f, -1.5f, 0.0f,
    0.0f, 1.5f, 0.0f,
    2.0f, -1.5f, 0.0f,

    2.0f, -1.5f, 0.0f,
    0.0f, 1.5f, 0.0f,
    2.0f, 1.5f, 0.0f
  };

  GLfloat norms[] = {
    0.0f, 0.0f, 1.0f,
    0.0f, 0.0f, 1.0f,
    0.0f, 0.0f, 1.0f,

    0.0f, 0.0f, 1.0f,
    0.0f, 0.0f, 1.0f,
    0.0f, 0.0f, 1.0f,
  };

  GLubyte colors[] = {
    255, 255, 255, 255,
    255, 255, 255, 255,
    255, 255, 255, 255,

    255, 255, 255, 255,
    255, 255, 255, 255,
    255, 255, 255, 255
  };

  GLfloat texCoords[] = {
    0.0, 0.0+1.0,
    0.0, 0.0,
    0.0+1.0, 0.0+1.0,

    0.0+1.0, 0.0+1.0,
    0.0, 0.0,
    0.0+1.0, 0.0
  };

  glEnable(GL_TEXTURE_2D); // テクスチャ機能を有効にする

  glVertexPointer(3, GL_FLOAT, 0, verticesRight);
  glEnableClientState(GL_VERTEX_ARRAY);
  glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
  glEnableClientState(GL_COLOR_ARRAY);

  glNormalPointer(GL_FLOAT, 0, norms);
  glEnableClientState(GL_NORMAL_ARRAY);

  glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);

  glBindTexture(GL_TEXTURE_2D, texture[2]);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

  glDrawArrays(GL_TRIANGLES, 0, 6);
}

-(void) drawCurlPage {
  int y_ref;
  int x_ref;

  if ( vector.y < 0 ) {
    y_ref = 1;
  } else {
    y_ref = -1;
    vector.y *= -1;
  }

  if ( vector.x > 0 ) {
    x_ref = -1;
    vector.x *= -1;
  } else {
    x_ref = 1;
  }

  float a = - 1.0f * vector.x / vector.y;

  // 指ベクトルの半分
  CGPoint col_vector = vecDivide(vector, 2.0f);

  // 起点と指ベクトル先端の中点
  CGPoint vec_half_point = vecDivide(vecPlus(vector, vecMul(base_point, 2.0f)), 2.0f);
#ifdef DEBUG
  drawTexture(vec_half_point.x, vec_half_point.y, 0.02, 0.02, texture[0], 255, 255, 255, 255);
#endif

  float b = -a * vec_half_point.x + vec_half_point.y;

  // 指ベクトルと直交し上記の中点を通るベクトルと，x軸との交点
  float x0 = vec_half_point.y / -a + vec_half_point.x;
  float y0 = 0.0f;

#ifdef DEBUG
  drawSquare(x0, y0, 0.01, 255, 0, 0, 155);
#endif

  // ページ切断線のぶれを決定するベクトル
  CGPoint cut_vec = vecMul(vecDivide(vector, vecNorm(vector)), 0.5 * (-1 * pow((vector.x + base_point.x) / 2, 2) + 1));

  // ページ切断線上の一点
  CGPoint cut_point = vecPlus(CGPointMake(x0, y0), cut_vec);

  if ( fabs(vector.y) > 0.0001 ) {
    // ページ切断線の対象線上の一点
    CGPoint r_cut_point = vecMinus(CGPointMake(x0, y0), cut_vec);

#ifdef DEBUG
    drawSquare(cut_point.x, cut_point.y, 0.01, 0, 255, 0, 155);
#endif

#ifdef DEBUG
    for (int i = 0; i < 20; i++ ) {
      float x3 = (float)i / 10;
      float y3 = a * x3 + b;
      drawSquare(x3, y3, 0.01, 0, 0, 255, 100);
    }
#endif

    //------ 曲面決定円錐の計算 -------//
    // 基準曲線 : y = -2 / (x - 2 - pivot_point.x) - 1 + pivot_point.y
    float t = 1.0f;
    float delta = 2 / (cut_point.x - pivot_point.x);

#ifdef DEBUG
    for (int i = 0; i < 40; i++ ) {
      float x3 = (float)(i - 20)/ 10;
      float y3 = -2.0f / ((x3 * delta) - 2 - pivot_point.x) - 1 + pivot_point.y;
      drawSquare(x3, y3, 0.01, 255, 255, 255, 100);
    }
#endif

    float alpha = (2+pivot_point.x) / delta;
    float beta = 1-pivot_point.y;

    float gamma = (b + beta) / a;
    float tau = 2 * t / (a * delta);
    float far_x = ((alpha - gamma) - sqrt(pow(alpha - gamma, 2) + 4.0f * ((alpha * gamma) - tau))) / 4;
    //float far_x = ((alpha - gamma) - sqrt(pow(alpha - gamma, 2) + 4.0f * ((alpha * gamma) - tau))) / 2;
    float far_y = a * far_x + b; 
    if (far_x < 0) {
      far_x = pivot_point.x;
      far_y = pivot_point.y;
    }

#ifdef DEBUG
    drawSquare(far_x, far_y, 0.01, 0, 0, 255, 155);
    // drawTriangle(far_x, far_y, cut_point.x, cut_point.y, 0, 255, 255, 100);
#endif

    float a2 = (cut_point.y - far_y) / (cut_point.x - far_x);
    float b2 = -a2 * cut_point.x + cut_point.y;

#ifdef DEBUG
    for (int i = 0; i < 40; i++ ) {
      float x3 = (float)(i - 20)/ 10;
      float y3 = a2 * x3 + b2;
      drawSquare(x3, y3, 0.01, 0, 0, 0, 100);
    }
#endif

    [self drawLackedPageWithVector:vector A:a2 B:b2 xRef:x_ref yRef:y_ref];

    float a3 = (r_cut_point.y - far_y) / (r_cut_point.x - far_x);
    float b3 = -a3 * r_cut_point.x + r_cut_point.y;

#ifdef DEBUG
    for (int i = 0; i < 40; i++ ) {
      float x3 = (float)(i - 20)/ 10;
      float y3 = a3 * x3 + b3;
      drawSquare(x3, y3, 0.01, 0, 0, 0, 100);
    }
#endif

    // TODO : 説明
    float delta_tan = ((a3 - a2) / (1 + a3 * a2));
    float delta_rad = atan(delta_tan);
    float main_rad = atan(a2);

    [self drawCurlingPageWithVector:CGPointMake(far_x, far_y) start:main_rad delta:delta_rad startTan:a2 endTan:a3 xRef:x_ref yRef:y_ref];
  } else {
    // ページ切断線の対象線上の一点
    CGPoint r_cut_point = vecMinus(CGPointMake(x0, y0), cut_vec);

    [self drawLackedPageWithXLine:cut_point.x xRef:x_ref yRef:y_ref];

    [self drawCurlingPageWithXline:cut_point.x X2:r_cut_point.x xRef:x_ref yRef:y_ref];
    // [self drawCurlingPageWithVector:CGPointMake(far_x, far_y) start:main_rad delta:delta_rad startTan:a2 endTan:a3 xRef:x_ref yRef:y_ref];

  }
  vector.x *= x_ref;
  vector.y *= y_ref;
}

-(void) drawCurlingPageWithXline:(float)x1 X2:(float)x2 xRef:(int)x_ref yRef:(int)y_ref {
  // 円錐の底面(高さrとした場合の)を求める
  float theta1 = M_PI / (float)PAGE_CURL_SPLIT;
  float mini_len = (x2 - x1) / (float)PAGE_CURL_SPLIT;
  float r = (mini_len / 2) / sin(theta1 / 2);

  float oval[PAGE_CURL_SPLIT][3];

  // 円錐の頂点から距離1の点集合を計算
  float tmp_x, tmp_y, tmp_z;
  //for (int i = 0; i < PAGE_CURL_SPLIT; i++ ) {
  for (int i = 0; i < PAGE_CURL_SPLIT; i++ ) {
    float t = ((i + 1) / 40.0) - 0.5;
    oval[i][0] = r * cos(M_PI * t) + x1;
    oval[i][1] = 0.0;
    oval[i][2] = r * sin(M_PI * t) + r;
  }

  GLfloat vertices[9 * 4 * PAGE_CURL_SPLIT];
  GLfloat* norms;
  GLubyte colors[6 * 4 * PAGE_CURL_SPLIT];
  GLfloat tex_coords[6 * 4 * PAGE_CURL_SPLIT];

  int active_counts = 0;

  int vertex_index = 0;
  int color_index = 0;
  int tex_index = 0;

  float pre_c1_x;
  float pre_c1_y;

  float pre_c2_x;
  float pre_c2_y;

  pre_c1_x = x1;
  pre_c1_y = 1.5;

  pre_c2_x = x1;
  pre_c2_y = -1.5;

  float pre_v1_x = pre_c1_x;
  float pre_v1_y = pre_c1_y;
  float pre_v1_z = 0.0;

  float pre_v2_x = pre_c2_x;
  float pre_v2_y = pre_c2_y;
  float pre_v2_z = 0.0;

  int alpha = 255;
  for (int i = 0; i < PAGE_CURL_SPLIT; i++ ) {
    float now_v1_x, now_v1_y, now_v1_z, now_v2_x, now_v2_y, now_v2_z;
    float now_c1_x, now_c1_y, now_c2_x, now_c2_y;

    now_c1_x = x1 + (mini_len * (i + 1));
    now_c1_y = 1.5;

    now_c2_x = x1 + (mini_len * (i + 1));
    now_c2_y = -1.5;

    now_v1_x = oval[i][0];
    now_v1_y = 1.5;
    now_v1_z = oval[i][2];

    now_v2_x = oval[i][0];
    now_v2_y = -1.5;
    now_v2_z = oval[i][2];

    if (x_ref * y_ref < 0) {
      vertices[vertex_index++] = x_ref * now_v1_x;
      vertices[vertex_index++] = y_ref * now_v1_y;
      vertices[vertex_index++] = now_v1_z;
    }

    vertices[vertex_index++] = x_ref * pre_v1_x;
    vertices[vertex_index++] = y_ref * pre_v1_y;
    vertices[vertex_index++] = pre_v1_z;

    if (x_ref * y_ref > 0) {
      vertices[vertex_index++] = x_ref * now_v1_x;
      vertices[vertex_index++] = y_ref * now_v1_y;
      vertices[vertex_index++] = now_v1_z;
    }

    vertices[vertex_index++] = x_ref * pre_v2_x;
    vertices[vertex_index++] = y_ref * pre_v2_y;
    vertices[vertex_index++] = pre_v2_z;

    tex_coords[tex_index++] = 0.5 + x_ref * (now_c1_x/ 2.0 - 0.5);
    tex_coords[tex_index++] = (1.5 - y_ref * now_c1_y) / 3.0;

    tex_coords[tex_index++] = 0.5 + x_ref * (pre_c1_x / 2.0 - 0.5);
    tex_coords[tex_index++] = (1.5 - y_ref * pre_c1_y) / 3.0;

    tex_coords[tex_index++] = 0.5 + x_ref * (pre_c2_x / 2.0 - 0.5);
    tex_coords[tex_index++] = (1.5 - y_ref * pre_c2_y) / 3.0;

    colors[color_index++] = 255; colors[color_index++] = 255;
    colors[color_index++] = 255; colors[color_index++] = alpha;
    colors[color_index++] = 255; colors[color_index++] = 255;
    colors[color_index++] = 255; colors[color_index++] = alpha;
    colors[color_index++] = 255; colors[color_index++] = 255;
    colors[color_index++] = 255; colors[color_index++] = alpha;

    active_counts++;

    if (x_ref < 0) {
      vertices[vertex_index++] = x_ref * now_v1_x;
      vertices[vertex_index++] = y_ref * now_v1_y;
      vertices[vertex_index++] = now_v1_z;
    }

    vertices[vertex_index++] = x_ref * pre_v2_x;
    vertices[vertex_index++] = y_ref * pre_v2_y;
    vertices[vertex_index++] = pre_v2_z;

    if (x_ref > 0) {
      vertices[vertex_index++] = x_ref * now_v1_x;
      vertices[vertex_index++] = y_ref * now_v1_y;
      vertices[vertex_index++] = now_v1_z;
    }

    vertices[vertex_index++] = x_ref * now_v2_x;
    vertices[vertex_index++] = y_ref * now_v2_y;
    vertices[vertex_index++] = now_v2_z;

    if (x_ref < 0) {
      tex_coords[tex_index++] = 0.5 + x_ref * (now_c1_x/ 2.0 - 0.5);
      tex_coords[tex_index++] = (1.5 - y_ref * now_c1_y) / 3.0;
    }

    tex_coords[tex_index++] = 0.5 + x_ref * (pre_c2_x / 2.0 - 0.5);
    tex_coords[tex_index++] = (1.5 - y_ref * pre_c2_y) / 3.0;

    if (x_ref > 0) {
      tex_coords[tex_index++] = 0.5 + x_ref * (now_c1_x/ 2.0 - 0.5);
      tex_coords[tex_index++] = (1.5 - y_ref * now_c1_y) / 3.0;
    }
    tex_coords[tex_index++] = 0.5 + x_ref * (now_c2_x / 2.0 - 0.5);
    tex_coords[tex_index++] = (1.5 - y_ref * now_c2_y) / 3.0;

    colors[color_index++] = 255; colors[color_index++] = 255;
    colors[color_index++] = 255; colors[color_index++] = alpha;
    colors[color_index++] = 255; colors[color_index++] = 255;
    colors[color_index++] = 255; colors[color_index++] = alpha;
    colors[color_index++] = 255; colors[color_index++] = 255;
    colors[color_index++] = 255; colors[color_index++] = alpha;

    active_counts++;

    pre_v1_x = now_v1_x;
    pre_v1_y = now_v1_y;
    pre_v1_z = now_v1_z;

    pre_c1_x = now_c1_x;
    pre_c1_y = now_c1_y;

    pre_v2_x = now_v2_x;
    pre_v2_y = now_v2_y;
    pre_v2_z = now_v2_z;

    pre_c2_x = now_c2_x;
    pre_c2_y = now_c2_y;

  }

  if (x_ref < 0) {
    vertices[vertex_index++] = x_ref * pre_v1_x;
    vertices[vertex_index++] = y_ref * pre_v1_y;
    vertices[vertex_index++] = pre_v1_z;
  }

  vertices[vertex_index++] = x_ref * pre_v2_x;
  vertices[vertex_index++] = y_ref * pre_v2_y;
  vertices[vertex_index++] = pre_v2_z;

  if (x_ref > 0) {
    vertices[vertex_index++] = x_ref * pre_v1_x;
    vertices[vertex_index++] = y_ref * pre_v1_y;
    vertices[vertex_index++] = pre_v1_z;
  }

  vertices[vertex_index++] = x_ref * (pre_v1_x - (2.0 - x2));
  vertices[vertex_index++] = y_ref * 1.5;
  vertices[vertex_index++] = pre_v1_z;

  if (x_ref < 0) {
    tex_coords[tex_index++] = 0.5 + x_ref * (pre_c1_x / 2.0 - 0.5);
    tex_coords[tex_index++] = (1.5 - y_ref * pre_c1_y) / 3.0;
  }

  tex_coords[tex_index++] = 0.5 + x_ref * (pre_c2_x / 2.0 - 0.5);
  tex_coords[tex_index++] = (1.5 - y_ref * pre_c2_y) / 3.0;

  if (x_ref > 0) {
    tex_coords[tex_index++] = 0.5 + x_ref * (pre_c1_x / 2.0 - 0.5);
    tex_coords[tex_index++] = (1.5 - y_ref * pre_c1_y) / 3.0;
  }

  tex_coords[tex_index++] = 0.5 + x_ref * 0.5;
  tex_coords[tex_index++] = 0.5 - y_ref * 0.5;

  colors[color_index++] = 255; colors[color_index++] = 255;
  colors[color_index++] = 255; colors[color_index++] = alpha;
  colors[color_index++] = 255; colors[color_index++] = 255;
  colors[color_index++] = 255; colors[color_index++] = alpha;
  colors[color_index++] = 255; colors[color_index++] = 255;
  colors[color_index++] = 255; colors[color_index++] = alpha;

  active_counts++;

  if (x_ref < 0) {
    vertices[vertex_index++] = x_ref * (pre_v1_x - (2.0 - x2));
    vertices[vertex_index++] = y_ref * -1.5;
    vertices[vertex_index++] = pre_v1_z;
  }

  vertices[vertex_index++] = x_ref * pre_v2_x;
  vertices[vertex_index++] = y_ref * pre_v2_y;
  vertices[vertex_index++] = pre_v2_z;

  if (x_ref > 0) {
    vertices[vertex_index++] = x_ref * (pre_v1_x - (2.0 - x2));
    vertices[vertex_index++] = y_ref * -1.5;
    vertices[vertex_index++] = pre_v1_z;
  }

  vertices[vertex_index++] = x_ref * (pre_v1_x - (2.0 - x2));
  vertices[vertex_index++] = y_ref * 1.5;
  vertices[vertex_index++] = pre_v1_z;

  if (x_ref < 0) {
    tex_coords[tex_index++] = 0.5 + x_ref * 0.5;
    tex_coords[tex_index++] = 0.5 + y_ref * 0.5;
  }

  tex_coords[tex_index++] = 0.5 + x_ref * (pre_c2_x / 2.0 - 0.5);
  tex_coords[tex_index++] = (1.5 - y_ref * pre_c2_y) / 3.0;

  if (x_ref > 0) {
    tex_coords[tex_index++] = 0.5 + x_ref * 0.5;
    tex_coords[tex_index++] = 0.5 + y_ref * 0.5;
  }

  tex_coords[tex_index++] = 0.5 + x_ref * 0.5;
  tex_coords[tex_index++] = 0.5 - y_ref * 0.5;

  colors[color_index++] = 255; colors[color_index++] = 255;
  colors[color_index++] = 255; colors[color_index++] = alpha;
  colors[color_index++] = 255; colors[color_index++] = 255;
  colors[color_index++] = 255; colors[color_index++] = alpha;
  colors[color_index++] = 255; colors[color_index++] = 255;
  colors[color_index++] = 255; colors[color_index++] = alpha;

  active_counts++;

  norms = (GLfloat*)[self getNormVectorsFromVertices:vertices Num:3 * active_counts];

  int tex_page;
  glEnable(GL_CULL_FACE); 
  for (int i = 0; i < 2; i++ ) {
    if ( i == 0 ) {
      glCullFace(GL_FRONT);
      // glFrontFace(GL_CCW);
    } else {
      glCullFace(GL_BACK);
      // glFrontFace(GL_CW);
    }
    if ( x_ref > 0 ) {
      if ( i == 0 ) tex_page = 3;
      else  tex_page = 4;
    } else {
      if ( i == 0 ) tex_page = 2;
      else  tex_page = 1;
    }

    // POINT
    glEnable(GL_TEXTURE_2D); // テクスチャ機能を有効にする
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
    glEnableClientState(GL_COLOR_ARRAY);

    glNormalPointer(GL_FLOAT, 0, norms);
    glEnableClientState(GL_NORMAL_ARRAY);

    glTexCoordPointer(2, GL_FLOAT, 0, tex_coords);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);

    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);

    glBindTexture(GL_TEXTURE_2D, texture[tex_page]);

    glDrawArrays(GL_TRIANGLES, 0, 3 * active_counts);
  }

  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_VERTEX_ARRAY);

  glDisable(GL_TEXTURE_2D); // テクスチャ機能を有効にする
}
-(void) drawCurlingPageWithVector:(CGPoint)v start:(float)start_rad delta:(float)delta_rad startTan:(float)start_tan endTan:(float)end_tan xRef:(int)x_ref yRef:(int)y_ref {
  // 円錐の底面(高さrとした場合の)を求める
  float r = 1;
  float theta1 = M_PI / (float)PAGE_CURL_SPLIT;
  float mini_rad = fabs(delta_rad) / 40.0;
  float tmp = pow(tan(mini_rad / 2), 2);
  float inside_l = sqrt( tmp / ( pow(tan(theta1 / 2), 2) - tmp ));
  float theta2 = atan(inside_l);
  float radius = inside_l / cos(theta1 / 2);

#ifdef DEBUG
  /*
     for (int i = 0; i < 40; i++ ) {
     float theta3 = 40.0 / (i + 1);
     float x3 = radius * cos(2 * M_PI * theta3);
     float y3 = radius * sin(2 * M_PI * theta3);
     drawSquare(x3, y3, 0.01, 0, 0, 0, 100);
     } */
#endif

  float oval[PAGE_CURL_SPLIT][3];

  // 円錐の頂点から距離1の点集合を計算
  float tmp_x, tmp_y, tmp_z;
  //for (int i = 0; i < PAGE_CURL_SPLIT; i++ ) {
  for (int i = 0; i < PAGE_CURL_SPLIT; i++ ) {
    oval[i][0] = 1.0;

    float t = ((i + 1) / 40.0) - 0.5;
    oval[i][1] = radius * cos(M_PI * t);
    oval[i][2] = radius * sin(M_PI * t);

    tmp_x = oval[i][0] * cos(theta2) - oval[i][2] * sin(theta2);
    tmp_z = oval[i][0] * sin(theta2) + oval[i][2] * cos(theta2);
    oval[i][0] = tmp_x;
    oval[i][2] = tmp_z;

    tmp_x = oval[i][0] * cos(-start_rad) + oval[i][1] * sin(-start_rad);
    tmp_y = -oval[i][0] * sin(-start_rad) + oval[i][1] * cos(-start_rad);
    oval[i][0] = tmp_x;
    oval[i][1] = tmp_y;

    // normalize
    float l = sqrt(pow(oval[i][0], 2) + pow(oval[i][1], 2) + pow(oval[i][2], 2));

    oval[i][0] /= l;
    oval[i][1] /= l;
    oval[i][2] /= l;

#ifdef DEBUG
    drawSquare(oval[i][0], oval[i][1], 0.01, 0, 255, 0, 100);
#endif
  }
  // GLfloat vertices[6 * 2 * BOMB_COUNT];
  // GLubyte colors[6 * 4 * BOMB_COUNT];
  // GLfloat texCoords[6 * 2 * BOMB_COUNT];
  //
  GLfloat vertices[9 * 4 * PAGE_CURL_SPLIT];
  GLfloat* norms;
  GLubyte colors[6 * 4 * PAGE_CURL_SPLIT];
  GLfloat tex_coords[6 * 4 * PAGE_CURL_SPLIT];

  int active_counts = 0;

  int vertex_index = 0;
  int color_index = 0;
  int tex_index = 0;

  float tmp_a = start_tan;
  float tmp_b = -tmp_a * v.x + v.y;

  float pre_c1_x;
  float pre_c1_y;

  float pre_c2_x;
  float pre_c2_y;

  pre_c1_x = ((1.5 - tmp_b) / tmp_a) - v.x;
  pre_c1_y = 1.5 - v.y;

  if ( tmp_a * 2.0 + tmp_b > -1.5) {
    pre_c2_x = 2.0 - v.x;
    pre_c2_y = tmp_a * 2.0 + tmp_b - v.y;
  } else {
    pre_c2_x = ((-1.5 - tmp_b) / tmp_a) - v.x;
    pre_c2_y = -1.5 - v.y;
  }

  float pre_v1_x = pre_c1_x + v.x;
  float pre_v1_y = pre_c1_y + v.y;
  float pre_v1_z = 0.0;

  float pre_v2_x = pre_c2_x + v.x;
  float pre_v2_y = pre_c2_y + v.y;
  float pre_v2_z = 0.0;

  float l1, l2;
  int alpha = 255;
  for (int i = 0; i < PAGE_CURL_SPLIT; i++ ) {
    float now_v1_x, now_v1_y, now_v1_z, now_v2_x, now_v2_y, now_v2_z;
    float now_c1_x, now_c1_y, now_c2_x, now_c2_y;

    tmp_a = tan((mini_rad * (i + 1)) + start_rad);
    tmp_b = -tmp_a * v.x + v.y;

    now_c1_x = ((1.5 - tmp_b) / tmp_a) - v.x;
    now_c1_y = (1.5 - v.y);

    if ( tmp_a * 2.0 + tmp_b > -1.5) {
      now_c2_x = 2.0 - v.x;
      now_c2_y = tmp_a * 2.0 + tmp_b - v.y;
    } else {
      now_c2_x = ((-1.5 - tmp_b) / tmp_a) - v.x;
      now_c2_y = -1.5 - v.y;
    }
    l1 = sqrt(pow(now_c1_x, 2) + pow(now_c1_y, 2));
    l2 = sqrt(pow(now_c2_x, 2) + pow(now_c2_y, 2));

    now_v1_x = oval[i][0] * l1 + v.x;
    now_v1_y = oval[i][1] * l1 + v.y;
    now_v1_z = oval[i][2] * l1;

    now_v2_x = oval[i][0] * l2 + v.x;
    now_v2_y = oval[i][1] * l2 + v.y;
    now_v2_z = oval[i][2] * l2;

    if (x_ref * y_ref < 0) {
      vertices[vertex_index++] = x_ref * now_v1_x;
      vertices[vertex_index++] = y_ref * now_v1_y;
      vertices[vertex_index++] = now_v1_z;
    }

    vertices[vertex_index++] = x_ref * pre_v1_x;
    vertices[vertex_index++] = y_ref * pre_v1_y;
    vertices[vertex_index++] = pre_v1_z;

    if (x_ref * y_ref > 0) {
      vertices[vertex_index++] = x_ref * now_v1_x;
      vertices[vertex_index++] = y_ref * now_v1_y;
      vertices[vertex_index++] = now_v1_z;
    }

    vertices[vertex_index++] = x_ref * pre_v2_x;
    vertices[vertex_index++] = y_ref * pre_v2_y;
    vertices[vertex_index++] = pre_v2_z;

    if (x_ref * y_ref < 0) {
      tex_coords[tex_index++] = 0.5 + x_ref * (((now_c1_x + v.x)/ 2.0) - 0.5);
      tex_coords[tex_index++] = (1.5 - y_ref * (now_c1_y + v.y)) / 3.0;
    }

    tex_coords[tex_index++] = 0.5 + x_ref * ((pre_c1_x + v.x) / 2.0 - 0.5);
    tex_coords[tex_index++] = (1.5 - y_ref * (pre_c1_y + v.y)) / 3.0;

    if (x_ref * y_ref > 0) {
      tex_coords[tex_index++] = 0.5 + x_ref * (((now_c1_x + v.x)/ 2.0) - 0.5);
      tex_coords[tex_index++] = (1.5 - y_ref * (now_c1_y + v.y)) / 3.0;
    }

    tex_coords[tex_index++] = 0.5 + x_ref * ((pre_c2_x + v.x) / 2.0 - 0.5);
    tex_coords[tex_index++] = (1.5 - y_ref * (pre_c2_y + v.y)) / 3.0;

    colors[color_index++] = 255; colors[color_index++] = 255;
    colors[color_index++] = 255; colors[color_index++] = alpha;
    colors[color_index++] = 255; colors[color_index++] = 255;
    colors[color_index++] = 255; colors[color_index++] = alpha;
    colors[color_index++] = 255; colors[color_index++] = 255;
    colors[color_index++] = 255; colors[color_index++] = alpha;

    active_counts++;

    if ( now_v1_x != now_v2_x ) {
      if (x_ref * y_ref < 0) {
	vertices[vertex_index++] = x_ref * now_v1_x;
	vertices[vertex_index++] = y_ref * now_v1_y;
	vertices[vertex_index++] = now_v1_z;
      }

      vertices[vertex_index++] = x_ref * pre_v2_x;
      vertices[vertex_index++] = y_ref * pre_v2_y;
      vertices[vertex_index++] = pre_v2_z;

      if (x_ref * y_ref > 0) {
	vertices[vertex_index++] = x_ref * now_v1_x;
	vertices[vertex_index++] = y_ref * now_v1_y;
	vertices[vertex_index++] = now_v1_z;
      }

      vertices[vertex_index++] = x_ref * now_v2_x;
      vertices[vertex_index++] = y_ref * now_v2_y;
      vertices[vertex_index++] = now_v2_z;

      if (x_ref * y_ref < 0) {
	tex_coords[tex_index++] = 0.5 + x_ref * ((now_c1_x + v.x)/ 2.0 - 0.5);
	tex_coords[tex_index++] = (1.5 - y_ref * (now_c1_y + v.y)) / 3.0;
      }

      tex_coords[tex_index++] = 0.5 + x_ref * ((pre_c2_x + v.x) / 2.0 - 0.5);
      tex_coords[tex_index++] = (1.5 - y_ref * (pre_c2_y + v.y)) / 3.0;

      if (x_ref * y_ref > 0) {
	tex_coords[tex_index++] = 0.5 + x_ref * ((now_c1_x + v.x)/ 2.0 - 0.5);
	tex_coords[tex_index++] = (1.5 - y_ref * (now_c1_y + v.y)) / 3.0;
      }
      tex_coords[tex_index++] = 0.5 + x_ref * ((now_c2_x + v.x) / 2.0 - 0.5);
      tex_coords[tex_index++] = (1.5 - y_ref * (now_c2_y + v.y)) / 3.0;

      colors[color_index++] = 255; colors[color_index++] = 255;
      colors[color_index++] = 255; colors[color_index++] = alpha;
      colors[color_index++] = 255; colors[color_index++] = 255;
      colors[color_index++] = 255; colors[color_index++] = alpha;
      colors[color_index++] = 255; colors[color_index++] = 255;
      colors[color_index++] = 255; colors[color_index++] = alpha;

      active_counts++;
    }

    pre_v1_x = now_v1_x;
    pre_v1_y = now_v1_y;
    pre_v1_z = now_v1_z;

    pre_c1_x = now_c1_x;
    pre_c1_y = now_c1_y;

    pre_v2_x = now_v2_x;
    pre_v2_y = now_v2_y;
    pre_v2_z = now_v2_z;

    pre_c2_x = now_c2_x;
    pre_c2_y = now_c2_y;

  }

  float a = end_tan;
  float b = -a * v.x + v.y;

  float cross_a = -1 / end_tan;
  float cross_b = -cross_a * 2.0 + 1.5;

  float cross_x = (b - cross_b) / (cross_a - a);
  float cross_y = cross_a * cross_x + cross_b;

  float cross_l = sqrt(pow(cross_x - 2.0 , 2) + pow(cross_y - 1.5, 2));

  float t = (cross_y - 1.5) / ((a * 2.0 + b) - 1.5);

  CGPoint v_1 = CGPointMake(cross_l * sqrt(1.0 / (pow(1.0/start_tan, 2) + 1.0)), (cross_l * sqrt(1.0 - (1.0 / (pow(1.0/start_tan, 2) + 1.0)))));

  if (x_ref * y_ref < 0) {
    vertices[vertex_index++] = x_ref * pre_v1_x;
    vertices[vertex_index++] = y_ref * pre_v1_y;
    vertices[vertex_index++] = pre_v1_z;
  }

  vertices[vertex_index++] = x_ref * pre_v2_x;
  vertices[vertex_index++] = y_ref * pre_v2_y;
  vertices[vertex_index++] = pre_v2_z;

  if (x_ref * y_ref > 0) {
    vertices[vertex_index++] = x_ref * pre_v1_x;
    vertices[vertex_index++] = y_ref * pre_v1_y;
    vertices[vertex_index++] = pre_v1_z;
  }

  vertices[vertex_index++] = x_ref * (((1 - t) * pre_v1_x + t * pre_v2_x) - v_1.x);
  vertices[vertex_index++] = y_ref*(((1 - t) * pre_v1_y + t * pre_v2_y) - v_1.y);
  vertices[vertex_index++] = pre_v1_z;

  if (x_ref * y_ref < 0) {
    tex_coords[tex_index++] = 0.5 + x_ref * ((pre_c1_x + v.x) / 2.0 - 0.5);
    tex_coords[tex_index++] = (1.5 - y_ref * (pre_c1_y + v.y)) / 3.0;
  }

  tex_coords[tex_index++] = 0.5 + x_ref * ((pre_c2_x + v.x) / 2.0 - 0.5);
  tex_coords[tex_index++] = (1.5 - y_ref * (pre_c2_y + v.y)) / 3.0;

  if (x_ref * y_ref > 0) {
    tex_coords[tex_index++] = 0.5 + x_ref * ((pre_c1_x + v.x) / 2.0 - 0.5);
    tex_coords[tex_index++] = (1.5 - y_ref * (pre_c1_y + v.y)) / 3.0;
  }

  tex_coords[tex_index++] = 0.5 + x_ref * 0.5;
  tex_coords[tex_index++] = 0.5 - y_ref * 0.5;

  colors[color_index++] = 255; colors[color_index++] = 255;
  colors[color_index++] = 255; colors[color_index++] = alpha;
  colors[color_index++] = 255; colors[color_index++] = 255;
  colors[color_index++] = 255; colors[color_index++] = alpha;
  colors[color_index++] = 255; colors[color_index++] = 255;
  colors[color_index++] = 255; colors[color_index++] = alpha;

  active_counts++;

  if ( a * 2.0 + b < -1.5 ) {
    CGPoint norm_vec = CGPointMake((((1 - t) * pre_v1_x + t * pre_v2_x) - v_1.x) - pre_v1_x, (((1 - t) * pre_v1_y + t * pre_v2_y) - v_1.y) - pre_v1_y);
    norm_vec = vecDivide(norm_vec, vecNorm(norm_vec));
    CGPoint new_vec = vecMul(norm_vec, (2.0 - (-1.5 - b) / a));

    if (x_ref * y_ref < 0) {
      vertices[vertex_index++] = x_ref * (((1 - t) * pre_v1_x + t * pre_v2_x) - v_1.x);
      vertices[vertex_index++] = y_ref * (((1 - t) * pre_v1_y + t * pre_v2_y) - v_1.y);
      vertices[vertex_index++] = pre_v1_z;
    }

    vertices[vertex_index++] = x_ref * pre_v2_x;
    vertices[vertex_index++] = y_ref * pre_v2_y;
    vertices[vertex_index++] = pre_v2_z;

    if (x_ref * y_ref > 0) {
      vertices[vertex_index++] = x_ref * (((1 - t) * pre_v1_x + t * pre_v2_x) - v_1.x);
      vertices[vertex_index++] = y_ref * (((1 - t) * pre_v1_y + t * pre_v2_y) - v_1.y);
      vertices[vertex_index++] = pre_v1_z;
    }

    vertices[vertex_index++] = x_ref * (new_vec.x + pre_v2_x);
    vertices[vertex_index++] = y_ref * (new_vec.y + pre_v2_y);
    vertices[vertex_index++] = pre_v2_z;

    if (x_ref * y_ref < 0) {
      tex_coords[tex_index++] = 0.5 + x_ref * 0.5;
      tex_coords[tex_index++] = 0.5 - y_ref * 0.5;
    }

    tex_coords[tex_index++] = 0.5 + x_ref * ((pre_c2_x + v.x) / 2.0 - 0.5);
    tex_coords[tex_index++] = (1.5 - y_ref * (pre_c2_y + v.y)) / 3.0;

    if (x_ref * y_ref > 0) {
      tex_coords[tex_index++] = 0.5 + x_ref * 0.5;
      tex_coords[tex_index++] = 0.5 - y_ref * 0.5;
    }

    tex_coords[tex_index++] = 0.5 + x_ref * 0.5;
    tex_coords[tex_index++] = 0.5 + y_ref * 0.5;

    colors[color_index++] = 255; colors[color_index++] = 255;
    colors[color_index++] = 255; colors[color_index++] = alpha;
    colors[color_index++] = 255; colors[color_index++] = 255;
    colors[color_index++] = 255; colors[color_index++] = alpha;
    colors[color_index++] = 255; colors[color_index++] = 255;
    colors[color_index++] = 255; colors[color_index++] = alpha;

    active_counts++;
  }

  norms = (GLfloat*)[self getNormVectorsFromVertices:vertices Num:3 * active_counts];

  int tex_page;
  if ( x_ref > 0 ) {
    tex_page = 1;
  } else {
    tex_page = 0;
  }

  glEnable(GL_CULL_FACE); 
  for (int i = 0; i < 2; i++ ) {
    if ( i == 0 ) {
      glCullFace(GL_FRONT);
      // glFrontFace(GL_CW);
    } else {
      glCullFace(GL_BACK);
      // glFrontFace(GL_CCW);
    }

    if ( x_ref > 0 ) {
      if ( i == 0 ) tex_page = 3;
      else  tex_page = 4;
    } else {
      if ( i == 0 ) tex_page = 2;
      else  tex_page = 1;
    }

    // POINT
    glEnable(GL_TEXTURE_2D); // テクスチャ機能を有効にする
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
    glEnableClientState(GL_COLOR_ARRAY);

    glNormalPointer(GL_FLOAT, 0, norms);
    glEnableClientState(GL_NORMAL_ARRAY);

    glTexCoordPointer(2, GL_FLOAT, 0, tex_coords);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);

    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);

    glBindTexture(GL_TEXTURE_2D, texture[tex_page]);

    glDrawArrays(GL_TRIANGLES, 0, 3 * active_counts);
  }

  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_VERTEX_ARRAY);

  glDisable(GL_TEXTURE_2D); // テクスチャ機能を有効にする
}

-(GLfloat *) getNormVectorsFromVertices:(GLfloat*)vertices Num:(int)n {
  GLfloat norms[9 * n];
  GLfloat ax, ay, az, bx, by, bz;

  for (int i = 0; i < 9 * n; i += 9) {
    bx = vertices[i + 3] - vertices[i];
    by = vertices[i + 4] - vertices[i + 1];
    bz = vertices[i + 5] - vertices[i + 2];

    ax = vertices[i + 6] - vertices[i];
    ay = vertices[i + 7] - vertices[i + 1];
    az = vertices[i + 8] - vertices[i + 2];

    norms[i] = ((ay * bz) - (by * az));
    norms[i + 1] = ((ax * bz) - (bx * az));
    norms[i + 2] = ((ax * by) - (bx * ay));

    norms[i + 3] = norms[i];
    norms[i + 4] = norms[i + 1];
    norms[i + 5] = norms[i + 2];

    norms[i + 6] = norms[i];
    norms[i + 7] = norms[i + 1];
    norms[i + 8] = norms[i + 2];
  }

  return norms;
}

-(void) drawLackedPageWithXLine:(float)x xRef:(int)x_ref yRef:(int)y_ref {
  GLfloat vertices[] = {
    0.0f, 1.5f, 0,
    0.0f, -1.5f, 0,
    x_ref * x, 1.5f, 0,

    x_ref * x, 1.5f, 0,
    0.0f, -1.5f, 0,
    x_ref * x, -1.5f, 0,
  };

  if (x_ref > 0) {
    GLfloat tmp;
    for (int i = 0; i < 2 * 9; i+=9) {
      for (int j = 0; j < 3; j++) {
	tmp = vertices[i+j];
	vertices[i+j] = vertices[i+j+3];
	vertices[i+j+3] = tmp;
      }
    }
  }

  // GLfloat* norms = [self getNormVectorsFromVertices:vertices Num:2];
  GLfloat norms[] = {
    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,

    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,
  };


  [self drawLackedPageWidthThreeTriangels:vertices Norms:norms Xref:x_ref];
}
-(void) drawLackedPageWithVector:(CGPoint)v A:(float)a B:(float)b xRef:(int)x_ref yRef:(int)y_ref {
  int cross_type;

  a *= y_ref * x_ref;
  b *= y_ref;

  if ( (1.5f * y_ref - b) / a < 2.0 ) cross_type = 2;
  else cross_type = 1;

  if ( cross_type == 1 ) {
    GLfloat vertices[] = {
      0.0f, 1.5f, 0,
      0.0f, -1.5f, 0,
      (1.5f - b) / a, 1.5f, 0,

      (1.5f - b) / a, 1.5f, 0,
      0.0f, -1.5f, 0,
      2.0f, a * 2.0f + b, 0,

      2.0f, a * 2.0f + b, 0,
      0.0f, -1.5f, 0,
      2.0f, -1.5f, 0,
    };

    if (x_ref > 0) {
      GLfloat tmp;
      for (int i = 0; i < 3 * 9; i+=9) {
	for (int j = 0; j < 3; j++) {
	  tmp = vertices[i+j];
	  vertices[i+j] = vertices[i+j+3];
	  vertices[i+j+3] = tmp;
	}
      }
    }

    GLfloat norms[] = {
      0.0, 0.0, 1.0,
      0.0, 0.0, 1.0,
      0.0, 0.0, 1.0,

      0.0, 0.0, 1.0,
      0.0, 0.0, 1.0,
      0.0, 0.0, 1.0,

      0.0, 0.0, 1.0,
      0.0, 0.0, 1.0,
      0.0, 0.0, 1.0,
    };

    [self drawLackedPageWidthThreeTriangels:vertices Norms:norms Xref:x_ref];
  } else if ( cross_type == 2 ) {
    GLfloat vertices[] = {
      0.0f, 1.5f, 0,
      0.0f, -1.5f, 0,
      (-1.5f - b) / a, -1.5f, 0,

      0.0f, 1.5f, 0,
      (-1.5f - b) / a, -1.5f, 0,
      (1.5f - b) / a, 1.5f, 0
    };

    if (x_ref > 0) {
      GLfloat tmp;
      for (int i = 0; i < 2 * 9; i+=9) {
	for (int j = 0; j < 3; j++) {
	  tmp = vertices[i+j];
	  vertices[i+j] = vertices[i+j+3];
	  vertices[i+j+3] = tmp;
	}
      }
    }

    GLfloat* norms = (GLfloat*)[self getNormVectorsFromVertices:vertices Num:2];

    [self drawLackedPageWidthTwoTriangels:vertices Norms:norms Xref:x_ref];
  }
}

-(void) drawLackedPageWidthTwoTriangels:(GLfloat *)vertices Norms:(GLfloat *)norms Xref:(int)x_ref {
  for (int i = 0 ; i < 18; i++ ) {
    float f = norms[i];
  }
  GLubyte colors[] = {
    255, 255, 255, 255,
    255, 255, 255, 255,
    255, 255, 255, 255,

    255, 255, 255, 255,
    255, 255, 255, 255,
    255, 255, 255, 255
  };

  GLfloat texCoords[] = {
    (vertices[0] / 2.0), ((1.5 - vertices[1]) / 3.0),
    (vertices[3] / 2.0), ((1.5 - vertices[4]) / 3.0),
    (vertices[6] / 2.0), ((1.5 - vertices[7]) / 3.0),

    vertices[9] / 2.0, (1.5 - vertices[10]) / 3.0,
    vertices[12] / 2.0, (1.5 - vertices[13]) / 3.0,
    vertices[15] / 2.0, (1.5 - vertices[16]) / 3.0,
  };

  /*
     const GLubyte cubeFaces[] = {
     1, 2, 0, 3
     }*/

  int tex_page;
  if ( x_ref > 0 ) {
    tex_page = 1;
  } else {
    tex_page = 0;
  }

  glEnable(GL_CULL_FACE); 
  for (int i = 0; i < 2; i++ ) {
    if ( i == 0 ) {
      glCullFace(GL_FRONT);
      // glFrontFace(GL_CW);
    } else {
      glCullFace(GL_BACK);
      // glFrontFace(GL_CCW);
    }

    if ( x_ref > 0 ) {
      if ( i == 0 ) tex_page = 3;
      else  tex_page = 4;
    } else {
      if ( i == 0 ) tex_page = 2;
      else  tex_page = 1;
    }


    glEnable(GL_TEXTURE_2D); // テクスチャ機能を有効にする

    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
    glEnableClientState(GL_COLOR_ARRAY);

    glNormalPointer(GL_FLOAT, 0, norms);
    glEnableClientState(GL_NORMAL_ARRAY);

    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);

    glBindTexture(GL_TEXTURE_2D, texture[tex_page]);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

    glDrawArrays(GL_TRIANGLES, 0, 6);
  }

  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_VERTEX_ARRAY);
  glDisable(GL_TEXTURE_2D); // テクスチャ機能を有効にする
}

-(void) drawLackedPageWidthThreeTriangels:(GLfloat *)vertices Norms:(GLfloat*)norms Xref:(int)x_ref {
  GLubyte colors[] = {
    255, 255, 255, 255,
    255, 255, 255, 255,
    255, 255, 255, 255,

    255, 255, 255, 255,
    255, 255, 255, 255,
    255, 255, 255, 255,

    255, 255, 255, 255,
    255, 255, 255, 255,
    255, 255, 255, 255
  };

  GLfloat texCoords[] = {
    (vertices[0] / 2.0), ((1.5 - vertices[1]) / 3.0),
    (vertices[3] / 2.0), ((1.5 - vertices[4]) / 3.0),
    (vertices[6] / 2.0), ((1.5 - vertices[7]) / 3.0),

    vertices[9] / 2.0, (1.5 - vertices[10]) / 3.0,
    vertices[12] / 2.0, (1.5 - vertices[13]) / 3.0,
    vertices[15] / 2.0, (1.5 - vertices[16]) / 3.0,

    vertices[18] / 2.0, (1.5 - vertices[19]) / 3.0,
    vertices[21] / 2.0, (1.5 - vertices[22]) / 3.0,
    vertices[24] / 2.0, (1.5 - vertices[25]) / 3.0,
  };

  /*
     const GLubyte cubeFaces[] = {
     1, 2, 0, 3
     }*/

  int tex_page;
  if ( x_ref > 0 ) {
    tex_page = 1;
  } else {
    tex_page = 0;
  }

  glEnable(GL_CULL_FACE); 
  for (int i = 0; i < 2; i++ ) {
    if ( i == 0 ) {
      glCullFace(GL_FRONT);
      // glFrontFace(GL_CW);
    } else {
      glCullFace(GL_BACK);
      // glFrontFace(GL_CCW);
    }

    if ( x_ref > 0 ) {
      if ( i == 0 ) tex_page = 3;
      else tex_page = 4;
    } else {
      if ( i == 0 ) tex_page = 2;
      else  tex_page = 1;
    }

    glEnable(GL_TEXTURE_2D); // テクスチャ機能を有効にする

    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
    glEnableClientState(GL_COLOR_ARRAY);

    glNormalPointer(GL_FLOAT, 0, norms);
    glEnableClientState(GL_NORMAL_ARRAY);

    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);

    glBindTexture(GL_TEXTURE_2D, texture[tex_page]);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

    glDrawArrays(GL_TRIANGLES, 0, 9);
  }

  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_VERTEX_ARRAY);
  glDisable(GL_TEXTURE_2D); // テクスチャ機能を有効にする
}

- (void) curlPageWithVector:(CGPoint)point {
  pre_vector = vector;
  vector = CGPointMake(2.0f * point.x / (WINDOW_W / 2), -1.5 * point.y / (WINDOW_H / 2));

  [self setPrimaryPoints];
  [self drawFrame];

  if ( vector.x == 0.0 ) {
    if ( pre_vector.x < 0.0 ) [self returnRightPage];
    else [self returnLeftPage];
  } else if (pre_vector.x * vector.x < 0 ) {
    // [self loadTextures];
    if ( pre_vector.x < 0 ) {
      [self returnRightPage];
      [self changeLeftPage];
    } else {
      [self returnLeftPage];
      [self changeRightPage];
    }
  } else if ( pre_vector.x == 0.0 ) {
    if ( vector.x < 0.0 ) {
      [self changeRightPage];
    } else {
      [self changeLeftPage];
    }
  }
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
// Return YES for supported orientations.
return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];

  // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}


- (void)dealloc {
  [super dealloc];
  [loader dealloc];
  [page_curl_view dealloc];
}

/* TouchesDelegate */

- (void)view:(UIView*)view touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  for (UITouch *touch in touches) {
    startPoint = [touch locationInView:self.view];
    break;
  }
}

- (void)view:(UIView*)view touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
  for (UITouch *touch in touches) {
    endPoint = [touch locationInView:self.view];
    [self curlPageWithVector:CGPointMake(endPoint.x - startPoint.x, endPoint.y - startPoint.y)];
    break;
  }
}

- (void)view:(UIView*)view touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
  for (UITouch *touch in touches) {
    endPoint = [touch locationInView:self.view];
    [self curlPageWithVector:CGPointMake(0.0, 0.0)];
    break;
  }
}

- (void)view:(UIView*)view touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
  for (UITouch *touch in touches) {
    [self curlPageWithVector:CGPointMake(0.0, 0.0)];
    break;
  }
}


@end
