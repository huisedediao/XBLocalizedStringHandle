//
//  XBLocalizedStringHandle.h
//  XBLocalizedStringHandle
//
//  Created by xxb on 2017/4/25.
//  Copyright © 2017年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XBLocalizedStringHandleHeader.h"

@interface XBLocalizedStringHandle : NSObject

//写入文件方法
-(void)writeString:(NSString *)str toFilePath:(NSString *)filePath;
/*
 获取文件内容
 参数1：文件路径
 参数2：是否过滤注释
 */
-(NSArray *)getContentWithPath:(NSString *)filePath deleteNote:(BOOL)deleteNote;

+(instancetype)shared;

/**
 参数1：文件夹路径,查找文件夹下所有.m和.h文件中所有本地化字符串
 参数2：是否要有值，
        yes：格式为"Select Photos" = "Select Photos";
        no： 格式为"Select Photos" = "";
 参数3：是否根据文件夹分段。
        举例：NSLocalizedStringFromTable(@"Save", @"SmanosCloud", nil)
            上面的内容出现在文件夹1和文件夹2包含的文件中，那么Save只会出现在文件夹1->表SmanosCloud分段下
 */
-(void)findLocalizedStringAtPath:(NSString *)directoryPath needValue:(BOOL)needValue componentsByFolder:(BOOL)componentsByFolder;


@end
