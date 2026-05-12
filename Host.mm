#import "EtcHostsURLProtocol.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "Esp/Obfuscate.h"

#define URL _uPt91AkZoGcV
#define HARJDUI56KQ _fNs64TbKwRmY
#define removeFileAtPath _bLt27VkYqDnP
#define initializeURLConfiguration _vNj61DbLqPoY
#define EtcHostsURLProtocol _jVk60DaNyRtF
#define EtcHostsConfiguration _oMq71UxLsEzG
#define configureHostsWithBlock _aBt74QfNsYcJ

@implementation NSObject (URL)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // ===== BƯỚC 1: Đăng ký URL Protocol =====
        [NSURLProtocol registerClass:[EtcHostsURLProtocol class]];
        
        // ===== BƯỚC 2: Inject vào URLSessionConfiguration (QUAN TRỌNG NHẤT) =====
        [self swizzleURLSessionConfiguration];
        
        // ===== BƯỚC 3: Swizzle NSURLConnection =====
        [self swizzleNSURLConnection];
        
        // ===== BƯỚC 4: Cấu hình host block =====
        [self setupBlockedHosts];
        
        // ===== BƯỚC 5: Xóa file =====
        [self removeFileAtPath:NSSENCRYPT("/Documents/repornetew.db")];
        [self removeFileAtPath:NSSENCRYPT("/Documents/garena")];
    });
}

#pragma mark - Cấu hình Host Block

+ (void)setupBlockedHosts {
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

    [EtcHostsURLProtocol configureHostsWithBlock:^(id <EtcHostsConfiguration> config) {
        for (NSString *host in blockedHosts) {
            [config _vEz99BcYmLxP:host toIPAddress:NSSENCRYPT("127.0.0.1")];
        }
    }];
}

#pragma mark - Swizzle URLSessionConfiguration (QUAN TRỌNG NHẤT)

+ (void)swizzleURLSessionConfiguration {
    // Swizzle defaultSessionConfiguration
    {
        Method origMethod = class_getClassMethod([NSURLSessionConfiguration class], @selector(defaultSessionConfiguration));
        Method newMethod = class_getClassMethod([self class], @selector(swizzled_defaultSessionConfiguration));
        method_exchangeImplementations(origMethod, newMethod);
    }
    
    // Swizzle ephemeralSessionConfiguration
    {
        Method origMethod = class_getClassMethod([NSURLSessionConfiguration class], @selector(ephemeralSessionConfiguration));
        Method newMethod = class_getClassMethod([self class], @selector(swizzled_ephemeralSessionConfiguration));
        method_exchangeImplementations(origMethod, newMethod);
    }
}

+ (NSURLSessionConfiguration *)swizzled_defaultSessionConfiguration {
    NSURLSessionConfiguration *config = [self swizzled_defaultSessionConfiguration];
    [self injectProtocolClasses:config];
    return config;
}

+ (NSURLSessionConfiguration *)swizzled_ephemeralSessionConfiguration {
    NSURLSessionConfiguration *config = [self swizzled_ephemeralSessionConfiguration];
    [self injectProtocolClasses:config];
    return config;
}

+ (void)injectProtocolClasses:(NSURLSessionConfiguration *)config {
    // Lấy protocol classes hiện tại
    NSMutableArray *protocolClasses = [config.protocolClasses mutableCopy] ?: [NSMutableArray array];
    
    // Thêm EtcHostsURLProtocol nếu chưa có
    Class protocolClass = [EtcHostsURLProtocol class];
    if (![protocolClasses containsObject:protocolClass]) {
        [protocolClasses insertObject:protocolClass atIndex:0];
        config.protocolClasses = protocolClasses;
    }
}

#pragma mark - Swizzle NSURLConnection

+ (void)swizzleNSURLConnection {
    // Swizzle sendSynchronousRequest
    {
        Method origMethod = class_getClassMethod([NSURLConnection class], @selector(sendSynchronousRequest:returningResponse:error:));
        Method newMethod = class_getClassMethod([self class], @selector(swizzled_sendSynchronousRequest:returningResponse:error:));
        method_exchangeImplementations(origMethod, newMethod);
    }
}

+ (NSData *)swizzled_sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error {
    if ([self isBlockedHost:request.URL.host]) {
        if (response) *response = nil;
        if (error) *error = [NSError errorWithDomain:NSSENCRYPT("Blocked") code:-1 userInfo:nil];
        return nil;
    }
    return [self swizzled_sendSynchronousRequest:request returningResponse:response error:error];
}

+ (BOOL)isBlockedHost:(NSString *)host {
    static NSSet *blockedSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blockedSet = [NSSet setWithArray:@[
            NSSENCRYPT("brevent.ggblueshark.com"),
            NSSENCRYPT("vnevent.ggblueshark.com"),
            NSSENCRYPT("vnnetwork.ggblueshark.com"),
            NSSENCRYPT("version.ggwhitehawk.com"),
            NSSENCRYPT("version.common.redflamenco.com"),
            NSSENCRYPT("datadome.garena.com"),
            NSSENCRYPT("100067.msdk.garena.com"),
            NSSENCRYPT("100067.connect.garena.com"),
            NSSENCRYPT("100067.ff.connect.garena.com"),
            NSSENCRYPT("core-ak.freefiremobile.com"),
            NSSENCRYPT("dl.ak.freefiremobile.com"),
            NSSENCRYPT("core-aw.freefiremobile.com"),
            NSSENCRYPT("dl.aw.freefiremobile.com"),
            NSSENCRYPT("core-cvs.freefiremobile.com"),
            NSSENCRYPT("dl.cvs.freefiremobile.com"),
            NSSENCRYPT("core-gmc.freefiremobile.com"),
            NSSENCRYPT("ff.dr.grtc.garenanow.com"),
            NSSENCRYPT("ff.sdk.grtc.garenanow.com"),
            NSSENCRYPT("sea.k8s.garenanow.com"),
            NSSENCRYPT("34.104.32.54.mcdn.garenanow.com"),
            NSSENCRYPT("34.104.35.84.mcdn.garenanow.com"),
            NSSENCRYPT("34.126.239.123.mcdn.garenanow.com"),
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
            NSSENCRYPT("d2yck1mfxndgx3.cloudfront.net"),
            NSSENCRYPT("api.smoot.apple.com"),
            NSSENCRYPT("api-glb-aaps1a.smoot.apple.com"),
            NSSENCRYPT("fpinit.itunes.apple.com"),
            NSSENCRYPT("amp-api-edge.apps.apple.com"),
            NSSENCRYPT("inappcheck.itunes.apple.com"),
            NSSENCRYPT("iid.googleapis.com"),
            NSSENCRYPT("fcmtoken.googleapis.com"),
            NSSENCRYPT("firebaselogging-pa.googleapis.com"),
            NSSENCRYPT("oauth2.googleapis.com"),
            NSSENCRYPT("securitydomain-pa.googleapis.com"),
            NSSENCRYPT("connect.facebook.net"),
            NSSENCRYPT("api.facebook.com"),
            NSSENCRYPT("graph.facebook.com"),
            NSSENCRYPT("m.facebook.com"),
            NSSENCRYPT("edge-mqtt.facebook.com"),
            NSSENCRYPT("gateway.facebook.com"),
            NSSENCRYPT("appsflyersdk.com"),
            NSSENCRYPT("appsflyer.com"),
            NSSENCRYPT("hotro.ff.garena.vn"),
        ]];
    });
    return [blockedSet containsObject:host];
}

+ (void)removeFileAtPath:(NSString *)filePath {
    NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:filePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fullPath error:nil]; 
}

@end
