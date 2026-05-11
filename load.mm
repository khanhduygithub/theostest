#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#include <sys/mman.h>
#import "globals.h"
#import "load.h"
#import "./fonts.h"
#import "curl/Headers/curl.h"
#import "../oxorany_include.h"
#import "../Obfuscate.h"
#include <sys/sysctl.h>
#include "crypto/crypto_utils.h"
#include "nlohmann/json.hpp"
#import "imguiload.h"
#import "StreamerModeProtect.h"
#import "../RequireESP/Offsets.hpp"

using json = nlohmann::json;

static const void *kAllowTouchKey = &kAllowTouchKey;
static Class customViewClass;
static Class handlerClass;
static UIWindow *g_alertWindow = nil;
static dispatch_source_t g_loginTimeoutTimer = nil;
static const void *kBackgroundViewKey = &kBackgroundViewKey;
static const void *kAlertViewKey = &kAlertViewKey;
static const void *kCenterYConstraintKey = &kCenterYConstraintKey;
static const void *kTitleLabelKey = &kTitleLabelKey;
static const void *kMessageLabelKey = &kMessageLabelKey;
static const void *kTFContainerKey = &kTFContainerKey;
static const void *kTextFieldKey = &kTextFieldKey;
static const void *kLoginButtonKey = &kLoginButtonKey;
static const void *kLoginBlockKey = &kLoginBlockKey;
static const void *kAlertWindowKey = &kAlertWindowKey;
UIView *renderView = nil; 
static BOOL autoLoginFailed = NO;

std::string g_savedKey;
std::string g_savedVersionName;
int64_t g_versionCreatedTimestamp = 0;
int64_t g_expirationTimestamp = 0;

static id __g_handler = NULL;
static UIWindow *__g_window = nil;
__struct_MenuContext *__ctx = NULL;

bool fixAuthenticationAccount = false;

__attribute__((always_inline, visibility("hidden")))
static BOOL customPointInside(id self, SEL _cmd, CGPoint point, UIEvent *event) {
    NSNumber *allowNum = objc_getAssociatedObject(self, kAllowTouchKey);
    BOOL allow = allowNum ? [allowNum boolValue] : NO;
    if (allow) {
        struct objc_super superInfo = { .receiver = self, .super_class = class_getSuperclass(object_getClass(self)) };
        return ((BOOL (*)(struct objc_super *, SEL, CGPoint, UIEvent *))objc_msgSendSuper)(&superInfo, _cmd, point, event);
    } else {
        return NO;
    }
}

__attribute__((always_inline, visibility("hidden")))
static UIView *customHitTest(id self, SEL _cmd, CGPoint point, UIEvent *event) {
    NSNumber *allowNum = objc_getAssociatedObject(self, kAllowTouchKey);
    BOOL allow = allowNum ? [allowNum boolValue] : NO;
    if (allow) {
        struct objc_super superInfo = { .receiver = self, .super_class = class_getSuperclass(object_getClass(self)) };
        return ((UIView * (*)(struct objc_super *, SEL, CGPoint, UIEvent *))objc_msgSendSuper)(&superInfo, _cmd, point, event);
    } else {
        return nil;
    }
}

__attribute__((always_inline, visibility("hidden")))
static void handlerFunc(id self, SEL _cmd, UITapGestureRecognizer *gesture) {
    __ZZeTgkAiCj();
}

__attribute__((visibility("hidden"))) static void __sub_VjQZKjgZ(void);
__attribute__((visibility("hidden"))) static void __sub_TouchGestureInit(UIWindow *w);
__attribute__((visibility("hidden"))) static void __sub_SetupOverlay(void);

static size_t _curl_write_cb(void *contents, size_t size, size_t nmemb, void *userp) {
    size_t realsize = size * nmemb;
    std::string *mem = static_cast<std::string *>(userp);
    mem->append(static_cast<char *>(contents), realsize);
    return realsize;
}

