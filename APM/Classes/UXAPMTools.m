//
//  UXAPMTools.m
//  YellowRiver
//
//  Created by 谢雷 on 2018/3/22.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import "UXAPMTools.h"
#import <CommonCrypto/CommonDigest.h>

@implementation UXAPMTools

+ (id)convertStringToJson:(NSString *)str{
    
    NSData *tempData = [str dataUsingEncoding:NSUTF8StringEncoding];
    if (tempData == nil) {
        return nil;
    }
    id tempJson = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableContainers error:nil];
    return tempJson;
}

+ (NSString *)convertJsonToString:(id)jsonObject{
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:nil];
    NSString *string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return string;
}

+ (NSString *)removeSpecialCharactors:(NSString *)string{
    NSString *value = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *components = [value componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];
    return [components componentsJoinedByString:@""];
}

+ (NSString *)MD5Hash:(NSString *)string{
    
    const char *cStr = [string UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

static unsigned char eax[] = {0,0x6D,0x72,0x31,0x3A,0x4B,0x4B,0x35,0x39,0x40,0x41,0x42,0x4B,0x63,0x68,0x78,0x81,0x55,0x57,0x6E,0x6E,0x21,0x23,0};

+ (NSString *)apiKeyWithParameters:(NSDictionary *)parameters{
    //对参数值进行索引排序
    NSArray *sortedKeys = [[parameters allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    NSMutableString *parameterString = [NSMutableString string];
    if (sortedKeys.count) {
        for (NSString *key in sortedKeys) {
            id object = parameters[key];
            //fix 适配参数类型不是string 并且可以转换成string的情况
            NSString *value;
            if ([object isKindOfClass:[NSString class]]) {
                value = parameters[key];
            } else {
                if ([object respondsToSelector:@selector(stringValue)]) {
                    value = [object stringValue];
                } else {
                    continue;
                }
            }
            
            //对参数value进行去掉空格和回车 格式化
            /*
             好好思考一番，其实不应该放在这里再处理，会造成httpbody的其他参数并没有进行格式化
             在服务端去计算apikey的时候肯定会不一样，不能要求服务端对参数也进行一次格式化
             */
//            NSString *string = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//
//            NSArray *components = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//            components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];
//
//            string = [components componentsJoinedByString:@""];
            
            if (parameterString.length) {
                [parameterString appendFormat:@"&%@=%@",key,value];
            } else {
                [parameterString appendFormat:@"%@=%@",key,value];
            }
            
        }
        
        [parameterString appendFormat:@"%c%c%c%c%c%c%c%c%c%c%c",eax[1],eax[3],eax[5],eax[7],eax[9],eax[11],eax[13],eax[15],eax[17],eax[19],eax[21]];
    } else {
        //没有参数情况下
        [parameterString appendFormat:@"%c%c%c%c%c%c%c%c%c%c%c",eax[1],eax[3],eax[5],eax[7],eax[9],eax[11],eax[13],eax[15],eax[17],eax[19],eax[21]];
    }
    
    NSString *output = [self MD5Hash:parameterString].lowercaseString;
    
    NSString *ptkValue = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                          [output substringWithRange:NSMakeRange(20, 1)],
                          [output substringWithRange:NSMakeRange(15, 1)],
                          [output substringWithRange:NSMakeRange(0, 1)],
                          [output substringWithRange:NSMakeRange(3, 1)],
                          [output substringWithRange:NSMakeRange(1, 1)],
                          [output substringWithRange:NSMakeRange(5, 1)]];
    //    return @"test";
    return ptkValue;
}

@end
