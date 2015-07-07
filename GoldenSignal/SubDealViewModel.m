//
//  SubDealViewModel.m
//  CBNAPP
//
//  Created by Frank on 14/12/11.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "SubDealViewModel.h"
#import "BDQuotationService.h"

#define ArrayCapacity 10

@implementation SubDealViewModel
{
    dispatch_queue_t _propertyUpdateQueue;
    BDQuotationService *_service;
    BDSubDeal *_latestDeal;
}

static NSArray *indicaters;

- (id)initWithCode:(NSString *)code {
    self = [super init];
    if (self) {
        _code = [code copy];
        _propertyUpdateQueue = dispatch_queue_create("SubDealUpdate", nil);
        _service = [BDQuotationService sharedInstance];
        _prevClose = [[_service getCurrentIndicateWithCode:code andName:@"PrevClose"] floatValue];
        _latestDeal = [[BDSubDeal alloc] init];
        _latestDeal.date = [[_service getCurrentIndicateWithCode:code andName:@"Date"] intValue];
        _latestDeal.time = [[_service getCurrentIndicateWithCode:code andName:@"Time"] intValue] / 1000;
        _latestDeal.price = [[_service getCurrentIndicateWithCode:code andName:@"Now"] floatValue];
        _latestDeal.change = [[_service getCurrentIndicateWithCode:code andName:@"Change"] floatValue];
        _latestDeal.volumeSpread = [[_service getCurrentIndicateWithCode:code andName:@"VolumeSpread"] intValue];
        _latestDeal.tradeDirection = [[_service getCurrentIndicateWithCode:code andName:@"TradeDirection"] intValue];
        _latestDeal.positionSpread = [[_service getCurrentIndicateWithCode:code andName:@"PositionSpread"] intValue];
        
        indicaters = @[@"PrevClose", @"Date", @"Time", @"Now", @"Change", @"VolumeSpread", @"TradeDirection", @"PositionSpread"];
        [_service subscribeScalarWithCode:_code indicaters:indicaters];
        [self subscribeSubDeal];
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(subscribeScalarChanged:) name:QUOTE_SCALAR_NOTIFICATION object:nil];
    }
    return self;
}

#pragma mark Subscribe

- (void)subscribeSubDeal {
    [_service subscribeSerialsWithCode:_code indicateName:@"SubDeal" beginDate:0 beginTime:0 numberType:2 number:ArrayCapacity];
}

- (void)subscribeScalarChanged:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    NSString *code = dic[@"code"];
    NSString *indicateName = dic[@"name"];
    id value = dic[@"value"];
    
    if ([code isEqualToString: _code]) {
        dispatch_async(_propertyUpdateQueue, ^{
            if ([indicateName isEqualToString: @"SubDeal"]) {
                NSMutableArray *temp = [NSMutableArray array];
                for (id item in [value objectForKey:@"SubDeal"]) {
                    BDSubDeal *deal = [[BDSubDeal alloc] init];
                    deal.date = [[item objectForKey:@"Date"] intValue];
                    deal.time = [[item objectForKey:@"Time"] intValue] / 1000;
                    deal.price = [[item objectForKey:@"Now"] floatValue];
                    deal.change = [[item objectForKey:@"Change"] floatValue];
                    deal.volumeSpread = [[item objectForKey:@"VolumeSpread"] intValue];
                    deal.tradeDirection = [[item objectForKey:@"TradeDirection"] intValue];
                    deal.positionSpread = [[item objectForKey:@"PositionSpread"] intValue];
                    [temp addObject:deal];
                }
                NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
                NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
                [temp sortUsingDescriptors:[NSArray arrayWithObjects:sort1, sort2, nil]];
                
                [self setValue:temp forKey:@"dealArray"];  //kvo
            }
            else if ([indicateName isEqualToString:@"PrevClose"]) {
                [self setValue:value forKey:@"prevClose"];
            }
            else if ([indicateName isEqualToString:@"Date"]) {
                _latestDeal.date = [value intValue];
            }
            else if ([indicateName isEqualToString:@"Time"]) {
                _latestDeal.time = [value intValue] / 1000;
            }
            else if ([indicateName isEqualToString:@"Now"]) {
                _latestDeal.price = [value floatValue];
            }
            else if ([indicateName isEqualToString:@"Change"]) {
                _latestDeal.change = [value floatValue];
            }
            else if ([indicateName isEqualToString:@"VolumeSpread"]) {
                _latestDeal.volumeSpread = [value intValue];
                
                BDSubDeal *deal = [[BDSubDeal alloc] init];
                deal.date = _latestDeal.date;
                deal.time = _latestDeal.time;
                deal.price = _latestDeal.price;
                deal.change = _latestDeal.change;
                deal.volumeSpread = _latestDeal.volumeSpread;
                deal.tradeDirection = _latestDeal.tradeDirection;
                deal.positionSpread = _latestDeal.positionSpread;
                if (_dealArray.count >= ArrayCapacity) {
                    [_dealArray removeObjectAtIndex:0];
                }
                [[self mutableArrayValueForKey:@"dealArray"] addObject:deal];
            }
            else if ([indicateName isEqualToString:@"TradeDirection"]) {
                _latestDeal.tradeDirection = [value intValue];
            }
            else if ([indicateName isEqualToString:@"PositionSpread"]) {
                _latestDeal.positionSpread = [value intValue];
            }
        });
    }
}

#pragma mark

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SCALAR_NOTIFICATION object:nil];
    [_service unsubscribeScalarWithCode:_code indicaters:indicaters];
//    NSLog(@"SubDealViewModel dealloc (%@)", self.code);
}

@end
