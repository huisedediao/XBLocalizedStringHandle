//
//  XBLocalizedStringHandle.m
//  XBLocalizedStringHandle
//
//  Created by xxb on 2017/4/25.
//  Copyright © 2017年 xxb. All rights reserved.
//

#import "XBLocalizedStringHandle.h"
#import "LocalizedStringHandle.h"



@interface XBLocalizedStringHandle ()

//是否需要对应值
@property (nonatomic,assign) BOOL needValue;

//是否需要按文件夹分
@property (nonatomic,assign) BOOL componentsByFolder;

//需要读取其中.h 和.m文件内容的文件夹路径
@property (nonatomic,copy) NSString *directoryPath;

//存储读取到的字符串，避免重复
@property (nonatomic,strong) NSMutableArray *recordStringArr;

//把文件内容存储在文件夹名对应的数组中，用于区分不同文件夹
@property (nonatomic,strong) NSMutableDictionary *folderNameStrDic;

@end


@implementation XBLocalizedStringHandle

#pragma mark - 生命周期
+(instancetype)shared
{
    return [self new];
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static XBLocalizedStringHandle *handle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handle = [super allocWithZone:zone];
    });
    return handle;
}


-(NSArray *)getContentWithPath:(NSString *)filePath deleteNote:(BOOL)deleteNote//是否过滤注释
{
    NSMutableArray *result = [NSMutableArray new];
    NSError* error;
    NSData* data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedAlways error:&error];
    if (error)
    {
        NSLog(@"error:%@",error);
    }
    else
    {
        NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *replaceStr = @[@"\r",@"*",@"\n"];
        for (int i=0; i<replaceStr.count; i++)
        {
            content = [content stringByReplacingOccurrencesOfString:replaceStr[i] withString:@""];
        }
        NSMutableArray *resultTem = [NSMutableArray new];
        for (NSString *str in [content componentsSeparatedByString:@"\";"])//以此分割是因为有些翻译里带这个符号 "
        {
            /*
            if ([str hasPrefix:@"//"]) //过滤掉注释的
            {
                if (deleteNote)
                {
                    continue;
                }
            }
             */
            if ([str isEqualToString:@""] == NO)
            {
                [resultTem addObject:[str stringByAppendingString:@"\""]];
            }
        }
        
        for (NSString *str in resultTem)
        {
            NSString *tempStr = str;
            NSRange range = [str rangeOfString:@"\""];
            NSLog(@"str:%@,range:%@",str,NSStringFromRange(range));
            if (range.location == NSNotFound)
            {
                
            }
            else
            {
                if (range.location != 0)
                {
                    tempStr = [str substringFromIndex:range.location];
                    if (deleteNote == NO)
                    {
                        [result addObject:[@"\r\r\r" stringByAppendingString:[[str substringToIndex:range.location] stringByAppendingString:@"\r"]]];
                    }
                }
            }
            [result addObject:tempStr];
        }
        
        NSLog(@"end");
    }
    return result;
}




#pragma mark - 读取文件夹的内容
/**
 参数：文件夹路径,查找文件夹下所有.m和.h文件中所有本地化字符串
 */
-(void)findLocalizedStringAtPath:(NSString *)directoryPath needValue:(BOOL)needValue componentsByFolder:(BOOL)componentsByFolder
{
    self.directoryPath = directoryPath;
    self.needValue = needValue;
    self.componentsByFolder = componentsByFolder;

    //将文件内容读取到recordStringArr中
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *arr = [fm subpathsOfDirectoryAtPath:directoryPath error:nil];
    for (NSString *path in arr) {
        if ([path hasSuffix:@".m"] || [path hasSuffix:@".h"])
        {
            NSString *fullPath = [directoryPath stringByAppendingPathComponent:path];
            [self handleContentWithFilePath:fullPath];
        }
    }
    
    //写入文件
    for (NSString *key in [self.folderNameStrDic allKeys])
    {
        NSArray *arr = self.folderNameStrDic[key];
        for (NSString *strNeedWrite in arr)
        {
            [self writeString:strNeedWrite toFilePath:savePath];
        }
    }
}

