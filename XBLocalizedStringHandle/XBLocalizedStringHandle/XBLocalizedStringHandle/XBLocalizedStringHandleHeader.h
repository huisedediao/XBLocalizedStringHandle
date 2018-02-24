//
//  XBLocalizedStringHandleHeader.h
//  XBLocalizedStringHandle
//
//  Created by xxb on 2017/4/26.
//  Copyright © 2017年 xxb. All rights reserved.
//

#ifndef XBLocalizedStringHandleHeader_h
#define XBLocalizedStringHandleHeader_h


//所有本地化自付出文件的路径
#define savePath [NSString stringWithFormat:@"%@/Desktop/xbLocalized.txt",NSHomeDirectory()]

//所有本地化自付出文件的路径
#define savePathForEmptyValue [NSString stringWithFormat:@"%@/Desktop/xbLocalizedEmptyValue.txt",NSHomeDirectory()]


//根据某份文件的内容替换另一份文件的存储路径
#define savePathForReplace [NSString stringWithFormat:@"%@/Desktop/xbLocalizedNew.txt",NSHomeDirectory()]


//两份文件中相同的内容的存储路径
#define savePathForSameContent [NSString stringWithFormat:@"%@/Desktop/xbSameContent.txt",NSHomeDirectory()]


//两份文件中不同的内容的存储路径
#define savePathForDifferentContent [NSString stringWithFormat:@"%@/Desktop/xbDifferentContent.txt",NSHomeDirectory()]


//根据keyFilePath和valueFilePath生成的.string文件的路径
#define savePathForIosStringFile [NSString stringWithFormat:@"%@/Desktop/xbIosStringFile.txt",NSHomeDirectory()]

#endif /* XBLocalizedStringHandleHeader_h */
