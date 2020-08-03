//
//  NetworkMonitorManager.m
//  YellowRiver
//
//  Created by 谢雷 on 2018/1/31.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import "UXNetworkMonitorManager.h"
#import <objc/runtime.h>
#import "UXURLSessionDelegateProxy.h"
#import "UXNetworkMonitorModel.h"
#import "UXReachability.h"
#import "UXRumtime.h"
#import "UXAPMConfig.h"
#import "UXAPMTracker.h"

typedef void(^ux_URLSessionDataTaskCompletionHandler)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable);

typedef void (^ux_URLSessionDownloadTaskCompletionHandler)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error);

static char * const NSURLSessionTaskNetworkMonitorKey;

@interface UXNetworkMonitorManager()

@end

@implementation UXNetworkMonitorManager

+ (instancetype)sharedManager{
    static UXNetworkMonitorManager *_networkMonitorManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _networkMonitorManager = [[UXNetworkMonitorManager alloc] init];
    });
    return _networkMonitorManager;
}

- (void)dealloc{

}

- (instancetype)init{
    if (self = [super init]) {

    }
    return self;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
        NSURLSessionDataTask *task = [session dataTaskWithURL:nil];
#pragma clang diagnostic pop
        Class currentClass = task.class;
        SEL ux_selector = @selector(ux_resume);
        IMP originalUXResumeIMP =  method_getImplementation(class_getInstanceMethod([self class], ux_selector));

        while (class_getInstanceMethod(currentClass, @selector(resume))) {
            Class superClass = [currentClass superclass];
            IMP classResumeIMP = method_getImplementation(class_getInstanceMethod(currentClass, @selector(resume)));
            IMP superclassResumeIMP = method_getImplementation(class_getInstanceMethod(superClass, @selector(resume)));
            if (classResumeIMP != superclassResumeIMP &&
                originalUXResumeIMP != classResumeIMP) {
                Method uxResumeMethod = class_getInstanceMethod(self, ux_selector);
                if (class_addMethod(currentClass, ux_selector, method_getImplementation(uxResumeMethod), method_getTypeEncoding(uxResumeMethod))) {
                    method_exchangeImplementations(class_getInstanceMethod(currentClass, @selector(resume)), class_getInstanceMethod(currentClass, @selector(ux_resume)));
                }
            }
            currentClass = [currentClass superclass];
        }
        
        [task cancel];
        [session finishTasksAndInvalidate];
        
        ux_ClassMethodSwizzle([NSURLSession class], @selector(sessionWithConfiguration:delegate:delegateQueue:), @selector(ux_sessionWithConfiguration:delegate:delegateQueue:));
        
        ux_ClassSwizzle([NSURLSession class], @selector(dataTaskWithURL:), @selector(ux_dataTaskWithURL:));
        ux_ClassSwizzle([NSURLSession class], @selector(dataTaskWithRequest:), @selector(ux_dataTaskWithRequest:));
        ux_ClassSwizzle([NSURLSession class], @selector(downloadTaskWithURL:), @selector(ux_downloadTaskWithURL:));
        ux_ClassSwizzle([NSURLSession class], @selector(downloadTaskWithRequest:), @selector(ux_downloadTaskWithRequest:));
        ux_ClassSwizzle([NSURLSession class], @selector(downloadTaskWithResumeData:), @selector(ux_downloadTaskWithResumeData:));
        ux_ClassSwizzle([NSURLSession class], @selector(uploadTaskWithRequest:fromFile:), @selector(ux_uploadTaskWithRequest:fromFile:));
        ux_ClassSwizzle([NSURLSession class], @selector(uploadTaskWithRequest:fromData:), @selector(ux_uploadTaskWithRequest:fromData:));
        ux_ClassSwizzle([NSURLSession class], @selector(uploadTaskWithStreamedRequest:), @selector(ux_uploadTaskWithStreamedRequest:));
        
        ux_ClassSwizzle([NSURLSession class], @selector(dataTaskWithURL:completionHandler:), @selector(ux_dataTaskWithURL:completionHandler:));
        ux_ClassSwizzle([NSURLSession class], @selector(dataTaskWithRequest:completionHandler:), @selector(ux_dataTaskWithRequest:completionHandler:));
        ux_ClassSwizzle([NSURLSession class], @selector(downloadTaskWithURL:completionHandler:), @selector(ux_downloadTaskWithURL:completionHandler:));
        ux_ClassSwizzle([NSURLSession class], @selector(downloadTaskWithRequest:completionHandler:), @selector(ux_downloadTaskWithRequest:completionHandler:));
        ux_ClassSwizzle([NSURLSession class], @selector(downloadTaskWithResumeData:completionHandler:), @selector(ux_downloadTaskWithResumeData:completionHandler:));
        ux_ClassSwizzle([NSURLSession class], @selector(uploadTaskWithRequest:fromData:completionHandler:), @selector(ux_uploadTaskWithRequest:fromData:completionHandler:));
        ux_ClassSwizzle([NSURLSession class], @selector(uploadTaskWithRequest:fromFile:completionHandler:), @selector(ux_uploadTaskWithRequest:fromFile:completionHandler:));
        
        
    });
}

