//
//  BDConstant.h
//  yicai_iso
//
//  Created by Frank on 14-7-30.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#define customTagsPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/customTags.arc"]
#define allTagsPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/allTags.arc"]
#define SQLITE_BASE_DATABASE [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/base.db"]

/* 基础服务地址 */
#define BASEURL @"http://t1.chinabigdata.com"
#define POSTURL BASEURL@"/PostService.aspx?"

/* 行情服务器 */
#define QUOTE_SERVER_HOST "123.57.144.48"   //q1.chinabigdata.com
#define QUOTE_SERVER_PORT "443"
//#define QUOTE_SERVER_HOST "10.10.141.172"
//#define QUOTE_SERVER_PORT "5011"
/* 行情服务器(http) */
#define QUOTE_HTTP_URL @"http://q1.chinabigdata.com/quote"

/* 产品编号 */
#define PRODUCT_SN @"016C222210405175E053A38D0A0A26EA"

/* 通知 */
#define QUOTE_SCALAR_NOTIFICATION @"QuoteScalarNotification"
#define QUOTE_SOCKET_CONNECT @"QuoteSocketConnect"
#define QUOTE_SOCKET_CLOSE @"QuoteSocketClose"
#define KEYBOARD_WIZARD_NOTIFICATION @"KeyboardWizardNotification"
#define CUSTOM_STOCK_CHANGED_NOTIFICATION @"CustomStockChangedNotification"
#define TAGS_CHANGED_NOTIFICATION @"CustomTagsChanged"
#define TAGS_SORTED_NOTIFICATION @"CustomTagsSorted"


#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136),[[UIScreen mainScreen] currentMode].size):NO)
#define IOS_7 [[[UIDevice currentDevice] systemVersion] floatValue] > 6.1

#define RGB(R,G,B,A) [UIColor colorWithRed:(R)/255.0 green:(G)/255.0 blue:(B)/255.0 alpha:(A)]
// 获取屏幕 宽度、高度
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

// CGMargin
typedef struct {
    CGFloat top;
    CGFloat right;
    CGFloat bottom;
    CGFloat left;
} CGMargin;
CG_INLINE CGMargin CGMarginMake(CGFloat top, CGFloat right, CGFloat bottom, CGFloat left);
CG_INLINE CGMargin CGMarginMake(CGFloat top, CGFloat right, CGFloat bottom, CGFloat left) {
    CGMargin margin;
    margin.top = top;
    margin.right = right;
    margin.bottom = bottom;
    margin.left = left;
    return margin;
}
static const CGMargin CGMarginZero = {0, 0, 0, 0};

typedef enum {
    unknown = -1,
    disconnection = 0,
    wwan = 1,
    wifi = 2
}NetworkStatus;

typedef enum {
    ok = 1,
    error = 2,
    exception = 254
}operStatus;

typedef struct {
    double low;
    double high;
}PriceRange;

typedef enum {
    KLINE_DAY = 16,       //日线
    KLINE_WEEK = 17,      //周线
    KLINE_MONTH = 18,     //月线
//    KLINE_SEASON = 19,   //季线
//    KLINE_YEAR = 20       //年线
} KLineType;

typedef enum {
    TRENDLINE_1 = 1,   //1日
    TRENDLINE_5 = 2,  //5日
} TrendLineType;