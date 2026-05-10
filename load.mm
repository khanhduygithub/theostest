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

std::string g_savedKey;
std::string g_savedVersionName;
int64_t g_versionCreatedTimestamp = 0;
int64_t g_expirationTimestamp = 0;

static id __g_handler = NULL;
static UIWindow *__g_window = nil;
__struct_MenuContext *__ctx = NULL;

__attribute__((always_inline, visibility("hidden")))
static BOOL customPointInside(id self, SEL _cmd, CGPoint point, UIEvent *event) {
    NSNumber *allowNum = objc_getAssociatedObject(self, kAllowTouchKey);
    BOOL allow = allowNum ? [allowNum boolValue] : NO;
    if (allow) {
        struct objc_super superInfo = { .receiver = self, .super_class = class_getSuperclass(object_getClass(self)) };
        return ((BOOL (*)(struct objc_super *, SEL, CGPoint, UIEvent *))objc_msgSendSuper)(&superInfo, _cmd, point, event);
    }
    return NO;
}

__attribute__((always_inline, visibility("hidden")))
static UIView *customHitTest(id self, SEL _cmd, CGPoint point, UIEvent *event) {
    NSNumber *allowNum = objc_getAssociatedObject(self, kAllowTouchKey);
    BOOL allow = allowNum ? [allowNum boolValue] : NO;
    if (allow) {
        struct objc_super superInfo = { .receiver = self, .super_class = class_getSuperclass(object_getClass(self)) };
        return ((UIView * (*)(struct objc_super *, SEL, CGPoint, UIEvent *))objc_msgSendSuper)(&superInfo, _cmd, point, event);
    }
    return nil;
}

__attribute__((always_inline, visibility("hidden")))
static void handlerFunc(id self, SEL _cmd, UITapGestureRecognizer *gesture) {
    __ZZeTgkAiCj();
}

static size_t _curl_write_cb(void *contents, size_t size, size_t nmemb, void *userp) {
    size_t realsize = size * nmemb;
    std::string *mem = static_cast<std::string *>(userp);
    mem->append(static_cast<char *>(contents), realsize);
    return realsize;
}

// ═══════════════════════════════════════════════════════════════
// HARCODE OFFSETS - Đảm bảo không crash
// ═══════════════════════════════════════════════════════════════
__attribute__((always_inline, visibility("hidden")))
static void hardcodeFallbackOffsets() {
    Offsets::get_main = 0x4A8478C;
    Offsets::get_transform = 0x854060C;
    Offsets::get_transformNode = 0x5C52CFC;
    Offsets::WorldToViewpoint = 0x84E6AC8;
    Offsets::get_position = 0x8552BAC;
    Offsets::Team = 0x4A38D90;
    Offsets::Local = 0x28FC854;
    Offsets::get_HP = 0x58691B8;
    Offsets::get_maxHP = 0x4A8489C;
    Offsets::get_IsDieing = 0x4A02EA8;
    Offsets::get_IsVisible = 0x4A20AF4;
    Offsets::GetLocalPlayer = 0x4C5A64C;
    Offsets::CurrentMatch = 0x4E355B0;
    Offsets::Camera_main = 0x84E7148;
    Offsets::GetRotation = 0x5081084;
    Offsets::get_isLocalTeam = 0x55A0560;
    Offsets::get_IsSighting = 0x4A0FF18;
    Offsets::get_IsFiring = 0x56D1580;
    Offsets::WorldToScreenPoint = 0x84E6AC8;
    Offsets::GetHeadPositions = 0x4AA1A28;
    Offsets::Component_GetTransform = 0x854060C;
    Offsets::GetForward = 0x85534CC;
    Offsets::Player_GetHeadCollider = 0x4A1A9D4;
    Offsets::Transform_GetPosition = 0x8552C10;
    Offsets::GetAnimator = 0x0;
    Offsets::Physics_Raycast = 0x5580870;
    Offsets::set_aim = 0x4A1C91C;
    Offsets::HipPosition = 0x4AA1BD8;
    Offsets::LeftShoulderPosition = 0x0;
    Offsets::RightShoulderPosition = 0x0;
    Offsets::LeftAnklePosition = 0x4AA2028;
    Offsets::RightAnklePosition = 0x4AA2134;
    Offsets::LeftToePosition = 0x4AA2240;
    Offsets::RightToePosition = 0x4AA234C;
    Offsets::LeftHandPosition = 0x4A1B9B4;
    Offsets::RightHandPosition = 0x4A1BAB8;
    Offsets::RightForeArmPosition = 0x4A1BCC0;
    Offsets::LeftForeArmPosition = 0x4A1BBBC;
    Offsets::CameraMain = 0x84E7148;
    Offsets::IsClientBot = 0x0;
    Offsets::IsAvatarInit = 0x0;
    Offsets::MatchPlayers = 0x4C869DC;
}

