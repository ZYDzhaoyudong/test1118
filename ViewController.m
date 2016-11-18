//
//  ViewController.m
//  AFN
//
//  Created by 东 on 16/10/30.
//  Copyright © 2016年 东. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "AppsModel.h"
#import "UIImageView+WebCache.h"
#import "Appcell.h"
#import "NSString+sanBox.h"
@interface ViewController ()
@property(nonatomic,strong)NSArray * dataArray;
@property (nonatomic,strong) NSOperationQueue *queue;
//为了内存缓存而创建的图片缓存池
@property(nonatomic,strong)NSMutableDictionary * imgCache;
//为了解决操作多次下载添加到队列的情况，创建操作缓存池
@property(nonatomic,strong)NSMutableDictionary * operationCache;
@end
/*
    1:同步下载:界面启动的时候很卡,上下滚动的时候也很卡
    2:异步下载:图片不展示,只有当点击cell或者上下滚动屏幕的时候才显示图片
    原因:cell上面的控件是懒加载的,现在的UIImageview的frame的大小是0*0
    解决:占位符
    3:自定义cell
    4:内存缓存： 当上下滚动屏幕的时候，因为已经下载过的图片还会下载一遍，浪费用户的流量，所以采用内存缓存。
    5: cell 的重用造成了cell的图片的错行，可以直接刷新所有的数据，也可以单独刷新对应行即可。
    6：操作数：cell上下滚动的时候，会重复的把相同下载多次的添加到队列中，会造成多次的操作下载，浪费用户的流量，所以采用操作缓存池解决这一问题
 */

@implementation ViewController
- (NSOperationQueue*)queue
{
    if (_queue == nil) {
        _queue = [[NSOperationQueue alloc]init];
    }
    return _queue;
}
- (NSMutableDictionary *)imgCache
{
    if (_imgCache == nil) {
        _imgCache = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return _imgCache;
}
//懒加载
- (NSMutableDictionary *)operationCache
{
    if (_operationCache == nil) {
        _operationCache = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return _operationCache;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadJesonData];
}
- (void)loadJesonData
{
    //创建网络管理者
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    [manager GET:@"https://raw.githubusercontent.com/ZYDzhaoyudong/jasonload/master/apps.json" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"%@ %@",[responseObject class],responseObject);
        NSMutableArray * arrayM = [NSMutableArray arrayWithCapacity:10];
        [responseObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AppsModel * model = [AppsModel appWithDict:obj];
            
            [arrayM addObject:model];
            
        }];
//        NSLog(@"%@",arrayM);
        self.dataArray = arrayM.copy;
        //刷新数据
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error %@",error);
    }];
}
//数据源方法：
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Appcell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    //获取模型
    AppsModel * model = self.dataArray[indexPath.row];
    cell.textLabel.text = model.name;
    cell.detailTextLabel.text = model.download;
    
    //设置占位符
    cell.imageView.image = [UIImage imageNamed:@"user_default@2x.png"];
    //在设置完占位符之后判断内存缓存池中是否已经存在
    if (self.imgCache[model.icon]) {
        NSLog(@"从图片缓存池（内存）中加载图片-- %@",model.name);
        cell.imageView.image = self.imgCache[model.icon];
        //如果有则直接加载而不用执行下面的下载图片的操作。
        return cell;
    }
    
    //判断沙盒缓存池中是否已经有了这个图片，
    NSString * path = [model.icon appdendCache];
    UIImage * image = [UIImage imageWithContentsOfFile:path];
    if (image) {
        NSLog(@"正在从沙盒中下载图片,,%@",model.name);
        cell.imageView.image = image;
        //把沙盒里面的图片放到内存中，这是因为在内存中加载的图片的效率比在沙盒中加载的效率更高
        [self.imgCache setObject:image forKey:model.icon];
        return cell;
    }
    //判断操作缓存池中是否已经含有该操作，如果有，则直接调用操作，不需要再执行下面的下载的操作
    if (self.operationCache[model.icon]) {
        NSLog(@"正在努力下载图片");
        return cell;
    }
    
    //异步下载图片
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        NSURL *url = [NSURL URLWithString:model.icon];
        //模拟延迟：
        if (indexPath.row > 9) {
            //前九个不设置延迟加载为了对比区别
            [NSThread sleepForTimeInterval:0.5];
        }
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [UIImage imageWithData:data];
        
        //沙盒缓存
        if (image) {
            [data writeToFile:[model.icon appdendCache] atomically:YES];
        }
        
        
        //回到主线程更新UI
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            cell.imageView.image = img;
            
            
            //此处刷新对应行，或者是刷新全部的tableView。
            //[self.tableView reloadData];
            
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            //此处内存缓存中，判断一下图片是否为空，如果不是，则将这个键值对加入内存的可变字典之中。
            if (img) {
                [self.imgCache setObject:img forKey:model.icon];
            }
        }];
    }];
    
    //将操作加到队列中
    
    [self.queue addOperation:op];
    
    //将操作添加到操作缓存池中：
    [self.operationCache setObject:op forKey:model.icon];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //在这里处理图片缓存池，操作缓存池，以及队列中的所有数据
    [self.imgCache removeAllObjects];
    [self.operationCache removeAllObjects];
    [self.queue cancelAllOperations];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%zd",self.queue.operationCount);
}
@end
