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
  UIImageView* view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"00%d.jpg", (page_num%8)+1]]];
  view.frame = CGRectMake(0, 0, 300, 300);
  return view;
}

-(BOOL) isExist:(int)num {
  return (num >= 0);
}

@end
