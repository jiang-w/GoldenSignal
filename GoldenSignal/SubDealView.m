//
//  SubDealView.m
//  CBNAPP
//
//  Created by Frank on 14/12/11.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "SubDealView.h"
#import "SubDealViewModel.h"
#import <FBKVOController.h>

@implementation SubDealView
{
    SubDealViewModel *_vm;
    FBKVOController *_kvo;
    __weak SubDealView *weakSelf;
}

- (id)initWithFrame:(CGRect)frame andCode:(NSString *)code {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _kvo = [FBKVOController controllerWithObserver:self];
        weakSelf = self;
        
        if (code) {
            _code = [code copy];
            _vm = [[SubDealViewModel alloc] initWithCode:code];
            [_kvo observe:_vm keyPath:@"dealArray" options:NSKeyValueObservingOptionNew action:@selector(updateViewWithDataChange)];
        }
    }
    return self;
}

-(void)updateViewWithDataChange {
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf setNeedsDisplay];
    });
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 设置画笔颜色和宽度
    CGContextSetStrokeColorWithColor(context, [RGB(80, 80, 80) CGColor]);
    CGContextSetLineWidth(context, 2);
    
    // 绘制文本
    float spacing = (self.frame.size.height) / 10.0;
    NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionary];
    [fontAttributes setObject:[UIFont boldSystemFontOfSize:10] forKey:NSFontAttributeName];
    NSString *label;
    
    CGPoint point = CGPointMake(0, 0);
    for (int i = 0; i < _vm.dealArray.count; i++) {
        BDSubDeal *deal = _vm.dealArray[i];
        [fontAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        int hour = deal.time/10000;
        int minute = deal.time%10000/100;
        label = [NSString stringWithFormat:@"%d:%@", hour, minute >= 10? [NSString stringWithFormat:@"%d",minute] : [NSString stringWithFormat:@"0%d",minute]];
        [label drawAtPoint:point withAttributes:fontAttributes];
        point.y += spacing;
    }
    
    point = CGPointMake(32, 0);
    for (int i = 0; i < _vm.dealArray.count; i++) {
        BDSubDeal *deal = _vm.dealArray[i];
        [fontAttributes setObject:[self textColorValue:deal.price otherValue:_vm.prevClose] forKey:NSForegroundColorAttributeName];
        label = [NSString stringWithFormat:@"%.2f", deal.price];
        [label drawAtPoint:point withAttributes:fontAttributes];
        point.y += spacing;
    }
    
    point = CGPointZero;
    for (int i = 0; i < _vm.dealArray.count; i++) {
        BDSubDeal *deal = _vm.dealArray[i];
        switch (deal.tradeDirection) {
            case 1:
                [fontAttributes setObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
                break;
            case 2:
                [fontAttributes setObject:[UIColor greenColor] forKey:NSForegroundColorAttributeName];
                break;
            default:
                [fontAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
                break;
        }
        
        label = [NSString stringWithFormat:@"%d", deal.volumeSpread / 100];
        CGFloat textWidth = [label boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributes context:nil].size.width;
        point.x = CGRectGetMaxX(self.bounds) - textWidth - 4;
        [label drawAtPoint:point withAttributes:fontAttributes];
        point.y += spacing;
    }
}

- (UIColor *)textColorValue:(float)val1 otherValue:(float)val2 {
    if (val1 > val2) {
        return [UIColor redColor];
    }
    else if (val1 < val2) {
        return [UIColor greenColor];
    }
    else {
        return [UIColor whiteColor];
    }
}

- (void)dealloc {
//    NSLog(@"SubDealView dealloc (%@)", _code);
}

@end
