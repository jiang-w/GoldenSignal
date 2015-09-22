//
//  BDDataService.m
//  yicai_iso
//
//  Created by Frank on 14-7-30.
//  Copyright (c) 2014年 bigdata. All rights reserved.
//

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "BDNetworkService.h"
#import <AFNetworking.h>
#import <ReactiveCocoa.h>

@interface BDNetworkService()

@property(nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property(nonatomic, strong) Reachability *reachability;

@end

@implementation BDNetworkService

+ (instancetype) sharedInstance {
    static dispatch_once_t  onceToken;
    static BDNetworkService *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BDNetworkService alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.reachability = Reachability.reachabilityForInternetConnection;
        self.manager = [AFHTTPRequestOperationManager manager];
        // 设置请求格式
        self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        // 设置返回格式
        self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        // 检测网络状态
//        __weak BDNetworkService *weakSelf = self;
//        [self.manager.reachabilityManager startMonitoring];
//        [self.manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//            NSLog(@"Network Status: %@", AFStringFromNetworkReachabilityStatus(status));
//            switch (status) {
//                case AFNetworkReachabilityStatusReachableViaWWAN:
//                    [weakSelf setValue:@(wwan) forKey:@"networkStatus"];
//                    [weakSelf.manager.operationQueue setSuspended:NO];
//                    break;
//                case AFNetworkReachabilityStatusReachableViaWiFi:
//                    [weakSelf setValue:@(wifi) forKey:@"networkStatus"];
//                    [weakSelf.manager.operationQueue setSuspended:NO];
//                    break;
//                case AFNetworkReachabilityStatusNotReachable:
//                    [weakSelf setValue:@(disconnection) forKey:@"networkStatus"];
//                    [weakSelf.manager.operationQueue setSuspended:YES];
//                    break;
//                default:
//                    [weakSelf setValue:@(unknown) forKey:@"networkStatus"];
//                    [weakSelf.manager.operationQueue setSuspended:YES];
//                    break;
//            }
//        }];
        
        
        RACSignal *statusSignal = [[[[NSNotificationCenter.defaultCenter
                                      rac_addObserverForName:kReachabilityChangedNotification object:nil]
                                     map:^id(NSNotification *notification) {
                                         return @([notification.object currentReachabilityStatus]);
                                     }]
                                    startWith:@(self.reachability.currentReachabilityStatus)]
                                   distinctUntilChanged];
        RAC(self, networkStatus) = statusSignal;
        
        @weakify(self);
        [statusSignal subscribeNext:^(id x) {
            NetworkStatus status = [x intValue];
            if (status == NotReachable) {
                [self.manager.operationQueue setSuspended:YES];
            }
            else {
                [self.manager.operationQueue setSuspended:NO];
            }
        }];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @strongify(self);
            [self.reachability startNotifier];
        });
    }
    return self;
}

- (void)asyncPostRequest:(NSString *)urlString parameters:(NSDictionary *)parameters
                 success:(void(^)(id responseObject))success
                 failure:(void(^)(NSError *error))failure {
    // 在向服务端发送请求状态栏显示网络活动标志
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [_manager POST:urlString parameters:parameters
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               if (success) {
                   success(responseObject);
               }
               [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (failure) {
                   failure(error);
               }
               [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
           }];
}

- (void)asyncGetRequest:(NSString *) urlString success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure {
    // 在向服务端发送请求状态栏显示网络活动标志
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [_manager GET:urlString parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              if (success) {
                  success(responseObject);
              }
              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(error);
              }
              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
          }];
}

- (NSData *)syncPostRequest:(NSString *)urlString parameters:(NSDictionary *) parameter returnResponse:(NSHTTPURLResponse **)response error:(NSError **) error {
    // 在向服务端发送请求状态栏显示网络活动标志
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSMutableURLRequest *request = [[[AFHTTPRequestSerializer alloc] init] requestWithMethod:@"POST" URLString:urlString parameters:parameter error:error];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:response error:error];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    return data;
}

- (NSData *)syncGetRequest:(NSString *)urlString returnResponse:(NSHTTPURLResponse **)response error:(NSError **) error {
    // 在向服务端发送请求状态栏显示网络活动标志
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSMutableURLRequest *request = [[[AFHTTPRequestSerializer alloc] init] requestWithMethod:@"GET" URLString:urlString parameters:nil error:error];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:response error:error];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    return data;
}

- (NSString *)getMacAddress {
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        //NSLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    //NSLog(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}

@end
