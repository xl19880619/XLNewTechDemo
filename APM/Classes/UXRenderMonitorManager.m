//
//  RenderMonitorManager.m
//  YellowRiver
//
//  Created by 谢雷 on 2018/2/2.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import "UXRenderMonitorManager.h"
#import "UXAPMReporter.h"
#import "UXAPMConfig.h"
#import "UXAPMTracker.h"
#import "UXRumtime.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "UXRenderMonitorModel.h"
#import "UXAPMTools.h"

//static inline const char * _Nonnull * _Nullable UXClassNamesInMainBundle(unsigned int *outCount) {
//    NSString *executablePath = [[NSBundle mainBundle] executablePath];
//    const char * _Nonnull * _Nullable classNames = objc_copyClassNamesForImage([executablePath UTF8String], outCount);
//    return classNames;
//}

@implementation UXRenderMonitorManager

+ (instancetype)sharedManager{
    static UXRenderMonitorManager *_renderMonitorManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _renderMonitorManager = [[UXRenderMonitorManager alloc] init];
    });
    return _renderMonitorManager;
}

/**
 通过交换方法，统计ViewController生命周期，已经重新渲染等方法
 */
+ (void)load{
    unsigned int count = 0;
    NSString *executablePath = [[NSBundle mainBundle] executablePath];
    const char * _Nonnull * _Nullable classes = objc_copyClassNamesForImage([executablePath UTF8String], &count);
    NSMutableArray *controllerClasses = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        Class class = objc_getMetaClass(classes[i]);
        if ([class isSubclassOfClass:object_getClass([UIViewController class])]) {
            Class controllerClass = objc_getClass(classes[i]);
            [controllerClasses addObject:NSStringFromClass(controllerClass)];
        }
    }
    free(classes);
    
    if (controllerClasses.count) {
        for (NSString *className in controllerClasses) {
            const char * classChar = [className UTF8String];
            Class class = objc_getClass(classChar);
            [self ux_hook_subOfController:class];
        }
    }
    
}