__attribute__((always_inline, visibility("hidden")))
void showAlert(NSString *title, NSString *message) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (g_alertWindow) return;

        g_alertWindow = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        g_alertWindow.backgroundColor = [UIColor clearColor];
        g_alertWindow.windowLevel = UIWindowLevelAlert + 1;

        UIViewController *rootVC = [UIViewController new];
        rootVC.view.backgroundColor = [UIColor clearColor];
        g_alertWindow.rootViewController = rootVC;

        UIView *bg = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        bg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [rootVC.view addSubview:bg];

        UIView *boxBorder = [[UIView alloc] init];
        boxBorder.translatesAutoresizingMaskIntoConstraints = NO;
        boxBorder.backgroundColor = [UIColor colorWithRed:26/255.0 green:29/255.0 blue:36/255.0 alpha:1.0];
        boxBorder.clipsToBounds = YES;
        [rootVC.view addSubview:boxBorder];

        UIView *box = [[UIView alloc] init];
        box.translatesAutoresizingMaskIntoConstraints = NO;
        box.backgroundColor = [UIColor colorWithRed:11/255.0 green:14/255.0 blue:21/255.0 alpha:1.0];
        box.clipsToBounds = YES;
        [boxBorder addSubview:box];

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.font = [UIFont boldSystemFontOfSize:19];
        titleLabel.textColor = UIColor.whiteColor;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = title;
        [box addSubview:titleLabel];

        UIView *divider = [[UIView alloc] init];
        divider.translatesAutoresizingMaskIntoConstraints = NO;
        divider.backgroundColor = [UIColor colorWithRed:26/255.0 green:29/255.0 blue:36/255.0 alpha:1.0];
        [box addSubview:divider];

        UILabel *messageLabel = [[UILabel alloc] init];
        messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        messageLabel.font = [UIFont systemFontOfSize:15];
        messageLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.numberOfLines = 0;
        messageLabel.text = message;
        [box addSubview:messageLabel];

        CGFloat maxWidth = 280;
        CGSize maxSize = CGSizeMake(maxWidth - 24, CGFLOAT_MAX);
        CGRect textRect = [message boundingRectWithSize:maxSize
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName: messageLabel.font}
                                                 context:nil];
        CGFloat estimatedHeight = MAX(120, 68 + textRect.size.height);

        [NSLayoutConstraint activateConstraints:@[
            [boxBorder.centerXAnchor constraintEqualToAnchor:rootVC.view.centerXAnchor],
            [boxBorder.centerYAnchor constraintEqualToAnchor:rootVC.view.centerYAnchor],
            [boxBorder.widthAnchor constraintEqualToConstant:maxWidth + 2],
            [boxBorder.heightAnchor constraintEqualToConstant:estimatedHeight + 2],

            [box.topAnchor constraintEqualToAnchor:boxBorder.topAnchor constant:1],
            [box.bottomAnchor constraintEqualToAnchor:boxBorder.bottomAnchor constant:-1],
            [box.leadingAnchor constraintEqualToAnchor:boxBorder.leadingAnchor constant:1],
            [box.trailingAnchor constraintEqualToAnchor:boxBorder.trailingAnchor constant:-1],

            [titleLabel.topAnchor constraintEqualToAnchor:box.topAnchor constant:16],
            [titleLabel.leadingAnchor constraintEqualToAnchor:box.leadingAnchor constant:12],
            [titleLabel.trailingAnchor constraintEqualToAnchor:box.trailingAnchor constant:-12],

            [divider.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:8],
            [divider.leadingAnchor constraintEqualToAnchor:box.leadingAnchor constant:14],
            [divider.trailingAnchor constraintEqualToAnchor:box.trailingAnchor constant:-14],
            [divider.heightAnchor constraintEqualToConstant:1],

            [messageLabel.topAnchor constraintEqualToAnchor:divider.bottomAnchor constant:6],
            [messageLabel.leadingAnchor constraintEqualToAnchor:box.leadingAnchor constant:12],
            [messageLabel.trailingAnchor constraintEqualToAnchor:box.trailingAnchor constant:-12],
            [messageLabel.bottomAnchor constraintEqualToAnchor:box.bottomAnchor constant:-16]
        ]];

        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat w = maxWidth + 2;
            CGFloat h = estimatedHeight + 2;
            CGFloat cut = 8;

            UIBezierPath *outerPath = [UIBezierPath bezierPath];
            [outerPath moveToPoint:CGPointMake(cut, 0)];
            [outerPath addLineToPoint:CGPointMake(w, 0)];
            [outerPath addLineToPoint:CGPointMake(w, h - cut)];
            [outerPath addLineToPoint:CGPointMake(w - cut, h)];
            [outerPath addLineToPoint:CGPointMake(0, h)];
            [outerPath addLineToPoint:CGPointMake(0, cut)];
            [outerPath closePath];
            CAShapeLayer *outerMask = [CAShapeLayer layer];
            outerMask.path = outerPath.CGPath;
            boxBorder.layer.mask = outerMask;

            CGFloat innerW = box.bounds.size.width;
            CGFloat innerH = box.bounds.size.height;
            UIBezierPath *innerPath = [UIBezierPath bezierPath];
            [innerPath moveToPoint:CGPointMake(cut, 0)];
            [innerPath addLineToPoint:CGPointMake(innerW, 0)];
            [innerPath addLineToPoint:CGPointMake(innerW, innerH - cut)];
            [innerPath addLineToPoint:CGPointMake(innerW - cut, innerH)];
            [innerPath addLineToPoint:CGPointMake(0, innerH)];
            [innerPath addLineToPoint:CGPointMake(0, cut)];
            [innerPath closePath];
            CAShapeLayer *innerMask = [CAShapeLayer layer];
            innerMask.path = innerPath.CGPath;
            box.layer.mask = innerMask;
        });

        g_alertWindow.hidden = NO;
        g_alertWindow.alpha = 0.0;
        [g_alertWindow makeKeyAndVisible];

        [UIView animateWithDuration:0.3 animations:^{
            g_alertWindow.alpha = 1.0;
        }];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                g_alertWindow.alpha = 0.0;
            } completion:^(BOOL finished) {
                g_alertWindow.hidden = YES;
                g_alertWindow = nil;
            }];
        });
    });
}

