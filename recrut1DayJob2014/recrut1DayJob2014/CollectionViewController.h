//
//  CollectionViewController.h
//  recrut1DayJob2014
//
//  Created by Imamori Daichi on 2014/12/14.
//  Copyright (c) 2014年 Imamori Daichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Const.m"
#import "APIController.h"
#import "AppDelegate.h"

@interface CollectionViewController : UICollectionViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
- (NSArray *) getImageURLsFromJson:(NSString *)json;
- (void) loadImages;

@end
