    //
//  TBookViewCtrl.mm
//  BookViewer
//
//  Created by Karatsu Naoya on 10/11/02.
//  Copyright 2010 ajapax. All rights reserved.
//

#import "TBookViewCtrl.h"
#import "graphicUtil.h"

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
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor redColor]];
    self.view.frame = CGRectMake(0, 0, WINDOW_W, WINDOW_H);

    loader = [[TPageLoader alloc] init];
    pre_vector = CGPointMake(0, 0);
    vector = CGPointMake(0, 0);
    base_point = CGPointMake(0, 0);
    pivot_point = CGPointMake(0, 0);

    for (int i = 0; i < 2; i++) {
      main_pages[i] = [loader getImageViewWithNumber:i];
      main_pages[i].frame = CGRectMake(WINDOW_W / 2 * i, 0, WINDOW_W / 2, WINDOW_H);
      //[self.view addSubview:main_pages[i]];
    }

    [self initPageCurlView];

    [self loadTexture];

    [self drawFrame];
}

-(void) loadTexture {
  for ( int i = 0; i < 2; i++ ) texture[i] = loadTextureFromUIView(main_pages[i]);
}

-(void) initPageCurlView {
  page_curl_view = [[TPageCurlView alloc] initWithFrame:CGRectMake(0, 0, WINDOW_W, WINDOW_H)];
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
  if (vector.y < 0 ) {
    pivot_point = CGPointMake(0.0f, 1.5f);
    if (vector.x < 0 ) {
      base_point = CGPointMake(2.0f, 1.5f);
    } else {
      base_point = CGPointMake(-2.0f, 1.5f);
    }
  } else {
    pivot_point = CGPointMake(0.0f, -1.5f);
    if (vector.x < 0 ) {
      base_point = CGPointMake(2.0f, -1.5f);
    } else {
      base_point = CGPointMake(-2.0f, -1.5f);
    }
  }
}

- (void)drawFrame
{
  [(TPageCurlView *)page_curl_view setFramebuffer];

  const GLfloat lightPos[] = {
    2.0f, 1.0f, 1.0f, 0.0f
  };

  const GLfloat lightColor[] = {
    1.0f, 1.0f, 1.0f, 1.0f
  };

  const GLfloat lightAmbient[] = {
    0.0f, 0.0f, 0.0f, 1.0f
  };

  const GLfloat diffuse[] = {
    0.7f, 0.7f, 0.7f, 1.0f
  };

  const GLfloat ambient[] = {
    0.3f, 0.3f, 0.3f, 1.0f
  };

  glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrthof(-2.0f, 2.0f, -1.5f, 1.5f, -1.5f, 1.5f);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glClearColor(1.0f, 0.0f, 0.0f, 0.5f);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  [self drawLeftPage];
  [self drawRightPage];

  // ライトを当ててみる
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glLightfv(GL_LIGHT0, GL_POSITION, lightPos);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, lightColor);
  glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, diffuse);
  glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, ambient);
  glDisable(GL_LIGHT0);
  glDisable(GL_LIGHTING);

  // drawTexture(1.0, 1.0, 0.5, 0.5, texture[0], 255, 255, 255, 255);

  if([(TPageCurlView *)page_curl_view presentFramebuffer]) {
    NSLog(@"success to present");
  }
}

-(void) drawLeftPage {
  [self drawLeftFullPage];
}

- (void) drawRightPage {
  if ( vector.y >= 0 ) {
    [self drawRightFullPage];
  } else {
    [self drawRightCurlPage];
  }
}

