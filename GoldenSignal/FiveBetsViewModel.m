//
//  BDFiveBets.m
//  CBNAPP
//
//  Created by Frank on 14/11/20.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "FiveBetsViewModel.h"
#import "BDQuotationService.h"

@implementation FiveBetsViewModel
{
    dispatch_queue_t _propertyUpdateQueue;
    BDQuotationService *_service;
}

static NSArray *indicaters;

- (id)initWithCode:(NSString *)code {
    self = [super init];
    if (self) {
        _code = [code copy];
        _propertyUpdateQueue = dispatch_queue_create("FiveBetsUpdate", nil);
        _service = [BDQuotationService sharedInstance];
        _prevClose = [[_service getCurrentIndicateWithCode:code andName:@"PrevClose"] floatValue];
        _bidPrice1 = [[_service getCurrentIndicateWithCode:code andName:@"BidPrice1"] floatValue];
        _bidPrice2 = [[_service getCurrentIndicateWithCode:code andName:@"BidPrice2"] floatValue];
        _bidPrice3 = [[_service getCurrentIndicateWithCode:code andName:@"BidPrice3"] floatValue];
        _bidPrice4 = [[_service getCurrentIndicateWithCode:code andName:@"BidPrice4"] floatValue];
        _bidPrice5 = [[_service getCurrentIndicateWithCode:code andName:@"BidPrice5"] floatValue];
        _bidVolume1 = [[_service getCurrentIndicateWithCode:code andName:@"BidVolume1"] intValue];
        _bidVolume2 = [[_service getCurrentIndicateWithCode:code andName:@"BidVolume2"] intValue];
        _bidVolume3 = [[_service getCurrentIndicateWithCode:code andName:@"BidVolume3"] intValue];
        _bidVolume4 = [[_service getCurrentIndicateWithCode:code andName:@"BidVolume4"] intValue];
        _bidVolume5 = [[_service getCurrentIndicateWithCode:code andName:@"BidVolume5"] intValue];
        _askPrice1 = [[_service getCurrentIndicateWithCode:code andName:@"AskPrice1"] floatValue];
        _askPrice2 = [[_service getCurrentIndicateWithCode:code andName:@"AskPrice2"] floatValue];
        _askPrice3 = [[_service getCurrentIndicateWithCode:code andName:@"AskPrice3"] floatValue];
        _askPrice4 = [[_service getCurrentIndicateWithCode:code andName:@"AskPrice4"] floatValue];
        _askPrice5 = [[_service getCurrentIndicateWithCode:code andName:@"AskPrice5"] floatValue];
        _askVolume1 = [[_service getCurrentIndicateWithCode:code andName:@"AskVolume1"] intValue];
        _askVolume2 = [[_service getCurrentIndicateWithCode:code andName:@"AskVolume2"] intValue];
        _askVolume3 = [[_service getCurrentIndicateWithCode:code andName:@"AskVolume3"] intValue];
        _askVolume4 = [[_service getCurrentIndicateWithCode:code andName:@"AskVolume4"] intValue];
        _askVolume5 = [[_service getCurrentIndicateWithCode:code andName:@"AskVolume5"] intValue];
        
        indicaters = @[@"PrevClose",
                       @"BidPrice1", @"BidPrice2", @"BidPrice3", @"BidPrice4", @"BidPrice5",
                       @"BidVolume1", @"BidVolume2", @"BidVolume3", @"BidVolume4", @"BidVolume5",
                       @"AskPrice1", @"AskPrice2", @"AskPrice3", @"AskPrice4", @"AskPrice5",
                       @"AskVolume1", @"AskVolume2", @"AskVolume3", @"AskVolume4", @"AskVolume5"];
        [self subscribeQuotationScalarWithCode:code];
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(subscribeScalarChanged:) name:QUOTE_SCALAR_NOTIFICATION object:nil];
    }
    return self;
}

#pragma mark Subscribe

- (void)subscribeQuotationScalarWithCode:(NSString *)code {
    [_service subscribeScalarWithCode:code indicaters:indicaters];
}

- (void)subscribeScalarChanged:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    NSString *code = dic[@"code"];
    NSString *indicateName = dic[@"name"];
    id value = dic[@"value"];
    
    if ([code isEqualToString: _code]) {
        dispatch_async(_propertyUpdateQueue, ^{
            if ([indicateName isEqualToString: @"PrevClose"]) {
                self.prevClose = [value floatValue];
            }
            else if ([indicateName isEqualToString: @"BidPrice1"]) {
                self.bidPrice1 = [value floatValue];
            }
            else if ([indicateName isEqualToString:@"BidPrice2"]) {
                self.bidPrice2 = [value floatValue];
            }
            else if ([indicateName isEqualToString:@"BidPrice3"]) {
                self.bidPrice3 = [value floatValue];
            }
            else if ([indicateName isEqualToString:@"BidPrice4"]) {
                self.bidPrice4 = [value floatValue];
            }
            else if ([indicateName isEqualToString:@"BidPrice5"]) {
                self.bidPrice5 = [value floatValue];
            }
            else if ([indicateName isEqualToString:@"BidVolume1"]) {
                self.bidVolume1 = [value unsignedLongLongValue];
            }
            else if ([indicateName isEqualToString:@"BidVolume2"]) {
                self.bidVolume2 = [value unsignedLongLongValue];
            }
            else if ([indicateName isEqualToString:@"BidVolume3"]) {
                self.bidVolume3 = [value unsignedLongLongValue];
            }
            else if ([indicateName isEqualToString:@"BidVolume4"]) {
                self.bidVolume4 = [value unsignedLongLongValue];
            }
            else if ([indicateName isEqualToString:@"BidVolume5"]) {
                self.bidVolume5 = [value unsignedLongLongValue];
            }
            else if ([indicateName isEqualToString:@"AskPrice1"]) {
                self.askPrice1 = [value floatValue];
            }
            else if ([indicateName isEqualToString:@"AskPrice2"]) {
                self.askPrice2 = [value floatValue];
            }
            else if ([indicateName isEqualToString:@"AskPrice3"]) {
                self.askPrice3 = [value floatValue];
            }
            else if ([indicateName isEqualToString:@"AskPrice4"]) {
                self.askPrice4 = [value floatValue];
            }
            else if ([indicateName isEqualToString:@"AskPrice5"]) {
                self.askPrice5 = [value floatValue];
            }
            else if ([indicateName isEqualToString:@"AskVolume1"]) {
                self.askVolume1 = [value unsignedLongLongValue];
            }
            else if ([indicateName isEqualToString:@"AskVolume2"]) {
                self.askVolume2 = [value unsignedLongLongValue];
            }
            else if ([indicateName isEqualToString:@"AskVolume3"]) {
                self.askVolume3 = [value unsignedLongLongValue];
            }
            else if ([indicateName isEqualToString:@"AskVolume4"]) {
                self.askVolume4 = [value unsignedLongLongValue];
            }
            else if ([indicateName isEqualToString:@"AskVolume5"]) {
                self.askVolume5 = [value unsignedLongLongValue];
            }
        });
    }
}

#pragma mark

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUOTE_SCALAR_NOTIFICATION object:nil];
    [_service unsubscribeScalarWithCode:self.code indicaters:indicaters];
//    NSLog(@"FiveBetsViewModel dealloc (%@)", self.code);
}

@end