- (void)ux_resume{
    id object = objc_getAssociatedObject(self, &NSURLSessionTaskNetworkMonitorKey);
    if (object && [object isKindOfClass:[UXNetworkMonitorModel class]]) {
        UXNetworkMonitorModel *networkModel = (UXNetworkMonitorModel *)object;
        networkModel.requestCreateTime = [NSDate date].timeIntervalSince1970;
    }
    [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_resume",__FUNCTION__,__LINE__] type:UXAPMTrackerTypeNetwork];
    [self ux_resume];
}

+ (NSURLSession *)ux_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(nullable id <NSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue{
    return nil;
}

- (NSURLSessionDataTask *)ux_dataTaskWithURL:(NSURL *)url{
    return nil;
}

- (NSURLSessionDataTask *)ux_dataTaskWithRequest:(NSURLRequest *)request{
    return nil;
}

- (NSURLSessionDownloadTask *)ux_downloadTaskWithURL:(NSURL *)url{
    return nil;
}

- (NSURLSessionDownloadTask *)ux_downloadTaskWithRequest:(NSURLRequest *)request{
    return nil;
}

- (NSURLSessionDownloadTask *)ux_downloadTaskWithResumeData:(NSData *)resumeData{
    return nil;
}

- (NSURLSessionUploadTask *)ux_uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL{
    return nil;
}

- (NSURLSessionUploadTask *)ux_uploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)bodyData{
    return nil;
}

- (NSURLSessionUploadTask *)ux_uploadTaskWithStreamedRequest:(NSURLRequest *)request{
    return nil;
}

- (NSURLSessionDataTask *)ux_dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler{
    return nil;
}

- (NSURLSessionDownloadTask *)ux_downloadTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSURL * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler{
    return nil;
}

- (NSURLSessionDataTask *)ux_dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler{
    return nil;
}

- (NSURLSessionDownloadTask *)ux_downloadTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler{
    return nil;
}

- (NSURLSessionDownloadTask *)ux_downloadTaskWithResumeData:(NSData *)resumeData completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler{
    return nil;
}

- (NSURLSessionUploadTask *)ux_uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler{
    return nil;
}

- (NSURLSessionUploadTask *)ux_uploadTaskWithRequest:(NSURLRequest *)request fromData:(nullable NSData *)bodyData completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler{
    return nil;
}

@end

@interface NSURLSession (Monitor)

@property (strong, nonatomic) UXURLSessionDelegateProxy *sessionDelegateProxy;

@end

static void ux_exchangeMethod(Class originalClass, SEL originalSel, Class replacedClass, SEL replacedSel, SEL orginReplaceSel){
    // 原方法
    Method originalMethod = class_getInstanceMethod(originalClass, originalSel);
    // 替换方法
    Method replacedMethod = class_getInstanceMethod(replacedClass, replacedSel);
    // 如果没有实现 delegate 方法，则手动动态添加
    if (!originalMethod) {
        Method orginReplaceMethod = class_getInstanceMethod(replacedClass, orginReplaceSel);
        BOOL didAddOriginMethod = class_addMethod(originalClass, originalSel, method_getImplementation(orginReplaceMethod), method_getTypeEncoding(orginReplaceMethod));
        if (didAddOriginMethod) {
//            UXLog(@"did Add Origin Replace Method");
        }
        return;
    }
    // 向实现 delegate 的类中添加新的方法
    // 这里是向 originalClass 的 replaceSel（@selector(replace_webViewDidFinishLoad:)） 添加 replaceMethod
    BOOL didAddMethod = class_addMethod(originalClass, replacedSel, method_getImplementation(replacedMethod), method_getTypeEncoding(replacedMethod));
    if (didAddMethod) {
        // 添加成功
//        UXLog(@"class_addMethod_success --> (%@)", NSStringFromSelector(replacedSel));
        // 重新拿到添加被添加的 method,这里是关键(注意这里 originalClass, 不 replacedClass), 因为替换的方法已经添加到原类中了, 应该交换原类中的两个方法
        Method newMethod = class_getInstanceMethod(originalClass, replacedSel);
        // 实现交换
        method_exchangeImplementations(originalMethod, newMethod);
    }else{
        // 添加失败，则说明已经 hook 过该类的 delegate 方法，防止多次交换。
//        UXLog(@"Already hook class --> (%@)",NSStringFromClass(originalClass));
    }
}

@implementation NSURLSession (Monitor)

static char * const URLSessionDelegateProxyKey;

- (void)setSessionDelegateProxy:(UXURLSessionDelegateProxy *)sessionDelegateProxy{
    objc_setAssociatedObject(self, &URLSessionDelegateProxyKey, sessionDelegateProxy, OBJC_ASSOCIATION_ASSIGN);
}

- (UXURLSessionDelegateProxy *)sessionDelegateProxy{
    return objc_getAssociatedObject(self, &URLSessionDelegateProxyKey);
}

+ (NSURLSession *)ux_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(id <NSURLSessionDelegate>)delegate delegateQueue:(NSOperationQueue *)queue{
    if (delegate) {
        UXURLSessionDelegateProxy *proxy = [[UXURLSessionDelegateProxy alloc] initWithTarget:delegate];
        NSURLSession *session = [NSURLSession ux_sessionWithConfiguration:configuration delegate:proxy delegateQueue:queue];
        session.sessionDelegateProxy = proxy;
        ux_exchangeMethod([delegate class], @selector(URLSession:task:didFinishCollectingMetrics:), [self class], @selector(replace_URLSession:task:didFinishCollectingMetrics:), @selector(oriReplace_URLSession:task:didFinishCollectingMetrics:));

        return session;
    }
    return [self ux_sessionWithConfiguration:configuration delegate:delegate delegateQueue:queue];
}

#ifdef __IPHONE_10_0
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"

// iOS10 or iOS11 specific code

- (void)oriReplace_URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics{
//    UXLog(@"metrics:%@",metrics);
}

- (void)replace_URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics{
//    UXLog(@"metrics:%@",metrics);
    [self replace_URLSession:session task:task didFinishCollectingMetrics:metrics];
}

#pragma clang diagnostic pop
#endif

- (NSURLSessionDataTask *)ux_dataTaskWithURL:(NSURL *)url{
    UXNetworkMonitorModel *networkMonitor = [[UXNetworkMonitorModel alloc] init];
    NSURLSessionDataTask *task = [self ux_dataTaskWithURL:url];
    if (task) {
        task.networkMonitor = networkMonitor;
    }
    return task;
}

- (NSURLSessionDataTask *)ux_dataTaskWithRequest:(NSURLRequest *)request{
    UXNetworkMonitorModel *networkMonitor = [[UXNetworkMonitorModel alloc] init];
    NSURLSessionDataTask *task = [self ux_dataTaskWithRequest:request];
    if (task) {
        task.networkMonitor = networkMonitor;
    }
    return task;
}

- (NSURLSessionDownloadTask *)ux_downloadTaskWithURL:(NSURL *)url{
    UXNetworkMonitorModel *networkMonitor = [[UXNetworkMonitorModel alloc] init];
    NSURLSessionDownloadTask *task = [self ux_downloadTaskWithURL:url];
    if (task) {
        task.networkMonitor = networkMonitor;
    }
    return task;
}

- (NSURLSessionDownloadTask *)ux_downloadTaskWithRequest:(NSURLRequest *)request{
    UXNetworkMonitorModel *networkMonitor = [[UXNetworkMonitorModel alloc] init];
    NSURLSessionDownloadTask *task = [self ux_downloadTaskWithRequest:request];
    if (task) {
        task.networkMonitor = networkMonitor;
    }
    return task;
}

- (NSURLSessionDownloadTask *)ux_downloadTaskWithResumeData:(NSData *)resumeData{
    UXNetworkMonitorModel *networkMonitor = [[UXNetworkMonitorModel alloc] init];
    NSURLSessionDownloadTask *task = [self ux_downloadTaskWithResumeData:resumeData];
    if (task) {
        task.networkMonitor = networkMonitor;
    }
    return task;
}

- (NSURLSessionUploadTask *)ux_uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL{
    UXNetworkMonitorModel *networkMonitor = [[UXNetworkMonitorModel alloc] init];
    NSURLSessionUploadTask *task = [self ux_uploadTaskWithRequest:request fromFile:fileURL];
    if (task) {
        task.networkMonitor = networkMonitor;
    }
    return task;
}

- (NSURLSessionUploadTask *)ux_uploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)bodyData{
    UXNetworkMonitorModel *networkMonitor = [[UXNetworkMonitorModel alloc] init];
    NSURLSessionUploadTask *task = [self ux_uploadTaskWithRequest:request fromData:bodyData];
    if (task) {
        task.networkMonitor = networkMonitor;
    }
    return task;
}

