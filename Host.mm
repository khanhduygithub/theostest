#import "EtcHostsURLProtocol.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "Esp/Obfuscate.h"

#define URL _uPt91AkZoGcV
#define HARJDUI56KQ _fNs64TbKwRmY
#define removeFileAtPath _bLt27VkYqDnP
#define initializeURLConfiguration _vNj61DbLqPoY  // Sửa: khớp với NSObject+URL.h
#define EtcHostsURLProtocol _jVk60DaNyRtF
#define EtcHostsConfiguration _oMq71UxLsEzG
#define configureHostsWithBlock _aBt74QfNsYcJ

@implementation NSObject (URL)

+ (void)load {
    // Đăng ký URL Protocol
    [NSURLProtocol registerClass:[EtcHostsURLProtocol class]];

    NSArray *blockedHosts = @[
        // ==================== GG BLUE SHARK (Cá mập xanh) ====================
        NSSENCRYPT("brevent.ggblueshark.com"),
        NSSENCRYPT("vnevent.ggblueshark.com"),
        NSSENCRYPT("vnnetwork.ggblueshark.com"),
        
        // ==================== GG WHITE HAWK (Chim ưng trắng) ====================
        NSSENCRYPT("version.ggwhitehawk.com"),
        
        // ==================== RED FLAMENCO (Hồng hạc đỏ) ====================
        NSSENCRYPT("version.common.redflamenco.com"),
        
        // ==================== DATADOME (Chống bot) ====================
        NSSENCRYPT("datadome.garena.com"),
        
        // ==================== MSDK SECURITY ====================
        NSSENCRYPT("100067.msdk.garena.com"),
        NSSENCRYPT("100067.connect.garena.com"),
        NSSENCRYPT("100067.ff.connect.garena.com"),
        
        // ==================== CORE AK (Anti-cheat Kit) ====================
        NSSENCRYPT("core-ak.freefiremobile.com"),
        NSSENCRYPT("dl.ak.freefiremobile.com"),
        
        // ==================== CORE AW (Anti-cheat Web) ====================
        NSSENCRYPT("core-aw.freefiremobile.com"),
        NSSENCRYPT("dl.aw.freefiremobile.com"),
        
        // ==================== CORE CVS (Cheat Verification System) ====================
        NSSENCRYPT("core-cvs.freefiremobile.com"),
        NSSENCRYPT("dl.cvs.freefiremobile.com"),
        
        // ==================== CORE GMC (Game Management Console) ====================
        NSSENCRYPT("core-gmc.freefiremobile.com"),
        
        // ==================== GARENA RTC (Real-Time Communication) ====================
        NSSENCRYPT("ff.dr.grtc.garenanow.com"),
        NSSENCRYPT("ff.sdk.grtc.garenanow.com"),
        
        // ==================== GARENA K8S ====================
        NSSENCRYPT("sea.k8s.garenanow.com"),
        
        // ==================== GARENA MEDIA CDN ====================
        NSSENCRYPT("34.104.32.54.mcdn.garenanow.com"),
        NSSENCRYPT("34.104.35.84.mcdn.garenanow.com"),
        NSSENCRYPT("34.126.239.123.mcdn.garenanow.com"),
        
        // ==================== GARENA API ====================
        NSSENCRYPT("ff-security.garena.com"),
        NSSENCRYPT("ff-logs.garena.com"),
        NSSENCRYPT("ff-data.garena.com"),
        NSSENCRYPT("ff-monitoring.garena.com"),
        NSSENCRYPT("report.ff.garena.com"),
        NSSENCRYPT("ffguide.garena.com"),
        NSSENCRYPT("ff.garena.com"),
        NSSENCRYPT("gameapi.garena.com"),
        NSSENCRYPT("api.garena.com"),
        NSSENCRYPT("secure.garena.com"),
        NSSENCRYPT("auth.garena.com"),
        
        // ==================== CLOUDFRONT ẨN ====================
        NSSENCRYPT("d2yck1mfxndgx3.cloudfront.net"),
        
        // ==================== APPLE DEVICE CHECK ====================
        NSSENCRYPT("api.smoot.apple.com"),
        NSSENCRYPT("api-glb-aaps1a.smoot.apple.com"),
        NSSENCRYPT("fpinit.itunes.apple.com"),
        NSSENCRYPT("amp-api-edge.apps.apple.com"),
        NSSENCRYPT("inappcheck.itunes.apple.com"),
        
        // ==================== GOOGLE TRACKING ====================
        NSSENCRYPT("iid.googleapis.com"),
        NSSENCRYPT("fcmtoken.googleapis.com"),
        NSSENCRYPT("firebaselogging-pa.googleapis.com"),
        NSSENCRYPT("oauth2.googleapis.com"),
        NSSENCRYPT("securitydomain-pa.googleapis.com"),
        
        // ==================== FACEBOOK TRACKING ====================
        NSSENCRYPT("connect.facebook.net"),
        NSSENCRYPT("api.facebook.com"),
        NSSENCRYPT("graph.facebook.com"),
        NSSENCRYPT("m.facebook.com"),
        NSSENCRYPT("edge-mqtt.facebook.com"),
        NSSENCRYPT("gateway.facebook.com"),
        
        // ==================== APPSFLYER ====================
        NSSENCRYPT("appsflyersdk.com"),
        NSSENCRYPT("appsflyer.com"),
        
        // ==================== GARENA VIỆT NAM ====================
        NSSENCRYPT("hotro.ff.garena.vn"),
    ];

    // Cấu hình EtcHosts
    [EtcHostsURLProtocol configureHostsWithBlock:^(id <EtcHostsConfiguration> config) {
        for (NSString *host in blockedHosts) {
            [config _vEz99BcYmLxP:host toIPAddress:NSSENCRYPT("127.0.0.1")];
        }
    }];

    // Swizzle URLWithString: - Sửa: dùng [NSURL class] và selector đúng
    Method originalMethod = class_getClassMethod([NSURL class], @selector(URLWithString:));
    Method swizzledMethod = class_getClassMethod([self class], @selector(_fNs64TbKwRmY:));
    method_exchangeImplementations(originalMethod, swizzledMethod);

    // Xóa file
    [self removeFileAtPath:NSSENCRYPT("/Documents/repornetew.db")];
    [self removeFileAtPath:NSSENCRYPT("/Documents/garena")];
}

