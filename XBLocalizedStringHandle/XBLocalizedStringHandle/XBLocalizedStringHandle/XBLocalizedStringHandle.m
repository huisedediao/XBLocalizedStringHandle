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
@property (nonatomic,strong) NSMutableArray *stringArr;

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

#pragma mark - 根据文件内容替换
/**
 比较两份文件中的内容，并分别存储相同和不同的内容
 参数1：文件路径1
 参数2：文件路径2
 */
-(void)compareContentAtFilePath:(NSString *)filePath1 andFileAtPaht:(NSString *)filePath2
{
    NSArray *content1 = [self getContentWithPath:filePath1 deleteNote:NO];
    NSArray *content2 = [self getContentWithPath:filePath2 deleteNote:NO];

    NSMutableArray *arrDifferent = [NSMutableArray new];
    NSMutableArray *arrSame = [NSMutableArray new];
    
    NSArray *large = content1.count > content2.count ? content1 : content2;
    NSArray *small = content1.count < content2.count ? content1 : content2;
    
    
    for (NSString *str in large)
    {
        if ([small containsObject:str])
        {
            [arrSame addObject:str];
        }
        else
        {
            [arrDifferent addObject:str];
        }
    }
    
    for (NSString *str in arrDifferent)
    {
        [self writeString:[str stringByAppendingString:@";"] toFilePath:savePathForDifferentContent];
    }
    
    for (NSString *str in arrSame)
    {
        [self writeString:[str stringByAppendingString:@";"] toFilePath:savePathForSameContent];
    }
}





#pragma mark - 根据文件内容替换
/**
 参数1：要替换value的文件的路径（旧）
 参数2：根据哪份文件替换，就传那份文件的路径 （新）
 替换完成后
 */
-(void)replaceValueAtFilePath:(NSString *)filePathNeedReplace byFileAtPaht:(NSString *)filePath needAddNotExist:(BOOL)needAddNotExist
{
    NSArray *tempArr = [self getContentWithPath:filePath deleteNote:YES];
    NSArray *arrNeed = [self getContentWithPath:filePathNeedReplace deleteNote:NO];
    NSMutableArray *newArr = [NSMutableArray new];
    
    
    for (int i = 0 ; i < arrNeed.count; i++)
    {
        NSString *tempStrNeed = arrNeed[i];
        NSArray *arr = [tempStrNeed componentsSeparatedByString:@" = "];
        if (arr.count > 1)
        {
            for (NSString *tempStr in tempArr)
            {
                NSArray *arrt = [tempStr componentsSeparatedByString:@" = "];
//                NSArray *arrt = [tempStr componentsSeparatedByString:@"="];
                if (arrt.count > 1 && [arr[1] isEqualToString:arrt[0]])//旧文件的value和新文件的key相同
//                if (arrt.count > 1 && [arr[0] isEqualToString:arrt[0]])//key相同
                {
                    tempStrNeed = [NSString stringWithFormat:@"%@ = %@",arr[0],arrt[1]];
                    break;
                }
                if (tempStr == [tempArr lastObject])
                {
                    NSString *hasNotReplace = @"xxb未替换";
                    tempStrNeed = [NSString stringWithFormat:@"%@%@",hasNotReplace,arrNeed[i]];
                }
            }
        }
        
        [newArr addObject:tempStrNeed];
    }
    

    
    //写入文件
    for (NSString *str in newArr)
    {
        NSRange range = [str rangeOfString:@"\""];
        NSLog(@"str:%@,range:%@",str,NSStringFromRange(range));
        if (range.location == NSNotFound)
        {
            [self writeString:str toFilePath:savePathForReplace];
        }
        else
        {
            [self writeString:[str stringByAppendingString:@";"] toFilePath:savePathForReplace];
        }
        
    }
    
    //获取旧文件中没有的key和值
    NSArray *needAddArr = [self getNeedAddStrByOldPath:filePathNeedReplace newPath:filePath];
    if (needAddNotExist)
    {
        for (NSString *str in needAddArr)
        {
            NSRange range = [str rangeOfString:@"\""];
            NSLog(@"str:%@,range:%@",str,NSStringFromRange(range));
            if (range.location == NSNotFound)
            {
                [self writeString:str toFilePath:savePathForReplace];
            }
            else
            {
                [self writeString:[str stringByAppendingString:@";"] toFilePath:savePathForReplace];
            }
        }
    }
}



