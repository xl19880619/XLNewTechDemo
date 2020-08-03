//
//  NetworkMonitorModel.h
//  YellowRiver
//
//  Created by 谢雷 on 2018/2/2.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NetworkMonitorDataType) {
    NetworkMonitorReponseTypeNormal,
    NetworkMonitorReponseTypeUpload,
    NetworkMonitorReponseTypeDownload
};

@interface UXNetworkMonitorModel : NSObject

@property (nonatomic) NetworkMonitorDataType monitorDataType;
@property (copy, nonatomic) NSString *networkType;

@property (nonatomic) NSInteger statusCode;
@property (nonatomic) NSInteger errorCode;

@property (copy, nonatomic) NSString *host;
@property (copy, nonatomic) NSString *apiPath;

/**
 客户端开始请求的时间
 */
@property (nonatomic) NSTimeInterval requestCreateTime;

/**
 客户端从服务器接收到最后一个字节的时间,请求完成时间
 */
@property (nonatomic) NSTimeInterval responseEndTime;

/**
 DNS解析开始时间
 */
@property (nonatomic) NSTimeInterval domainLookupStartTime;

/**
 DNS解析结束时间
 */
@property (nonatomic) NSTimeInterval domainLookupEndTime;

/**
 TCP/IP建立连接时间
 */
@property (nonatomic) NSTimeInterval connectStartTime;

/**
 TCP/IP建立连接完成
 */
@property (nonatomic) NSTimeInterval connectEndTime;

/**
 开始传输 HTTP 请求的 header 第一个字节的时间
 */
@property (nonatomic) NSTimeInterval requestStartTime;

/**
 HTTP 请求最后一个字节传输完成的时间,服务端开始处理时间
 */
@property (nonatomic) NSTimeInterval requestEndTime;

/**
 客户端从服务器接收到响应的第一个字节的时间,客户端开始接收数据时间
 */
@property (nonatomic) NSTimeInterval responseStartTime;

- (void)requestFinished;

- (void)collectBasicInfo:(NSURLSessionTask *)task response:(NSURLResponse *)response error:(NSError *)error;
@end
