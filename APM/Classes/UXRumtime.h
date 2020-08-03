//
//  UXRumtime.h
//  YellowRiver
//
//  Created by 谢雷 on 2018/3/15.
//  Copyright © 2018年 谢雷. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

BOOL ux_ClassMethodSwizzle(Class aClass, SEL originalSelector, SEL swizzleSelector);

BOOL ux_ClassSwizzle(Class aClass, SEL originalSelector, SEL swizzleSelector);

void ux_Swizzle(Class class, SEL swizzleSelector, SEL selector);

IMP ux_getInstanceImpOf(Class class, SEL selector);

void ux_Swizzle_orReplaceWithIMPs(Class class, SEL selector, SEL swizzleSelector, IMP arg3, IMP arg4);

BOOL ux_hookClass_CopyAMetaMethod(Class currentClass,Class controller, SEL selector);

BOOL ux_hookClass_CopyAMethod(Class currentClass,Class controller, SEL selector);

BOOL ux_isClassItSelfHasMethod(Class class, SEL selector);
