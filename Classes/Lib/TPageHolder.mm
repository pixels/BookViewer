//
//  TPageHolder.m
//  BookViewer
//
//  Created by Karatsu Naoya on 10/11/02.
//  Copyright 2010 ajapax. All rights reserved.
//

#import "TPageHolder.h"


@implementation TPageHolder

-(id) init {
  if ( self = [super init] ) {
    max_page_num = 20;
    page_num = 2;
    direction = DIRECTION_LEFT;

    loader = [[TPageLoader alloc] init];
    page_dict = [[NSMutableDictionary alloc] init];
    [self setAllPages];
  }
  return self;
}

-(void) setAllPages {
  NSNumber *number;
  UIImageView* image_view;
  for (int i = page_num - 2; i < page_num + 4; i++ ) {
    if ( [loader isExist:i] ) {
      number = [NSNumber numberWithInteger:i];
      image_view = [loader getImageViewWithNumber:i];
      if ( image_view ) {
	[page_dict setObject:image_view forKey:number];
	[image_view release];
      }
    }
  }
}

-(void) goToRight {
  if ( direction == DIRECTION_LEFT ) {
    page_num -= 2;
  } else {
    page_num += 2;
  }
  [self arrangeDictionary];
  NSLog(@"page number : %d", page_num);
}

-(void) goToLeft {
  if ( direction == DIRECTION_LEFT ) {
    page_num += 2;
  } else {
    page_num -= 2;
  }
  [self arrangeDictionary];
  NSLog(@"page number : %d", page_num);
}

-(UIImageView*) getRightPage:(int)num {
   NSNumber *number;
  if ( direction == DIRECTION_LEFT ) {
    number = [NSNumber numberWithInteger:page_num - num];
  } else {
    number = [NSNumber numberWithInteger:page_num + num + 1];
  }
  return [page_dict objectForKey:number];
}

-(UIImageView*) getLeftPage:(int)num {
   NSNumber *number;
  if ( direction == DIRECTION_LEFT ) {
    number = [NSNumber numberWithInteger:page_num + num + 1];
  } else {
    number = [NSNumber numberWithInteger:page_num - num];
  }
  return [page_dict objectForKey:number];
}

-(BOOL) hasLeft:(int)num {
  if ( direction == DIRECTION_LEFT ) {
    return [loader isExist:page_num+num+1];
  } else {
    return [loader isExist:page_num-num];
  }
}

-(BOOL) hasRight:(int)num {
  if ( direction == DIRECTION_LEFT ) {
    return [loader isExist:page_num-num];
  } else {
    return [loader isExist:page_num+num+1];
  }
}

- (void) arrangeDictionary {
  NSNumber* num;
  UIImageView* image_view;
  for ( int i = 0; i < max_page_num; i++ ) {
    num = [NSNumber numberWithInteger:i];
    if ( i < page_num - 2 || i > page_num + 3 ) {
      [page_dict removeObjectForKey:num];
    } else {
      if (![page_dict objectForKey:num]) {
	image_view = [loader getImageViewWithNumber:i];
	if ( image_view ) {
	  [page_dict setObject:image_view forKey:num];
	  [image_view release];
	}
      }
    }
  }
}

- (void) dealloc {
  [super dealloc];
  [loader dealloc];
}

@end
