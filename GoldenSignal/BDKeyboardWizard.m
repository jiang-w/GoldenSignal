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
    FMResultSet *rs = [dbAccess queryTable:@"select * from SecuInfo where BD_CODE = ?", bdCode];
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
    NSString *sql = [NSString stringWithFormat:@"select * from SecuInfo where TRD_CODE like '%%%@%%' or PY_SHT like '%%%@%%' or SECU_SHT like '%%%@%%'", text, text, text];
    FMResultSet *rs = [dbAccess queryTable:sql];
    while ([rs next]){
        BDSecuCode *secu = [self parseFromResult:rs];
        [resultArray addObject:secu];
    }
    [rs close];
    return resultArray;
}

- (void)requestServiceData {
    BDCoreService *service = [BDCoreService new];
    NSArray *data = [service syncRequestDatasourceService:1542 parameters:nil query:nil];
    
    if (data != nil && data.count > 0) {
        NSString *tableName = @"SecuInfo";
        BDDatabaseAccess *dbAccess = [[BDDatabaseAccess alloc] initWithPath:KEYBOARD_WIZARD_DATABASE];
        if ([dbAccess tableExists:tableName]) {
            [dbAccess eraseTable:tableName];
        }
        else {
            [dbAccess createTable:tableName withColumns:@"BD_CODE text,TRD_CODE text,SECU_SHT text,PY_SHT text,TYP_CODEI int"];
        }
        
        FMDatabase *database = [FMDatabase databaseWithPath:KEYBOARD_WIZARD_DATABASE];
        if ([database open]) {
            [database beginTransaction];
            BOOL isRollBack = NO;
            @try {
                NSString *sql = [NSString stringWithFormat:@"insert into %@ values (?,?,?,?,?)", tableName];
                for (NSDictionary *item in data) {
                    [database executeUpdate:sql, item[@"BD_CODE"], item[@"TRD_CODE"], item[@"SECU_SHT"], item[@"PY_SHT"], item[@"TYP_CODEI"]];
                }
            }
            @catch (NSException *exception) {
                isRollBack = YES;
                [database rollback];
            }
            @finally {
                if (!isRollBack) {
                    [database commit];
                }
                [database close];
            }
        }
    }
}

- (BDSecuCode *)parseFromResult:(FMResultSet *)rs {
    BDSecuCode *secu = [[BDSecuCode alloc] init];
    secu.bdCode = [rs stringForColumn:@"BD_CODE"];
    secu.trdCode = [rs stringForColumn:@"TRD_CODE"];
    secu.name = [rs stringForColumn:@"SECU_SHT"];
    secu.py = [rs stringForColumn:@"PY_SHT"];
    int typVal = [rs intForColumn:@"TYP_CODEI"];
    switch (typVal) {
        case 10: secu.typ = stock;
            break;
        case 13: secu.typ = idx;
            break;
        default: secu.typ = stock;
            break;
    }
    return secu;
}

@end
