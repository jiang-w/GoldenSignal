//
//  BDStockPoolInfoService.m
//  GoldenSignal
//
//  Created by Frank on 15/6/18.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "BDStockPoolInfoService.h"
#import "BDCoreService.h"
#import <AFNetworking.h>



@implementation BDStockPoolInfoService

#pragma mark    --提示列表
- (NSMutableArray *)getPromptListBySecuCodes:(NSMutableArray *)codes pageIndex:(NSUInteger)index andPageSize:(NSUInteger)size {
    Stopwatch *watch = [Stopwatch startNew];
    NSMutableArray *list = [NSMutableArray array];
    @try {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        if (codes.count > 0) {
            NSString *codeString = [NSString stringWithFormat:@"'%@'", [codes componentsJoinedByString:@"','"]];
            [parameters setObject:codeString forKey:@"BD_CODE"];
        }
        [parameters setObject:[NSNumber numberWithUnsignedInteger:size] forKey:@"COUNT"];
        [parameters setObject:[NSNumber numberWithUnsignedInteger:index] forKey:@"INDEX"];
        
        BDCoreService *service = [BDCoreService new];
        NSArray *data = [service syncRequestDatasourceService:1578 parameters:parameters query:nil];
        for (NSDictionary *item in data) {
            BDPrompt *prompt = [[BDPrompt alloc] init];
            prompt.innerId = [item[@"ID"] longValue];
            prompt.title = item[@"NTC_CONT"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd";
            prompt.date = [formatter dateFromString:item[@"PUB_DT"]];
            prompt.bdCode = item[@"BD_CODE"];
            prompt.trdCode = item[@"TRD_CODE_STK"];
            prompt.secuName = item[@"SECU_SHT"];
            [list addObject:prompt];
        }
        
        [watch stop];
        NSLog(@"Success: 加载自选股提示列表 Timeout:%.3fs", watch.elapsed);
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载自选股提示列表 %@",exception.reason);
    }
    return list;
}


#pragma mark    --公告列表
- (NSMutableArray *)getBulletinListBySecuCodes:(NSArray *)codes lastId:(long)lastId quantity:(int)quantity {
    Stopwatch *watch = [Stopwatch startNew];
    NSMutableArray *list = [NSMutableArray array];
    @try {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        if (codes.count > 0) {
            NSString *codeString = [NSString stringWithFormat:@"'%@'", [codes componentsJoinedByString:@"','"]];
            [parameters setObject:codeString forKey:@"BD_CODE"];
        }
        [parameters setValue:[NSNumber numberWithInt:quantity] forKey:@"COUNT"];
        [parameters setValue:[NSNumber numberWithLong:lastId] forKey:@"ID"];
        
        BDCoreService *service = [BDCoreService new];
        NSArray *data = [service syncRequestDatasourceService:1575 parameters:parameters query:nil];
        for (NSDictionary *item in data) {
            BDAnnouncementList *bulletin = [[BDAnnouncementList alloc] init];
            bulletin.innerId = [item[@"ID"] longValue];
            bulletin.title = item[@"TIT"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd";
            bulletin.date = [formatter dateFromString:item[@"PUB_DT"]];
            bulletin.contentId = bulletin.innerId;
            
//            if (item[@"CONT_ID"] == [NSNull null]) {
//                bulletin.connectId = 0;//标记下
//            } else {
//                bulletin.connectId = [item[@"CONT_ID"] longValue];
//            }
            
            [list addObject:bulletin];
        }
        
        [watch stop];
        NSLog(@"Success: 加载自选股公告列表 Timeout:%.3fs", watch.elapsed);
        
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载自选股公告列表 %@",exception.reason);
    }
    return list;
}

#pragma mark    --研报列表
- (NSMutableArray *)getReportListBySecuCode:(NSArray *)codes pageIndex:(NSUInteger)index andPageSize:(NSUInteger)size {
    Stopwatch *watch = [Stopwatch startNew];
    NSMutableArray *list = [NSMutableArray array];
    @try {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        if (codes.count > 0) {
            NSString *codeString = [NSString stringWithFormat:@"'%@'", [codes componentsJoinedByString:@"','"]];
            [parameters setObject:codeString forKey:@"BD_CODE"];
        }
        [parameters setObject:[NSNumber numberWithUnsignedInteger:size] forKey:@"COUNT"];
        [parameters setObject:[NSNumber numberWithUnsignedInteger:index] forKey:@"INDEX"];
        
        BDCoreService *service = [BDCoreService new];
        //这步比较耗时间
        NSArray *data = [service syncRequestDatasourceService:1576 parameters:parameters query:nil];
        
        for (NSDictionary *item in data) {
            BDReportList *report = [[BDReportList alloc] init];
            report.innerId = [item[@"ID"] longValue];
            report.title = item[@"TIT"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd";
            report.date = [formatter dateFromString:item[@"PUB_DT"]];
            
            //有空值的情况
            report.rating = (item[@"RAT_ORIG_DESC"] == [NSNull null]) ? @"" : item[@"RAT_ORIG_DESC"];
            report.RAT_CODE = (item[@"RAT_CODE"] == [NSNull null]) ? 0 : [item[@"RAT_CODE"] longValue];
            report.targ_prc = (item[@"TARG_PRC"] == [NSNull null]) ? 0.00 : [item[@"TARG_PRC"] floatValue];
            report.com = item[@"COM_NAME"];
            report.aut = (item[@"AUT"] == [NSNull null]) ? @"" : item[@"AUT"];
            report.abst = item[@"ABST"];
            report.cont_id = [item[@"CONT_ID"] longValue];
            [list addObject:report];
        }
        
        //买入、推荐10  谨慎推荐 增持 审慎推荐20  中性、持有30 卖出、回避50
        [watch stop];
        NSLog(@"Success: 加载自选股研报列表 Timeout:%.3fs", watch.elapsed);
        
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载自选股研报列表 %@",exception.reason);
    }
    return list;
}

#pragma mark    --新闻列表
- (NSMutableArray *)getNewsListBySecuCodes:(NSMutableArray *)codes lastId:(long)lastId quantity:(int)quantity {
    Stopwatch *watch = [Stopwatch startNew];
    NSMutableArray *list = [NSMutableArray array];
    @try {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        if (codes.count > 0) {
            NSString *codeString = [NSString stringWithFormat:@"'%@'", [codes componentsJoinedByString:@"','"]];
            [parameters setObject:codeString forKey:@"BD_CODE"];
        }
        [parameters setValue:[NSNumber numberWithInt:quantity] forKey:@"COUNT"];
        [parameters setValue:[NSNumber numberWithLong:lastId] forKey:@"ID"];
        
        BDCoreService *service = [BDCoreService new];
        NSArray *data = [service syncRequestDatasourceService:1577 parameters:parameters query:nil];
        for (NSDictionary *item in data) {
            BDNewsList *news = [[BDNewsList alloc] init];
            news.innerId = [item[@"ID"] longValue];
            news.title = item[@"TIT"];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm";
            //为空不为空两种情况
            news.date = (item[@"PUB_DT"] == [NSNull null]) ? 0 : [formatter dateFromString:item[@"PUB_DT"]] ;
            
            news.connectId = (item[@"CONT_ID"] == [NSNull null]) ? 0 : [item[@"CONT_ID"] longValue];
            
            news.media = item[@"MED_NAME"];
            news.abstract = item[@"ABST"];
            [list addObject:news];
        }
        [watch stop];
        NSLog(@"Success: 加载自选股新闻列表 Timeout:%.3fs", watch.elapsed);
        
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载自选股新闻列表 %@",exception.reason);
    }
    return list;
}


#pragma mark    --业绩列表
- (NSMutableArray *)getPerformanceListBySecuCodes:(NSMutableArray *)codes lastId:(long)lastId quantity:(int)quantity {
    Stopwatch *watch = [Stopwatch startNew];
    NSMutableArray *list = [NSMutableArray array];
    @try {
        NSString *codeString = [NSString stringWithFormat:@"'%@'", [codes componentsJoinedByString:@"','"]];
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setValue:codeString forKey:@"BD_CODE"];
        [parameters setValue:[NSNumber numberWithInt:quantity] forKey:@"PSize"];
        [parameters setValue:[NSNumber numberWithInt:1] forKey:@"PIndex"];
        if (lastId != 0) {
            NSString *filter = [NSString stringWithFormat:@"{\"LeftPart\":\"ID\",\"RightPart\":%ld,\"Mode\":2}", lastId];
            [parameters setValue:filter forKey:@"filter"];
        }
        
        BDCoreService *service = [BDCoreService new];
        NSArray *data = [service syncRequestDatasourceService:1579 parameters:parameters query:nil];
        for (NSDictionary *item in data) {
            BDPrompt *prompt = [[BDPrompt alloc] init];
            prompt.innerId = [item[@"ID"] longValue];
            prompt.title = item[@"NTC_CONT"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd";
            prompt.date = [formatter dateFromString:item[@"BGN_DT"]];
            prompt.bdCode = item[@"BD_CODE"];
            prompt.trdCode = item[@"TRD_CODE_STK"];
            prompt.secuName = item[@"SECU_SHT"];
            [list addObject:prompt];
        }
        [watch stop];
        NSLog(@"Success: 加载自选股提示列表 Timeout:%.3fs", watch.elapsed);
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载自选股提示列表 %@",exception.reason);
    }
    return list;
}

@end