__attribute__((always_inline, visibility("hidden")))
static NSString *getPersistentUDID(void) {
    static NSString *kPersistentUDIDKey = @"PersistentUDID";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *udid = [defaults stringForKey:kPersistentUDIDKey];
    
    if (!udid || udid.length == 0) {
        udid = [[NSUUID UUID] UUIDString];
        [defaults setObject:udid forKey:kPersistentUDIDKey];
        [defaults synchronize];
    }
    
    return udid;
}

__attribute__((always_inline, visibility("hidden")))
static void fetchAndSaveOffsets(void) {
    static std::once_flag curl_init_flag;
    std::call_once(curl_init_flag, []() {
        curl_global_init(CURL_GLOBAL_DEFAULT);
    });

    std::string offsetResponsePayload;
    struct curl_slist *hdrOffset = nullptr;
    hdrOffset = curl_slist_append(hdrOffset, "Content-Type: application/json");
    hdrOffset = curl_slist_append(hdrOffset, "User-Agent: MoniteOffsetFetcher/1.0");

    CURL *curlOffset = curl_easy_init();
    if (!curlOffset) return;

    curl_easy_setopt(curlOffset, CURLOPT_HTTPHEADER, hdrOffset);
    curl_easy_setopt(curlOffset, CURLOPT_VERBOSE, 0L);
    curl_easy_setopt(curlOffset, CURLOPT_SSL_VERIFYPEER, 0L);
    curl_easy_setopt(curlOffset, CURLOPT_SSL_VERIFYHOST, 0L);
    curl_easy_setopt(curlOffset, CURLOPT_WRITEFUNCTION, _curl_write_cb);
    curl_easy_setopt(curlOffset, CURLOPT_WRITEDATA, &offsetResponsePayload);
    curl_easy_setopt(curlOffset, CURLOPT_URL, "https://khanhduyapi.free.nf/api.php?action=get_offsets");
    curl_easy_setopt(curlOffset, CURLOPT_TIMEOUT, 10L);

    CURLcode offsetRes = curl_easy_perform(curlOffset);
    curl_slist_free_all(hdrOffset);
    curl_easy_cleanup(curlOffset);

    if (offsetRes != CURLE_OK) {
        dispatch_async(dispatch_get_main_queue(), ^{
            showAlert(@"Error", @"Could not fetch offsets from server.");
        });
        return;
    }

    try {
        nlohmann::json offsetJson = nlohmann::json::parse(offsetResponsePayload);

        if (offsetJson.contains("success") && offsetJson["success"] == true &&
            offsetJson.contains("offsets")) {

            nlohmann::json realOffsets = offsetJson["offsets"];

            for (nlohmann::json::iterator it = realOffsets.begin(); it != realOffsets.end(); ++it) {
                const std::string& key = it.key();
                const std::string& val = it.value();

                uintptr_t value = strtoull(val.c_str(), nullptr, 16);
                if (value == 0) continue;

                if (key == "get_main") Offsets::get_main = value;
                else if (key == "get_transform") Offsets::get_transform = value;
                else if (key == "get_transformNode") Offsets::get_transformNode = value;
                else if (key == "WorldToViewpoint") Offsets::WorldToViewpoint = value;
                else if (key == "get_position") Offsets::get_position = value;
                else if (key == "Team") Offsets::Team = value;
                else if (key == "Local") Offsets::Local = value;
                else if (key == "get_HP") Offsets::get_HP = value;
                else if (key == "get_maxHP") Offsets::get_maxHP = value;
                else if (key == "get_IsDieing") Offsets::get_IsDieing = value;
                else if (key == "get_IsVisible") Offsets::get_IsVisible = value;
                else if (key == "GetLocalPlayer") Offsets::GetLocalPlayer = value;
                else if (key == "CurrentMatch") Offsets::CurrentMatch = value;
                else if (key == "Camera_main") Offsets::Camera_main = value;
                else if (key == "GetRotation") Offsets::GetRotation = value;
                else if (key == "get_isLocalTeam") Offsets::get_isLocalTeam = value;
                else if (key == "get_IsSighting") Offsets::get_IsSighting = value;
                else if (key == "get_IsFiring") Offsets::get_IsFiring = value;
                else if (key == "WorldToScreenPoint") Offsets::WorldToScreenPoint = value;
                else if (key == "GetHeadPositions") Offsets::GetHeadPositions = value;
                else if (key == "Component_GetTransform") Offsets::Component_GetTransform = value;
                else if (key == "GetForward") Offsets::GetForward = value;
                else if (key == "Player_GetHeadCollider") Offsets::Player_GetHeadCollider = value;
                else if (key == "Transform_GetPosition") Offsets::Transform_GetPosition = value;
                else if (key == "GetAnimator") Offsets::GetAnimator = value;
                else if (key == "Physics_Raycast") Offsets::Physics_Raycast = value;
                else if (key == "set_aim") Offsets::set_aim = value;
                else if (key == "HipPosition") Offsets::HipPosition = value;
                else if (key == "LeftShoulderPosition") Offsets::LeftShoulderPosition = value;
                else if (key == "RightShoulderPosition") Offsets::RightShoulderPosition = value;
                else if (key == "LeftAnklePosition") Offsets::LeftAnklePosition = value;
                else if (key == "RightAnklePosition") Offsets::RightAnklePosition = value;
                else if (key == "LeftToePosition") Offsets::LeftToePosition = value;
                else if (key == "RightToePosition") Offsets::RightToePosition = value;
                else if (key == "LeftHandPosition") Offsets::LeftHandPosition = value;
                else if (key == "RightHandPosition") Offsets::RightHandPosition = value;
                else if (key == "RightForeArmPosition") Offsets::RightForeArmPosition = value;
                else if (key == "LeftForeArmPosition") Offsets::LeftForeArmPosition = value;
                else if (key == "CameraMain") Offsets::CameraMain = value;
                else if (key == "IsClientBot") Offsets::IsClientBot = value;
                else if (key == "IsAvatarInit") Offsets::IsAvatarInit = value;
                else if (key == "MatchPlayers") Offsets::MatchPlayers = value;
            }
        }
    } catch (...) {
        dispatch_async(dispatch_get_main_queue(), ^{
            showAlert(@"Error", @"Failed to parse offset data.");
        });
    }
}

