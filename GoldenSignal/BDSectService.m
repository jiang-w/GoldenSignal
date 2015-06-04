//
//  BDSectService.m
//  GoldenSignal
//
//  Created by Frank on 15/1/26.
//  Copyright (c) 2015年 bigdata. All rights reserved.
//

#import "BDSectService.h"
#import "BDCoreService.h"
#import "BDNetworkService.h"

@implementation BDSectService

- (NSArray *)getSectInfoByTypeCode:(NSString *)typCode {
    NSMutableArray *sectArray = [NSMutableArray array];
    BDCoreService *service = [BDCoreService new];
    NSDictionary *paramDic = nil;
    if (typCode != nil) {
        paramDic = @{@"filter": [NSString stringWithFormat:@"{\"LeftPart\":\"TYP\",\"RightPart\":\"%@\",\"Mode\":4}", typCode]};
    }
    
    NSArray *data = [service syncRequestDatasourceService:1553 parameters:paramDic query:nil];
    for (NSDictionary *item in data) {
        BDSectInfo *sect = [[BDSectInfo alloc] init];
        sect.sectId = [item[@"SECT_ID"] longValue];
        sect.name = item[@"SECT_NAME"];
        sect.typCode = [item[@"TYP"] stringValue];
        sect.typName = item[@"TYP_NAME"];
        sect.sort = [item[@"RN"] intValue];
        [sectArray addObject:sect];
    }
    return sectArray;
}

- (NSArray *)getSecuCodesBySectId:(long)sectId sortByIndicateName:(NSString *)name ascending:(BOOL)asc {
    @try {
        NSHTTPURLResponse *response;
        NSError *error;
        NSString *url = [NSString stringWithFormat:@"%@/SortRequest?sector-id=%ld&indicate-name=%@&sort-type=%d"
                         , QUOTE_HTTP_URL
                         , sectId, name != nil ? name : @"ChangeRange"
                         , asc ? 1 : 2];
        NSData *data = [[BDNetworkService sharedInstance] syncGetRequest:url returnResponse:&response error:&error];
        if (data) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            NSArray *codes = [dic objectForKey:@"codes"];
            return codes;
        }
        else {
            return nil;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 获取板块(%ld)成分出错 %@", sectId, exception.reason);
    }
}

- (NSArray *)getSecuCodesBySectId:(long)sectId andCodes:(NSArray *)codeArray sortByIndicateName:(NSString *)name ascending:(BOOL)asc {
    @try {
        NSHTTPURLResponse *response;
        NSError *error;
        NSString *url = [NSString stringWithFormat:@"%@/SortRequest?sector-id=%ld&indicate-name=%@&sort-type=%d"
                         , QUOTE_HTTP_URL
                         , sectId, name != nil ? name : @"ChangeRange"
                         , asc ? 1 : 2];
        if (codeArray != nil && codeArray.count > 0) {
            NSString *codesParm = [codeArray componentsJoinedByString:@","];
            url = [NSString stringWithFormat:@"%@&codes=%@", url, codesParm];
        }
        NSData *data = [[BDNetworkService sharedInstance] syncGetRequest:url returnResponse:&response error:&error];
        if (data) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            NSArray *codes = [dic objectForKey:@"codes"];
            return codes;
        }
        else {
            return nil;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Failure: 获取板块(%ld)成分出错 %@", sectId, exception.reason);
    }
}

@end
