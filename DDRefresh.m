//
//  DDRefresh.m
//  DuoDuo
//
//  Created by Hong Zhang on 2019/3/26.
//  Copyright © 2019 Muqiu. All rights reserved.
//

#import "DDRefresh.h"
#import <objc/runtime.h>


@implementation MJRefreshComponent (Extension)

static NSInteger kListPageCount = 5;//列表页，每页默认数据量

+(void)load
{
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(setState:)), class_getInstanceMethod(self, @selector(dd_setState:)));
    
     method_exchangeImplementations(class_getInstanceMethod(self, @selector(beginRefreshing)), class_getInstanceMethod(self, @selector(dd_beginRefreshing)));

}


- (void)dd_beginRefreshing
{
    // 保证header 和footer 其中一个在刷新时另一个停止刷新
    if ([self isKindOfClass:[MJRefreshHeader class]]){
        if (_scrollView.mj_footer != nil ) {
            [_scrollView.mj_footer endRefreshing];
        }
    }
    else if ([self isKindOfClass:[MJRefreshFooter class]]){

        if (_scrollView.mj_header != nil){
            [_scrollView.mj_header endRefreshing];
        }
    }
    
    [self dd_beginRefreshing];
}

-(void)dd_setState:(MJRefreshState)state
{
    [self dd_setState:state];
    //下拉刷新结束 列表数据量不满一页时 不允许上拉
    if ([self isKindOfClass:[MJRefreshHeader class]] && state == MJRefreshStateIdle){
        if (_scrollView.mj_footer != nil) {
            if (_scrollView.mj_totalDataCount < kListPageCount ) {//5是后台列表数据每一页默认数量
                [_scrollView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    }
}


@end

@implementation MJRefreshFooter(Extension)

+(void)load
{
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(endRefreshingWithNoMoreData)), class_getInstanceMethod(self, @selector(dd_endRefreshingWithNoMoreData)));
}

-(void)dd_endRefreshingWithNoMoreData
{
    [self dd_endRefreshingWithNoMoreData];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    // 列表为空隐藏footer
    if (_scrollView.mj_totalDataCount == 0) {
        _scrollView.mj_footer.alpha = 0;
    }else{
        _scrollView.mj_footer.alpha = 1;
    }
}

@end