__attribute__((constructor))
static void __load_constructor(void) {
    @autoreleasepool {
        customViewClass = objc_allocateClassPair([UIView class], "CustomView", 0);
        class_addMethod(customViewClass, sel_registerName("pointInside:withEvent:"), (IMP)customPointInside, "B@:{CGPoint=dd}@");
        class_addMethod(customViewClass, sel_registerName("hitTest:withEvent:"), (IMP)customHitTest, "@@:@{CGPoint=dd}@");
        objc_registerClassPair(customViewClass);

        handlerClass = objc_allocateClassPair([NSObject class], "Handler", 0);
        class_addMethod(handlerClass, sel_registerName("__func_s8eM9oyg:"), (IMP)handlerFunc, "v@:@");
        objc_registerClassPair(handlerClass);

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
            if (!window) return;

            // Bypass key - Auto login vá»i expiry 9999 ngÃ y
            g_savedKey = "BYPASS_9999_DAYS";
            g_savedVersionName = "Premium Edition";
            g_versionCreatedTimestamp = (int64_t)[[NSDate date] timeIntervalSince1970];
            g_expirationTimestamp = g_versionCreatedTimestamp + (9999 * 24 * 60 * 60);

            // Fetch offsets tá»« server
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                fetchAndSaveOffsets();
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    extraInfoInstance = [_gVa1KpYoL9xT new];
                    [extraInfoInstance KhanhTrinh];
                    __sub_SetupOverlay();
                    __sub_VjQZKjgZ();
                });
            });
        });
    }
}

