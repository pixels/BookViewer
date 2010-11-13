//
//  TPageHolder.h
//  BookViewer
//
//  Created by Karatsu Naoya on 10/11/02.
//  Copyright 2010 ajapax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPageLoader.h"

enum {
  DIRECTION_LEFT,
  DIRECTION_RIGHT
};

@interface TPageHolder : NSObject {
  TPageLoader* loader;
  NSMutableDictionary* page_dict;
  int page_num;
  int max_page_num;
  int direction;
}

-(BOOL) hasLeft:(int)num;
-(BOOL) hasRight:(int)num;

@end