-(void) drawLeftFullPage {
  const GLfloat verticesLeft[] = {
    -2.0f, 1.5f, 0.0f,
    -2.0f, -1.5f, 0.0f,
    0.0f, -1.5f, 0.0f,

    -2.0f, 1.5f, 0.0f,
    0.0f, -1.5f, 0.0f,
    0.0f, 1.5f, 0.0f
  };

  const GLubyte colors[] = {
    255, 255, 255, 255,
    255, 255, 255, 255,
    255, 255, 255, 255,

    255, 255, 255, 255,
    255, 255, 255, 255,
    255, 255, 255, 255
  };

  const GLfloat texCoords[] = {
    0.0, 0.0,
    0.0, 0.0+1.0,
    0.0+1.0, 0.0+1.0,

    0.0, 0.0,
    0.0+1.0, 0.0+1.0,
    0.0+1.0, 0.0
  };

  /*
  const GLubyte cubeFaces[] = {
    1, 2, 0, 3
  }*/

  glEnable(GL_DEPTH_TEST);
  glEnable(GL_TEXTURE_2D); // テクスチャ機能を有効にする

  glVertexPointer(3, GL_FLOAT, 0, verticesLeft);
  glEnableClientState(GL_VERTEX_ARRAY);
  glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
  glEnableClientState(GL_COLOR_ARRAY);

  glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);

  glBindTexture(GL_TEXTURE_2D, texture[0]);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

  glDrawArrays(GL_TRIANGLES, 0, 6);

  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_VERTEX_ARRAY);
  glDisable(GL_TEXTURE_2D); // テクスチャ機能を有効にする
  glDisable(GL_DEPTH_TEST);
}

-(void) drawRightFullPage {
  const GLfloat verticesRight[] = {
    0.0f, 1.5f, 0.0f,
    0.0f, -1.5f, 0.0f,
    2.0f, -1.5f, 0.0f,

    0.0f, 1.5f, 0.0f,
    2.0f, -1.5f, 0.0f,
    2.0f, 1.5f, 0.0f
  };

  const GLubyte colors[] = {
    255, 255, 255, 255,
    255, 255, 255, 255,
    255, 255, 255, 255,

    255, 255, 255, 255,
    255, 255, 255, 255,
    255, 255, 255, 255
  };

  const GLfloat texCoords[] = {
    0.0, 0.0,
    0.0, 0.0+1.0,
    0.0+1.0, 0.0+1.0,

    0.0, 0.0,
    0.0+1.0, 0.0+1.0,
    0.0+1.0, 0.0
  };

  /*
  const GLubyte cubeFaces[] = {
    1, 2, 0, 3
  }*/

  glEnable(GL_DEPTH_TEST);
  glEnable(GL_TEXTURE_2D); // テクスチャ機能を有効にする

  glVertexPointer(3, GL_FLOAT, 0, verticesRight);
  glEnableClientState(GL_VERTEX_ARRAY);
  glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
  glEnableClientState(GL_COLOR_ARRAY);

  glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);

  glBindTexture(GL_TEXTURE_2D, texture[1]);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

  glDrawArrays(GL_TRIANGLES, 0, 6);
}

-(void) drawRightCurlPage {
  float ref_y;
  float a = - 1.0f * vector.x / vector.y;
  if ( vector.y < 0 ) {
    ref_y = 1.0f;
  } else {
    ref_y = -1.0f;
  }
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
  float t;
  if ( vector.y > 0 ) {
    t = -1.0f;
  } else {
    t = 1.0f;
  }
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
  NSLog(@"%f", far_x);
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

[self drawLackedRightPageWithVector:vector A:a2 B:b2];

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
  NSLog(@"before delta_rad : %f", fabs(delta_rad));
  float main_rad = atan(a2);

  [self drawCurlingRightPageWithVector:CGPointMake(far_x, far_y) start:main_rad delta:delta_rad startTan:a2 endTan:a3];
  /*
  for (int i = 0; i < PAGE_CURL_SPLIT; i++ ) {
    float mini_rad_2 = delta_rad * (i + 1) / 40.0;

    float tmp_a = tan(mini_rad_2 + main_rad);
    float tmp_b = -tmp_a * far_x + far_y;
    for (int j = 0; j < 40; j++ ) {
      float x3 = (float)(j - 20)/ 10;
      float y3 = tmp_a * x3 + tmp_b;
#ifdef DEBUG
      drawSquare(x3, y3, 0.01, 0, 0, 255 * (i % 2), 100);
#endif
    }
  }*/
}