- (NSURLSessionUploadTask *)ux_uploadTaskWithStreamedRequest:(NSURLRequest *)request{
    UXNetworkMonitorModel *networkMonitor = [[UXNetworkMonitorModel alloc] init];
    NSURLSessionUploadTask *task = [self ux_uploadTaskWithStreamedRequest:request];
    if (task) {
        task.networkMonitor = networkMonitor;
    }
    return task;
}

- (NSURLSessionDataTask *)ux_dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler{
    UXNetworkMonitorModel *networkMonitor = [[UXNetworkMonitorModel alloc] init];
    ux_URLSessionDataTaskCompletionHandler wrappedCompletionHandler;
     __block NSURLSessionDataTask *dataTask;
    if (completionHandler) {
        wrappedCompletionHandler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if ([UXAPMConfig sharedConfig].sdk_enabled) {
                [dataTask.networkMonitor collectBasicInfo:nil response:response error:error];
                [dataTask.networkMonitor requestFinished];
            }
            completionHandler(data, response, error);
        };
    }
    dataTask = [self ux_dataTaskWithURL:url completionHandler:wrappedCompletionHandler];
    if (dataTask) {
        dataTask.networkMonitor = networkMonitor;
    }
    return dataTask;
}

- (NSURLSessionDataTask *)ux_dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler{
    UXNetworkMonitorModel *networkMonitor = [[UXNetworkMonitorModel alloc] init];
    ux_URLSessionDataTaskCompletionHandler wrappedCompletionHandler;
    __block NSURLSessionDataTask *dataTask;
    if (completionHandler) {
        wrappedCompletionHandler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if ([UXAPMConfig sharedConfig].sdk_enabled) {
                [dataTask.networkMonitor collectBasicInfo:nil response:response error:error];
                [dataTask.networkMonitor requestFinished];
            }
            completionHandler(data, response, error);
        };
    }
    dataTask = [self ux_dataTaskWithRequest:request completionHandler:wrappedCompletionHandler];
    if (dataTask) {
        dataTask.networkMonitor = networkMonitor;
    }
    return dataTask;
}

