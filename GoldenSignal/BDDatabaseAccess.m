//
//  BDDatabaseAccess.m
//  CBNAPP
//
//  Created by Frank on 14/12/2.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import "BDDatabaseAccess.h"

@implementation BDDatabaseAccess
{
    NSString *_dbPath;
}

- (id)initWithPath:(NSString *)path {
    self = [super init];
    if(nil != self) {
        _dbPath = path;
    }
    return self;
}

// 删除数据库
- (void)deleteDatabse {
    BOOL success;
    NSError *error;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:_dbPath])
    {
        success = [fileManager removeItemAtPath:_dbPath error:&error];
        if (!success) {
            NSException *ex = [NSException exceptionWithName:@"DatabaseException"
                                                      reason:[NSString stringWithFormat:@"Failed to delete old database file with message '%@'.", [error localizedDescription]] userInfo:nil];
            @throw(ex);
        }
    }
}

// 判断是否存在表
- (BOOL)tableExists:(NSString *)tableName {
    FMDatabase *database = [FMDatabase databaseWithPath:_dbPath];
    @try {
        [database open];
        FMResultSet *rs = [database executeQuery:@"SELECT count(*) as 'count' FROM sqlite_master WHERE type ='table' and name = ?", tableName];
        while ([rs next]) {
            NSInteger count = [rs intForColumn:@"count"];
            if (0 == count) {
                return NO;
            }
            else {
                return YES;
            }
        }
        return NO;
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        [database close];
    }
}

// 获得表的数据条数
- (int)getRowNumberOfTable:(NSString *)tableName {
    FMDatabase *database = [FMDatabase databaseWithPath:_dbPath];
    @try {
        [database open];
        NSString *sqlstr = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM %@", tableName];
        FMResultSet *rs = [database executeQuery:sqlstr];
        while ([rs next]) {
            int count = [rs intForColumn:@"count"];
            return count;
        }
        return 0;
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        
    }
}

// 创建表
- (BOOL)createTable:(NSString *)tableName withColumns:(NSString *)columns {
    FMDatabase *database = [FMDatabase databaseWithPath:_dbPath];
    @try {
        [database open];
        NSString *sqlstr = [NSString stringWithFormat:@"CREATE TABLE %@ (%@)", tableName, columns];
        if (![database executeUpdate:sqlstr]) {
            return NO;
        }
        return YES;
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        [database close];
    }
}

// 删除表
- (BOOL)deleteTable:(NSString *)tableName {
    FMDatabase *database = [FMDatabase databaseWithPath:_dbPath];
    @try {
        [database open];
        NSString *sqlstr = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
        if (![database executeUpdate:sqlstr]) {
            return NO;
        }
        return YES;
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        [database close];
    }
}

// 清除表
- (BOOL)eraseTable:(NSString *)tableName {
    FMDatabase *database = [FMDatabase databaseWithPath:_dbPath];
    @try {
        [database open];
        NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
        if (![database executeUpdate:sqlstr]) {
            return NO;
        }
        return YES;
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        [database close];
    }
}

// 插入数据
- (BOOL)insertTable:(NSString*)sql, ... {
    FMDatabase *database = [FMDatabase databaseWithPath:_dbPath];
    @try {
        [database open];
        va_list args;
        va_start(args, sql);
        BOOL result = [database executeUpdate:sql withVAList:args];
        va_end(args);
        return result;
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        [database close];
    }
}

// 修改数据
- (BOOL)updateTable:(NSString*)sql, ... {
    FMDatabase *database = [FMDatabase databaseWithPath:_dbPath];
    @try {
        [database open];
        va_list args;
        va_start(args, sql);
        BOOL result = [database executeUpdate:sql withVAList:args];
        va_end(args);
        return result;
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        [database close];
    }
}

// 查询数据
- (FMResultSet *)queryTable:(NSString*)sql, ... {
    FMDatabase *database = [FMDatabase databaseWithPath:_dbPath];
    @try {
        [database open];
        va_list args;
        va_start(args, sql);
        FMResultSet *result = [database executeQuery:sql withVAList:args];
        va_end(args);
        return result;
    }
    @catch (NSException *exception) {
        [database close];
        @throw exception;
    }
}

@end
