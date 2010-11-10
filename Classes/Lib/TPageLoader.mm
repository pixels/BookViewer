//
//  TPageLoader.m
//  BookViewer
//
//  Created by Karatsu Naoya on 10/11/02.
//  Copyright 2010 ajapax. All rights reserved.
//

#import "TPageLoader.h"
#import "testView.h"


@implementation TPageLoader

-(UIImageView*) getImageViewWithNumber:(int)page_num {
  UIImageView* view = [[testView alloc] initWithFrame:CGRectMake(0,0,512,512) Str:[NSString stringWithFormat:@"%d", page_num]];
  return view;
}

@end
