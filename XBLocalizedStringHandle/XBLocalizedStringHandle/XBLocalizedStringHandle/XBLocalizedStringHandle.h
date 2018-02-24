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

+(instancetype)shared;

/**
 参数1：文件夹路径,查找文件夹下所有.m和.h文件中所有本地化字符串
 参数2：是否要有值，
        yes：格式为"Select Photos" = "Select Photos";
        no： 格式为"Select Photos" = "";
 */
-(void)findLocalizedStringAtPath:(NSString *)directoryPath needValue:(BOOL)needValue componentsByFolder:(BOOL)componentsByFolder;

/**
 参数1：要替换value的文件的路径（旧）
 参数2：根据哪份文件替换，就传那份文件的路径 （新）
 参数2：是否需要添加旧文件中没有的key和对应的value，例如：旧文件中没有 "hehe" = "呵呵" ,如果需要则会把这句话添加进去
 */
-(void)replaceValueAtFilePath:(NSString *)filePathNeedReplace byFileAtPaht:(NSString *)filePath needAddNotExist:(BOOL)needAddNotExist;


/**
 剔除两份文件中相同的内容
 参数1：文件路径1
 参数2：文件路径2
 */
-(void)compareContentAtFilePath:(NSString *)filePath1 andFileAtPaht:(NSString *)filePath2;


/**
 替换文件中key对应的value为@""
 */
-(void)setValueEmptyAtFilePaht:(NSString *)filePath;


/**
 根据两份文件的内容生成新的翻译文件
 参数一：key字符串文件
 参数二：value字符串文件
 */
-(void)getStringFileWithKeyFilePath:(NSString *)keyFilePath valueFilePaht:(NSString *)valueFilePaht;

@end
