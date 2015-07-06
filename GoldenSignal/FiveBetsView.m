//
//  FiveBetsView.m
//  CBNAPP
//
//  Created by Frank on 14/11/26.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "FiveBetsView.h"
#import "FiveBetsViewModel.h"
#import "PPiFlatSegmentedControl.h"
#import <FBKVOController.h>

@implementation FiveBetsView
{
    FiveBetsViewModel *_vm;
    FBKVOController *_kvo;
    __weak FiveBetsView *weakSelf;
}

- (id)initWithFrame:(CGRect)frame andCode:(NSString *)code {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _kvo = [FBKVOController controllerWithObserver:self];
        weakSelf = self;
        
        if (code) {
            _code = [code copy];
            _vm = [[FiveBetsViewModel alloc] initWithCode:code];
            NSArray *keyPaths = @[@"bidPrice1", @"bidPrice2", @"bidPrice3", @"bidPrice4", @"bidPrice5",
                                  @"bidVolume1", @"bidVolume2", @"bidVolume3", @"bidVolume4", @"bidVolume5",
                                  @"askPrice1", @"askPrice2", @"askPrice3", @"askPrice4", @"askPrice5",
                                  @"askVolume1", @"askVolume2", @"askVolume3", @"askVolume4", @"askVolume5"];
            [_kvo observe:_vm keyPaths:keyPaths options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew action:@selector(updateViewWithDataChange)];
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
    CGContextSetStrokeColorWithColor(context, [RGB(80.0, 80.0, 80.0, 1.0) CGColor]);
    CGContextSetLineWidth(context, 2);
    
    // 绘制边框
//    CGContextAddRect(context, (CGRect){CGPointZero, self.frame.size});
//    CGContextDrawPath(context, kCGPathStroke);

    // 绘制文本
    float spacing = (self.frame.size.height) / 10.0;
    NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionary];
    [fontAttributes setObject:[UIFont boldSystemFontOfSize:10] forKey:NSFontAttributeName];
    NSString *label;
    
    CGPoint point = CGPointMake(6, 0);
    for (int i = 5; i >= 1; i--) {
        [fontAttributes setObject:[UIColor grayColor] forKey:NSForegroundColorAttributeName];
        label = [NSString stringWithFormat:@"卖%d", i];
        [label drawAtPoint:point withAttributes:fontAttributes];
        point.y += spacing;
    }
    point.y += 2;
    for (int i = 1; i <= 5; i++) {
        [fontAttributes setObject:[UIColor grayColor] forKey:NSForegroundColorAttributeName];
        label = [NSString stringWithFormat:@"买%d", i];
        [label drawAtPoint:point withAttributes:fontAttributes];
        point.y += spacing;
    }

    point = CGPointMake(28, 0);
    for (int i = 5; i >= 1; i--) {
        float price = [[_vm valueForKey:[NSString stringWithFormat:@"askPrice%d", i]] floatValue];
        UIColor *color = [UIColor whiteColor];
        if (price == 0) {
            label = [NSString stringWithFormat:@"—"];
        }
        else {
            label = [NSString stringWithFormat:@"%.2f", price];
            color = [self textColorValue:price otherValue:_vm.prevClose];
        }
        [fontAttributes setObject:color forKey:NSForegroundColorAttributeName];
        [label drawAtPoint:point withAttributes:fontAttributes];
        point.y += spacing;
    }
    point.y += 2;
    for (int i = 1; i <= 5; i++) {
        float price = [[_vm valueForKey:[NSString stringWithFormat:@"bidPrice%d", i]] floatValue];
        UIColor *color = [UIColor whiteColor];
        if (price == 0) {
            label = [NSString stringWithFormat:@"—"];
        }
        else {
            label = [NSString stringWithFormat:@"%.2f", price];
            color = [self textColorValue:price otherValue:_vm.prevClose];
        }
        [fontAttributes setObject:color forKey:NSForegroundColorAttributeName];
        [label drawAtPoint:point withAttributes:fontAttributes];
        point.y += spacing;
    }
    
    point = CGPointMake(68, 0);
    for (int i = 5; i >= 1; i--) {
        float volume = [[_vm valueForKey:[NSString stringWithFormat:@"askVolume%d", i]] intValue]/100.0;
        [fontAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        if (volume == 0) {
            label = [NSString stringWithFormat:@"—"];
        }
        else {
            label = [NSString stringWithFormat:@"%.0f", volume];
        }
        CGFloat textWidth = [label boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributes context:nil].size.width;
        point.x = self.frame.size.width - textWidth - 6;
        [label drawAtPoint:point withAttributes:fontAttributes];
        point.y += spacing;
    }
    point.y += 2;
    for (int i = 1; i <= 5; i++) {
        float volume = [[_vm valueForKey:[NSString stringWithFormat:@"bidVolume%d", i]] intValue]/100.0;
        [fontAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        if (volume == 0) {
            label = [NSString stringWithFormat:@"—"];
        }
        else {
            label = [NSString stringWithFormat:@"%.0f", volume];
        }
        CGFloat textWidth = [label boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin attributes:fontAttributes context:nil].size.width;
        point.x = self.frame.size.width - textWidth - 6;
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
    NSLog(@"FiveBetsView dealloc (%@)", _code);
}

@end
