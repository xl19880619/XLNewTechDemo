//
//  UXAPMTools.h
//  YellowRiver
//
//  Created by 谢雷 on 2018/3/22.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UXAPMTools : NSObject

+ (id)convertStringToJson:(NSString *)str;//字符串转为json对象

+ (NSString *)convertJsonToString:(id)jsonObject;//json对象转为字符串

/**
 去除字符串中的特殊符号，换行空格等

 @param string 字符串
 @return 格式化后等字符串
 */
+ (NSString *)removeSpecialCharactors:(NSString *)string;

//+ (NSString *)apiKeyWithParameters:(NSDictionary *)parameters;

+ (NSString *)MD5Hash:(NSString *)string;

@end
