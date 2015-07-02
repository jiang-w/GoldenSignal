//
//  BDStockPoolInfoService.m
//  GoldenSignal
//
//  Created by Frank on 15/6/18.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "BDStockPoolInfoService.h"
#import "BDCoreService.h"

@implementation BDStockPoolInfoService

- (NSArray *)getBulletinListBySecuCodes:(NSArray *)codes lastId:(long)lastId quantity:(int)quantity {
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
        NSArray *data = [service syncRequestDatasourceService:1575 parameters:parameters query:nil];
        for (NSDictionary *item in data) {
            BDBulletin *bulletin = [[BDBulletin alloc] init];
            bulletin.innerId = [item[@"ID"] longValue];
            bulletin.title = item[@"TIT"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd";
            bulletin.date = [formatter dateFromString:item[@"PUB_DT"]];
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

- (NSArray *)getPromptListBySecuCodes:(NSArray *)codes lastId:(long)lastId quantity:(int)quantity {
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

- (NSArray *)getReportListBySecuCodes:(NSArray *)codes lastId:(long)lastId quantity:(int)quantity {
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
        NSArray *data = [service syncRequestDatasourceService:1576 parameters:parameters query:nil];
        for (NSDictionary *item in data) {
            BDReport *report = [[BDReport alloc] init];
            report.innerId = [item[@"ID"] longValue];
            report.title = item[@"TIT"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd";
            report.date = [formatter dateFromString:item[@"PUB_DT"]];
            report.rating = item[@"RAT_ORIG_DESC"];
            if (item[@"TARG_PRC"] != [NSNull null]) {
                report.targ_prc = [item[@"TARG_PRC"] floatValue];
            }
            else {
                report.targ_prc = 0;
            }
            report.com = item[@"COM_NAME"];
            report.aut = item[@"AUT"];
            report.abst = item[@"ABST"];
            [list addObject:report];
        }
        [watch stop];
        NSLog(@"Success: 加载自选股研报列表 Timeout:%.3fs", watch.elapsed);
        
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载自选股研报列表 %@",exception.reason);
    }
    return list;
}

- (NSArray *)getNewsListBySecuCodes:(NSArray *)codes lastId:(long)lastId quantity:(int)quantity {
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
        NSArray *data = [service syncRequestDatasourceService:1577 parameters:parameters query:nil];
        for (NSDictionary *item in data) {
            BDNews *news = [[BDNews alloc] init];
            news.innerId = [item[@"ID"] longValue];
            news.title = item[@"TIT"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd";
            news.date = [formatter dateFromString:item[@"PUB_DT"]];
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

- (NSArray *)getPerformanceListBySecuCodes:(NSArray *)codes lastId:(long)lastId quantity:(int)quantity {
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

// 获取公告详细内容数据
- (BDBulletin *)getBulletinDetailById:(long)id {
    BDBulletin *bulletin = nil;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSNumber numberWithLong:id] forKey:@"ID"];
    BDCoreService *service = [BDCoreService new];
    NSArray *data = [service syncRequestDatasourceService:1589 parameters:parameters query:nil];
    for (NSDictionary *item in data) {
        bulletin = [[BDBulletin alloc] init];
        bulletin.innerId = id;
        bulletin.title = item[@"TIT"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        bulletin.date = [formatter dateFromString:item[@"PUB_DT"]];
        bulletin.content = item[@"CONT"];
        break;
    }
    return bulletin;
}

@end
