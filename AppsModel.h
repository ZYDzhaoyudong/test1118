//
//  AppsModel.h
//  AFN
//
//  Created by 东 on 16/10/30.
//  Copyright © 2016年 东. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppsModel : NSObject
//名称
@property(nonatomic,copy)NSString * name;
//下载量
@property(nonatomic,copy)NSString * download;
//图片
@property(nonatomic,copy)NSString * icon;


+ (instancetype)appWithDict:(NSDictionary *)dict;
@end