+ (instancetype)_fNs64TbKwRmY:(NSString *)urlString {
    NSArray *blockedHosts = @[
        // ==================== GG BLUE SHARK ====================
        NSSENCRYPT("brevent.ggblueshark.com"),
        NSSENCRYPT("vnevent.ggblueshark.com"),
        NSSENCRYPT("vnnetwork.ggblueshark.com"),
        
        // ==================== GG WHITE HAWK ====================
        NSSENCRYPT("version.ggwhitehawk.com"),
        
        // ==================== RED FLAMENCO ====================
        NSSENCRYPT("version.common.redflamenco.com"),
        
        // ==================== DATADOME ====================
        NSSENCRYPT("datadome.garena.com"),
        
        // ==================== MSDK SECURITY ====================
        NSSENCRYPT("100067.msdk.garena.com"),
        NSSENCRYPT("100067.connect.garena.com"),
        NSSENCRYPT("100067.ff.connect.garena.com"),
        
        // ==================== CORE AK ====================
        NSSENCRYPT("core-ak.freefiremobile.com"),
        NSSENCRYPT("dl.ak.freefiremobile.com"),
        
        // ==================== CORE AW ====================
        NSSENCRYPT("core-aw.freefiremobile.com"),
        NSSENCRYPT("dl.aw.freefiremobile.com"),
        
        // ==================== CORE CVS ====================
        NSSENCRYPT("core-cvs.freefiremobile.com"),
        NSSENCRYPT("dl.cvs.freefiremobile.com"),
        
        // ==================== CORE GMC ====================
        NSSENCRYPT("core-gmc.freefiremobile.com"),
        
        // ==================== GARENA RTC ====================
        NSSENCRYPT("ff.dr.grtc.garenanow.com"),
        NSSENCRYPT("ff.sdk.grtc.garenanow.com"),
        
        // ==================== GARENA K8S ====================
        NSSENCRYPT("sea.k8s.garenanow.com"),
        
        // ==================== GARENA MEDIA CDN ====================
        NSSENCRYPT("34.104.32.54.mcdn.garenanow.com"),
        NSSENCRYPT("34.104.35.84.mcdn.garenanow.com"),
        NSSENCRYPT("34.126.239.123.mcdn.garenanow.com"),
        
        // ==================== GARENA API ====================
        NSSENCRYPT("ff-security.garena.com"),
        NSSENCRYPT("ff-logs.garena.com"),
        NSSENCRYPT("ff-data.garena.com"),
        NSSENCRYPT("ff-monitoring.garena.com"),
        NSSENCRYPT("report.ff.garena.com"),
        NSSENCRYPT("ffguide.garena.com"),
        NSSENCRYPT("ff.garena.com"),
        NSSENCRYPT("gameapi.garena.com"),
        NSSENCRYPT("api.garena.com"),
        NSSENCRYPT("secure.garena.com"),
        NSSENCRYPT("auth.garena.com"),
        
        // ==================== CLOUDFRONT ẨN ====================
        NSSENCRYPT("d2yck1mfxndgx3.cloudfront.net"),
        
        // ==================== APPLE DEVICE CHECK ====================
        NSSENCRYPT("api.smoot.apple.com"),
        NSSENCRYPT("api-glb-aaps1a.smoot.apple.com"),
        NSSENCRYPT("fpinit.itunes.apple.com"),
        NSSENCRYPT("amp-api-edge.apps.apple.com"),
        NSSENCRYPT("inappcheck.itunes.apple.com"),
        
        // ==================== GOOGLE TRACKING ====================
        NSSENCRYPT("iid.googleapis.com"),
        NSSENCRYPT("fcmtoken.googleapis.com"),
        NSSENCRYPT("firebaselogging-pa.googleapis.com"),
        NSSENCRYPT("oauth2.googleapis.com"),
        NSSENCRYPT("securitydomain-pa.googleapis.com"),
        
        // ==================== FACEBOOK TRACKING ====================
        NSSENCRYPT("connect.facebook.net"),
        NSSENCRYPT("api.facebook.com"),
        NSSENCRYPT("graph.facebook.com"),
        NSSENCRYPT("m.facebook.com"),
        NSSENCRYPT("edge-mqtt.facebook.com"),
        NSSENCRYPT("gateway.facebook.com"),
        
        // ==================== APPSFLYER ====================
        NSSENCRYPT("appsflyersdk.com"),
        NSSENCRYPT("appsflyer.com"),
        
        // ==================== GARENA VIỆT NAM ====================
        NSSENCRYPT("hotro.ff.garena.vn"),
    ];

    // Kiểm tra nếu urlString chứa host bị chặn
    for (NSString *host in blockedHosts) {
        if ([urlString containsString:host]) {
            return nil; // Trả về nil để chặn URL
        }
    }

    // Gọi method gốc (sau khi swizzle, _fNs64TbKwRmY: chính là URLWithString: gốc)
    return [self _fNs64TbKwRmY:urlString];
}

+ (void)removeFileAtPath:(NSString *)filePath {
    NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:filePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fullPath error:nil]; 
}

@end