__attribute__((always_inline, visibility("hidden")))
static void fetchAndSaveOffsets(void) {
    hardcodeFallbackOffsets();
    
    static std::once_flag curl_init_flag;
    std::call_once(curl_init_flag, []() { curl_global_init(CURL_GLOBAL_DEFAULT); });

    std::string offsetResponsePayload;
    struct curl_slist *hdrOffset = nullptr;
    hdrOffset = curl_slist_append(hdrOffset, "Content-Type: application/json");

    CURL *curlOffset = curl_easy_init();
    if (!curlOffset) return;

    curl_easy_setopt(curlOffset, CURLOPT_HTTPHEADER, hdrOffset);
    curl_easy_setopt(curlOffset, CURLOPT_SSL_VERIFYPEER, 0L);
    curl_easy_setopt(curlOffset, CURLOPT_SSL_VERIFYHOST, 0L);
    curl_easy_setopt(curlOffset, CURLOPT_WRITEFUNCTION, _curl_write_cb);
    curl_easy_setopt(curlOffset, CURLOPT_WRITEDATA, &offsetResponsePayload);
    curl_easy_setopt(curlOffset, CURLOPT_URL, "https://khanhduyapi.free.nf/api.php?action=get_offsets");
    curl_easy_setopt(curlOffset, CURLOPT_TIMEOUT, 10L);

    CURLcode res = curl_easy_perform(curlOffset);
    curl_slist_free_all(hdrOffset);
    curl_easy_cleanup(curlOffset);
    if (res != CURLE_OK) return;

    try {
        json j = json::parse(offsetResponsePayload);
        if (j.contains("success") && j["success"] == true && j.contains("offsets")) {
            for (auto& [key, val] : j["offsets"].items()) {
                uintptr_t v = strtoull(val.get<std::string>().c_str(), nullptr, 16);
                if (v == 0) continue;
                if (key == "get_main") Offsets::get_main = v;
                else if (key == "get_transform") Offsets::get_transform = v;
                else if (key == "get_transformNode") Offsets::get_transformNode = v;
                else if (key == "WorldToViewpoint") Offsets::WorldToViewpoint = v;
                else if (key == "get_position") Offsets::get_position = v;
                else if (key == "Team") Offsets::Team = v;
                else if (key == "Local") Offsets::Local = v;
                else if (key == "get_HP") Offsets::get_HP = v;
                else if (key == "get_maxHP") Offsets::get_maxHP = v;
                else if (key == "get_IsDieing") Offsets::get_IsDieing = v;
                else if (key == "get_IsVisible") Offsets::get_IsVisible = v;
                else if (key == "GetLocalPlayer") Offsets::GetLocalPlayer = v;
                else if (key == "CurrentMatch") Offsets::CurrentMatch = v;
                else if (key == "Camera_main") Offsets::Camera_main = v;
                else if (key == "GetRotation") Offsets::GetRotation = v;
                else if (key == "get_isLocalTeam") Offsets::get_isLocalTeam = v;
                else if (key == "get_IsSighting") Offsets::get_IsSighting = v;
                else if (key == "get_IsFiring") Offsets::get_IsFiring = v;
                else if (key == "WorldToScreenPoint") Offsets::WorldToScreenPoint = v;
                else if (key == "GetHeadPositions") Offsets::GetHeadPositions = v;
                else if (key == "Component_GetTransform") Offsets::Component_GetTransform = v;
                else if (key == "GetForward") Offsets::GetForward = v;
                else if (key == "Player_GetHeadCollider") Offsets::Player_GetHeadCollider = v;
                else if (key == "Transform_GetPosition") Offsets::Transform_GetPosition = v;
                else if (key == "GetAnimator") Offsets::GetAnimator = v;
                else if (key == "Physics_Raycast") Offsets::Physics_Raycast = v;
                else if (key == "set_aim") Offsets::set_aim = v;
                else if (key == "HipPosition") Offsets::HipPosition = v;
                else if (key == "LeftShoulderPosition") Offsets::LeftShoulderPosition = v;
                else if (key == "RightShoulderPosition") Offsets::RightShoulderPosition = v;
                else if (key == "LeftAnklePosition") Offsets::LeftAnklePosition = v;
                else if (key == "RightAnklePosition") Offsets::RightAnklePosition = v;
                else if (key == "LeftToePosition") Offsets::LeftToePosition = v;
                else if (key == "RightToePosition") Offsets::RightToePosition = v;
                else if (key == "LeftHandPosition") Offsets::LeftHandPosition = v;
                else if (key == "RightHandPosition") Offsets::RightHandPosition = v;
                else if (key == "RightForeArmPosition") Offsets::RightForeArmPosition = v;
                else if (key == "LeftForeArmPosition") Offsets::LeftForeArmPosition = v;
                else if (key == "CameraMain") Offsets::CameraMain = v;
                else if (key == "IsClientBot") Offsets::IsClientBot = v;
                else if (key == "IsAvatarInit") Offsets::IsAvatarInit = v;
                else if (key == "MatchPlayers") Offsets::MatchPlayers = v;
            }
        }
    } catch (...) {}
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

            g_savedKey = "BYPASS_9999_DAYS";
            g_savedVersionName = "Premium Edition";
            g_versionCreatedTimestamp = (int64_t)[[NSDate date] timeIntervalSince1970];
            g_expirationTimestamp = g_versionCreatedTimestamp + (9999 * 24 * 60 * 60);

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
                window = w; break;
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
    if (![NSThread isMainThread]) { dispatch_async(dispatch_get_main_queue(), ^{ __sub_VjQZKjgZ(); }); return; }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:ENCRYPT_NS("StreamerMode")] != nil) {
        StreamerMode = [defaults boolForKey:ENCRYPT_NS("StreamerMode")];
    }

    BOOL isOpen = __ctx->__view_controller && [__ctx->__view_controller.view isDescendantOfView:__ctx->__view_container];

    if (!isOpen) {
        if (__ctx->__view_container.superview != __g_window) [__g_window addSubview:__ctx->__view_container];
        if (renderView) [__g_window bringSubviewToFront:renderView];
        [__g_window bringSubviewToFront:__ctx->__view_container];
        objc_setAssociatedObject(__ctx->__view_container, kAllowTouchKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        __ctx->__view_container.userInteractionEnabled = YES;
        if (!__ctx->__view_controller) {
            __ctx->__view_controller = [[_m1Bf03WvGkXe alloc] init];
            __ctx->__view_controller.view.frame = UIScreen.mainScreen.bounds;
            __ctx->__view_controller.view.backgroundColor = UIColor.clearColor;
            __ctx->__view_controller.view.userInteractionEnabled = YES;
        }
        if (!__ctx->__view_controller.view.superview) [__ctx->__view_container addSubview:__ctx->__view_controller.view];
    } else {
        if (__ctx->__view_controller.view.superview) [__ctx->__view_controller.view removeFromSuperview];
        objc_setAssociatedObject(__ctx->__view_container, kAllowTouchKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        __ctx->__view_container.userInteractionEnabled = NO;
        if (__ctx->__view_container.superview) [__ctx->__view_container removeFromSuperview];
        if (renderView) { [__g_window bringSubviewToFront:renderView]; __fn_hideCaptureForView(renderView, StreamerMode); }
    }
}

__attribute__((visibility("default"))) extern "C"
void __hidden_symbol_toggleMenu(void) __asm__("_ZZeTgkAiCj");
void __ZZeTgkAiCj(void) { __sub_VjQZKjgZ(); }

extern "C" void __hidden_streamproof_refresh(void) __attribute__((visibility("default"))) __asm__("_ZZoxr_fj28dj_4ud93");
void oxr_fj28dj_4ud93(void) {
    if (__ctx && __ctx->__view_container) __fn_hideCaptureForView(__ctx->__view_container, StreamerMode);
    if (renderView) __fn_hideCaptureForView(renderView, StreamerMode);
}