- (NSURLSessionDownloadTask *)ux_downloadTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler{
    UXNetworkMonitorModel *networkMonitor = [[UXNetworkMonitorModel alloc] init];
    ux_URLSessionDownloadTaskCompletionHandler wrappedCompletionHandler;
    __block NSURLSessionDownloadTask *downloadTask;
    if (completionHandler) {
        wrappedCompletionHandler = ^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if ([UXAPMConfig sharedConfig].sdk_enabled) {
                [downloadTask.networkMonitor collectBasicInfo:nil response:response error:error];
                [downloadTask.networkMonitor requestFinished];
            }
            completionHandler(location, response, error);
        };
    }
    downloadTask = [self ux_downloadTaskWithURL:url completionHandler:wrappedCompletionHandler];
    if (downloadTask) {
        downloadTask.networkMonitor = networkMonitor;
    }
    return downloadTask;
}

- (NSURLSessionDownloadTask *)ux_downloadTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler{
    UXNetworkMonitorModel *networkMonitor = [[UXNetworkMonitorModel alloc] init];
    ux_URLSessionDownloadTaskCompletionHandler wrappedCompletionHandler;
    __block NSURLSessionDownloadTask *downloadTask;
    if (completionHandler) {
        wrappedCompletionHandler = ^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if ([UXAPMConfig sharedConfig].sdk_enabled) {
                [downloadTask.networkMonitor collectBasicInfo:nil response:response error:error];
                [downloadTask.networkMonitor requestFinished];
            }
            completionHandler(location, response, error);
        };
    }
    downloadTask = [self ux_downloadTaskWithRequest:request completionHandler:wrappedCompletionHandler];
    if (downloadTask) {
        downloadTask.networkMonitor = networkMonitor;
    }
    return downloadTask;
}

