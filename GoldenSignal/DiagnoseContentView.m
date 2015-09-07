//
//  DiagnoseContentView.m
//  GoldenSignal
//
//  Created by CBD on 15/8/11.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "DiagnoseContentView.h"
#import <Masonry.h>
#import <PPiFlatSegmentedControl.h>

#import "FunddViewController.h"//资金
#import "FinanceViewController.h"//财务
#import "MainBusinessViewController.h"//主营
#import "ApproveViewController.h"//认同
#import "FundFlowBarView.h"
#import "FundFlowCircleChart.h"

@interface DiagnoseContentView ()<UIScrollViewDelegate>


@property (nonatomic, strong) PPiFlatSegmentedControl *flatSegmentView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger infoTabIndex;


@property (nonatomic, strong) FunddViewController *fundView;//资金视图
@property (nonatomic, strong) FinanceViewController *financeView;//财务视图
@property (nonatomic, strong) MainBusinessViewController *mbView;//主营视图
@property (nonatomic, strong) ApproveViewController *approveView;//认同视图

@property(nonatomic, strong) FundFlowBarView *fundFlowBarView;
@property(nonatomic, strong) FundFlowCircleChart *fundFlowCircleChart;

@end

@implementation DiagnoseContentView


- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self labelTitleView];

    
    _infoTabIndex = 0;
    
    [self loadEachView];
}

- (void)labelTitleView{
    
    CGRect titleFrame = CGRectMake(0, 0, 200, 30);
    __weak DiagnoseContentView *weakSelf = self;    // 解决block循环引用的问题
    self.flatSegmentView = [[PPiFlatSegmentedControl alloc]initWithFrame:titleFrame items:@[@{@"text":@"资金",}, @{@"text":@"财务",}, @{@"text":@"主营",}, @{@"text":@"认同"}] iconPosition:IconPositionLeft andSelectionBlock:^(NSUInteger segmentIndex) {
        
        weakSelf.infoTabIndex = segmentIndex;
        
        [weakSelf loadEachView];
        
        // 点击Tab后scrollView滚动到其位置
        CGFloat scrollHeight = weakSelf.scrollView.frame.size.height;
        CGFloat contentHeight = weakSelf.scrollView.contentSize.height;
        CGFloat tabViewY = weakSelf.flatSegmentView.frame.origin.y;
        CGFloat offsetY = tabViewY + scrollHeight > contentHeight ? contentHeight - scrollHeight : tabViewY;
        [weakSelf.scrollView setContentOffset:CGPointMake(0, offsetY) animated:YES];
        
    }];
    _flatSegmentView.color = [UIColor blackColor];
//    _flatSegmentView.borderWidth = 1;
//    _flatSegmentView.borderColor = RGB(80.0, 80.0, 80.0, 1.0);
//    _flatSegmentView.selectedColor = RGB(30, 30, 30, 1);
    _flatSegmentView.textAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:[UIColor whiteColor]};
    _flatSegmentView.selectedTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:RGB(216, 1, 1)};
    [self.view addSubview:self.flatSegmentView];
    
//    self.scrollView = [[UIScrollView alloc] init];
//    self.scrollView.delegate = self;
//    self.scrollView.backgroundColor = [UIColor clearColor];
//    self.scrollView.bounces = NO;
//    [self.view addSubview:self.scrollView];
//    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.bottom.and.right.equalTo(self.view);
//    }];
    
}


- (void)loadEachView{
    self.mainView = [[UIView alloc] init];
    _mainView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.mainView];
    
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.flatSegmentView.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
//        make.bottom.equalTo(self.view.mas_bottom);
    }];


    for (UIView *subViews in self.view.subviews) {
        if ((subViews != self.flatSegmentView) && (subViews != _mainView)) {
            [subViews removeFromSuperview];
        }
    }
    
    switch (_infoTabIndex) {
        case 0:{
            if (self.fundFlowCircleChart == nil) {
                self.fundFlowCircleChart = [[FundFlowCircleChart alloc] init];
                self.fundFlowCircleChart.backgroundColor = RGB(22, 25, 30);
                [self.fundFlowCircleChart loadDataWithSecuCode:self.secuCode];
            }
            [self.mainView addSubview:self.fundFlowCircleChart];
            
            [self.fundFlowCircleChart mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.equalTo(self.mainView);
                make.height.mas_equalTo(160);
            }];
            
            if (self.fundFlowBarView == nil) {
                self.fundFlowBarView = [[FundFlowBarView alloc] initWithNibName:@"FundFlowBarView" bundle:nil];
                self.fundFlowBarView.code = self.secuCode;
            }
            [self.mainView addSubview:self.fundFlowBarView.view];

            [self.fundFlowBarView.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.fundFlowCircleChart.mas_bottom);
                make.left.right.equalTo(self.mainView);
                make.height.mas_equalTo(self.fundFlowBarView.view.frame.size.height);
            }];

            [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.fundFlowBarView.view);
            }];
            
            [self.view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.flatSegmentView.mas_bottom);
                make.left.equalTo(self.view.mas_left);
                make.right.equalTo(self.view.mas_right);
                make.bottom.equalTo(self.mainView.mas_bottom);
            }];
        }
            break;
            
        case 1:{
            if (_financeView == nil) {
                _financeView = [[FinanceViewController alloc]init];
                _financeView.BD_CODE = self.secuCode;
                
            }
            [self.mainView addSubview:_financeView.view];
            
            [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.equalTo(_financeView.view);
                make.bottom.equalTo(_financeView.view);
//                make.height.mas_equalTo(320);
            }];
            [self.view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.flatSegmentView.mas_bottom);
                make.left.equalTo(self.view.mas_left);
                make.right.equalTo(self.view.mas_right);
                make.bottom.equalTo(self.mainView.mas_bottom);
            }];
        }
            break;
            
        case 2:{
            if (_mbView == nil) {
                _mbView = [[MainBusinessViewController alloc]init];
                _mbView.BD_CODE = self.secuCode;
            }
            _mbView.view.backgroundColor = [UIColor whiteColor];
            [self.mainView addSubview:_mbView.view];
            
//            NSLog(@"66>%lf",_mbView.baseView.frame.size.height);
            
            [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.equalTo(_mbView.baseView);
                make.bottom.equalTo(_mbView.baseView.mas_bottom);
            }];
            
            //更新self.view
            [self.view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.flatSegmentView.mas_bottom);
                make.left.equalTo(self.view.mas_left);
                make.right.equalTo(self.view.mas_right);
                make.bottom.equalTo(self.mainView.mas_bottom);
            }];
            
          }
            break;
        
        case 3:{
            if (self.approveView == nil) {
                self.approveView = [[ApproveViewController alloc]init];
                self.approveView.BD_CODE = self.secuCode;
            }
            [self.mainView addSubview:self.approveView.view];
            
            [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.equalTo(self.approveView.view);
                make.bottom.equalTo(self.approveView.view);
            }];
            [self.view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.flatSegmentView.mas_bottom);
                make.left.equalTo(self.view.mas_left);
                make.right.equalTo(self.view.mas_right);
                make.bottom.equalTo(self.mainView.mas_bottom);
            }];
        }
            break;
            
        default:
            
            break;
    }
    
    [self.scrollView layoutIfNeeded];
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
