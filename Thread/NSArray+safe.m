//
//  NSArray+safe.m
//  Thread
//
//  Created by chenwang on 2018/1/17.
//  Copyright © 2018年 chenwang. All rights reserved.
//

#import "NSArray+safe.h"
#import <objc/runtime.h>
@implementation NSArray (safe)
+ (void)load {
//    [super load];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method sMethod = class_getInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(objectAtIndex:));
        Method mMethod = class_getInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(cw_objectAtIndex:));
        method_exchangeImplementations(mMethod, sMethod);
    });
    Method m1 = class_getInstanceMethod([self class], @selector(containsObject:));
    Method m2 = class_getInstanceMethod([self class], @selector(cw_containsObject:));
    method_exchangeImplementations(m2, m1);
}

- (id)cw_objectAtIndex:(NSUInteger)index {
    return [self cw_objectAtIndex:index];
}
- (BOOL)cw_containsObject:(id)anObject {
    return [self cw_containsObject:anObject];
}
@end

@implementation NSDictionary (safe)
+ (void)load {
    [super load];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(initWithObjects:forKeys:count:) withMethod:@selector(avoidCrashDictionaryWithObjects:forKeys:count:) class:NSClassFromString(@"__NSPlaceholderDictionary")];
    });
}
- (instancetype)avoidCrashDictionaryWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt {
    id instance = nil;
    @try {
        instance = [self avoidCrashDictionaryWithObjects:objects forKeys:keys count:cnt];
    }@catch (NSException *exception) {
        NSUInteger index = 0;
        id  _Nonnull __unsafe_unretained newObjects[cnt];
        id  _Nonnull __unsafe_unretained newkeys[cnt];
        for (int i = 0; i < cnt; i++) {
            if (objects[i] && keys[i]) {
                newObjects[index] = objects[i];
                newkeys[index] = keys[i];
                index++;
            }
        }
        instance = [self avoidCrashDictionaryWithObjects:newObjects forKeys:newkeys count:index];
    }    @finally {
        return instance;
    }
}

+ (void)swizzleMethod:(SEL)origSelector withMethod:(SEL)newSelector class:(Class)cls
{
    Method originalMethod = class_getInstanceMethod(cls, origSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, newSelector);
    
    BOOL didAddMethod = class_addMethod(cls,
                                        origSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(cls,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
@end
