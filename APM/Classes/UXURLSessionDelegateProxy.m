//
//  URLSessionDelegateProxy.m
//  YellowRiver
//
//  Created by 谢雷 on 2018/1/31.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import "UXURLSessionDelegateProxy.h"
#import "UXNetworkMonitorManager.h"
#import "UXNetworkMonitorModel.h"
#import "UXAPMConfig.h"
#import "UXAPMTracker.h"

@interface UXURLSessionDelegateProxy ()

@property (strong, nonatomic) id proxyTarget;

@end

@implementation UXURLSessionDelegateProxy

- (instancetype)initWithTarget:(id)target{
    self.proxyTarget = target;
    return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation{
    SEL sel = [invocation selector];
    if ( [self.proxyTarget respondsToSelector:sel]) {
        if (sel == @selector(URLSession:task:didCompleteWithError:)) {
            if ([UXAPMConfig sharedConfig].sdk_enabled) {
                __unsafe_unretained NSURLSessionTask *task = nil;
                __unsafe_unretained NSError *error = nil;
                [invocation getArgument:&task atIndex:3];
                [invocation getArgument:&error atIndex:4];
                
                //可能对象为空
                @try {
                    if (task && [task respondsToSelector:@selector(taskIdentifier)]) {
                        [invocation invokeWithTarget:self.proxyTarget];
                    }
                } @catch (NSException *exception) {
                    //handle exception if has handler method
                } @finally {
                    
                }
                
                [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_URLSession:task:%@didCompleteWithError:%@",__FUNCTION__,__LINE__,task,error] type:UXAPMTrackerTypeNetwork];
                UXNetworkMonitorModel *networkMonitor = task.networkMonitor;
                if (networkMonitor && [networkMonitor isKindOfClass:[UXNetworkMonitorModel class]]) {
                    networkMonitor.host = task.originalRequest.URL.host;
                    networkMonitor.apiPath = task.originalRequest.URL.path;
                    if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
                        networkMonitor.statusCode = [(NSHTTPURLResponse *)task.response statusCode];
                    }
                    networkMonitor.errorCode = error ? error.code : 0;
                    [networkMonitor requestFinished];
                }
                
            } else {
                [invocation invokeWithTarget:self.proxyTarget];
            }
        } else if (sel == @selector(URLSession:task:didFinishCollectingMetrics:)) {
            if ([UXAPMConfig sharedConfig].sdk_enabled) {
                if (@available(iOS 10.0, *)) {
                    __unsafe_unretained NSURLSessionTask *task = nil;
                    __unsafe_unretained NSURLSessionTaskMetrics *metrics;
                    [invocation getArgument:&task atIndex:3];
                    [invocation getArgument:&metrics atIndex:4];
                    [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_URLSession:task:%@didFinishCollectingMetrics:%@",__FUNCTION__,__LINE__,task,metrics] type:UXAPMTrackerTypeNetwork];

                    if (metrics.transactionMetrics.count > 0) {
                        UXNetworkMonitorModel *networkMonitor = task.networkMonitor;
                        if (networkMonitor && [networkMonitor isKindOfClass:[UXNetworkMonitorModel class]]) {
                            NSURLSessionTaskTransactionMetrics *transactionMetrics = metrics.transactionMetrics.firstObject;
                            networkMonitor.domainLookupStartTime = transactionMetrics.domainLookupStartDate.timeIntervalSince1970;
                            networkMonitor.domainLookupEndTime = transactionMetrics.domainLookupEndDate.timeIntervalSince1970;
                            networkMonitor.connectStartTime = transactionMetrics.connectStartDate.timeIntervalSince1970;
                            networkMonitor.connectEndTime = transactionMetrics.connectEndDate.timeIntervalSince1970;
                            networkMonitor.requestStartTime = transactionMetrics.requestStartDate.timeIntervalSince1970;
                            networkMonitor.requestEndTime = transactionMetrics.requestEndDate.timeIntervalSince1970;
                            networkMonitor.responseStartTime = transactionMetrics.responseStartDate.timeIntervalSince1970;
                        }
                    }
                    if (task && [task respondsToSelector:@selector(taskIdentifier)]) {
                        [invocation invokeWithTarget:self.proxyTarget];
                    }
                }
            } else {
                [invocation invokeWithTarget:self.proxyTarget];
            }
        } else {
            [invocation invokeWithTarget:self.proxyTarget];
        }
        
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
    NSMethodSignature *methodSignature = nil;
    if ([self.proxyTarget respondsToSelector:sel]) {
        methodSignature = [self.proxyTarget methodSignatureForSelector:sel];
    }
    return methodSignature;
}

@end
