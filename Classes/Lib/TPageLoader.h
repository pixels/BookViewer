//
//  TPageLoader.h
//  BookViewer
//
//  Created by Karatsu Naoya on 10/11/02.
//  Copyright 2010 ajapax. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TPageLoader : NSObject {

}

-(UIImageView*) getImageViewWithNumber:(int)page_num;
-(BOOL) isExist:(int)num;

@end
