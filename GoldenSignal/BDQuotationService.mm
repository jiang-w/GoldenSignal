//
//  BDQuotationService.m
//  CBNAPP
//
//  Created by Frank on 14/10/24.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#import <BookPoint.hpp>
#import <GroupBookPoint.hpp>
#import <ScalarBookPoint.hpp>
#import <SortBookPoint.hpp>
#import <SerialsBookPoint.hpp>
#import <Context.hpp>

#import <Messages/MessageFormatter.h>
#import <Messages/Sequence.h>
#import <Messages/Group.h>

#import "BDQuotationService.h"
#import "RegexKitLite.h"

using namespace std;
using namespace quotelib;

Context* context;
NSMutableDictionary *BookingPoint;

@implementation BDQuotationService

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static BDQuotationService *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        BookingPoint = [NSMutableDictionary dictionaryWithCapacity:0];
        sharedInstance = [[BDQuotationService alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(resubmit) name:QUOTE_SOCKET_CONNECT object:nil];
    }
    return self;
}

#pragma mark - Connect

// 是否与服务器保持连接
- (BOOL)isConnected {
    if(context == nil) {
        return NO;
    }
    bool b = context->is_connected();
    if (b == true) {
        return YES;
    }
    else {
        return NO;
    }
}

// 连接行情服务器
- (void)connect {
    [self disconnect];
    const std::ios::openmode openMode = std::ios::in;
    NSString *path =  [[NSBundle mainBundle] pathForResource:@"SubscribeTemplate" ofType:@"xml"];
    ifstream template_stream([path UTF8String], openMode);
    if (!template_stream.good()){
        cerr << "Error: Can't open template file" << endl;
    }
    
    context = new Context(template_stream, QUOTE_SERVER_HOST, QUOTE_SERVER_PORT);
    context->set_on_receive_bookpoint(handle_receive_bookpoint);
    context->set_on_connect_socket(handle_connect_socket);
    context->set_on_close_socket(handle_close_socket);
    context->set_on_error(handle_error);
    NSLog(@"连接行情服务器...");
}

// 断开与行情服务器连接
- (void)disconnect {
    if (context != nil) {
        NSLog(@"断开行情服务器链接...");
        delete context;
        context = nil;
    }
}

void handle_connect_socket()
{
    NSLog(@"%s:%s 连接成功", QUOTE_SERVER_HOST, QUOTE_SERVER_PORT);
    // 连接成功发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:QUOTE_SOCKET_CONNECT object:nil userInfo:nil];
}

void handle_close_socket()
{
    NSLog(@"%s:%s 连接中断", QUOTE_SERVER_HOST, QUOTE_SERVER_PORT);
    // 连接断开发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:QUOTE_SOCKET_CLOSE object:nil userInfo:nil];
}

void handle_error(const boost::system::error_code& error, const std::string msg)
{
    NSLog(@"Error: %@", [NSString stringWithCString:msg.c_str() encoding:NSUTF8StringEncoding]);
}

#pragma mark - Receive

