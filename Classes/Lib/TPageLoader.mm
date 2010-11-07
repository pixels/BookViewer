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
  if ( page_num == 0 ) {
    return [[testView alloc] initWithFrame:CGRectMake(0,0,512,512) Str:@"左"];
  } else {
    return [[testView alloc] initWithFrame:CGRectMake(0,0,512,512) Str:@"右"];
  }
}

@end
