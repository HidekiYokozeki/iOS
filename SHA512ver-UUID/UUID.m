//
//  UUID.m
//  
//
//  Created by VCJPCM012 on 2015/01/22.
//  Copyright (c) 2015年 HidekiYokozeki. All rights reserved.
//

#import "UUID.h"
#include <CommonCrypto/CommonDigest.h>

@implementation UUID

//ユニークな名前を設定する
static NSString *UUIDkeyName = @"INPUT YOUR KEYNAME";


+ (NSString*)getUUID{

    NSString    *g_UUIDKey;
    OSStatus res = [UUID searchKeychain];
    
    //ある場合、読み込み
    if( res == noErr )
    {
        NSMutableDictionary *item = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)ref];
        [item setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        [item setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
        
        CFTypeRef pass = nil;
        res = SecItemCopyMatching((__bridge CFDictionaryRef)item, &pass);
        if( res == noErr )
        {
            NSData *data = (__bridge NSData *)pass;
            g_UUIDKey = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
        }
        
    }else{
        // 無い場合は新規作成
        CFUUIDRef uuidRef = CFUUIDCreate( kCFAllocatorDefault );
        CFStringRef uuidStr = CFUUIDCreateString( kCFAllocatorDefault, uuidRef );
        CFRelease( uuidRef );
        g_UUIDKey = [NSString stringWithFormat:@"%@:%@", uuidStr,[self getTimeStamp]];
        g_UUIDKey = [self createSHA512:g_UUIDKey];
        
        // キーチェイン登録
        NSMutableDictionary *item = [NSMutableDictionary dictionary];
        [item setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        [item setObject:UUIDkeyName forKey:(__bridge id)kSecAttrService];
        [item setObject:[g_UUIDKey dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
        
        SecItemAdd((__bridge CFDictionaryRef)item, nil);
        CFRelease( uuidStr );
    }
    
    return g_UUIDKey;
    
}

+(NSString*)getTimeStamp{
    
    NSDate *date = [NSDate date];
    NSTimeInterval ti = [date timeIntervalSince1970];
    NSString* timeStamp = [NSString stringWithFormat:@"%f",ti];
    
    return timeStamp;
}

+(NSString *)createSHA512:(NSString *)string
{
    
    //TimeStamp+UUIDをSHA512にかける
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes, data.length, digest);
    NSMutableString* output = [NSMutableString  stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}



+(void)deleteKeyChain{
#ifdef DEBUG
    
    //対象キーチェーンデータがあった場合、削除
    OSStatus res = [UUID searchKeychain];
    if( res == noErr )
    {
        NSMutableDictionary *item = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)ref];
        [item setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        [item setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
        SecItemDelete((__bridge CFDictionaryRef)item);
        
    }
    
#endif
}

+(OSStatus)searchKeychain{
    
    // キーチェーンを検索
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [query setObject:UUIDkeyName forKey:(__bridge id)kSecAttrService];
    [query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    
    CFTypeRef ref = nil;
    OSStatus res = SecItemCopyMatching((__bridge CFDictionaryRef)query, &ref);
    
    return res;
    
}


@end
