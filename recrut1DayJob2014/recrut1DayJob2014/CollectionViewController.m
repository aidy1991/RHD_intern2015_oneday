//
//  CollectionViewController.m
//  recrut1DayJob2014
//
//  Created by Imamori Daichi on 2014/12/14.
//  Copyright (c) 2014年 Imamori Daichi. All rights reserved.
//

#import "CollectionViewController.h"

@interface CollectionViewController ()

@end

@implementation CollectionViewController{
    NSInteger width_;
    NSInteger height_;
    NSMutableArray *imageURLs_;
    dispatch_queue_t main_queue_;
    dispatch_queue_t sub_queue_;
    APIController *apiController;
    AppDelegate *appDelegate;
}

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    imageURLs_ = [NSMutableArray array];
    apiController = [[APIController alloc] initWithUrl:@"http://webservice.recruit.co.jp/beauty/salon/v1/" key:KEY];
    width_ = [[UIScreen mainScreen] bounds].size.width;
    height_ = [[UIScreen mainScreen] bounds].size.height;
    
    //CoreDataの変わりのグローバル変数
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.likedImageViews == nil){
        appDelegate.likedImageViews = [NSMutableArray array];
    }
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.

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
            
            //imageURLsを空に
            [imageURLs_ removeAllObjects];
            for (NSString *url in images) {
                
                NSData *dt = [NSData dataWithContentsOfURL:
                              [NSURL URLWithString:url]];
                UIImage *image = [[UIImage alloc] initWithData:dt];
                double isTate = image.size.height > image.size.width;
                double widthRatio = (isTate) ? image.size.width / image.size.height : 1;
                double heightRatio = (isTate) ? 1 : image.size.height / image.size.width;

                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, IMAGE_SIZE * widthRatio, IMAGE_SIZE * heightRatio)];
                imageView.image = image;
                [imageURLs_ addObject:imageView];
            }
            
            [self.collectionView reloadData];
        });
    });
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
#warning Incomplete method implementation -- Return the number of sections
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
#warning Incomplete method implementation -- Return the number of items in the section
    NSInteger number = 0;
    if(imageURLs_ != nil){ number = [imageURLs_ count];}
    return number;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    //cell.backgroundColor = [UIColor redColor];
    
    // Configure the cell
    if(imageURLs_ != nil){
        UIImageView *imageView = imageURLs_[indexPath.row];
        //cell.backgroundColor = [UIColor blueColor];
        [cell addSubview:imageView];
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%d番目が選ばれた", indexPath.row);

    //選択された写真はお気に入りに登録

    //グローバル変数に登録
    [appDelegate.likedImageViews addObject:imageURLs_[indexPath.row]];

    
    [imageURLs_ removeObjectAtIndex:indexPath.row];
    [self.collectionView reloadData];
    
    return YES;
}

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/


- (NSArray *) getImageURLsFromJson:(NSString *)json{
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
@end
