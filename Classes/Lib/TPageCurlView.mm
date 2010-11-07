//
//  TPageCurlView.mm
//  BookViewer
//
//  Created by Karatsu Naoya on 10/10/19.
//  Copyright 2010 ajapax. All rights reserved.
//
//
#import <QuartzCore/QuartzCore.h>

#import "TPageCurlView.h"

@interface TPageCurlView (PrivateMethods)
- (void)createFramebuffer;
- (void)deleteFramebuffer;
@end

@implementation TPageCurlView

@dynamic context;

+ (Class)layerClass {
  return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code.
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;

    eaglLayer.opaque = TRUE;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
						     [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
      kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
      nil];

  }
  self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
  return self;
}

- (void)dealloc
{
  [self deleteFramebuffer];    
  [context release];

  [super dealloc];
}

- (EAGLContext *)context
{
  return context;
}

- (void)setContext:(EAGLContext *)newContext
{
  if (context != newContext)
  {
    [self deleteFramebuffer];

    [context release];
    context = [newContext retain];

    [EAGLContext setCurrentContext:nil];
  }
}

- (void)createFramebuffer
{
  NSLog(@"create frame buffer");
  if (context && !defaultFramebuffer)
  {
    [EAGLContext setCurrentContext:context];

    glGenFramebuffersOES(1, &defaultFramebuffer);
    glGenRenderbuffersOES(1, &colorRenderbuffer);

    glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);

    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer *)self.layer];
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &framebufferWidth); 
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &framebufferHeight); 

    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
      NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));

    // Create color render buffer and allocate backing store.
    glGenRenderbuffersOES(1, &depthRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
    glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, self.bounds.size.width, self.bounds.size.height);

    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
      NSLog(@"Failed to make complete depth render buffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    glEnable(GL_DEPTH_TEST);
  }
}

- (void)deleteFramebuffer
{
  if (context)
  {
    [EAGLContext setCurrentContext:context];

    if (defaultFramebuffer)
    {
      glDeleteFramebuffers(1, &defaultFramebuffer);
      defaultFramebuffer = 0;
    }

    if (colorRenderbuffer)
    {
      glDeleteRenderbuffers(1, &colorRenderbuffer);
      colorRenderbuffer = 0;
    }
  }
}

- (void)setFramebuffer
{
  if (context)
  {
    [EAGLContext setCurrentContext:context];

    if (!defaultFramebuffer)
      [self createFramebuffer];

    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);

    glViewport(0, 0, framebufferWidth, framebufferHeight);
  }
}

- (BOOL)presentFramebuffer
{
  BOOL success = FALSE;

  if (context)
  {
    [EAGLContext setCurrentContext:context];

    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);

    success = [context presentRenderbuffer:GL_RENDERBUFFER_OES];
  }

  return success;
}

- (void)layoutSubviews
{
  // The framebuffer will be re-created at the beginning of the next setFramebuffer method call.
  [self deleteFramebuffer];
}

@end
