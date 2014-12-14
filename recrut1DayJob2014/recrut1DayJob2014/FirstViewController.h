//
//  FirstViewController.h
//  recrut1DayJob2014
//
//  Created by Imamori Daichi on 2014/12/14.
//  Copyright (c) 2014年 Imamori Daichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APIController.h"
#import "Const.m"

@interface FirstViewController : UIViewController 
- (NSMutableArray *) getImageURLsFromJson:(NSString *)json;
@end

