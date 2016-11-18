//
//  NSString+sanBox.m
//  AFN
//
//  Created by 东 on 16/11/2.
//  Copyright © 2016年 东. All rights reserved.
//

#import "NSString+sanBox.h"

@implementation NSString (sanBox)
//获取沙盒的cache目录
- (instancetype)appdendCache
{
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)lastObject] stringByAppendingPathComponent:[self lastPathComponent]];
}
//document
- (instancetype)appdendDocument
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[self lastPathComponent]];
}
//temp
@end
