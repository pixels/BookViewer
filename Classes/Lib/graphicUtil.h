/*
 *  graphicUtil.h
 *  BombVoyage
 *
 *  Created by Karatsu Naoya on 10/10/19.
 *  Copyright 2010 ajapax. All rights reserved.
 *
 */

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

void drawSquare(float x, float y, float width, int red, int green, int blue, int alpha);

void drawTriangle(float x1, float y1, float x2, float y2, int red, int green, int blue, int alpha);

GLuint loadTexture(NSString* fileName);

GLuint loadTextureFromUIView(UIView* target_view);

void drawTexture(float x, float y, float width, float height,
    GLuint texture, int red, int green, int blue, int alpha);

void drawTexture2(float x, float y, float width, float height,
    GLuint texture, float u, float v, float tex_width,
    float tex_height, int red, int green, int blue, int alpha);

void printOpenGLError();
