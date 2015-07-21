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


//提示
- (NSMutableArray *)getPromptListBySecuCodes:(NSMutableArray *)codes lastId:(long)lastId quantity:(int)quantity {
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

//公告
- (NSMutableArray *)getBulletinListBySecuCodes:(NSMutableArray *)codes lastId:(long)lastId quantity:(int)quantity {
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
            
            if (item[@"TXT_CONT_ID"] == [NSNull null]) {
                bulletin.connectId = 0;//标记下
            } else {
                bulletin.connectId = [item[@"TXT_CONT_ID"] longValue];
            }
            
            [list addObject:bulletin];
        }
        
        //MJExtension.h 方法
        //    NSMutableArray *testAry = [TestModel objectArrayWithKeyValuesArray:data];
        //    DEBUGLog(@"Debug:%@",testAry);
        //        list = testAry;
        
        [watch stop];
        NSLog(@"Success: 加载自选股公告列表 Timeout:%.3fs", watch.elapsed);
        
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载自选股公告列表 %@",exception.reason);
    }
    return [list copy];
}

//研报 、、ABST_SHT 摘要全文
- (NSMutableArray *)getReportListBySecuCodes:(NSMutableArray *)codes lastId:(long)lastId quantity:(int)quantity {
    Stopwatch *watch = [Stopwatch startNew];
    NSMutableArray *list = [NSMutableArray array];
    @try {
        NSString *codeString = [NSString stringWithFormat:@"'%@'", [codes componentsJoinedByString:@"','"]];
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setValue:codeString forKey:@"BD_CODE"];
        [parameters setValue:[NSNumber numberWithLong:lastId] forKey:@"ID"];
        [parameters setValue:[NSNumber numberWithInt:quantity] forKey:@"COUNT"];
        //        [parameters setValue:[NSNumber numberWithInt:quantity] forKey:@"PSize"];
        //        [parameters setValue:[NSNumber numberWithInt:1] forKey:@"PIndex"];
        //        if (lastId != 0) {
        //            NSString *filter = [NSString stringWithFormat:@"{\"LeftPart\":\"ID\",\"RightPart\":%ld,\"Mode\":2}", lastId];
        //            [parameters setValue:filter forKey:@"filter"];
        //        }
        
        
        BDCoreService *service = [BDCoreService new];
        //这步比较耗时间
        NSArray *data = [service syncRequestDatasourceService:1576 parameters:parameters query:nil];
        
        for (NSDictionary *item in data) {
            BDReport *report = [[BDReport alloc] init];
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
            report.aut = item[@"AUT"];
            report.abst = item[@"ABST"];
            //            DEBUGLog(@"Debug>%@",item[@"ABST_SHT"]);
            report.abstsht = [item[@"ABST_SHT"] isKindOfClass:[NSNull class]]? @"" : item[@"ABST_SHT"];
            [list addObject:report];
        }
        
        //买入、推荐10  谨慎推荐 增持 审慎推荐20  中性、持有30 卖出、回避50
        [watch stop];
        NSLog(@"Success: 加载自选股研报列表 Timeout:%.3fs", watch.elapsed);
        
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 加载自选股研报列表 %@",exception.reason);
    }
    return [list copy];
}


//新闻
- (NSMutableArray *)getNewsListBySecuCodes:(NSMutableArray *)codes lastId:(long)lastId quantity:(int)quantity {
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
            formatter.dateFormat = @"yyyy-MM-dd HH:mm";
            //为空不为空两种情况
            news.date = (item[@"PUB_DT"] == [NSNull null]) ? 0 : [formatter dateFromString:item[@"PUB_DT"]] ;
            
            news.connectId = (item[@"ORIG_ID"] == [NSNull null]) ? 0 : [item[@"ORIG_ID"] longValue];
            
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

//业绩
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



/**
 *  获取 公告 详细内容数据
 *
 *  @param id 每个cell对应的id（自己找下）
 *
 *  @return 返回一个model
 */
- (BDBulletin *)getBulletinDetailById:(long)connectId {
    BDBulletin *bulletin = nil;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSNumber numberWithLong:connectId] forKey:@"ID"];
    BDCoreService *service = [BDCoreService new];
    NSArray *data = [service syncRequestDatasourceService:1589 parameters:parameters query:nil];
    for (NSDictionary *item in data) {
        bulletin = [[BDBulletin alloc] init];
        bulletin.connectId = connectId;
        
        bulletin.title = item[@"TIT"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        bulletin.date = [formatter dateFromString:item[@"PUB_DT"]];
        bulletin.content = item[@"CONT"];
        
        break;
    }
    return bulletin;
}


/**
 *  获取 公告 详细内容数据
 *
 *  @param id 每个cell对应的id（自己找下）
 *
 *  @return 返回一个model
 */
- (BDBulletin *)getReportDetailById:(long)connectId {
    BDBulletin *bulletin = nil;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSNumber numberWithLong:connectId] forKey:@"ID"];
    BDCoreService *service = [BDCoreService new];
    NSArray *data = [service syncRequestDatasourceService:1589 parameters:parameters query:nil];
    for (NSDictionary *item in data) {
        bulletin = [[BDBulletin alloc] init];
        bulletin.connectId = connectId;
        
        bulletin.title = item[@"TIT"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        bulletin.date = [formatter dateFromString:item[@"PUB_DT"]];
        bulletin.content = item[@"CONT"];
        
        break;
    }
    return bulletin;
}


// 新闻 详细子页面 PUB_DT    TIT   MED_NAME    AUT   CONT    传的id
- (BDNews *)getOptionalNewsDetailById:(long)connectId andPageId:(int)pageId{
    BDNews *newsModel = [[BDNews alloc]init];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSNumber numberWithLong:connectId] forKey:@"id"];
    BDCoreService *service = [BDCoreService new];
    
    NSArray *data = [service syncRequestDatasourceService:pageId parameters:parameters query:nil];
    for (NSDictionary *item in data) {
        
        newsModel.connectId = connectId;
        
        newsModel.title = item[@"TIT"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
        
        //        newsModel.date = [formatter dateFromString:item[@"PUB_DT"]];
        newsModel.date = (item[@"PUB_DT"] == [NSNull null]) ? 0 : [formatter dateFromString:item[@"PUB_DT"]] ;
        
        newsModel.media = item[@"MED_NAME"];//媒体名字
        newsModel.companyName = item[@"COM_NAME"];//列表里的公司名字
        
        newsModel.author = (item[@"AUT"] == [NSNull null]) ? @"" : item[@"AUT"];
        newsModel.content = item[@"CONT"];//在详细页面里的内容数据
        newsModel.ABST_SHT = item[@"ABST_SHT"];//在列表里的摘要全文数据
        
        break;
    }
    return newsModel;
}




@end
