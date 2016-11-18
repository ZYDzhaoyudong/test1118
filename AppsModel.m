//
//  AppsModel.m
//  AFN
//
//  Created by 东 on 16/10/30.
//  Copyright © 2016年 东. All rights reserved.
//

#import "AppsModel.h"

@implementation AppsModel
+ (instancetype)appWithDict:(NSDictionary *)dict
{
    AppsModel * model = [[AppsModel alloc]init];
    //kvc
    [model setValuesForKeysWithDictionary:dict];
    return model;
}
@end
