//
//  DDRefresh.h
//  DuoDuo
//
//  Created by Hong Zhang on 2019/3/26.
//  Copyright © 2019 Muqiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJRefresh.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDRefresh : NSObject

+ (MJRefreshGifHeader *)header;

+ (MJRefreshAutoGifFooter *)footer;


+ (MJRefreshGifHeader *)headerWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

+ (MJRefreshAutoGifFooter *)footerWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

@end




NS_ASSUME_NONNULL_END
