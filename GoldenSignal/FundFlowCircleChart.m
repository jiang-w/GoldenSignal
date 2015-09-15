//
//  FundFlowCircleChart.m
//  GoldenSignal
//
//  Created by Frank on 15/7/10.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "FundFlowCircleChart.h"
#import "BDQuotationService.h"
#import <Masonry.h>

#define IndicaterNames @[@"FundFlowIn", @"FundFlowOut"]

@interface FundFlowCircleChart()

@property(nonatomic, strong) NSMutableArray* layers;
@property(nonatomic, strong) UILabel *title;
@property(nonatomic, strong) UIView *circle;
@property(nonatomic, strong) UILabel *flowInValue;
@property(nonatomic, strong) UILabel *flowOutValue;

@end

@implementation FundFlowCircleChart
{
    double _fundFlowIn;
    double _fundFlowOut;
    NSString *_code;
    dispatch_queue_t _propertyUpdateQueue;
    BDQuotationService *_service;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _layers = [NSMutableArray array];
        [self setSubView];
        
        _propertyUpdateQueue = dispatch_queue_create("TrendLineUpdate", nil);
        _service = [BDQuotationService sharedInstance];

        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(subscribeScalarChanged:) name:QUOTE_SCALAR_NOTIFICATION object:nil];
    }
    return self;
}

- (void)subscribeScalarChanged:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    NSString *code = dic[@"code"];
    NSString *indicateName = dic[@"name"];
    id value = dic[@"value"];
    
    if ([code isEqualToString: _code]) {
        dispatch_async(_propertyUpdateQueue, ^{
            BOOL changed = NO;
            if ([indicateName isEqualToString:@"FundFlowIn"]) {
                _fundFlowIn = [value doubleValue];
                changed = YES;
            }
            else if ([indicateName isEqualToString:@"FundFlowOut"]) {
                _fundFlowOut = [value doubleValue];
                changed = YES;
            }
            
            if (changed && _fundFlowIn !=0 && _fundFlowOut != 0) {
                for (CALayer *layer in self.layers) {
                    [layer removeFromSuperlayer];
                }
                [self.layers removeAllObjects];
                
                [self strokeCircle];
            }
        });
    }
}

- (void)loadDataWithSecuCode:(NSString *)code {
    if (code != nil && ![code isEqualToString:_code]) {
        if (_code != nil) {
            [_service unsubscribeScalarWithCode:_code indicaters:IndicaterNames];
        }
        [self initPropertyWithCode:code];
        [_service subscribeScalarWithCode:code indicaters:IndicaterNames];
    }
}

- (void)initPropertyWithCode:(NSString *)code {
    _code = code;
    _fundFlowIn = [[_service getCurrentIndicateWithCode:code andName:@"FundFlowIn"] doubleValue];
    _fundFlowOut = [[_service getCurrentIndicateWithCode:code andName:@"FundFlowOut"] doubleValue];
}

- (void)setSubView {
    self.title = [[UILabel alloc] init];
    self.title.text = @"今日实时资金博弈";
    self.title.font = [UIFont boldSystemFontOfSize:12];
    self.title.textColor = [UIColor whiteColor];
    [self addSubview:self.title];
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(10);
    }];
    
    self.circle = [[UIView alloc] init];
    [self addSubview:self.circle];
    [self.circle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.title.mas_bottom).offset(10);
        make.height.equalTo(self.circle.mas_width);
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-10);
    }];
    
    self.flowInValue = [[UILabel alloc] init];
    self.flowInValue.font = [UIFont boldSystemFontOfSize:12];
    self.flowInValue.textColor = [UIColor redColor];
    [self addSubview:self.flowInValue];
    [self.flowInValue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(30);
    }];
    
    self.flowOutValue = [[UILabel alloc] init];
    self.flowOutValue.font = [UIFont boldSystemFontOfSize:12];
    self.flowOutValue.textColor = [UIColor greenColor];
    [self addSubview:self.flowOutValue];
    [self.flowOutValue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-30);
    }];
}

- (void)drawRect:(CGRect)rect {
    [self strokeCircle];
}

- (void)strokeCircle {
    CGFloat radius = (self.circle.frame.size.height - 20) / 2;
    CGPoint center = self.circle.center;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:2 * M_PI clockwise:YES];
    CAShapeLayer *backgroundLayer = [CAShapeLayer layer];
    backgroundLayer.path = path.CGPath;
    backgroundLayer.strokeColor = [RGB(59, 59, 59) CGColor];
    backgroundLayer.fillColor = nil;
    backgroundLayer.lineWidth = 20;
    [self.layer addSublayer:backgroundLayer];
    [self.layers addObject:backgroundLayer];
    
    CGFloat startAngle = DEGREE_TO_RADIAN(0);
    CGFloat endAngle = DEGREE_TO_RADIAN(360 * _fundFlowOut / (_fundFlowOut + _fundFlowIn));
    
    path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    CAShapeLayer *flowOutLayer = [CAShapeLayer layer];
    flowOutLayer.path = path.CGPath;
    flowOutLayer.strokeColor = [[UIColor greenColor] CGColor];
    flowOutLayer.fillColor = nil;
    flowOutLayer.lineWidth = 12;
    [self.layer addSublayer:flowOutLayer];
    [self.layers addObject:flowOutLayer];
    
    path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:endAngle endAngle:startAngle clockwise:YES];
    CAShapeLayer *flowInLayer = [CAShapeLayer layer];
    flowInLayer.path = path.CGPath;
    flowInLayer.strokeColor = [[UIColor redColor] CGColor];
    flowInLayer.fillColor = nil;
    flowInLayer.lineWidth = 12;
    [self.layer addSublayer:flowInLayer];
    [self.layers addObject:flowInLayer];
    
    self.flowInValue.text = [NSString stringWithFormat:@"%.0f%%", _fundFlowIn / (_fundFlowOut + _fundFlowIn) * 100];
    self.flowOutValue.text = [NSString stringWithFormat:@"%.0f%%", _fundFlowOut / (_fundFlowOut + _fundFlowIn) * 100];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SCALAR_NOTIFICATION object:nil];
    [_service unsubscribeScalarWithCode:_code indicaters:IndicaterNames];
//    NSLog(@"FundFlowCircleChart dealloc (%@)", _code);
}

@end
