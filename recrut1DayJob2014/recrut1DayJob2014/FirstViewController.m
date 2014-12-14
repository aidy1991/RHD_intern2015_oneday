//
//  FirstViewController.m
//  recrut1DayJob2014
//
//  Created by Imamori Daichi on 2014/12/14.
//  Copyright (c) 2014年 Imamori Daichi. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController (){
    APIController *apiController;
}

@end

@implementation FirstViewController{
    dispatch_queue_t main_queue_;
    dispatch_queue_t sub_queue_;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    apiController = [[APIController alloc] initWithUrl:@"http://webservice.recruit.co.jp/beauty/salon/v1/" key:KEY];
    
    
    // マルチスレッド処理の準備
    // メインスレッド用で処理を実行するキューを定義する
    main_queue_ = dispatch_get_main_queue();
    
    // サブスレッドで実行するキューを定義する
    sub_queue_ = dispatch_queue_create("sadp.team.sink.toiletApi", 0);


    // 並列処理開始
    dispatch_async(sub_queue_, ^{
        //ここはサブスレッド
        NSString *json = [apiController call:@"東京" offset:12];

        dispatch_async(main_queue_, ^{
            // ここはメインスレッド
            // APIを叩いたあとの処理をここへ記述
            if([json isEqualToString:@"{}"]){ return ;}
            //NSLog(@"%@", json);
            NSMutableArray *images = [self getImageURLsFromJson:json];
            NSLog(@"%@", images);
        });
    });
    


    
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSMutableArray *) getImageURLsFromJson:(NSString *)json{
    NSMutableArray *imageURLs = [[NSMutableArray alloc] init];
    // jsonをDicに変換
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError* error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    //NSLog(@"%@ %@", dic, error);
    
    for (NSDictionary *salon in dic[@"results"][@"salon"]) {
        if(![salon.allKeys containsObject:@"feature"]) { continue; }
        if ([salon[@"feature"] count] == 0) { continue; }
        NSDictionary *feature = salon[@"feature"][0];

        if(![feature.allKeys containsObject:@"photo"]) { continue; }
        NSDictionary *photo = feature[@"photo"];
        if([photo count] == 0) { continue; }
        //NSLog(@"%@", photo[@"l"]);
        [imageURLs addObject:photo[@"l"]];
    }
    
    return imageURLs;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
