//
//  NSString+sanBox.h
//  AFN
//
//  Created by 东 on 16/11/2.
//  Copyright © 2016年 东. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (sanBox)
//获取沙盒的cache目录
- (instancetype)appdendCache;
//document
- (instancetype)appdendDocument;
//temp
- (instancetype)appdendTemp;
@end