// 接收推送数据
void handle_receive_bookpoint(quotelib::BookPointPtr bookpoint, QuickFAST::Messages::MessageField msg_field)
{
    @try {
        NSString *bookpoint_objcstring = [NSString stringWithCString: bookpoint->to_string().c_str() encoding:NSUTF8StringEncoding];
        NSString *code = [bookpoint_objcstring stringByReplacingOccurrencesOfRegex:@"^code: ([0-9A-Z]*\\.[A-Z]*) .*" withString:@"$1"];
        NSString *indicateName = [bookpoint_objcstring stringByReplacingOccurrencesOfRegex:@"^.* indicateName: (.*)" withString:@"$1"];
        
//        std::ostringstream output;
//        QuickFAST::Messages::MessageFormatter formatter(output);
//        std::cout << "received a bookpoint in objective C++ " << bookpoint->to_string() << std::endl;
//        std::cout << " message: ";
//        const Messages::FieldIdentityCPtr & identity = msg_field.getIdentity();
//        const Messages::FieldCPtr & field = msg_field.getField();
//        ValueType::Type type = field->getType();
//        if(type == ValueType::SEQUENCE) {
//            formatter.formatSequence(identity, field);
//        }
//        else if(type == ValueType::GROUP) {
//            formatter.formatGroup(identity, field);
//
//        }
//        else {
//            formatter.displayFieldValue(field);
//        }
//        std::cout << output.str() << std::endl;

        id value = convertFieldValue(msg_field.getField());
        if(value) {
            NSDictionary *userInfo = nil;
            ScalarBookPoint *scalarBookPoint = dynamic_cast<ScalarBookPoint*>(&*bookpoint);
            if (scalarBookPoint) {
                // 将接收的Scalar值存入字典
                NSString *key = [BDQuotationService generateKeyWithCode:code andIndicaterName:indicateName];
                @synchronized(BookingPoint) {
                    if ([BookingPoint.allKeys containsObject:key]) {
                        [BookingPoint[key] setObject:value forKey:@"value"];
                    }
                }
                userInfo = @{@"code": code, @"name": indicateName, @"value": value};
            }
            
            SerialsBookPoint *serialsBookPoint = dynamic_cast<SerialsBookPoint*>(&*bookpoint);
            if (serialsBookPoint) {
                int numberFromBegin = serialsBookPoint->NumberFromBegin();
                int numberType = (int)serialsBookPoint->NumberType();
                userInfo = @{@"code": code, @"name": indicateName, @"value": value, @"numberFromBegin": [NSNumber numberWithInt:-numberFromBegin], @"numberType": [NSNumber numberWithInt:numberType]};
            }
            
            // 使用通知队列异步发送通知
            NSNotification *notification = [[NSNotification alloc] initWithName:QUOTE_SCALAR_NOTIFICATION object:nil userInfo:userInfo];
            [[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostNow];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"BDQuotationService receive error: %@", exception.reason);
    }
}

// 将fast类型转换为oc类型
id convertFieldValue(const Messages::FieldCPtr field)
{
    if(field == nil)
    {
        return nil;
    }
    switch(field->getType())
    {
        case ValueType::EXPONENT:
        case ValueType::INT32:
        {
            return [NSNumber numberWithInt:field->toInt32()];
        }
        case ValueType::LENGTH:
        case ValueType::UINT32:
        {
            return [NSNumber numberWithUnsignedInt:field->toUInt32()];
        }
        case ValueType::MANTISSA:
        case ValueType::INT64:
        {
            return [NSNumber numberWithLong:field->toInt64()];
        }
        case ValueType::UINT64:
        {
            return [NSNumber numberWithUnsignedLong:field->toUInt64()];
        }
        case ValueType::DECIMAL:
        {
            return [NSNumber numberWithDouble:field->toDecimal()];
        }
        case ValueType::ASCII:
        {
            std::string val = (std::string)field->toAscii();
            return [NSString stringWithCString:val.c_str() encoding:NSASCIIStringEncoding];
        }
        case ValueType::UTF8:
        {
            std::string val = (std::string)field->toUtf8();
            return [NSString stringWithCString:val.c_str() encoding:NSUTF8StringEncoding];
        }
//        case ValueType::BYTEVECTOR:
//        {
//            // todo: we probably should hex dump this
//            field->toByteVector();
//            break;
//        }
        case ValueType::GROUP:
        {
            NSMutableDictionary *groupDic = [NSMutableDictionary dictionaryWithCapacity:0];
            Messages::GroupCPtr group = field->toGroup();
            for(Messages::FieldSet::const_iterator fsit = group->begin();fsit != group->end();++fsit)
            {
                NSString *key = [NSString stringWithCString:fsit->name().c_str() encoding:NSUTF8StringEncoding];
                id val = convertFieldValue(fsit->getField());
                groupDic[key] = val;
            }
            
            if (groupDic.count == 0) {
                return nil;
            }
            else if (groupDic.count == 1) {
                return [groupDic.allValues firstObject];
            }
            else {
                return groupDic;
            }
        }
        case ValueType::SEQUENCE:
        {
            NSMutableArray *sequenceArray = [NSMutableArray arrayWithCapacity:0];
            Messages::SequenceCPtr sequence = field->toSequence();
            for(Messages::Sequence::const_iterator it = sequence->begin();it != sequence->end();++it)
            {
                Messages::FieldSetCPtr fieldSet = *it;
                if(fieldSet != nil) {
                    NSMutableDictionary *sequenceItem = [NSMutableDictionary dictionaryWithCapacity:0];
                    for(Messages::FieldSet::const_iterator fsit = fieldSet->begin(); fsit != fieldSet->end(); ++fsit)
                    {
                        NSString *key = [NSString stringWithCString:fsit->name().c_str() encoding:NSUTF8StringEncoding];
                        id val = convertFieldValue(fsit->getField());
                        sequenceItem[key] = val;
                    }
                    [sequenceArray addObject:sequenceItem];
                }
            }
            
            return sequenceArray;
        }
        default:
        {
            return nil;
        }
    }
}


#pragma mark - Subscribe

- (void)subscribeScalarWithCode:(NSString *)code indicaters:(NSArray *)names {
    GroupBookPoint group;
    std::string bookCode = [code cStringUsingEncoding:NSUTF8StringEncoding];
    
    @synchronized(BookingPoint) {
        for (NSString *name in names) {
            NSString *key = [BDQuotationService generateKeyWithCode:code andIndicaterName:name];
            if ([BookingPoint.allKeys containsObject:key]) {
                int count = [[BookingPoint[key] objectForKey:@"count"] intValue];
                [BookingPoint[key] setObject:[NSNumber numberWithInt:count+1] forKey:@"count"];
            }
            else {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"count":[NSNumber numberWithInt:1]}];
                [BookingPoint setObject:dic forKey:key];
                std::string bookName = [name cStringUsingEncoding:NSUTF8StringEncoding];
                group.add(new ScalarBookPoint(context->finder(), bookCode, bookName));
            }
        }
    }
    context->sub(group);
}

