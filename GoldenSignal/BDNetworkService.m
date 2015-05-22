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

@implementation BDNetworkService
{
    AFHTTPRequestOperationManager *_manager;
}

+ (instancetype) sharedInstance {
    static dispatch_once_t  onceToken;
    static BDNetworkService *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BDNetworkService alloc] init];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        // 设置请求格式
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        // 设置返回格式
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        // 检测网络状态
        NSOperationQueue *operationQueue = manager.operationQueue;
        [manager.reachabilityManager startMonitoring];
        [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            NSLog(@"Network Status: %@", AFStringFromNetworkReachabilityStatus(status));
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    sharedInstance->_networkStatus = wwan;
                    [operationQueue setSuspended:NO];
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    sharedInstance->_networkStatus = wifi;
                    [operationQueue setSuspended:NO];
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                    sharedInstance->_networkStatus = disconnection;
                    [operationQueue setSuspended:YES];
                    break;
                default:
                    sharedInstance->_networkStatus = unknown;
                    [operationQueue setSuspended:YES];
                    break;
            }
        }];
        
        sharedInstance->_manager = manager;
    });
    return sharedInstance;
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
