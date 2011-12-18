//
//  A2BlockDelegate+BlocksKit.m
//  BlocksKit
//
//  Created by Zachary Waldowski on 12/17/11.
//  Copyright (c) 2011 Dizzy Technology. All rights reserved.
//

#import "A2BlockDelegate+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"
#import "NSObject+BlocksKit.h"
#import <objc/runtime.h>

static char kDelegateKey;
static char kDataSourceKey;
static void bk_delegateSetter(id self, SEL _cmd, id delegate);
static id bk_delegateGetter(id self, SEL _cmd);
static void bk_dataSourceSetter(id self, SEL _cmd, id dataSource);
static id bk_dataSourceGetter(id self, SEL _cmd);

@interface NSObject ()

- (id) bk_dataSource;
- (void) bk_setDataSource: (id) dataSource;

- (id) bk_delegate;
- (void) bk_setDelegate: (id) delegate;

@end

@implementation NSObject (A2BlockDelegateBlocksKit)

+ (void)swizzleDelegateProperty {
	class_addMethod(self, @selector(bk_delegate), (IMP)bk_delegateGetter, "@@:");
	class_addMethod(self, @selector(bk_setDelegate:), (IMP)bk_delegateSetter, "v@:@");
	[self swizzleSelector:@selector(delegate) withSelector:@selector(bk_delegate)];
	[self swizzleSelector:@selector(setDelegate:) withSelector:@selector(bk_setDelegate:)];
}

+ (void)swizzleDataSourceProperty {
	class_addMethod(self, @selector(bk_dataSource), (IMP)bk_dataSourceGetter, "@@:");
	class_addMethod(self, @selector(bk_setDataSource:), (IMP)bk_dataSourceSetter, "v@:@");
	[self swizzleSelector:@selector(dataSource) withSelector:@selector(bk_dataSource)];
	[self swizzleSelector:@selector(setDataSource:) withSelector:@selector(bk_setDataSource:)];
}

@end

@implementation A2DynamicDelegate (BlocksKit)

- (id)realDelegate {
	return [self associatedValueForKey:&kDelegateKey];
}

- (id)realDataSource {
	return [self associatedValueForKey:&kDataSourceKey];
}

@end

static void bk_delegateSetter(id self, SEL _cmd, id delegate) {
	id dynamicDelegate = [self dynamicDelegate];
	[self bk_setDelegate:dynamicDelegate];
	if ([delegate isEqual:self] || [delegate isEqual:dynamicDelegate])
		delegate = nil;
	[dynamicDelegate weaklyAssociateValue:delegate withKey:&kDelegateKey];
}

static id bk_delegateGetter(id self, SEL _cmd) {
	return [[self dynamicDelegate] associatedValueForKey:&kDelegateKey];
}

static void bk_dataSourceSetter(id self, SEL _cmd, id dataSource) {
	id dynamicDataSource = [self dynamicDataSource];
	[self bk_setDataSource:dynamicDataSource];
	if ([dataSource isEqual:self] || [dataSource isEqual:dynamicDataSource])
		dataSource = nil;
	[dynamicDataSource weaklyAssociateValue:dataSource withKey:&kDataSourceKey];

}

static id bk_dataSourceGetter(id self, SEL _cmd) {
	return [[self dynamicDataSource] associatedValueForKey:&kDataSourceKey];
}