-(void)handleContentWithFilePath:(NSString *)filePath
{
    NSMutableArray *contentArr = [self addFolderNameTorecordStringArrWithPath:filePath];
    
    NSError* error;
    NSData* data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedAlways error:&error];
    if (error)
    {
        NSLog(@"error:%@",error);
    }
    else
    {
        NSString* content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *resultDic = [LocalizedStringHandle handleOriginFileContent:content];
        for (NSString *key in resultDic.allKeys)
        {
            NSArray *arr = resultDic[key];
            arr = [self removeSameKeyForArr:arr];
            
            ///添加表名，按表名分段
            NSString *tableName = [NSString stringWithFormat:@"\r//xxxxx--tableName:%@--xxxxx",key];
            if ([contentArr containsObject:tableName] == NO)
            {
                [contentArr addObject:tableName];
            }
            
            
            for (NSString *str in arr)
            {
                if ([str isEqualToString:@""])
                {
                    continue;
                }
                NSString *strToWrite = [NSString stringWithFormat:@"\"%@\" = \"%@\";",str , self.needValue ? str:@""];
                
                //包含表名的内容
                NSString *str_tableContent = [NSString stringWithFormat:@"%@-%@",key,strToWrite];
                
                if ([self.recordStringArr containsObject:str_tableContent] == NO)
                {
                    [self.recordStringArr addObject:str_tableContent];
                    [contentArr addObject:strToWrite];
                }
            }
        }
    }
}

- (NSArray *)removeSameKeyForArr:(NSArray *)arr
{
    NSMutableArray *arrM = [NSMutableArray new];
    for (NSString *str in arr)
    {
        if ([arrM containsObject:str] == NO)
        {
            [arrM addObject:str];
        }
    }
    return arrM;
}



#pragma mark - 其他方法
//写入文件方法
-(void)writeString:(NSString *)str toFilePath:(NSString *)filePath
{
    NSLog(@"strNeedWrite:%@",str);
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:filePath] == false)
    {
        [fm createFileAtPath:filePath contents:nil attributes:nil];
    }

    

    
    str = [str stringByAppendingString:@"\r\r"];
    NSFileHandle *fh = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    [fh seekToEndOfFile];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [fh writeData:data];
}


//根据传入的path，判断是否需要添加文件夹名字到输出的文档中，用于区分翻译属于哪个文件夹
-(NSMutableArray *)addFolderNameTorecordStringArrWithPath:(NSString *)path
{
    NSString *folderName = nil;
    
    
    NSString *tempStr = [[path stringByDeletingLastPathComponent] substringFromIndex:self.directoryPath.length - 1];
    if (tempStr.length > 0)
    {
        folderName = [[[tempStr substringFromIndex:1] componentsSeparatedByString:@"/"] firstObject];
    }
    else
    {
        folderName = [self.directoryPath lastPathComponent];
    }
    NSLog(@"floderName:%@",folderName);
    folderName = [NSString stringWithFormat:@"folderName : %@",folderName];
    
    
    
    NSMutableArray *strArr = self.folderNameStrDic[folderName];
    if (strArr == nil)
    {
        strArr = [NSMutableArray new];
        self.folderNameStrDic[folderName] = strArr;
    }
    
    
    NSString *tempFolderName = [NSString stringWithFormat:@"\r\r\r//xxxxxxxxxx---%@---xxxxxxxxxx\r",folderName];

    if ([strArr containsObject:tempFolderName] == NO)
    {
        if (self.componentsByFolder)
        {
            [strArr addObject:tempFolderName];
        }
    }
    return strArr;
}



#pragma mark - 懒加载

-(NSMutableArray *)recordStringArr
{
    if (_recordStringArr == nil)
    {
        _recordStringArr = [NSMutableArray new];
    }
    return _recordStringArr;
}

-(NSMutableDictionary *)folderNameStrDic
{
    if (_folderNameStrDic == nil)
    {
        _folderNameStrDic = [NSMutableDictionary new];
    }
    return _folderNameStrDic;
}
@end