- (void)unsubscribeScalarWithCode:(NSString *)code indicaters:(NSArray *)names {
    GroupBookPoint group;
    std::string bookCode = [code cStringUsingEncoding:NSUTF8StringEncoding];
    
    @synchronized(BookingPoint) {
        for (NSString *name in names) {
            NSString *key = [BDQuotationService generateKeyWithCode:code andIndicaterName:name];
            if ([BookingPoint.allKeys containsObject:key]) {
                int count = [[BookingPoint[key] objectForKey:@"count"] intValue];
                if (count == 1) {
                    [BookingPoint removeObjectForKey:key];
                    std::string bookName = [name cStringUsingEncoding:NSUTF8StringEncoding];
                    group.add(new ScalarBookPoint(context->finder(), bookCode, bookName));
                }
                else {
                    [BookingPoint[key] setObject:[NSNumber numberWithInt:count-1] forKey:@"count"];
                }
            }
        }
    }
    context->unsub(group);
}

- (void)subscribeSerialsWithCode:(NSString *)code indicateName:(NSString *)name beginDate:(int)date beginTime:(int)time numberType:(int)type number:(int)number {
    GroupBookPoint group;
    SerialsBookPoint *sbp = new SerialsBookPoint(context->finder(), [code UTF8String], [name UTF8String]);
    
    sbp->set_BeginDate(date);
    sbp->set_BeginTime(time);
    sbp->set_NumberFromBegin(-number);
    sbp->set_NumberType((SerialsNumberType)type);
    group.add(sbp);
    context->sub(group);
}

// 重新订阅
- (void)resubmit {
    int count = (int)BookingPoint.allKeys.count;
    if (count > 0) {
        GroupBookPoint group;
        for (int i = 0; i < count; i++) {
            NSString *key = BookingPoint.allKeys[i];
            NSString *code = [key stringByReplacingOccurrencesOfRegex:@"([0-9A-Z]*\\.[A-Z]*)->(.*)" withString:@"$1"];
            NSString *name = [key stringByReplacingOccurrencesOfRegex:@"([0-9A-Z]*\\.[A-Z]*)->(.*)" withString:@"$2"];
            
            std::string bookCode = [code cStringUsingEncoding:NSUTF8StringEncoding];
            std::string bookName = [name cStringUsingEncoding:NSUTF8StringEncoding];
            group.add(new ScalarBookPoint(context->finder(), bookCode, bookName));
        }
        context->sub(group);
        NSLog(@"重新订阅指标(count:%d)", count);
    }
}

