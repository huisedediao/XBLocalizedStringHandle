//
//  ViewController.m
//  XBLocalizedStringHandle
//
//  Created by xxb on 2017/4/25.
//  Copyright © 2017年 xxb. All rights reserved.
//

#import "ViewController.h"
#import "XBLocalizedStringHandle.h"



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //NSString *dirPath = @"/Users/xxb/Desktop/SuperAppNew";
    //更换路径
    NSString *dirPath = @"/Users/sunlu/Desktop/h4_plus/h4_plus";

    //[[XBLocalizedStringHandle shared] findLocalizedStringAtPath:dirPath needValue:YES componentsByFolder:NO];
    
//    [[XBLocalizedStringHandle shared] replaceValueAtFilePath:savePath byFileAtPaht:@"/Users/xxb/Desktop/superApp_英文 2.txt"];
    
    
    //[[XBLocalizedStringHandle shared] compareContentAtFilePath:@"/Users/xxb/Desktop/superApp_英文.txt" andFileAtPaht:@"/Users/xxb/Desktop/xbLocalized.txt"];
    
    //[[XBLocalizedStringHandle shared] replaceValueAtFilePath:@"/Users/xxb/Desktop/test_old.h" byFileAtPaht:@"/Users/xxb/Desktop/test_new.h" needAddNotExist:YES];
    
    //读取内容，获得文件1
    [[XBLocalizedStringHandle shared] findLocalizedStringAtPath:dirPath needValue:YES componentsByFolder:YES];
    
    //和旧的比较，得到不同的内容，获得文件2
    //[[XBLocalizedStringHandle shared] compareContentAtFilePath:@"/Users/xxb/Desktop/xbLocalized.txt" andFileAtPaht:@"/Users/xxb/Desktop/superApp_英文.txt"];
    
    //用文件2 替换 文件1 中的内容，获得文件3
    //[[XBLocalizedStringHandle shared] replaceValueAtFilePath:@"/Users/xxb/Desktop/xbLocalized.txt" byFileAtPaht:@"/Users/xxb/Desktop/xbDifferentContent.txt" needAddNotExist:YES];
    
    //
    //[[XBLocalizedStringHandle shared] setValueEmptyAtFilePaht:@"/Users/xxb/Desktop/superApp_en_new.txt"];
    
//    NSString *keyFilePath = @"/Users/xxb/Downloads/aw1Plus_en.txt";
//
//    NSString *valueFilePath = @"/Users/xxb/Downloads/aw1Plus_fr.txt";
//
//    [[XBLocalizedStringHandle shared] getStringFileWithKeyFilePath:keyFilePath valueFilePaht:valueFilePath];
    
//    NSString *oldPath = @"/Users/sunlu/Desktop/db20_70_langurage.txt";
//    NSString *newPath = @"/Users/xxb/Desktop/xbIosStringFile.txt";
//
//    [[XBLocalizedStringHandle shared] replaceValueAtFilePath:oldPath byFileAtPaht:newPath needAddNotExist:NO];
    
}


@end