-(void) drawCurlingRightPageWithVector:(CGPoint)v start:(float)start_rad delta:(float)delta_rad startTan:(float)start_tan endTan:(float)end_tan {
  // 円錐の底面(高さrとした場合の)を求める
  float r = 1;
  NSLog(@"delta_rad : %f", fabs(delta_rad));
  float theta1 = M_PI / (float)PAGE_CURL_SPLIT;
  NSLog(@"theta1 : %f", theta1);
  float mini_rad = fabs(delta_rad) / 40.0;
  float tmp = pow(tan(mini_rad / 2), 2);
  float inside_l = sqrt( tmp / ( pow(tan(theta1 / 2), 2) - tmp ));
  NSLog(@"inside_l : %f", inside_l);
  float theta2 = atan(inside_l);
  float radius = inside_l / cos(theta1 / 2);
  NSLog(@"radius : %f", radius);

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
  GLubyte colors[6 * 4 * PAGE_CURL_SPLIT];
  GLfloat tex_coords[6 * 4 * PAGE_CURL_SPLIT];

  int active_counts = 0;

  int vertex_index = 0;
  int color_index = 0;
  int tex_index = 0;

  float tmp_a = start_tan;
  float tmp_b = -tmp_a * v.x + v.y;

  if ( v.y == 1.5f ) {
    float pre_v_x;
    float pre_v_y;
    if ( tmp_a * 2.0 + tmp_b > -1.5 ) {
      pre_v_x = 2.0;
      pre_v_y = tmp_a * 2.0 + tmp_b;
    } else {
      pre_v_x = ((-1.5 - tmp_b) / tmp_a);
      pre_v_y = -1.5;
    }

    float pre_c_x;
    float pre_c_y;
    if ( tmp_a * 2.0 + tmp_b > -1.5 ) {
      pre_c_x = 2.0 - v.x;
      pre_c_y = tmp_a * 2.0 + tmp_b - v.y;
    } else {
      pre_c_x = ((-1.5 - tmp_b) / tmp_a) - v.x;
      pre_c_y = -1.5 - v.y;
    }
    float pre_v_z = 0.0;

    float l;
    int alpha = 255;
    for (int i = 0; i < PAGE_CURL_SPLIT; i++ ) {
      tmp_a = tan((mini_rad * (i + 1)) + start_rad);
      tmp_b = -tmp_a * v.x + v.y;

      vertices[vertex_index++] = v.x;
      vertices[vertex_index++] = v.y;
      vertices[vertex_index++] = 0.0;

      vertices[vertex_index++] = pre_v_x;
      vertices[vertex_index++] = pre_v_y;
      vertices[vertex_index++] = pre_v_z;

      tex_coords[tex_index++] = 0.0;
      tex_coords[tex_index++] = 0.0;

      tex_coords[tex_index++] = (pre_c_x + v.x)/ 2.0;
      tex_coords[tex_index++] = (1.5 - (pre_c_y + v.y)) / 3.0;

      if ( tmp_a * 2.0 + tmp_b > -1.5) {
	pre_c_x = 2.0 - v.x;
	pre_c_y = tmp_a * 2.0 + tmp_b - v.y;
      } else {
	pre_c_x = ((-1.5 + tmp_b) / tmp_a) - v.x;
	pre_c_y = -1.5 - v.y;
      }

      tex_coords[tex_index++] = (pre_c_x + v.x) / 2.0;
      tex_coords[tex_index++] = (1.5 - (pre_c_y + v.y)) / 3.0;

      l = sqrt(pow(pre_c_x, 2) + pow(pre_c_y, 2));
      pre_v_x = oval[i][0] * l + v.x;
      pre_v_y = oval[i][1] * l + v.y;
      pre_v_z = oval[i][2] * l;

      vertices[vertex_index++] = pre_v_x;
      vertices[vertex_index++] = pre_v_y;
      vertices[vertex_index++] = pre_v_z;

      colors[color_index++] = 255; colors[color_index++] = 255;
      colors[color_index++] = 255; colors[color_index++] = alpha;
      colors[color_index++] = 255; colors[color_index++] = 255;
      colors[color_index++] = 255; colors[color_index++] = alpha;
      colors[color_index++] = 255; colors[color_index++] = 255;
      colors[color_index++] = 255; colors[color_index++] = alpha;

      active_counts++;
    }

    float a = end_tan;
    float b = -a * v.x + v.y;

    float cross_a = -1 / end_tan;
    float cross_b = -cross_a * 2.0 + 1.5;

    float cross_x = (b - cross_b) / (cross_a - a);
    float cross_y = cross_a * cross_x + cross_b;

    float cross_l = sqrt(pow(cross_x - 2.0 , 2) + pow(cross_y - 1.5, 2));

    float t = (cross_y - 1.5) / ((a * 2.0 + b) - 1.5);

    CGPoint v_1 = CGPointMake(cross_l * sqrt(1.0 / (pow(1.0/start_tan, 2) + 1.0)), cross_l * sqrt(1.0 - (1.0 / (pow(1.0/start_tan, 2) + 1.0))));

    vertices[vertex_index++] = v.x;
    vertices[vertex_index++] = v.y;
    vertices[vertex_index++] = 0.0;

    vertices[vertex_index++] = pre_v_x;
    vertices[vertex_index++] = pre_v_y;
    vertices[vertex_index++] = pre_v_z;

    vertices[vertex_index++] = ((1 - t) * v.x + t * pre_v_x) - v_1.x;
    vertices[vertex_index++] = ((1 - t) * v.y + t * pre_v_y) - v_1.y;
    vertices[vertex_index++] = pre_v_z;

    tex_coords[tex_index++] = 0.0;
    tex_coords[tex_index++] = 0.0;

    tex_coords[tex_index++] = (pre_c_x + v.x) / 2.0;
    tex_coords[tex_index++] = (1.5 - (pre_c_y + v.y)) / 3.0;

    tex_coords[tex_index++] = 1.0;
    tex_coords[tex_index++] = 0.0;

    colors[color_index++] = 255; colors[color_index++] = 255;
    colors[color_index++] = 255; colors[color_index++] = alpha;
    colors[color_index++] = 255; colors[color_index++] = 255;
    colors[color_index++] = 255; colors[color_index++] = alpha;
    colors[color_index++] = 255; colors[color_index++] = 255;
    colors[color_index++] = 255; colors[color_index++] = alpha;



    active_counts++;

  } else if ( v.y > 1.5f ) {
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
      now_c1_y = 1.5 - v.y;

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

      vertices[vertex_index++] = now_v1_x;
      vertices[vertex_index++] = now_v1_y;
      vertices[vertex_index++] = now_v1_z;

      vertices[vertex_index++] = pre_v1_x;
      vertices[vertex_index++] = pre_v1_y;
      vertices[vertex_index++] = pre_v1_z;

      vertices[vertex_index++] = pre_v2_x;
      vertices[vertex_index++] = pre_v2_y;
      vertices[vertex_index++] = pre_v2_z;

      tex_coords[tex_index++] = (now_c1_x + v.x)/ 2.0;
      tex_coords[tex_index++] = (1.5 - (now_c1_y + v.y)) / 3.0;

      tex_coords[tex_index++] = (pre_c1_x + v.x) / 2.0;
      tex_coords[tex_index++] = (1.5 - (pre_c1_y + v.y)) / 3.0;

      tex_coords[tex_index++] = (pre_c2_x + v.x) / 2.0;
      tex_coords[tex_index++] = (1.5 - (pre_c2_y + v.y)) / 3.0;

      colors[color_index++] = 255; colors[color_index++] = 255;
      colors[color_index++] = 255; colors[color_index++] = alpha;
      colors[color_index++] = 255; colors[color_index++] = 255;
      colors[color_index++] = 255; colors[color_index++] = alpha;
      colors[color_index++] = 255; colors[color_index++] = 255;
      colors[color_index++] = 255; colors[color_index++] = alpha;

      active_counts++;

      vertices[vertex_index++] = now_v1_x;
      vertices[vertex_index++] = now_v1_y;
      vertices[vertex_index++] = now_v1_z;

      vertices[vertex_index++] = pre_v2_x;
      vertices[vertex_index++] = pre_v2_y;
      vertices[vertex_index++] = pre_v2_z;

      now_v2_x = oval[i][0] * l2 + v.x;
      now_v2_y = oval[i][1] * l2 + v.y;
      now_v2_z = oval[i][2] * l2;

      vertices[vertex_index++] = now_v2_x;
      vertices[vertex_index++] = now_v2_y;
      vertices[vertex_index++] = now_v2_z;

      tex_coords[tex_index++] = (now_c1_x + v.x)/ 2.0;
      tex_coords[tex_index++] = (1.5 - (now_c1_y + v.y)) / 3.0;

      tex_coords[tex_index++] = (pre_c2_x + v.x) / 2.0;
      tex_coords[tex_index++] = (1.5 - (pre_c2_y + v.y)) / 3.0;

      tex_coords[tex_index++] = (now_c2_x + v.x) / 2.0;
      tex_coords[tex_index++] = (1.5 - (now_c2_y + v.y)) / 3.0;

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

    float a = end_tan;
    float b = -a * v.x + v.y;

    float cross_a = -1 / end_tan;
    float cross_b = -cross_a * 2.0 + 1.5;

    float cross_x = (b - cross_b) / (cross_a - a);
    float cross_y = cross_a * cross_x + cross_b;

    float cross_l = sqrt(pow(cross_x - 2.0 , 2) + pow(cross_y - 1.5, 2));

    float t = (cross_y - 1.5) / ((a * 2.0 + b) - 1.5);

    CGPoint v_1 = CGPointMake(cross_l * sqrt(1.0 / (pow(1.0/start_tan, 2) + 1.0)), cross_l * sqrt(1.0 - (1.0 / (pow(1.0/start_tan, 2) + 1.0))));

    vertices[vertex_index++] = pre_v1_x;
    vertices[vertex_index++] = pre_v1_y;
    vertices[vertex_index++] = pre_v1_z;

    vertices[vertex_index++] = pre_v2_x;
    vertices[vertex_index++] = pre_v2_y;
    vertices[vertex_index++] = pre_v2_z;

    vertices[vertex_index++] = ((1 - t) * pre_v1_x + t * pre_v2_x) - v_1.x;
    vertices[vertex_index++] = ((1 - t) * pre_v1_y + t * pre_v2_y) - v_1.y;
    // vertices[vertex_index++] = ((1 - t) * pre_v1_z + t * pre_v2_z);
    vertices[vertex_index++] = pre_v1_z;

    tex_coords[tex_index++] = (pre_c1_x + v.x) / 2.0;
    tex_coords[tex_index++] = (1.5 - (pre_c1_y + v.y)) / 3.0;

    tex_coords[tex_index++] = (pre_c2_x + v.x) / 2.0;
    tex_coords[tex_index++] = (1.5 - (pre_c2_y + v.y)) / 3.0;

    tex_coords[tex_index++] = 1.0;
    tex_coords[tex_index++] = 0.0;

    colors[color_index++] = 255; colors[color_index++] = 255;
    colors[color_index++] = 255; colors[color_index++] = alpha;
    colors[color_index++] = 255; colors[color_index++] = 255;
    colors[color_index++] = 255; colors[color_index++] = alpha;
    colors[color_index++] = 255; colors[color_index++] = 255;
    colors[color_index++] = 255; colors[color_index++] = alpha;


    active_counts++;


  }

  // POINT
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_TEXTURE_2D); // テクスチャ機能を有効にする
  glVertexPointer(3, GL_FLOAT, 0, vertices);
  glEnableClientState(GL_VERTEX_ARRAY);
  glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
  glEnableClientState(GL_COLOR_ARRAY);

  glTexCoordPointer(2, GL_FLOAT, 0, tex_coords);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);

  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);

  glBindTexture(GL_TEXTURE_2D, texture[1]);

  glDrawArrays(GL_TRIANGLES, 0, 3 * active_counts);

  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_VERTEX_ARRAY);

  glDisable(GL_TEXTURE_2D); // テクスチャ機能を有効にする
  glDisable(GL_DEPTH_TEST);
}

