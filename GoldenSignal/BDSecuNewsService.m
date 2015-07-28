//
//  BDBulletinService.m
//  CBNAPP
//
//  Created by Frank on 14/12/16.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "BDSecuNewsService.h"
#import "BDCoreService.h"

@implementation BDSecuNewsService

- (NSArray *)getListWithSecuCode:(NSString *)code type:(NewsType)type quantity:(NSUInteger)quantity {
    NSMutableArray *list = [NSMutableArray array];
    switch (type) {
        case NWS:
            [list addObjectsFromArray:[self getNewsListWithSecuCode:code andQuantity:quantity]];
            break;
        case RPT:
            [list addObjectsFromArray:[self getReportListWithSecuCode:code andQuantity:quantity]];
            break;
        case ANNC:
            [list addObjectsFromArray:[self getAnnouncementListWithSecuCode:code andQuantity:quantity]];
            break;
        default:
            break;
    }
    return list;
}

- (NSArray *)getNewsListWithSecuCode:(NSString *)code andQuantity:(NSUInteger)quantity {
    NSMutableArray *list = [NSMutableArray array];
    BDSecuCode *secu = [[BDKeyboardWizard sharedInstance] queryWithSecuCode:code];
    
    BDCoreService *service = [BDCoreService new];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *codeString = [NSString stringWithFormat:@"'%@'", code];
    [parameters setObject:codeString forKey:@"BD_CODE"];
    [parameters setValue:[NSNumber numberWithUnsignedInteger:quantity] forKey:@"COUNT"];
    [parameters setValue:[NSNumber numberWithLong:0] forKey:@"ID"];
    
    NSArray *data = nil;
    if (secu.typ == idx) {
        NSArray *idxList = @[@"000001", @"000002", @"000003", @"000010", @"000016", @"000300", @"399001", @"399005", @"399006"];
        if ([idxList containsObject:secu.trdCode]) {    // 是否为市场指数
            data = [[BDCoreService new] syncRequestDatasourceService:1580 parameters:parameters query:nil];
        }
        else {
            data = [[BDCoreService new] syncRequestDatasourceService:1584 parameters:parameters query:nil];
        }
    }
    else {
        data = [service syncRequestDatasourceService:1577 parameters:parameters query:nil];
    }
    
    if (data) {
        for (NSDictionary *item in data) {
            BDSecuNewsList *obj = [[BDSecuNewsList alloc] init];
            obj.innerId = [item[@"ID"] longValue];
            obj.title = item[@"TIT"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm";
            obj.date = [formatter dateFromString:item[@"PUB_DT"]];
            
            if (item[@"CONT_ID"] == [NSNull null]) {
                obj.contentId = 0;
            } else {
                obj.contentId = [item[@"CONT_ID"] longValue];
            }
            obj.type = NWS;
            
            [list addObject:obj];
        }
    }
    return list;
}

- (NSArray *)getReportListWithSecuCode:(NSString *)code andQuantity:(NSUInteger)quantity {
    NSMutableArray *list = [NSMutableArray array];
    BDCoreService *service = [BDCoreService new];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *codeString = [NSString stringWithFormat:@"'%@'", code];
    [parameters setObject:codeString forKey:@"BD_CODE"];
    [parameters setObject:[NSNumber numberWithUnsignedInteger:quantity] forKey:@"COUNT"];
    [parameters setObject:[NSNumber numberWithUnsignedInteger:1] forKey:@"INDEX"];
    NSArray *data = [service syncRequestDatasourceService:1576 parameters:parameters query:nil];
    
    if (data) {
        for (NSDictionary *item in data) {
            BDSecuNewsList *obj = [[BDSecuNewsList alloc] init];
            obj.innerId = [item[@"ID"] longValue];
            obj.title = item[@"TIT"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd";
            obj.date = [formatter dateFromString:item[@"PUB_DT"]];
            
            if (item[@"CONT_ID"] == [NSNull null]) {
                obj.contentId = 0;
            } else {
                obj.contentId = [item[@"CONT_ID"] longValue];
            }
            obj.type = RPT;
            
            [list addObject:obj];
        }
    }
    return list;
}

- (NSArray *)getAnnouncementListWithSecuCode:(NSString *)code andQuantity:(NSUInteger)quantity {
    NSMutableArray *list = [NSMutableArray array];
    BDCoreService *service = [BDCoreService new];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *codeString = [NSString stringWithFormat:@"'%@'", code];
    [parameters setObject:codeString forKey:@"BD_CODE"];
    [parameters setValue:[NSNumber numberWithUnsignedInteger:quantity] forKey:@"COUNT"];
    [parameters setValue:[NSNumber numberWithLong:0] forKey:@"ID"];
    NSArray *data = [service syncRequestDatasourceService:1575 parameters:parameters query:nil];
    
    if (data) {
        for (NSDictionary *item in data) {
            BDSecuNewsList *obj = [[BDSecuNewsList alloc] init];
            obj.innerId = [item[@"ID"] longValue];
            obj.title = item[@"TIT"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd";
            obj.date = [formatter dateFromString:item[@"PUB_DT"]];
            
            if (item[@"CONT_ID"] == [NSNull null]) {
                obj.contentId = 0;
            } else {
                obj.contentId = [item[@"CONT_ID"] longValue];
            }
            obj.type = ANNC;
            
            [list addObject:obj];
        }
    }
    return list;
}

@end