+ (void)ux_hook_subOfController:(Class )class{
//    if (![class respondsToSelector:@selector(ux_jump_initialize:)]) {
//        ux_hookClass_CopyAMetaMethod(self, class, @selector(ux_jump_initialize:));
//    }
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"ux_%s_initialize",class_getName(class)]);
    
    /*
     IMP cacheHandlerIMP = imp_implementationWithBlock(^(id _self){
     [_self viewDidLoad_cacheHandler];
     cacheHandler(_self);
     });
     */
    
    /*
     SEL selector = NSSelectorFromString(@"setMailComposeDelegate:");
     IMP imp = [vc methodForSelector:selector];
     void (*func)(id, SEL, id) = (void *)imp;
     func(vc, selector, delegater);
     */
    IMP impBlock1 = imp_implementationWithBlock(^id(id _self) {
        [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_init_block1:%@",__FUNCTION__,__LINE__,_self] type:UXAPMTrackerTypeUI];
        IMP imp = [_self methodForSelector:selector];
        id (*func)(id, SEL) = (void*)imp;
        id controller = func(_self,selector);
        [UXRenderMonitorManager ux_jump_initialize:controller];
        return controller;
    });
    
    IMP initIMP = method_getImplementation(class_getInstanceMethod(class, @selector(init)));
    IMP impBlock2 = imp_implementationWithBlock(^id(id _self) {
        if (![class_getSuperclass(_self) isEqual:[NSObject class]]) {
//            IMP imp = [UXRenderMonitorManager getImplementationOf:@selector(init) class:[_self class]];
            [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_init_block2:%@",__FUNCTION__,__LINE__,_self] type:UXAPMTrackerTypeUI];
            id (*func)(id, SEL) = (void*)initIMP;
            id controller = func(_self,@selector(init));
            /**
             这个地方构造super结构体，想objc_msgSendSuper里面发送消息
             达到类似super直接调用的目的，避免super编译错误
             */
//            struct objc_super superReceiver = {
//                _self,
//                //这个地方不是superClass，而是持有该selector的class
//                class_getSuperclass([_self class])
//            };
//            id controller = ((id (*)(id, SEL))objc_msgSendSuper)((__bridge id)(&superReceiver), @selector(init));
            
            [UXRenderMonitorManager ux_jump_initialize:controller];
            return controller;
        }
        return nil;
    });
    
    
    /**
     这里猜测交换的初始化方法不是initialize的类方法，而是init方法。
     首先调研initialize执行原理（
     网上大部分博客是错误的，都以init的方法做测试，
     误导了很多人以为initialize方法就会在初始化时调用）
     ，是在触发该类的任意方法，都会调用类方法，而且调用次数不定，
     在调用swizzle方法之前，已经执行完initialize方法，根本hook不到；
     
     替换init的方法之前，声明了2个Block，并初始化IMP，因为controller存在两种情况；
     1.重写了init方法的controller调用block1，做正常交换即可
     2.未重写init方法的controller，需要调用super，调用原理objc_msgSendSuper，比较复杂，
     但查阅大量资料同时也理清了self与super微妙的关系
     */
    ux_Swizzle_orReplaceWithIMPs(class, @selector(init), selector, impBlock2, impBlock1);
}

+ (BOOL)checkIfObject:(id)object overridesSelector:(SEL)selector {
    
    Class objSuperClass = class_getSuperclass([object class]);
    BOOL isMethodOverridden = NO;
    
    while (objSuperClass != Nil) {
        
        IMP subMethod = method_getImplementation(class_getInstanceMethod([object class], selector));
        IMP superMethod = method_getImplementation(class_getInstanceMethod(objSuperClass, selector));
        isMethodOverridden = subMethod != superMethod;
        
        if (isMethodOverridden) {
            break;
        }
        
        objSuperClass = class_getSuperclass(objSuperClass);
    }
    
    return isMethodOverridden;
}

- (instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

+ (void)ux_jump_initialize:(id)controller {
    NSString *className = NSStringFromClass([controller class]);
    if ([className rangeOfString:@"RACSelectorSignal"].location != NSNotFound || [className rangeOfString:@"_Aspects_"].location != NSNotFound) {
        
    } else {
        SEL flagSelector = NSSelectorFromString(@"ux_vc_flag");
        if (!ux_isClassItSelfHasMethod([controller class], flagSelector)) {
            IMP impBlock = imp_implementationWithBlock(^void() {
                return;
            });
            [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_hook_instance:%@",__FUNCTION__,__LINE__,controller] type:UXAPMTrackerTypeUI];
            class_addMethod([controller class], flagSelector, impBlock, "v@:");
            [UXRenderMonitorManager hook_loadView:controller];
            [UXRenderMonitorManager hook_viewDidLoad:controller];
            [UXRenderMonitorManager hook_viewWillAppear:controller];
            [UXRenderMonitorManager hook_viewWillLayoutSubviews:controller];
            [UXRenderMonitorManager hook_viewDidLayoutSubviews:controller];
            [UXRenderMonitorManager hook_viewDidAppear:controller];
            [UXRenderMonitorManager hook_viewWillDisappear:controller];
            [UXRenderMonitorManager hook_viewDidDisappear:controller];
        }
    }
}

+ (void)hook_loadView:(id)controller{
    Class currentClass = [controller class];
    IMP loadViewIMP = method_getImplementation(class_getInstanceMethod(currentClass, @selector(loadView)));
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"ux_%s_loadView",class_getName(currentClass)]);
    
    IMP impBlock1 = imp_implementationWithBlock(^void(id _self) {
        if ([UXAPMConfig sharedConfig].sdk_enabled) {
            UXRenderMonitorModel *model = [[UXRenderMonitorModel alloc] init];
            model.className = NSStringFromClass([_self class]);
            model.uploadTitle = model.className;
            if ([_self isKindOfClass:[UIViewController class]]) {
                UIViewController *controller = (UIViewController *)_self;
                [controller generateUniqueID];
                model.uniqueID = controller.uniqueID;
            }
            [[UXAPMReporter sharedReporter] addRenderModel:model];
            [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_hook_loadView_block1:%@",__FUNCTION__,__LINE__,_self] type:UXAPMTrackerTypeUI];
        }
        
        if ([UXAPMConfig sharedConfig].sdk_enabled) {
            
            UIViewController *controller = (UIViewController *)_self;
            UXRenderMonitorModel *model = [[UXAPMReporter sharedReporter] modelWithUniqueID:controller.uniqueID];
            model.loadViewStartTime = @([[NSDate date] timeIntervalSince1970]*1000).longLongValue;
            
            IMP imp = [_self methodForSelector:selector];
            void (*func)(id, SEL) = (void*)imp;
            func(_self,selector);
            
            if (model && !model.isViewDidAppear) {
                [model appendDetailInfoWithMethodName:@"loadView" begin:model.loadViewStartTime end:@([[NSDate date] timeIntervalSince1970]*1000).longLongValue];
            }
        } else {
            IMP imp = [_self methodForSelector:selector];
            void (*func)(id, SEL) = (void*)imp;
            func(_self,selector);
        }
        
        return ;
    });
    
    IMP impBlock2 = imp_implementationWithBlock(^void(id _self) {
        if (![class_getSuperclass(_self) isEqual:[NSObject class]]) {
            if ([UXAPMConfig sharedConfig].sdk_enabled) {
                UXRenderMonitorModel *model = [[UXRenderMonitorModel alloc] init];
                model.className = NSStringFromClass([_self class]);
                model.uploadTitle = model.className;
                if ([_self isKindOfClass:[UIViewController class]]) {
                    UIViewController *controller = (UIViewController *)_self;
                    [controller generateUniqueID];
                    model.uniqueID = controller.uniqueID;

                }
                [[UXAPMReporter sharedReporter] addRenderModel:model];
                [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_hook_loadView_block2:%@",__FUNCTION__,__LINE__,_self] type:UXAPMTrackerTypeUI];
            }
            
            if ([UXAPMConfig sharedConfig].sdk_enabled) {
                UIViewController *controller = (UIViewController *)_self;
                UXRenderMonitorModel *model = [[UXAPMReporter sharedReporter] modelWithUniqueID:controller.uniqueID];
                model.loadViewStartTime = @([[NSDate date] timeIntervalSince1970]*1000).longLongValue;
                
                void (*func)(id, SEL) = (void*)loadViewIMP;
                func(_self,@selector(loadView));
                
                if (model && !model.isViewDidAppear) {
                    [model appendDetailInfoWithMethodName:@"loadView" begin:model.loadViewStartTime end:@([[NSDate date] timeIntervalSince1970]*1000).longLongValue];
                }
            } else {
                void (*func)(id, SEL) = (void*)loadViewIMP;
                func(_self,@selector(loadView));
            }
            
        }
        return ;
    });
    
    ux_Swizzle_orReplaceWithIMPs(currentClass, @selector(loadView), selector, impBlock2, impBlock1);
}

+ (void)hook_viewDidLoad:(id)controller{
    Class currentClass = [controller class];
    IMP viewDidLoadIMP = method_getImplementation(class_getInstanceMethod(currentClass, @selector(viewDidLoad)));
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"ux_%s_viewDidLoad",class_getName(currentClass)]);

    IMP impBlock1 = imp_implementationWithBlock(^void(id _self) {

        if ([UXAPMConfig sharedConfig].sdk_enabled) {
            
            UIViewController *controller = (UIViewController *)_self;
            UXRenderMonitorModel *model = [[UXAPMReporter sharedReporter] modelWithUniqueID:controller.uniqueID];
            long long start = @([[NSDate date] timeIntervalSince1970]*1000).longLongValue;
            
            IMP imp = [_self methodForSelector:selector];
            void (*func)(id, SEL) = (void*)imp;
            func(_self,selector);
            if (model && !model.isViewDidAppear) {
                [model appendDetailInfoWithMethodName:@"viewDidLoad" begin:start end:@([[NSDate date] timeIntervalSince1970]*1000).longLongValue];
            }
        } else {
            IMP imp = [_self methodForSelector:selector];
            void (*func)(id, SEL) = (void*)imp;
            func(_self,selector);
        }

        return ;
    });
    
    IMP impBlock2 = imp_implementationWithBlock(^void(id _self) {
        if (![class_getSuperclass(_self) isEqual:[NSObject class]]) {

            if ([UXAPMConfig sharedConfig].sdk_enabled) {
                UIViewController *controller = (UIViewController *)_self;
                UXRenderMonitorModel *model = [[UXAPMReporter sharedReporter] modelWithUniqueID:controller.uniqueID];
                long long start = @([[NSDate date] timeIntervalSince1970]*1000).longLongValue;
                
                void (*func)(id, SEL) = (void*)viewDidLoadIMP;
                func(_self,@selector(viewDidLoad));
                
                if (model && !model.isViewDidAppear) {
                    [model appendDetailInfoWithMethodName:@"viewDidLoad" begin:start end:@([[NSDate date] timeIntervalSince1970]*1000).longLongValue];
                }
            } else {
                void (*func)(id, SEL) = (void*)viewDidLoadIMP;
                func(_self,@selector(viewDidLoad));
            }

        }
        return ;
    });

    ux_Swizzle_orReplaceWithIMPs(currentClass, @selector(viewDidLoad), selector, impBlock2, impBlock1);
}

+ (void)hook_viewWillAppear:(id)controller{
    Class currentClass = [controller class];
    SEL viewWillAppearSelector = @selector(viewWillAppear:);
    IMP superIMP = method_getImplementation(class_getInstanceMethod(currentClass, viewWillAppearSelector));
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"ux_%s_viewWillAppear:",class_getName(currentClass)]);
    
    IMP impBlock1 = imp_implementationWithBlock(^void(id _self,BOOL animated) {
        
        if ([UXAPMConfig sharedConfig].sdk_enabled) {
            [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_hook_viewWillAppear_block1_animated:%@,:%@",__FUNCTION__,__LINE__,_self,@(animated)] type:UXAPMTrackerTypeUI];
            UIViewController *controller = (UIViewController *)_self;
            UXRenderMonitorModel *model = [[UXAPMReporter sharedReporter] modelWithUniqueID:controller.uniqueID];
            
            long long start = @([[NSDate date] timeIntervalSince1970]*1000).longLongValue;
            
            IMP imp = [_self methodForSelector:selector];
            void (*func)(id, SEL, BOOL) = (void*)imp;
            func(_self,selector,animated);
            
            if (model && model.viewWillAppearTimes.count == model.viewDidAppearTimes.count) {
                model.viewWillAppearTimes = [[NSArray arrayWithArray:model.viewWillAppearTimes] arrayByAddingObject:@(start)];
            }
            
            if (model && !model.isViewDidAppear) {
                [model appendDetailInfoWithMethodName:@"viewWillAppear" begin:start end:@([[NSDate date] timeIntervalSince1970]*1000).longLongValue];
            }
            
        } else {
            IMP imp = [_self methodForSelector:selector];
            void (*func)(id, SEL, BOOL) = (void*)imp;
            func(_self,selector,animated);
        }
        return ;
    });
    
    IMP impBlock2 = imp_implementationWithBlock(^void(id _self,BOOL animated) {
        if (![class_getSuperclass(_self) isEqual:[NSObject class]]) {
            if ([UXAPMConfig sharedConfig].sdk_enabled) {
  
                [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_hook_viewWillAppear_block2_animated:%@,:%@",__FUNCTION__,__LINE__,_self,@(animated)] type:UXAPMTrackerTypeUI];
                
                UIViewController *controller = (UIViewController *)_self;
                UXRenderMonitorModel *model = [[UXAPMReporter sharedReporter] modelWithUniqueID:controller.uniqueID];
                
                long long start = @([[NSDate date] timeIntervalSince1970]*1000).longLongValue;
                
                void (*func)(id, SEL, BOOL) = (void*)superIMP;
                func(_self,viewWillAppearSelector,animated);
                
                if (model && model.viewWillAppearTimes.count == model.viewDidAppearTimes.count) {
                    model.viewWillAppearTimes = [[NSArray arrayWithArray:model.viewWillAppearTimes] arrayByAddingObject:@(start)];
                }
                
                if (model && !model.isViewDidAppear) {
                    [model appendDetailInfoWithMethodName:@"viewWillAppear" begin:start end:@([[NSDate date] timeIntervalSince1970]*1000).longLongValue];
                }
                
            } else {
                void (*func)(id, SEL, BOOL) = (void*)superIMP;
                func(_self,viewWillAppearSelector,animated);
            }

        }
        return ;
    });
    
    ux_Swizzle_orReplaceWithIMPs(currentClass, viewWillAppearSelector, selector, impBlock2, impBlock1);
}

+ (void)hook_viewWillDisappear:(id)controller{
    Class currentClass = [controller class];
    SEL viewWillDisappearSelector = @selector(viewWillDisappear:);
    IMP superIMP = method_getImplementation(class_getInstanceMethod(currentClass, viewWillDisappearSelector));
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"ux_%s_viewWillDisappear:",class_getName(currentClass)]);
    
    IMP impBlock1 = imp_implementationWithBlock(^void(id _self, BOOL animated) {
        
        if ([UXAPMConfig sharedConfig].sdk_enabled) {
            
            [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_hook_viewWillDisappear_block1_animated:%@,:%@",__FUNCTION__,__LINE__,_self,@(animated)] type:UXAPMTrackerTypeUI];
            
            long long start = @([[NSDate date] timeIntervalSince1970]*1000).longLongValue;
            
            IMP imp = [_self methodForSelector:selector];
            void (*func)(id, SEL, BOOL) = (void*)imp;
            func(_self,selector,animated);
            
            if (![UXAPMReporter sharedReporter].currendModel.viewWillDisappearCalled) {
                [UXAPMReporter sharedReporter].currendModel.viewWillDisappearCalled = YES;
                [[UXAPMReporter sharedReporter].currendModel appendDetailInfoWithMethodName:@"viewWillDisappear" begin:start end:@([[NSDate date] timeIntervalSince1970]*1000).longLongValue];
            }
            
        } else {
            IMP imp = [_self methodForSelector:selector];
            void (*func)(id, SEL, BOOL) = (void*)imp;
            func(_self,selector,animated);
        }
        
        return ;
    });
    
    IMP impBlock2 = imp_implementationWithBlock(^void(id _self, BOOL animated) {
        if (![class_getSuperclass(_self) isEqual:[NSObject class]]) {
            if ([UXAPMConfig sharedConfig].sdk_enabled) {
                
                [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_hook_viewWillDisappear_block2_animated:%@,:%@",__FUNCTION__,__LINE__,_self,@(animated)] type:UXAPMTrackerTypeUI];
                
                long long start = @([[NSDate date] timeIntervalSince1970]*1000).longLongValue;
                
                void (*func)(id, SEL, BOOL) = (void*)superIMP;
                func(_self,viewWillDisappearSelector,animated);
                
                if (![UXAPMReporter sharedReporter].currendModel.viewWillDisappearCalled) {
                    [UXAPMReporter sharedReporter].currendModel.viewWillDisappearCalled = YES;
                    [[UXAPMReporter sharedReporter].currendModel appendDetailInfoWithMethodName:@"viewWillDisappear" begin:start end:@([[NSDate date] timeIntervalSince1970]*1000).longLongValue];
                }
            } else {
                void (*func)(id, SEL, BOOL) = (void*)superIMP;
                func(_self,viewWillDisappearSelector,animated);
            }
            
        }
        return ;
    });
    
    ux_Swizzle_orReplaceWithIMPs(currentClass, viewWillDisappearSelector, selector, impBlock2, impBlock1);
}

+ (void)hook_viewDidAppear:(id)controller{
    Class currentClass = [controller class];
    SEL viewDidAppearSelector = @selector(viewDidAppear:);
    IMP superIMP = method_getImplementation(class_getInstanceMethod(currentClass, viewDidAppearSelector));
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"ux_%s_viewDidAppear:",class_getName(currentClass)]);
    
    IMP impBlock1 = imp_implementationWithBlock(^void(id _self, BOOL animated) {
        
        if ([UXAPMConfig sharedConfig].sdk_enabled) {
            
            [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_hook_viewDidAppear_block1_animated:%@,:%@",__FUNCTION__,__LINE__,_self,@(animated)] type:UXAPMTrackerTypeUI];
            
            UIViewController *controller = (UIViewController *)_self;
            UXRenderMonitorModel *model = [[UXAPMReporter sharedReporter] modelWithUniqueID:controller.uniqueID];
            
            long long start = @([[NSDate date] timeIntervalSince1970]*1000).longLongValue;
            
            IMP imp = [_self methodForSelector:selector];
            void (*func)(id, SEL, BOOL) = (void*)imp;
            func(_self,selector,animated);
            
            if (model && !model.loadViewEndTime && model.loadViewStartTime) {
                model.loadViewEndTime =  @([[NSDate date] timeIntervalSince1970]*1000).longLongValue;
                [UXAPMTracker trackMessage:[NSString stringWithFormat:@"[FUNCTION:%s] [Line:%d]_addRenderLife:%@_duration:%lld",__FUNCTION__,__LINE__,_self,model.loadViewEndTime-model.loadViewStartTime]];
            }
            
            if (model && model.viewWillAppearTimes.count - model.viewDidAppearTimes.count == 1) {
                model.viewDidAppearTimes = [[NSArray arrayWithArray:model.viewDidAppearTimes] arrayByAddingObject:@(start)];
            }
            
            if (!model.isViewDidAppear) {
                model.isViewDidAppear = YES;
                [model appendDetailInfoWithMethodName:@"viewDidAppear" begin:start end:model.loadViewEndTime];
            }

        } else {
            IMP imp = [_self methodForSelector:selector];
            void (*func)(id, SEL, BOOL) = (void*)imp;
            func(_self,selector,animated);
        }

        return ;
    });
    
    IMP impBlock2 = imp_implementationWithBlock(^void(id _self, BOOL animated) {
        if (![class_getSuperclass(_self) isEqual:[NSObject class]]) {
            if ([UXAPMConfig sharedConfig].sdk_enabled) {
                
                [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_hook_viewDidAppear_block2_animated:%@,:%@",__FUNCTION__,__LINE__,_self,@(animated)] type:UXAPMTrackerTypeUI];
                
                UIViewController *controller = (UIViewController *)_self;
                UXRenderMonitorModel *model = [[UXAPMReporter sharedReporter] modelWithUniqueID:controller.uniqueID];
                
                long long start = @([[NSDate date] timeIntervalSince1970]*1000).longLongValue;
                
                void (*func)(id, SEL, BOOL) = (void*)superIMP;
                func(_self,viewDidAppearSelector,animated);
                
                if (model && !model.loadViewEndTime && model.loadViewStartTime) {
                    model.loadViewEndTime =  @([[NSDate date] timeIntervalSince1970]*1000).longLongValue;
                    [UXAPMTracker trackMessage:[NSString stringWithFormat:@"[FUNCTION:%s] [Line:%d]_addRenderLife:%@_duration:%lld",__FUNCTION__,__LINE__,_self,model.loadViewEndTime-model.loadViewStartTime]];
                }
                
                if (model && model.viewWillAppearTimes.count - model.viewDidAppearTimes.count == 1) {
                    model.viewDidAppearTimes = [[NSArray arrayWithArray:model.viewDidAppearTimes] arrayByAddingObject:@(start)];
                }
                
                if (!model.isViewDidAppear) {
                    model.isViewDidAppear = YES;
                    [model appendDetailInfoWithMethodName:@"viewDidAppear" begin:start end:model.loadViewEndTime];
                }

                
            } else {
                void (*func)(id, SEL, BOOL) = (void*)superIMP;
                func(_self,viewDidAppearSelector,animated);
            }

        }
        return ;
    });
    
    ux_Swizzle_orReplaceWithIMPs(currentClass, viewDidAppearSelector, selector, impBlock2, impBlock1);
}

+ (void)hook_viewDidDisappear:(id)controller{
    Class currentClass = [controller class];
    SEL viewDidDisappearSelector = @selector(viewDidDisappear:);
    IMP superIMP = method_getImplementation(class_getInstanceMethod(currentClass, viewDidDisappearSelector));
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"ux_%s_viewDidDisappear:",class_getName(currentClass)]);
    
    IMP impBlock1 = imp_implementationWithBlock(^void(id _self, BOOL animated) {
        
        if ([UXAPMConfig sharedConfig].sdk_enabled) {
            
            [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_hook_viewDidDisappear_block1_animated:%@,:%@",__FUNCTION__,__LINE__,_self,@(animated)] type:UXAPMTrackerTypeUI];
            
            long long start = @([[NSDate date] timeIntervalSince1970]*1000).longLongValue;
            
            IMP imp = [_self methodForSelector:selector];
            void (*func)(id, SEL, BOOL) = (void*)imp;
            func(_self,selector,animated);
            
            if (![UXAPMReporter sharedReporter].currendModel.viewDidDisappearCalled) {
                [UXAPMReporter sharedReporter].currendModel.viewDidDisappearCalled = YES;
                [[UXAPMReporter sharedReporter].currendModel appendDetailInfoWithMethodName:@"viewDidDisappear" begin:start end:@([[NSDate date] timeIntervalSince1970]*1000).longLongValue];
            }
            
        } else {
            IMP imp = [_self methodForSelector:selector];
            void (*func)(id, SEL, BOOL) = (void*)imp;
            func(_self,selector,animated);
        }
        
        return ;
    });
    
    IMP impBlock2 = imp_implementationWithBlock(^void(id _self, BOOL animated) {
        if (![class_getSuperclass(_self) isEqual:[NSObject class]]) {
            if ([UXAPMConfig sharedConfig].sdk_enabled) {
                
                [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_hook_viewDidDisappear_block2_animated:%@,:%@",__FUNCTION__,__LINE__,_self,@(animated)] type:UXAPMTrackerTypeUI];
                
                long long start = @([[NSDate date] timeIntervalSince1970]*1000).longLongValue;
                
                void (*func)(id, SEL, BOOL) = (void*)superIMP;
                func(_self,viewDidDisappearSelector,animated);
                
                if (![UXAPMReporter sharedReporter].currendModel.viewDidDisappearCalled) {
                    [UXAPMReporter sharedReporter].currendModel.viewDidDisappearCalled = YES;
                    [[UXAPMReporter sharedReporter].currendModel appendDetailInfoWithMethodName:@"viewDidDisappear" begin:start end:@([[NSDate date] timeIntervalSince1970]*1000).longLongValue];
                }
            } else {
                void (*func)(id, SEL, BOOL) = (void*)superIMP;
                func(_self,viewDidDisappearSelector,animated);
            }
            
        }
        return ;
    });
    
    ux_Swizzle_orReplaceWithIMPs(currentClass, viewDidDisappearSelector, selector, impBlock2, impBlock1);
}

+ (void)hook_viewWillLayoutSubviews:(id)controller{
    Class currentClass = [controller class];
    SEL viewWillLayoutSubviewsSelector = @selector(viewWillLayoutSubviews);
    IMP superIMP = method_getImplementation(class_getInstanceMethod(currentClass, viewWillLayoutSubviewsSelector));
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"ux_%s_viewWillLayoutSubviews",class_getName(currentClass)]);
    
    IMP impBlock1 = imp_implementationWithBlock(^void(id _self) {
        if ([UXAPMConfig sharedConfig].sdk_enabled) {
            
            [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_hook_viewWillLayoutSubviews_block1:%@",__FUNCTION__,__LINE__,_self] type:UXAPMTrackerTypeUI];
            
            UIViewController *controller = (UIViewController *)_self;
            UXRenderMonitorModel *model = [[UXAPMReporter sharedReporter] modelWithUniqueID:controller.uniqueID];
            
            long long start = @([[NSDate date] timeIntervalSince1970]*1000).longLongValue;
            
            IMP imp = [_self methodForSelector:selector];
            void (*func)(id, SEL) = (void*)imp;
            func(_self,selector);
            
            if (model && model.viewWillLayoutTimes.count == model.viewDidLayoutTimes.count) {
                model.viewWillLayoutTimes = [[NSArray arrayWithArray:model.viewWillLayoutTimes] arrayByAddingObject:@(start)];
            }
            if (model && !model.isViewDidAppear) {
                [model appendDetailInfoWithMethodName:@"viewWillLayoutSubviews" begin:start end:@([[NSDate date] timeIntervalSince1970]*1000).longLongValue];
            }
            
        } else {
            IMP imp = [_self methodForSelector:selector];
            void (*func)(id, SEL) = (void*)imp;
            func(_self,selector);
        }

        return ;
    });
    
    IMP impBlock2 = imp_implementationWithBlock(^void(id _self) {
        if (![class_getSuperclass(_self) isEqual:[NSObject class]]) {
            if ([UXAPMConfig sharedConfig].sdk_enabled) {
                [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_hook_viewWillLayoutSubviews_block2:%@",__FUNCTION__,__LINE__,_self] type:UXAPMTrackerTypeUI];
                
                UIViewController *controller = (UIViewController *)_self;
                UXRenderMonitorModel *model = [[UXAPMReporter sharedReporter] modelWithUniqueID:controller.uniqueID];
                
                long long start = @([[NSDate date] timeIntervalSince1970]*1000).longLongValue;
                
                void (*func)(id, SEL) = (void*)superIMP;
                func(_self,viewWillLayoutSubviewsSelector);
                
                if (model && model.viewWillLayoutTimes.count == model.viewDidLayoutTimes.count) {
                    model.viewWillLayoutTimes = [[NSArray arrayWithArray:model.viewWillLayoutTimes] arrayByAddingObject:@(start)];
                }
                if (model && !model.isViewDidAppear) {
                    [model appendDetailInfoWithMethodName:@"viewWillLayoutSubviews" begin:start end:@([[NSDate date] timeIntervalSince1970]*1000).longLongValue];
                }
                
            } else {
                void (*func)(id, SEL) = (void*)superIMP;
                func(_self,viewWillLayoutSubviewsSelector);
            }

        }
        return ;
    });
    
    ux_Swizzle_orReplaceWithIMPs(currentClass, viewWillLayoutSubviewsSelector, selector, impBlock2, impBlock1);
}

+ (void)hook_viewDidLayoutSubviews:(id)controller{
    Class currentClass = [controller class];
    SEL viewDidLayoutSubviewsSelector = @selector(viewDidLayoutSubviews);
    IMP superIMP = method_getImplementation(class_getInstanceMethod(currentClass, viewDidLayoutSubviewsSelector));
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"ux_%s_viewDidLayoutSubviews",class_getName(currentClass)]);
    
    IMP impBlock1 = imp_implementationWithBlock(^void(id _self) {
        if ([UXAPMConfig sharedConfig].sdk_enabled) {
            
            [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_hook_viewDidLayoutSubviews_block1:%@",__FUNCTION__,__LINE__,_self] type:UXAPMTrackerTypeUI];
            
            UIViewController *controller = (UIViewController *)_self;
            UXRenderMonitorModel *model = [[UXAPMReporter sharedReporter] modelWithUniqueID:controller.uniqueID];
            
            long long start = @([[NSDate date] timeIntervalSince1970]*1000).longLongValue;
            
            IMP imp = [_self methodForSelector:selector];
            void (*func)(id, SEL) = (void*)imp;
            func(_self,selector);
            
            long long end = @([[NSDate date] timeIntervalSince1970]*1000).longLongValue;
            if (model && model.viewWillLayoutTimes.count - model.viewDidLayoutTimes.count == 1) {
                model.viewDidLayoutTimes = [[NSArray arrayWithArray:model.viewDidLayoutTimes] arrayByAddingObject:@(end)];
                
                long long viewWillLayoutTime = [[model.viewWillLayoutTimes lastObject] longLongValue];
                [UXAPMTracker trackMessage:[NSString stringWithFormat:@"[FUNCTION:%s] [Line:%d]_addRenderLayout:%@_duration:%lld",__FUNCTION__,__LINE__,_self,end - viewWillLayoutTime]];
            }
            if (model && !model.isViewDidAppear) {
                [model appendDetailInfoWithMethodName:@"viewDidLayoutSubviews" begin:start end:end];
            }
            
        } else {
            IMP imp = [_self methodForSelector:selector];
            void (*func)(id, SEL) = (void*)imp;
            func(_self,selector);
        }

        return ;
    });
    
    IMP impBlock2 = imp_implementationWithBlock(^void(id _self) {
        if (![class_getSuperclass(_self) isEqual:[NSObject class]]) {
            if ([UXAPMConfig sharedConfig].sdk_enabled) {
                
                [UXAPMTracker trackMessage:[NSString stringWithFormat:@"UXAPM_[FUNCTION:%s]_[Line:%d]_hook_viewDidLayoutSubviews_block2:%@",__FUNCTION__,__LINE__,_self] type:UXAPMTrackerTypeUI];
                
                UIViewController *controller = (UIViewController *)_self;
                UXRenderMonitorModel *model = [[UXAPMReporter sharedReporter] modelWithUniqueID:controller.uniqueID];
                
                long long start = @([[NSDate date] timeIntervalSince1970]*1000).longLongValue;
                
                void (*func)(id, SEL) = (void*)superIMP;
                func(_self,viewDidLayoutSubviewsSelector);
                
                long long end = @([[NSDate date] timeIntervalSince1970]*1000).longLongValue;
                if (model && model.viewWillLayoutTimes.count - model.viewDidLayoutTimes.count == 1) {
                    model.viewDidLayoutTimes = [[NSArray arrayWithArray:model.viewDidLayoutTimes] arrayByAddingObject:@(end)];
                    
                    long long viewWillLayoutTime = [[model.viewWillLayoutTimes lastObject] longLongValue];
                    [UXAPMTracker trackMessage:[NSString stringWithFormat:@"[FUNCTION:%s] [Line:%d]_addRenderLayout:%@_duration:%lld",__FUNCTION__,__LINE__,_self,end - viewWillLayoutTime]];
                }
                if (model && !model.isViewDidAppear) {
                   [model appendDetailInfoWithMethodName:@"viewDidLayoutSubviews" begin:start end:end];
                }
                
            } else {
                void (*func)(id, SEL) = (void*)superIMP;
                func(_self,viewDidLayoutSubviewsSelector);
            }

        }
        return ;
    });
    
    ux_Swizzle_orReplaceWithIMPs(currentClass, viewDidLayoutSubviewsSelector, selector, impBlock2, impBlock1);
}

@end

static char * const UIViewControllerUniqueIDKey;

@implementation UIViewController (Monitor)

- (void)generateUniqueID{
    if (!self.uniqueID.length) {
        NSString *md5 = [UXAPMTools MD5Hash:[NSProcessInfo processInfo].globallyUniqueString];
        self.uniqueID = md5;
    }
}

- (void)setUniqueID:(NSString *)uniqueID{
    objc_setAssociatedObject(self, &UIViewControllerUniqueIDKey, uniqueID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)uniqueID{
    return objc_getAssociatedObject(self, &UIViewControllerUniqueIDKey);
}

@end