// 返回字典中保存的值
- (id)getCurrentIndicateWithCode:(NSString *)code andName:(NSString *)name {
    NSString *key = [BDQuotationService generateKeyWithCode:code andIndicaterName:name];
    if ([BookingPoint.allKeys containsObject:key]) {
        id val = [BookingPoint[key] objectForKey:@"value"];
        return val;
    }
    else {
        return nil;
    }
}

// 生成字典中的Key
+ (NSString *)generateKeyWithCode:(NSString *)code andIndicaterName:(NSString *)name {
    NSString *key = [NSString stringWithFormat:@"%@->%@", code, name];
    return key;
}


#pragma - ReactiveCocoa

- (RACSignal *)scalarSignalWithCode:(NSString *)code andIndicater:(NSString *)name {
    @weakify(self);
    RACSignal *localSignal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        id value = [self getCurrentIndicateWithCode:code andName:name];
        [subscriber sendNext:value];
        [subscriber sendCompleted];
        return nil;
    }] doCompleted:^{
        // subscribe quote
        [self subscribeScalarWithCode:code indicaters:@[name]];
//        NSLog(@"subscribe:%@ -> %@", code, name);
    }];
    
    RACSignal *quoteSignal = [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:QUOTE_SCALAR_NOTIFICATION object:nil] filter:^BOOL(NSNotification *notification) {
        NSDictionary *dic = notification.userInfo;
        NSString *secuCode = dic[@"code"];
        NSString *indicaterName = dic[@"name"];
        if ([secuCode isEqualToString:code] && [indicaterName isEqualToString:name]) {
            return YES;
        }
        else {
            return NO;
        }
    }] map:^id(NSNotification *notification) {
        NSDictionary *dic = notification.userInfo;
        return dic[@"value"];
    }];
    
    RACSignal *combineSignal = [[localSignal concat:quoteSignal] ignore:nil];
    return combineSignal;
}

- (RACSignal *)kLineSignalWithCode:(NSString *)code forType:(KLineType)type andNumber:(NSInteger)number {
    RACSignal *signal = [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:QUOTE_SCALAR_NOTIFICATION object:nil] filter:^BOOL(NSNotification *notification) {
        NSDictionary *dic = notification.userInfo;
        NSString *secuCode = dic[@"code"];
        NSString *indicaterName = dic[@"name"];
        int num = [dic[@"numberFromBegin"] intValue];
        KLineType ktype = (KLineType)[dic[@"numberType"] intValue];
        
        if ([secuCode isEqualToString:code] && [indicaterName isEqualToString:@"KLine"]
            && ktype == type && num == number) {
            return YES;
        }
        else {
            return NO;
        }
    }] map:^id(NSNotification *notification) {
        NSDictionary *dic = notification.userInfo;
        NSArray *values = [dic[@"value"] objectForKey:@"KLine"];
//        NSLog(@"Signal: 订阅历史K线(%@)", dic[@"code"]);
        return values;
    }];
    
    [self subscribeSerialsWithCode:code indicateName:@"KLine" beginDate:0 beginTime:0 numberType:(int)type number:(int)number];
    return signal;
}

- (RACSignal *)trendLineWithCode:(NSString *)code forDays:(NSUInteger)days andInterval:(NSUInteger)interval {
    RACSignal *signal = [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:QUOTE_SCALAR_NOTIFICATION object:nil] filter:^BOOL(NSNotification *notification) {
        NSDictionary *dic = notification.userInfo;
        NSString *secuCode = dic[@"code"];
        NSString *indicaterName = dic[@"name"];
        int num = [dic[@"numberFromBegin"] intValue];
        int type = [dic[@"numberType"] intValue];
        
        if ([secuCode isEqualToString:code] && [indicaterName isEqualToString:@"TrendLine"]
            && type == interval && num == days) {
            return YES;
        }
        else {
            return NO;
        }
    }] map:^id(NSNotification *notification) {
        NSDictionary *dic = notification.userInfo;
        NSArray *values = [dic[@"value"] objectForKey:@"TrendLine"];
//        NSLog(@"Signal: 订阅历史走势线(%@)", dic[@"code"]);
        return values;
    }];

    [self subscribeSerialsWithCode:code indicateName:@"TrendLine" beginDate:0 beginTime:0 numberType:(int)interval number:(int)days];
    return signal;
}

@end
