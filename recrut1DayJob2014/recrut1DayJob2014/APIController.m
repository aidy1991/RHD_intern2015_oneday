//
//  APIController.m
//  Resty
//
//  Created by Imamori Daichi on 2014/11/17.
//  Copyright (c) 2014年 Kazuma Nagaya. All rights reserved.
//

#import "APIController.h"


@implementation APIController : NSObject
NSURL * url_;
NSMutableSet *obtainedMeshMutableSet_;

- (id) initWithUrl:(NSURL *) url{
    obtainedMeshMutableSet_ = [NSMutableSet set];
    self = [super init];
    url_ = url;
    return self;
}

- (NSString *) call:(NSMutableArray *)meshArray{
    NSString *returnedJson = @"{}";
    NSLog(@"Called call in APIController: %@", meshArray);

    //送信するパラメータの組み立て
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
    [mutableDic setValue:meshArray forKey:@"mesh_numbers"];
    
    NSError *error;
    if([NSJSONSerialization isValidJSONObject:mutableDic]){
        NSData *json = [NSJSONSerialization dataWithJSONObject:mutableDic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
        NSMutableURLRequest *request;
        request =
        [NSMutableURLRequest requestWithURL:[NSURL URLWithString:API_URL]
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                timeoutInterval:60.0];

        //HTTPメソッドは"POST"
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", [json length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody: json];

        //レスポンス
        NSURLResponse *resp;  
        NSError *err;  

        //HTTPリクエスト送信  
        NSData *result = [NSURLConnection sendSynchronousRequest:request   
                                               returningResponse:&resp error:&err];
        returnedJson = [[NSString alloc] initWithData:result encoding:
                        NSUTF8StringEncoding];

        // 返ってきた文字列の処理
        NSInteger front = 1;
        NSInteger end = 1;
        returnedJson = [returnedJson substringWithRange:NSMakeRange(front, returnedJson.length - front - end)];
        returnedJson = [returnedJson stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];

        NSLog(@"Result: %@, err: %@", returnedJson, err);
        
    }else{
        NSLog(@"!!!The Array can not convert json!!!");
    }
    return returnedJson;
}

@end