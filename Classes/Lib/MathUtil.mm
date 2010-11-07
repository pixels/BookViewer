//
//  MathUtil.m
//  BookViewer
//
//  Created by Karatsu Naoya on 10/11/03.
//  Copyright 2010 ajapax. All rights reserved.
//

#import "MathUtil.h"

CGPoint vecMinus(CGPoint v1, CGPoint v2) {
  return CGPointMake(v1.x - v2.x, v1.y - v2.y);
}

CGPoint vecPlus(CGPoint v1, CGPoint v2) {
  return CGPointMake(v1.x + v2.x, v1.y + v2.y);
}

CGPoint vecMul(CGPoint v1, float a) {
  return CGPointMake(v1.x * a, v1.y * a);
}

CGPoint vecDivide(CGPoint v1, float a) {
  return CGPointMake(v1.x / a, v1.y / a);
}

float vecDistance(CGPoint v1, CGPoint v2) {
  return sqrt(pow(v1.x - v2.x, 2) + pow(v1.y - v2.y, 2));
}

float vecNorm(CGPoint v1) {
  return sqrt(pow(v1.x, 2) + pow(v1.y, 2));
}
