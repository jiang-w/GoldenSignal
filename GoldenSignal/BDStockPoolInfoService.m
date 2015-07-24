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
            BDBulletin *bulletin = [[BDBulletin alloc] init];
            bulletin.innerId = [item[@"ID"] longValue];
            bulletin.title = item[@"TIT"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd";
            bulletin.date = [formatter dateFromString:item[@"PUB_DT"]];
            
            if (item[@"CONT_ID"] == [NSNull null]) {
                bulletin.connectId = 0;//标记下
            } else {
                bulletin.connectId = [item[@"CONT_ID"] longValue];
            }
            
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
            BDNews *news = [[BDNews alloc] init];
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
    [parameters setValue:[NSNumber numberWithLong:connectId] forKey:@"CONT_ID"];
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
 *  获取 研报 详细内容数据
 *
 *  @param id 每个cell对应的id（自己找下）
 *
 *  @return 返回一个model
 */
- (BDReportList *)getReportDetailById:(long)connectId {
    BDReportList *report = nil;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSNumber numberWithLong:connectId] forKey:@"CONT_ID"];
    BDCoreService *service = [BDCoreService new];
    NSArray *data = [service syncRequestDatasourceService:1595 parameters:parameters query:nil];
    for (NSDictionary *item in data) {
        report = [[BDReportList alloc] init];
        report.title = item[@"TIT"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        report.date = [formatter dateFromString:item[@"PUB_DT"]];
        
        //有空值的情况
        report.rating = (item[@"RAT_ORIG_DESC"] == [NSNull null]) ? @"" : item[@"RAT_ORIG_DESC"];//评级
        report.RAT_CODE = (item[@"RAT_CODE"] == [NSNull null]) ? 0 : [item[@"RAT_CODE"] longValue];
        report.targ_prc = (item[@"TARG_PRC"] == [NSNull null]) ? 0.00 : [item[@"TARG_PRC"] floatValue];//价格
        report.com = item[@"COM_NAME"];
        report.aut = item[@"AUT"];
        report.cont_id = [item[@"CONT_ID"] longValue];//链接Id
//        report.CONT = item[@"CONT"];
        break;
    }
    return report;
}

//value	__NSCFString *	@"　　预计 创业板 上半年净利润同比增速达到26.8%，二季度单季净利润同比增速达到37.8%，相较一季度出现明显反弹，在对并购重组产生的外延增长效应做适当修正后，创业板二季度单季净利润增速仍然有32.8%，反映其内生增长也保持较快速度\r\n　　由于工业企业利润在5、6月份恢复增长且 房地产 投资增速有所企稳，预计主板非金融上市公司二季度净利润整体增速会有小幅提升，但上半年整体增速较去年同期仍有明显下滑\r\n　　目前中信二级行业中白色家电、小家电、汽车零部件、牧业（畜牧养殖类上市公司）和食品拥有相对稳定的 业绩 增速与合理的估值，具有较高的中期配置价值\r\n　　股灾对创业板上市公司形成了明显的负反馈效应，在暂时丧失二级市场融资能力后，许多寻求外延式扩张或转型的上市公司都放慢脚步，但此前已充分融资备足弹药的公司会度过这段股价低迷期，并在业务模式进一步被证实和认可后，迎来绝佳投资机会\r\n　　——中信证券\r\n　　据上海证券报报道 根据目前 中小板 、创业板的半 年报 盈利预告情况以及对主板上市公司盈利趋势的判断，在经过一定修正后， 中信证券(600030)预计主板、中小板和创业板二季度单季的盈利同比增速分别为-2.4%、22.8%和37.8%，中小创上市公司依旧保持较高盈利增速。在剔除并购重组带来的外延式盈利增长后，中信证券估计中小板和创业板的内生盈利仍然能够维持较高增速，分别为18.6%和32.8%。\r\n　　半年报业绩\r\n　　创业板 二季度业绩增速明显加快\r\n　　截至7月15日，创业板全部上市公司均已预告了2015年半年报业绩。从历史情况来看，创业板 业绩预告 与最终实际的 中报 业绩差别并不大，在2011年到2014年这四年间，板块实际盈利与预告盈利的比值平均为96.88%，仅有小幅度的高估。所以基本可以用创业板上市公司半年报业绩预告去估计创业板整体2015年半年度业绩增速，在业绩预告的基础上假设“实际盈利/预告盈利”为97%。按照3%的高估率，我们预计创业板上半年净利润同比增长率为26.8%，去年同期是15.9%。二季度单季盈利同比增速为37.8%，相较一季度出现明显反弹，接近2014Q4的历史增速高点。\r\n　　为了尽可能排除创业板公司并购重组产生的外延式增长，剔除所有在2014年6月30日至2015年6月30日之间完成重大重组事项的上市公司，其二季度净利润占创业板总净利润的比例约11.6%。扣除这部分上市公司的影响后，"	0x00007fd8fb419e40


#pragma mark    -- 新闻 详细子页面 PUB_DT    TIT   MED_NAME    AUT   CONT    传的id
- (BDNews *)getOptionalNewsDetailById:(long)connectId andPageId:(int)pageId{
    BDNews *newsModel = [[BDNews alloc]init];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSNumber numberWithLong:connectId] forKey:@"CONT_ID"];
    BDCoreService *service = [BDCoreService new];
    
    NSArray *data = [service syncRequestDatasourceService:pageId parameters:parameters query:nil];
    for (NSDictionary *item in data) {
        
        newsModel.connectId = connectId;
        
        newsModel.title = item[@"TIT"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
        if (pageId == 1595) {//策略的详情页面
            formatter.dateFormat = @"yyyy-MM-dd";
        }
        
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
