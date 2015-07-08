//
//  ConvertUIImage.m
//  
//
//  Created by VCJPCM012 on 2015/01/27.
//  Copyright (c) 2015年 HidekiYokozeki. All rights reserved.
//

#import "ConvertUIImage.h"

@implementation ConvertUIImage{
    
    NSCache *aCache;
    
}

//シングルトン制御
static ConvertUIImage *sharedData_ = nil;

//暗号化ファイルの拡張子指定
static NSString *crypto_extension = @"bin";

//caches以下のリソース保存先
static NSString *resouce_path = @"Resouce";

//暗号化のbitローテーション数とmask設定
static int rotate = 3;
static char mask = 0x02;

//メモリキャッシュする画像上限（上限を超えた場合は古いものから削除される）
static int cache_limit = 25;

//imageNamedはスレッドセーフではないため、明示的にこのメソッドを呼び出さない限り、contentsOfFileを使って呼び出す
+(ConvertUIImage*)imageNamedinMain:(NSString *)name{
    return (ConvertUIImage*)[UIImage imageNamed:name];
}

//imageWithCashを使ってキャッシュ済みの画像はキャッシュから高速呼び出し。それ以外は復号し、呼び出し
+ (ConvertUIImage*) imageNamed:(NSString*) name{
    
    // ファイルの拡張子を取得
    NSString*fileName =  [name stringByDeletingPathExtension];
    ConvertUIImage* img = [[ConvertUIImage sharedManager] imageWithCash:name];
    
    //キャッシュ済みの場合はそのまま返す
    if(img){
        
        return img;
    }
    
    // ファイル名の取得
    NSString* fileExtension = [name pathExtension];
    
    if([fileExtension isEqualToString:crypto_extension]){
        
        img = [[self class] convert:fileName Extensiton:fileExtension];
    
    }else{
        //ios8以降imageNamedをサブスレッドで実行するとまれにクラッシュするため、対策
        if([NSThread isMainThread]){
            img = (ConvertUIImage*)[UIImage imageNamed:name];
        }else{
            NSString *bundlePath  = [[NSBundle mainBundle] bundlePath];
            NSString *imagePath   = [bundlePath stringByAppendingPathComponent:name];
            img       = (ConvertUIImage*)[UIImage imageWithContentsOfFile:imagePath];
        }
    
    }
    
    return img;
}

+(ConvertUIImage*)convert:(NSString*)fileName Extensiton:(NSString*)fileExtension{
    
    ConvertUIImage* img;
    
    NSData *pngData=nil;
    
    if([fileExtension isEqualToString:crypto_extension]){
        
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirPath = [array objectAtIndex:0];
        cacheDirPath = [NSString stringWithFormat:@"%@/%@/%@.%@",cacheDirPath,resouce_path,fileName,fileExtension];
        pngData = [[NSData alloc] initWithContentsOfFile:cacheDirPath];
        
    }else{
        
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:fileName ofType:fileExtension];
        pngData = [[NSData alloc] initWithContentsOfFile:path];
        
    }
    
    

    
    //復号処理
    unsigned char *CharArray = (unsigned char*)[pngData bytes];
    unsigned long length = [pngData length];
    Byte *byteData = (Byte*)malloc(length);
    memcpy(byteData, CharArray, length);
    Obfuscate(byteData, length, mask, rotate);
    NSData* convertData = [NSData dataWithBytes:(const void*)byteData length:(sizeof(unsigned char) * length)];
    img = (ConvertUIImage*)[UIImage imageWithData:convertData];
    
    return img;
    
}

void logger(unsigned char * buf, size_t size){
    
    unsigned char * ptr = buf;
    int a = 10;
    NSString* str = @" ";
    while(a > 0) {
        str = [NSString stringWithFormat:@"%@%02x",str,*ptr++];
        a--;
    }
    
}


void Obfuscate(unsigned char * buf, size_t size, unsigned char mask, int rotate)
{
    unsigned char * ptr = buf;
    
    while(size > 0) {
        *ptr++ ^= mask;
        mask =  (mask << rotate) | (mask >> (8 - rotate));
        size--;
    }
}

+ (ConvertUIImage *)sharedManager{
    
    @synchronized(self){
        
        if (!sharedData_) {
            sharedData_ = [ConvertUIImage new];
            [sharedData_ memCpyCache];
        }
        
    }
    return sharedData_;
}

-(void)memCpyCache{
    
    aCache = [[NSCache alloc] init];
    [aCache setCountLimit:cache_limit];
    
}

-(ConvertUIImage*)imageWithCash:(NSString*)keyName{
    
    ConvertUIImage* image = [aCache objectForKey:keyName];
    
    return image;
    
}

-(void)cacheImage:(ConvertUIImage*)img keyName:(NSString*)fileName{
    
    UIGraphicsBeginImageContext(CGSizeMake(img.size.width, img.size.height));
    [img drawAtPoint:CGPointMake(0,0)];
    img = (ConvertUIImage*)UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [aCache setObject:img forKey:fileName];

}




@end
