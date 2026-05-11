#import "EtcHostsURLProtocol.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "Esp/Obfuscate.h"

#define URL _uPt91AkZoGcV
#define HARJDUI56KQ _fNs64TbKwRmY
#define removeFileAtPath _bLt27VkYqDnP
#define initializeURLConfiguration _yLd73RxGwMzQ
#define EtcHostsURLProtocol _jVk60DaNyRtF
#define EtcHostsConfiguration _oMq71UxLsEzG
#define configureHostsWithBlock _aBt74QfNsYcJ

@implementation NSObject (URL)

+ (void)load {
    [NSURLProtocol registerClass:[EtcHostsURLProtocol class]];

    NSArray *blockedHosts = @[
        // ==================== GG BLUE SHARK ====================
        NSSENCRYPT("brevent.ggblueshark.com"),
        NSSENCRYPT("vnevent.ggblueshark.com"),
        
        // ==================== GG WHITE HAWK ====================
        NSSENCRYPT("version.ggwhitehawk.com"),
        
        // ==================== DATADOME ====================
        NSSENCRYPT("datadome.garena.com"),
        
        // ==================== MSDK SECURITY ====================
        NSSENCRYPT("100067.msdk.garena.com"),
        NSSENCRYPT("100067.connect.garena.com"),
        NSSENCRYPT("100067.ff.connect.garena.com"),
        
        // ==================== CORE ANTICHEAT ====================
        NSSENCRYPT("core-ak.freefiremobile.com"),
        NSSENCRYPT("dl.ak.freefiremobile.com"),
        NSSENCRYPT("dl.aw.freefiremobile.com"),
        NSSENCRYPT("core-cvs.freefiremobile.com"),
        NSSENCRYPT("dl.cvs.freefiremobile.com"),
        
        // ==================== GARENA API ====================
        NSSENCRYPT("sea.k8s.garenanow.com"),
        NSSENCRYPT("34.104.32.54.mcdn.garenanow.com"),
        NSSENCRYPT("ff-security.garena.com"),
        NSSENCRYPT("ff-logs.garena.com"),
        NSSENCRYPT("ff-data.garena.com"),
        NSSENCRYPT("ff-monitoring.garena.com"),
        NSSENCRYPT("report.ff.garena.com"),
        NSSENCRYPT("ffguide.garena.com"),
        
        // ==================== TRACKING GOOGLE ====================
        NSSENCRYPT("iid.googleapis.com"),
        NSSENCRYPT("fcmtoken.googleapis.com"),
        NSSENCRYPT("firebaselogging-pa.googleapis.com"),
        
        // ==================== APPSFLYER ====================
        NSSENCRYPT("appsflyersdk.com"),
        NSSENCRYPT("appsflyer.com"),
        
        // ==================== APPLE ====================
        NSSENCRYPT("amp-api-edge.apps.apple.com"),
        NSSENCRYPT("inappcheck.itunes.apple.com"),
    ];

    [EtcHostsURLProtocol configureHostsWithBlock:^(id <EtcHostsConfiguration> config) {
        for (NSString *host in blockedHosts) {
            [config _vEz99BcYmLxP:host toIPAddress:NSSENCRYPT("127.0.0.1")];
        }
    }];

    Method originalMethod = class_getClassMethod([self class], @selector(URLWithString:));
    Method swizzledMethod = class_getClassMethod([self class], @selector(HARJDUI56KQ));
    method_exchangeImplementations(originalMethod, swizzledMethod);

    [self removeFileAtPath:NSSENCRYPT("/Documents/repornetew.db")];
    [self removeFileAtPath:NSSENCRYPT("/Documents/garena")];
}

+ (instancetype)HARJDUI56KQ:(NSString *)urlString {
    NSArray *blockedHosts = @[
        // ==================== GG BLUE SHARK ====================
        NSSENCRYPT("brevent.ggblueshark.com"),
        NSSENCRYPT("vnevent.ggblueshark.com"),
        
        // ==================== GG WHITE HAWK ====================
        NSSENCRYPT("version.ggwhitehawk.com"),
        
        // ==================== DATADOME ====================
        NSSENCRYPT("datadome.garena.com"),
        
        // ==================== MSDK SECURITY ====================
        NSSENCRYPT("100067.msdk.garena.com"),
        NSSENCRYPT("100067.connect.garena.com"),
        NSSENCRYPT("100067.ff.connect.garena.com"),
        
        // ==================== CORE ANTICHEAT ====================
        NSSENCRYPT("core-ak.freefiremobile.com"),
        NSSENCRYPT("dl.ak.freefiremobile.com"),
        NSSENCRYPT("dl.aw.freefiremobile.com"),
        NSSENCRYPT("core-cvs.freefiremobile.com"),
        NSSENCRYPT("dl.cvs.freefiremobile.com"),
        
        // ==================== GARENA API ====================
        NSSENCRYPT("sea.k8s.garenanow.com"),
        NSSENCRYPT("34.104.32.54.mcdn.garenanow.com"),
        NSSENCRYPT("ff-security.garena.com"),
        NSSENCRYPT("ff-logs.garena.com"),
        NSSENCRYPT("ff-data.garena.com"),
        NSSENCRYPT("ff-monitoring.garena.com"),
        NSSENCRYPT("report.ff.garena.com"),
        NSSENCRYPT("ffguide.garena.com"),
        
        // ==================== TRACKING GOOGLE ====================
        NSSENCRYPT("iid.googleapis.com"),
        NSSENCRYPT("fcmtoken.googleapis.com"),
        NSSENCRYPT("firebaselogging-pa.googleapis.com"),
        
        // ==================== APPSFLYER ====================
        NSSENCRYPT("appsflyersdk.com"),
        NSSENCRYPT("appsflyer.com"),
        
        // ==================== APPLE ====================
        NSSENCRYPT("amp-api-edge.apps.apple.com"),
        NSSENCRYPT("inappcheck.itunes.apple.com"),
    ];

    for (NSString *host in blockedHosts) {
        if ([urlString containsString:host]) {
            return [NSURL HARJDUI56KQ:@" "];
        }
    }

    return [NSURL HARJDUI56KQ:urlString];
}

+ (void)removeFileAtPath:(NSString *)filePath {
    NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:filePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fullPath error:nil]; 
}

@end
