//
//  IdxDetailViewController.m
//  GoldenSignal
//
//  Created by Frank on 15/6/24.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "IdxDetailViewController.h"
#import "IdxQuoteView.h"
#import "TrendLineChart.h"
#import <Masonry.h>
#import <PPiFlatSegmentedControl.h>

@interface IdxDetailViewController ()

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UIView *chartContainerView;

@property(nonatomic, strong) IdxQuoteView *idxQuoteView;
@property(nonatomic, strong) PPiFlatSegmentedControl *chartTabView;
@property(nonatomic, strong) TrendLineChart *trendLineChart;

@property(nonatomic, assign) NSInteger chartTabIndex;

@end

@implementation IdxDetailViewController
{
    NSString *_idxCode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingView];

    [self loadChartView];
}

- (void)settingView {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.and.right.equalTo(self.view);
    }];
    
    self.containerView = [[UIView alloc] init];
    [self.scrollView addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];

    /* 添加指数标价 */
    self.idxQuoteView = [IdxQuoteView createView];
    [self addSubView:self.idxQuoteView withHeight:110 andSpace:0];
    [self.idxQuoteView loadDataWithIdxCode:_idxCode];
    
    __weak IdxDetailViewController *weakSelf = self;    // 解决block循环引用的问题
    /* 行情走势图Tab */
    self.chartTabView = [[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 320, 30) items:@[@{@"text":@"分时"}, @{@"text":@"五日"}, @{@"text":@"日K"}, @{@"text":@"周K"}, @{@"text":@"月K"}] iconPosition:IconPositionRight andSelectionBlock:^(NSUInteger segmentIndex) {
        weakSelf.chartTabIndex = segmentIndex;
        [weakSelf loadChartView];
    }];
    self.chartTabView.color = RGB(7, 9, 8, 1);
    self.chartTabView.borderWidth = 1;
    self.chartTabView.borderColor = RGB(80.0, 80.0, 80.0, 1.0);
    self.chartTabView.selectedColor = RGB(30, 30, 30, 1);
    self.chartTabView.textAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:RGB(214, 214, 214, 1)};
    self.chartTabView.selectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:RGB(216, 1, 1, 1)};
    [self addSubView:self.chartTabView withHeight:30 andSpace:2];
    
    /* 分时、K线容器视图 */
    self.chartContainerView = [[UIView alloc] init];
    self.chartContainerView.backgroundColor = RGB(30, 30, 30, 1);
    [self addSubView:self.chartContainerView withHeight:180 andSpace:4];

    UIView *lastView = self.containerView.subviews.lastObject;
    if (lastView) {
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(lastView.mas_bottom);
        }];
    }
}

- (void)addSubView:(UIView *) subView withHeight:(CGFloat)height andSpace:(CGFloat)space {
    UIView *lastView = self.containerView.subviews.lastObject;
    if (subView) {
        [self.containerView addSubview:subView];
        [subView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastView) {
                make.top.equalTo(lastView.mas_bottom).with.offset(space);
            }
            else {
                make.top.equalTo(self.containerView).with.offset(space);
            }
            make.left.and.right.equalTo(self.containerView);
            make.height.mas_equalTo(height);
        }];
    }
}

// 加载分时、K线视图
- (void)loadChartView {
    for (UIView *sub in self.chartContainerView.subviews) {
        [sub removeFromSuperview];
    }
    
    switch (_chartTabIndex) {
        case 0: {
            if (self.trendLineChart == nil) {
                self.trendLineChart = [[TrendLineChart alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
                self.trendLineChart.margin = 1;
                self.trendLineChart.lineColor = [UIColor orangeColor];
                self.trendLineChart.fillColor = [[UIColor orangeColor] colorWithAlphaComponent:0.15];
                [self.trendLineChart loadDataWithSecuCode:_idxCode];
            }
            [self.chartContainerView addSubview:self.trendLineChart];
            break;
        }
        default:break;
    }
}

- (void)loadDataWithSecuCode:(NSString *)code {
    if (![code isEqualToString:_idxCode]) {
        BDSecuCode *secuCode = [[BDKeyboardWizard sharedInstance] queryWithSecuCode:code];
        if (secuCode) {
            _idxCode = code;
            
//            [self.idxQuoteView loadDataWithIdxCode:_idxCode];
            
            // 载入分时、K线视图
//            [self loadChartView];
        }
    }
}

- (void)dealloc {
    NSLog(@"IdxDetailViewController dealloc");
}

@end
