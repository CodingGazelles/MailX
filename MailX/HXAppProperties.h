//
//  HXAppProperties.h
//  HexaMail
//
//  Created by Tancrède on 2/9/16.
//  Copyright © 2016 Hexa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HXAppProperties : NSObject

extern NSString * _Nonnull const k_Notification_UserInfo_Error;
extern NSString * _Nonnull const k_Notification_UserInfo_ProviderId;
extern NSString * _Nonnull const k_Notification_UserInfo_MailboxId;

extern NSString * _Nonnull const k_Notification_ProxyDidLogin;
extern NSString * _Nonnull const k_Notification_ProxyLoginWithError;

extern NSString * _Nonnull const k_Notification_MessagesDidLoad;

extern NSString * _Nonnull const k_Provider_Name;
extern NSString * _Nonnull const k_Provider_Id;
extern NSString * _Nonnull const k_Provider_ProxyClassName;
extern NSString * _Nonnull const k_Provider_Labels;

extern NSString * _Nonnull const k_Label_Id;
extern NSString * _Nonnull const k_Label_Name;

extern NSString * _Nonnull const k_LABEL_TYPE_SYSTEM;
extern NSString * _Nonnull const k_LABEL_TYPE_USER;




+ (nonnull HXAppProperties *) defaultProperties;


- (nonnull NSArray<NSDictionary<NSString *, NSObject *> *> *) providersProperties;
- (nonnull NSDictionary *) providerPropertiesWithProviderId: (nonnull NSString *) providerId;

- (nonnull NSArray<NSString *> *) defaultLabels;
- (nonnull NSArray<NSDictionary<NSString *, NSString *> *> *) systemLabels;
- (nonnull NSDictionary<NSString *, NSString *> *) systemLabels: (nonnull NSString *) providerId;

- (nonnull NSDictionary<NSString *, NSString *> *)labelWithLabelId:(nonnull NSString *)labelId;


@end
