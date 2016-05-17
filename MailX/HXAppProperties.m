//
//  HXAppProperties.m
//  HexaMail
//
//  Created by Tancrède on 2/9/16.
//  Copyright © 2016 Hexa. All rights reserved.
//

#import "HXAppProperties.h"

@implementation HXAppProperties{
    
    NSDictionary * _Nonnull _rootDictionary;
}


// Property file
static NSString * const kDefaultPropertyFileName = @"Properties";
static NSString * const kDefaultPropertyFileType = @"plist";


// Property file entries
static NSString * const kPFE_Providers = @"MailboxProviders";

NSString * _Nonnull const k_Provider_Name = @"Name";
NSString * _Nonnull const k_Provider_Id = @"Id";
NSString * _Nonnull const k_Provider_ProxyClassName = @"ProxyClassName";
NSString * _Nonnull const k_Provider_Labels = @"Labels";

static NSString * const kPFE_DefaultLabels = @"DefaultLabels";
static NSString * const kPFE_SystemLabels = @"SystemLabels";

NSString * _Nonnull const k_Label_Id = @"Id";
NSString * _Nonnull const k_Label_Name = @"Name";


// Notifications
NSString * _Nonnull const k_Notification_UserInfo_Error = @"k_Notification_UserInfo_Error";
NSString * _Nonnull const k_Notification_UserInfo_ProviderId = @"k_Notification_UserInfo_ProviderId";
NSString * _Nonnull const k_Notification_UserInfo_MailboxId = @"k_Notification_UserInfo_MailboxId";

NSString * _Nonnull const k_Notification_ProxyDidLogin = @"k_Notification_ProxyDidLogin";
NSString * _Nonnull const k_Notification_ProxyLoginWithError = @"k_Notification_ProxyLoginWithError";




NSString * _Nonnull const k_LABEL_TYPE_SYSTEM = @"SYSTEM";
NSString * _Nonnull const k_LABEL_TYPE_USER = @"USER";



+ (nonnull HXAppProperties *) defaultProperties
{
    
    static HXAppProperties *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HXAppProperties alloc] initWithFileName: kDefaultPropertyFileName
                                                       andFileType: kDefaultPropertyFileType];
    });
    
    return sharedInstance;
    
}

- (instancetype) initWithFileName: (nonnull NSString *) fileName andFileType: (nonnull  NSString *) fileType
{
    self = [super init];
    if (!self) return nil;
    
    _rootDictionary = [self readPropertyWithFileName:fileName
                                         andFileType:fileType];
    
    return self;
}

- (nonnull NSDictionary *) readPropertyWithFileName: (nonnull NSString *) fileName
                                        andFileType: (nonnull NSString *) fileType
{
    // Read and store app properties
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    return dict;
}

- (nonnull NSArray<NSDictionary<NSString *, NSObject *> *> *) providersProperties
{
    return [_rootDictionary objectForKey:kPFE_Providers];
}

- (nonnull NSDictionary *) providerPropertiesWithProviderId: (nonnull NSString *) providerId
{
    NSMutableString *format = [[NSMutableString alloc] init];
    [format appendString: @"("];
    [format appendString: k_Provider_Id];
    [format appendString: @" == %@)"];

    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: format, providerId];
    NSArray *results = [[self providersProperties] filteredArrayUsingPredicate:predicate];
    
    return results[0];
}

- (nonnull NSArray<NSString *> *) defaultLabels
{
    return [_rootDictionary objectForKey:kPFE_DefaultLabels];
}

- (nonnull NSArray<NSDictionary<NSString *, NSString *> *> *) systemLabels
{
    return [_rootDictionary objectForKey:kPFE_SystemLabels];
}

- (nonnull NSDictionary<NSString *, NSString *> *) systemLabels: (nonnull NSString *) providerId
{
    NSDictionary *providerProps = [self providerPropertiesWithProviderId: providerId];
    NSDictionary *labelsProps = [providerProps objectForKey:k_Provider_Labels];
    
    return labelsProps;
}

- (nonnull NSDictionary<NSString *, NSString *> *)labelWithLabelId:(nonnull NSString *)labelId
{
    NSMutableString *format = [[NSMutableString alloc] init];
    [format appendString: @"("];
    [format appendString: k_Label_Id];
    [format appendString: @" == %@)"];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: format, labelId];
    NSArray *results = [[self systemLabels] filteredArrayUsingPredicate:predicate];
    
    return results[0];
}

@end