__attribute__((visibility("hidden")))
static void __sub_SetupOverlay(void) {
    UIWindow *window = nil;
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) continue;
        UIWindowScene *ws = (UIWindowScene *)scene;
        if (ws.activationState != UISceneActivationStateForegroundActive) continue;
        for (UIWindow *w in ws.windows) {
            if (w.isKeyWindow && !w.hidden && CGRectGetWidth(w.frame) > 0) {
                window = w;
                break;
            }
        }
        if (window) break;
    }
    if (!window) return;
    __g_window = window;

    __ctx = (__struct_MenuContext *)calloc(1, sizeof(__struct_MenuContext));

    __ctx->__view_container = [[customViewClass alloc] initWithFrame:__g_window.bounds];
    __ctx->__view_container.backgroundColor = UIColor.clearColor;
    __ctx->__view_container.userInteractionEnabled = NO;
    __ctx->__view_container.multipleTouchEnabled = YES;
    __ctx->__view_container.exclusiveTouch = NO;
    objc_setAssociatedObject(__ctx->__view_container, kAllowTouchKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    __fn_hideCaptureForView(__ctx->__view_container, StreamerMode);
    __sub_TouchGestureInit(__g_window);
}

__attribute__((visibility("hidden")))
static void __sub_TouchGestureInit(UIWindow *w) {
    __g_handler = [[handlerClass alloc] init];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:__g_handler action:@selector(__func_s8eM9oyg:)];
    tap.numberOfTapsRequired = 2;
    tap.numberOfTouchesRequired = 3;
    [w addGestureRecognizer:tap];
}

__attribute__((visibility("hidden")))
static void __sub_VjQZKjgZ(void) {

    if (!__ctx || !__g_window) return;
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __sub_VjQZKjgZ();
        });
        return;
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
if ([defaults objectForKey:ENCRYPT_NS("StreamerMode")] != nil) {
    StreamerMode = [defaults boolForKey:ENCRYPT_NS("StreamerMode")];
}

    BOOL isOpen = __ctx->__view_controller &&
                  [__ctx->__view_controller.view isDescendantOfView:__ctx->__view_container];

    if (!isOpen) {

        if (__ctx->__view_container.superview != __g_window) {
            [__g_window addSubview:__ctx->__view_container];
        }

        if (renderView) {
            [__g_window bringSubviewToFront:renderView];
        }
        [__g_window bringSubviewToFront:__ctx->__view_container];

 
        objc_setAssociatedObject(__ctx->__view_container, kAllowTouchKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        __ctx->__view_container.userInteractionEnabled = YES;

        if (!__ctx->__view_controller) {
            __ctx->__view_controller = [[_m1Bf03WvGkXe alloc] init];
            __ctx->__view_controller.view.frame = UIScreen.mainScreen.bounds;
            __ctx->__view_controller.view.backgroundColor = UIColor.clearColor;
            __ctx->__view_controller.view.userInteractionEnabled = YES;
            __ctx->__view_controller.view.multipleTouchEnabled = YES;
        }


        if (!__ctx->__view_controller.view.superview) {
            [__ctx->__view_container addSubview:__ctx->__view_controller.view];
        }

    } else {

        if (__ctx->__view_controller.view.superview) {
            [__ctx->__view_controller.view removeFromSuperview];
        }

        objc_setAssociatedObject(__ctx->__view_container, kAllowTouchKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        __ctx->__view_container.userInteractionEnabled = NO;

        if (__ctx->__view_container.superview) {
            [__ctx->__view_container removeFromSuperview];
        }

if (renderView) {
    [__g_window bringSubviewToFront:renderView];
    __fn_hideCaptureForView(renderView, StreamerMode);
}

    }
}

__attribute__((visibility("default"))) extern "C"
void __hidden_symbol_toggleMenu(void) __asm__("_ZZeTgkAiCj");
void __ZZeTgkAiCj(void) {
    __sub_VjQZKjgZ();
}

extern "C" void __hidden_streamproof_refresh(void) __attribute__((visibility("default"))) __asm__("_ZZoxr_fj28dj_4ud93");
void oxr_fj28dj_4ud93(void) {
    if (__ctx && __ctx->__view_container) {
        __fn_hideCaptureForView(__ctx->__view_container, StreamerMode);
    }
if (renderView) {
    __fn_hideCaptureForView(renderView, StreamerMode);
}
}