-(NSArray *)getNeedAddStrByOldPath:(NSString *)oldPath newPath:(NSString *)newPath
{
    NSArray *oldArr = [self getContentWithPath:oldPath deleteNote:NO];
    NSArray *newArr = [self getContentWithPath:newPath deleteNote:NO];
    
    NSMutableArray *needAddArr = [NSMutableArray new];
    [needAddArr addObject:@"\r\r\r//needAdd\r"];
    
    for (NSString *strTempNew in newArr)
    {
        NSArray *arrTempNew = [strTempNew componentsSeparatedByString:@"="];
        NSString *strCurrent = arrTempNew[0];
        if (arrTempNew.count > 1)
        {
            BOOL needAdd = YES;
            for (NSString *strTempOld in oldArr)
            {
                NSArray *arrTempOld = [strTempOld componentsSeparatedByString:@"="];
                if (arrTempOld.count > 1)
                {
                    if ([strCurrent isEqualToString:arrTempOld[0]])
                    {
                        needAdd = NO;
                        break;
                    }
                }
            }
            if (needAdd)
            {
                [needAddArr addObject:strTempNew];
            }
        }
    }
    
    return needAddArr;
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
    
    //将文件内容读取到stringArr中
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
    NSMutableArray *folderNameArr = [self addFolderNameToStringArrWithPath:filePath];
    
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
        NSArray *arr = resultDic[@"Localizable"];
        for (NSString *str in arr)
        {
            if ([str isEqualToString:@""])
            {
                continue;
            }
            NSString *strToWrite = [NSString stringWithFormat:@"\"%@\" = \"%@\";",str , self.needValue ? str:@""];
            
            if ([self.stringArr containsObject:strToWrite] == NO)//这一步判断，导致自付出只有先出现的文件夹才会有
            {
                [self.stringArr addObject:strToWrite];
                [folderNameArr addObject:strToWrite];
            }
        }
    }
}



/**
 替换文件中key对应的value为@""
 */
-(void)setValueEmptyAtFilePaht:(NSString *)filePath
{
    NSArray *content = [self getContentWithPath:filePath deleteNote:NO];
    NSMutableArray *newArr = [NSMutableArray new];
    for (NSString *str in content)
    {
        NSRange range = [str rangeOfString:@"\""];
        NSLog(@"str:%@,range:%@",str,NSStringFromRange(range));
        if (range.location == NSNotFound)
        {
            [newArr addObject:str];
        }
        else
        {
            NSArray *arrTemp = [str componentsSeparatedByString:@"="];
            if (arrTemp.count > 1)
            {
                [newArr addObject:[NSString stringWithFormat:@"%@ = \"\";",arrTemp[0]]];
            }
        }
    }
    for (NSString *str in newArr)
    {
        [self writeString:str toFilePath:savePathForEmptyValue];
    }
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
-(NSMutableArray *)addFolderNameToStringArrWithPath:(NSString *)path
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
    
    
    
    NSMutableArray *strArr = self.folderNameStrDic[folderName];
    if (strArr == nil)
    {
        strArr = [NSMutableArray new];
        self.folderNameStrDic[folderName] = strArr;
    }
    
    
    NSString *tempFolderName = [NSString stringWithFormat:@"\r\r\r//%@",folderName];

    if ([strArr containsObject:tempFolderName] == NO)
    {
        if (self.componentsByFolder)
        {
            [strArr addObject:tempFolderName];
        }
    }
    return strArr;
}


/**
 根据两份文件的内容生成新的翻译文件
 参数一：key字符串文件
 参数二：value字符串文件
 */
-(void)getStringFileWithKeyFilePath:(NSString *)keyFilePath valueFilePaht:(NSString *)valueFilePaht
{
    NSArray *keyArr = [self getContentForStringFileWithPath:keyFilePath deleteNote:YES];
    NSArray *valueArr = [self getContentForStringFileWithPath:valueFilePaht deleteNote:YES];
    
    for (int i = 0; i < keyArr.count; i++)
    {
//        if ([keyArr[i] hasPrefix:@"//"])
//        {
//            continue;
//        }

        NSString *keyValueStr = [NSString stringWithFormat:@"\"%@\" = \"%@\";",keyArr[i],valueArr[i]];
        [self writeString:keyValueStr toFilePath:savePathForIosStringFile];
    }
}

-(NSArray *)getContentForStringFileWithPath:(NSString *)filePath deleteNote:(BOOL)deleteNote//是否过滤注释
{
    NSMutableArray *result = [NSMutableArray new];
    NSError* error;
    //NSData* data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedAlways error:&error];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    if (error)
    {
        NSLog(@"error:%@",error);
    }
    else
    {
        NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        
        NSArray *tempArr = [content componentsSeparatedByString:@"\r"];
//        int count = 2;
        //过滤操作
        for (NSString *strTemp in tempArr)
        {
            //过滤字符串结尾的空格
            NSString *str = [self removePlaceAtEndOfStr:strTemp];
            if (str.length > 1)
            {

                if ([str hasPrefix:@"//"] == NO)
                {
                    if ([str isEqualToString:@"\n\""] == NO)
                    {
//                        NSString *temp = [[NSString stringWithFormat:@"xbtestNo.%zd ",count] stringByAppendingString:[str stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
                        
//                        [result addObject:temp];
//                        count++;
                        [result addObject:[str stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
                    }
                }
            }
        }

    }
    return result;
}

- (NSString *)removePlaceAtEndOfStr:(NSString *)str
{
    for (NSInteger i = str.length - 1; i >= 0; i--)
    {
        if (i < 1)
        {
            break;
        }
        NSRange range = NSMakeRange(i - 1, 1);
        if ([[str substringWithRange:range] isEqualToString:@" "])
        {
            str = [str substringToIndex:i-1];
        }
        else
        {
            break;
        }
    }
    return str;
}




#pragma mark - 懒加载

-(NSMutableArray *)stringArr
{
    if (_stringArr == nil)
    {
        _stringArr = [NSMutableArray new];
    }
    return _stringArr;
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
