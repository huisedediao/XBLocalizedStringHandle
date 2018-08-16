//
//  XBLocalizedStringHandle+Extension.m
//  XBLocalizedStringHandle
//
//  Created by xxb on 2018/8/16.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBLocalizedStringHandle+Extension.h"

@implementation XBLocalizedStringHandle (Extension)

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


-(NSArray *)getContentForStringFileWithPath:(NSString *)filePath deleteNote:(BOOL)deleteNote
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
@end