- (NSURLSessionDownloadTask *)ux_downloadTaskWithResumeData:(NSData *)resumeData completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler{
    UXNetworkMonitorModel *networkMonitor = [[UXNetworkMonitorModel alloc] init];
    ux_URLSessionDownloadTaskCompletionHandler wrappedCompletionHandler;
    __block NSURLSessionDownloadTask *downloadTask;
    if (completionHandler) {
        wrappedCompletionHandler = ^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if ([UXAPMConfig sharedConfig].sdk_enabled) {
                [downloadTask.networkMonitor collectBasicInfo:nil response:response error:error];
                [downloadTask.networkMonitor requestFinished];
            }
            completionHandler(location, response, error);
        };
    }
    downloadTask = [self ux_downloadTaskWithResumeData:resumeData completionHandler:wrappedCompletionHandler];
    if (downloadTask) {
        downloadTask.networkMonitor = networkMonitor;
    }
    return downloadTask;
}

- (NSURLSessionUploadTask *)ux_uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler{
    UXNetworkMonitorModel *networkMonitor = [[UXNetworkMonitorModel alloc] init];
    ux_URLSessionDataTaskCompletionHandler wrappedCompletionHandler;
    __block NSURLSessionUploadTask *uploadTask;
    if (completionHandler) {
        wrappedCompletionHandler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if ([UXAPMConfig sharedConfig].sdk_enabled) {
                [uploadTask.networkMonitor collectBasicInfo:nil response:response error:error];
                [uploadTask.networkMonitor requestFinished];
            }
            completionHandler(data, response, error);
        };
    }
    uploadTask = [self ux_uploadTaskWithRequest:request fromFile:fileURL completionHandler:wrappedCompletionHandler];
    if (uploadTask) {
        uploadTask.networkMonitor = networkMonitor;
    }
    return uploadTask;
}

- (NSURLSessionUploadTask *)ux_uploadTaskWithRequest:(NSURLRequest *)request fromData:(nullable NSData *)bodyData completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler{
    UXNetworkMonitorModel *networkMonitor = [[UXNetworkMonitorModel alloc] init];
    ux_URLSessionDataTaskCompletionHandler wrappedCompletionHandler;
    __block NSURLSessionUploadTask *uploadTask;
    if (completionHandler) {
        wrappedCompletionHandler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if ([UXAPMConfig sharedConfig].sdk_enabled) {
                [uploadTask.networkMonitor collectBasicInfo:nil response:response error:error];
                [uploadTask.networkMonitor requestFinished];
            }
            completionHandler(data, response, error);
        };
    }
    uploadTask = [self ux_uploadTaskWithRequest:request fromData:bodyData completionHandler:wrappedCompletionHandler];
    if (uploadTask) {
        uploadTask.networkMonitor = networkMonitor;
    }
    return uploadTask;
}


@end

@implementation NSObject (Monitor)

- (UXNetworkMonitorModel *)networkMonitor{
    return objc_getAssociatedObject(self, &NSURLSessionTaskNetworkMonitorKey);
}

- (void)setNetworkMonitor:(UXNetworkMonitorModel *)networkMonitor{
    if (networkMonitor) {
        objc_setAssociatedObject(self, &NSURLSessionTaskNetworkMonitorKey, networkMonitor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end
