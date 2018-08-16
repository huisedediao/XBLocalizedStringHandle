//
//  XBLocalizedStringHandle+Extension.h
//  XBLocalizedStringHandle
//
//  Created by xxb on 2018/8/16.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBLocalizedStringHandle.h"

@interface XBLocalizedStringHandle (Extension)
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
