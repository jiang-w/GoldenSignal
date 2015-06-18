//
//  BDKeyboardWizard.m
//  CBNAPP
//
//  Created by Frank on 14/11/20.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "BDKeyboardWizard.h"
#import "BDCoreService.h"
#import "BDDatabaseAccess.h"

#define TABLENAME @"SecuInfo"

@implementation BDKeyboardWizard

+ (instancetype)sharedInstance {
    static dispatch_once_t  onceToken;
    static BDKeyboardWizard *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BDKeyboardWizard alloc] init];
    });
    return sharedInstance;
}

- (BDSecuCode *)queryWithSecuCode:(NSString *)bdCode {
    BDSecuCode *secu = nil;
    BDDatabaseAccess *dbAccess = [[BDDatabaseAccess alloc] initWithPath:KEYBOARD_WIZARD_DATABASE];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where BD_CODE = ?", TABLENAME];
    FMResultSet *rs = [dbAccess queryTable:sql, bdCode];
    while ([rs next]){
        secu = [self parseFromResult:rs];
        break;
    }
    [rs close];
    return secu;
}

- (NSArray *)fuzzyQueryWithText:(NSString *)text {
    NSMutableArray *resultArray = [NSMutableArray array];
    BDDatabaseAccess *dbAccess = [[BDDatabaseAccess alloc] initWithPath:KEYBOARD_WIZARD_DATABASE];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where TRD_CODE like '%%%@%%' or PY_SHT like '%%%@%%' or SECU_SHT like '%%%@%%'", TABLENAME, text, text, text];
    FMResultSet *rs = [dbAccess queryTable:sql];
    while ([rs next]){
        BDSecuCode *secu = [self parseFromResult:rs];
        [resultArray addObject:secu];
    }
    [rs close];
    return resultArray;
}

- (void)update {
    @try {
        NSDate *maxDate = [self getMaxUpdateTime];
        if (maxDate) {
            BDCoreService *service = [BDCoreService new];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
            NSString *filter = [NSString stringWithFormat:@"{\"LeftPart\":\"UPD_TIME\",\"RightPart\":\"%@\",\"Mode\":0}", [dateFormatter stringFromDate:maxDate]];
            NSDictionary *parameters = @{@"filter": filter};
            NSArray *data = [service syncRequestDatasourceService:1542 parameters:parameters query:nil];
            
            if (data != nil && data.count > 0) {
                for (NSDictionary *item in data) {
                    BDSecuCode *secu = [self parseFromRespone:item];
                    [self InsertOrUpdateSecuCode:secu];
                    NSLog(@"已更新键盘精灵数据(BD_CODE:%@)", secu.bdCode);
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"更新键盘精灵数据出错：%@", exception.reason);
    }
}

- (void)InsertOrUpdateSecuCode:(BDSecuCode *)secu {
    BDSecuCode *original = [self queryWithSecuCode:secu.bdCode];
    BDDatabaseAccess *dbAccess = [[BDDatabaseAccess alloc] initWithPath:KEYBOARD_WIZARD_DATABASE];
    if (original) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set TRD_CODE = ?, SECU_SHT = ?, PY_SHT = ?, TYP_CODEI = ?, UPD_TIME = ?, EXCH = ? where BD_CODE = ?", TABLENAME];
        [dbAccess updateTable:sql, secu.trdCode, secu.name, secu.py, [NSNumber numberWithInt:(int)secu.typ], secu.updateTime, [NSNumber numberWithInt:secu.exchCode], secu.bdCode];
    }
    else {
        NSString *sql = [NSString stringWithFormat:@"insert into %@ values (?,?,?,?,?,?,?)", TABLENAME];
        [dbAccess insertTable:sql, secu.bdCode, secu.trdCode, secu.name, secu.py, [NSNumber numberWithInt:(int)secu.typ], secu.updateTime, [NSNumber numberWithInt:secu.exchCode]];
    }
}

- (BDSecuCode *)parseFromResult:(FMResultSet *)rs {
    BDSecuCode *secu = [[BDSecuCode alloc] init];
    secu.bdCode = [rs stringForColumn:@"BD_CODE"];
    secu.trdCode = [rs stringForColumn:@"TRD_CODE"];
    secu.name = [rs stringForColumn:@"SECU_SHT"];
    secu.py = [rs stringForColumn:@"PY_SHT"];
    secu.typ = (SecuType)[rs intForColumn:@"TYP_CODEI"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    secu.updateTime = [dateFormatter dateFromString:[rs stringForColumn:@"UPD_TIME"]];
    secu.exchCode = [rs intForColumn:@"EXCH"];
    return secu;
}

- (BDSecuCode *)parseFromRespone:(NSDictionary *)dic {
    BDSecuCode *secu = [[BDSecuCode alloc] init];
    secu.bdCode = dic[@"BD_CODE"];
    secu.trdCode = dic[@"TRD_CODE"];
    secu.name = dic[@"SECU_SHT"];
    secu.py = dic[@"PY_SHT"];
    secu.typ = (SecuType)[dic[@"TYP_CODEI"] intValue];
    BDCoreService *server = [[BDCoreService alloc] init];
    secu.updateTime = [server deserializeJsonDateString:dic[@"UPD_TIME"]];
    secu.exchCode = [dic[@"EXCH"] intValue];
    return secu;
}

- (NSDate *)getMaxUpdateTime {
    NSDate *maxDate = nil;
    BDDatabaseAccess *dbAccess = [[BDDatabaseAccess alloc] initWithPath:KEYBOARD_WIZARD_DATABASE];
    NSString *sql = [NSString stringWithFormat:@"select max(upd_time) upd_time from %@", TABLENAME];
    FMResultSet *rs = [dbAccess queryTable:sql];
    if ([rs next]){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        maxDate = [dateFormatter dateFromString:[rs stringForColumn:@"upd_time"]];
    }
    [rs close];
    return maxDate;
}

@end
