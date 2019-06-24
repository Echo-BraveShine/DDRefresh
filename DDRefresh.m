//
//  DDRefresh.m
//  DuoDuo
//
//  Created by Hong Zhang on 2019/3/26.
//  Copyright © 2019 Muqiu. All rights reserved.
//

#import "DDRefresh.h"
#import <objc/runtime.h>
@implementation DDRefresh


/**
 生成默认的header（target action 无效）
 @return MJRefreshGifHeader
 */
+ (MJRefreshGifHeader *)header
{
    //target action 为了不影响外部调用 默认为 self class
    return [self headerWithRefreshingTarget:self refreshingAction:@selector(class)];
}

/**
 生成默认的footer（target action 无效）
 @return MJRefreshAutoFooter
 */
+ (MJRefreshAutoGifFooter *)footer
{
    //target action 为了不影响外部调用 默认为 self class
    return [self footerWithRefreshingTarget:self refreshingAction:@selector(class)];
}


+ (MJRefreshGifHeader *)headerWithRefreshingTarget:(id)target refreshingAction:(SEL)action{
    
    NSMutableArray *gifs = [NSMutableArray array];
    for (NSInteger i = 0; i < 15; i++) {
        [gifs addObject:[UIImage imageNamed:[NSString stringWithFormat:@"refresh_gif_%ld",(long)i]]];
    }
    
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:target refreshingAction:action];
    [header setImages:@[[UIImage imageNamed:@"refresh_gif_9"],[UIImage imageNamed:@"refresh_gif_11"],[UIImage imageNamed:@"refresh_gif_13"],[UIImage imageNamed:@"refresh_gif_15"]] forState:MJRefreshStateRefreshing];
    [header setImages:gifs forState:MJRefreshStateIdle];
    [header setImages:@[gifs.lastObject] forState:MJRefreshStatePulling];
    
    header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    
    return header;
}

+ (MJRefreshAutoGifFooter *)footerWithRefreshingTarget:(id)target refreshingAction:(SEL)action{
    MJRefreshAutoGifFooter *footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:target refreshingAction:action];
  
    footer.stateLabel.textColor = [UIColor lightGrayColor];
    footer.stateLabel.font = [UIFont systemFontOfSize:13];
    
    NSMutableArray *gifs = [NSMutableArray array];
    for (NSInteger i = 0; i < 15; i++) {
        [gifs addObject:[UIImage imageNamed:[NSString stringWithFormat:@"refresh_gif_%ld",(long)i]]];
    }
    
    [footer setImages:@[[UIImage imageNamed:@"refresh_gif_9"],[UIImage imageNamed:@"refresh_gif_11"],[UIImage imageNamed:@"refresh_gif_13"],[UIImage imageNamed:@"refresh_gif_15"]] forState:MJRefreshStateRefreshing];
    [footer setImages:gifs forState:MJRefreshStateIdle];
    [footer setImages:@[gifs.lastObject] forState:MJRefreshStatePulling];
//    [footer setImages:@[gifs.firstObject] forState:MJRefreshStateNoMoreData];
//    footer.automaticallyChangeAlpha = YES;
    
    footer.refreshingTitleHidden = YES;
    
    
    return footer;
}


@end


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




