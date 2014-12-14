//
//  APIController.h
//  Resty
//
//  Created by Imamori Daichi on 2014/11/17.
//  Copyright (c) 2014年 Kazuma Nagaya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Const.m"


@interface APIController : NSObject
- (id) initWithUrl:(NSURL *)url;
- (NSString *) call:(NSMutableArray *) meshArray;
@end