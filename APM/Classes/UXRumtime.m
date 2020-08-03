//
//  UXRumtime.m
//  YellowRiver
//
//  Created by 谢雷 on 2018/3/15.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import "UXRumtime.h"

BOOL ux_ClassMethodSwizzle(Class aClass, SEL originalSelector, SEL swizzleSelector){
    
    Method originalMethod = class_getClassMethod(aClass, originalSelector);
    Method swizzleMethod = class_getClassMethod(aClass, swizzleSelector);
    if (originalMethod && swizzleMethod) {
        method_exchangeImplementations(originalMethod, swizzleMethod);
    }
    return YES;
}

BOOL ux_ClassSwizzle(Class aClass, SEL originalSelector, SEL swizzleSelector){
    
    Method originalMethod = class_getInstanceMethod(aClass, originalSelector);
    Method swizzleMethod = class_getInstanceMethod(aClass, swizzleSelector);
    if (class_addMethod(aClass, originalSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))) {
        class_replaceMethod(aClass, swizzleSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzleMethod);
    }
    return YES;
}

void ux_Swizzle(Class class, SEL swizzleSelector, SEL selector) {
    if (class != nil) {
        Method swizzleMethod = class_getInstanceMethod(class, swizzleSelector);
        Method originalMethod = class_getInstanceMethod(class, selector);
        IMP originalIMP = method_getImplementation(originalMethod);
        if (class_addMethod(class, swizzleSelector, originalIMP, method_getTypeEncoding(originalMethod)) == YES) {
            class_replaceMethod(class, selector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));
        }
        else {
            method_exchangeImplementations(swizzleMethod, originalMethod);
            
        }
    }
}

IMP ux_getInstanceImpOf(Class class, SEL selector) {
    Method method = class_getInstanceMethod(class, selector);
    IMP imp = method_getImplementation(method);
    return imp;
}

void ux_Swizzle_orReplaceWithIMPs(Class class, SEL selector, SEL swizzleSelector, IMP arg3, IMP arg4) {
    if (class != nil) {
        const char * _Nullable methodType = method_getTypeEncoding(class_getInstanceMethod(class, selector));
        if (class_addMethod(class, selector, arg3, methodType)) {
//            NSLog(@"done");
        } else {
            if (class_addMethod(class, swizzleSelector, arg4, methodType)) {
                ux_Swizzle(class, swizzleSelector, selector);
//                NSLog(@"done");
            }
        }
    }
}

BOOL ux_hookClass_CopyAMetaMethod(Class currentClass,Class controller, SEL selector) {
    if (selector == nil) return false;
    Method method = class_getClassMethod(currentClass, selector);
    if (method == nil) return false;
    return  class_addMethod(controller, selector, method_getImplementation(method), method_getTypeEncoding(method));
    
}

BOOL ux_hookClass_CopyAMethod(Class currentClass,Class controller, SEL selector) {
    if (selector == nil) return false;
    Method method = class_getInstanceMethod(currentClass, selector);
    if (method == nil) return false;
    return  class_addMethod(controller, selector, method_getImplementation(method), method_getTypeEncoding(method));
}

BOOL ux_isClassItSelfHasMethod(Class class, SEL selector) {
    BOOL result;
   Class superClass = class_getSuperclass(class);
    if (superClass != class) {
        IMP classIMP = class_getMethodImplementation(class, selector);
        if ((classIMP != nil) && (classIMP != _objc_msgForward)) {
            IMP superClassIMP = class_getMethodImplementation(superClass, selector);
            result = (classIMP != superClassIMP ? YES : NO) | (superClassIMP == nil ? YES : NO) | (superClassIMP == _objc_msgForward ? YES : NO);
        }
        else {
             result = NO;
        }
    }
    else {
        result = NO;
    }
    return result;
}