-(void) drawLackedRightPageWithVector:(CGPoint)v A:(float)a B:(float)b {
  int cross_type;
  if (v.y < 0) {
    if ( (-1.5f - b) / a < 2.0 ) cross_type = 2;
    else cross_type = 1;
  } else {
    if ( (1.5f - b) / a < 2.0 ) cross_type = 2;
    else cross_type = 3;
  }

  if ( cross_type == 1 ) {
    const GLfloat vertices[] = {
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

    [self drawLackedRightPageWidthThreeTriangels:vertices];
  } else if ( cross_type == 2 ) {
    const GLfloat vertices[] = {
      0.0f, 1.5f, 0,
      0.0f, -1.5f, 0,
      (-1.5f - b) / a, -1.5f, 0,

      0.0f, 1.5f, 0,
      (-1.5f - b) / a, -1.5f, 0,
      (1.5f - b) / a, 1.5f, 0
    };

    [self drawLackedRightPageWidthTwoTriangels:vertices];
  } else if ( cross_type == 3 ) {
    const GLfloat vertices[] = {
      0.0f, 1.5f, 0,
      0.0f, -1.5f, 0,
      (-1.5f - b) / a, -1.5f, 0,

      0.0f, 1.5f, 0,
      (-1.5f - b) / a, -1.5f, 0,
      2.0f, a * 2.0f + b, 0,

      0.0f, 1.5f, 0,
      2.0f, a * 2.0f + b, 0,
      2.0f, 1.5f, 0,
    };

    [self drawLackedRightPageWidthThreeTriangels:vertices];
  }
}

-(void) drawLackedRightPageWidthTwoTriangels:(GLfloat *)vertices {
  const GLubyte colors[] = {
    255, 255, 255, 255,
    255, 255, 255, 255,
    255, 255, 255, 255,

    255, 255, 255, 255,
    255, 255, 255, 255,
    255, 255, 255, 255
  };

  const GLfloat texCoords[] = {
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

  glEnable(GL_DEPTH_TEST);
  glEnable(GL_TEXTURE_2D); // テクスチャ機能を有効にする

  glVertexPointer(3, GL_FLOAT, 0, vertices);
  glEnableClientState(GL_VERTEX_ARRAY);
  glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
  glEnableClientState(GL_COLOR_ARRAY);

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
  glDisable(GL_DEPTH_TEST);
}

-(void) drawLackedRightPageWidthThreeTriangels:(GLfloat *)vertices {
  const GLubyte colors[] = {
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

  const GLfloat texCoords[] = {
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

  glEnable(GL_DEPTH_TEST);
  glEnable(GL_TEXTURE_2D); // テクスチャ機能を有効にする

  glVertexPointer(3, GL_FLOAT, 0, vertices);
  glEnableClientState(GL_VERTEX_ARRAY);
  glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
  glEnableClientState(GL_COLOR_ARRAY);

  glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);

  glBindTexture(GL_TEXTURE_2D, texture[1]);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

  glDrawArrays(GL_TRIANGLES, 0, 9);

  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_VERTEX_ARRAY);
  glDisable(GL_TEXTURE_2D); // テクスチャ機能を有効にする
  glDisable(GL_DEPTH_TEST);
}

- (void) curlPageWithVector:(CGPoint)point {
  NSLog(@"curl page %d %d", point.x, point.y);
  pre_vector = vector;
  vector = CGPointMake(2.0f * point.x / (WINDOW_W / 2), -1.5 * point.y / (WINDOW_H / 2));
  [self setPrimaryPoints];
  [self drawFrame];
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
}


@end
