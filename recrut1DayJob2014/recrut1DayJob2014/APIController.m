//
//  APIController.m
//  Resty
//
//  Created by Imamori Daichi on 2014/11/17.
//  Copyright (c) 2014年 Kazuma Nagaya. All rights reserved.
//

#import "APIController.h"


@implementation APIController{
    NSString *url_;
    NSString *key_;
    NSMutableSet *obtainedMeshMutableSet_;
}

- (id) initWithUrl:(NSString *)url key:(NSString *)key{
    obtainedMeshMutableSet_ = [NSMutableSet set];
    self = [super init];
    url_ = url;
    key_ = key;
    return self;
}

- (NSString *) call:(NSString *)word offset:(NSInteger)offset{
    NSString *returnedJson = @"{}";

    //送信するパラメータの組み立て
    NSMutableURLRequest *request;
    NSString *encodedKeyword = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)word,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8 ));
    NSString *requestURL = [NSString stringWithFormat:@"%@?format=json&key=%@&keyword=%@&count=%d&start=%d", url_, key_, encodedKeyword, COUNT, offset];
    NSLog(requestURL);
    request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]
                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                            timeoutInterval:60.0];

    
    //HTTPメソッドは"GET"
    [request setHTTPMethod:@"GET"];

    //レスポンス
    NSURLResponse *resp;  
    NSError *err;  

    //HTTPリクエスト送信  
    NSData *result = [NSURLConnection sendSynchronousRequest:request   
                                           returningResponse:&resp error:&err];
    returnedJson = [[NSString alloc] initWithData:result encoding:
                    NSUTF8StringEncoding];

    // 返ってきた文字列の処理
    //NSLog(@"Result: %@, err: %@", returnedJson, err);
        
    return returnedJson;
}

@end