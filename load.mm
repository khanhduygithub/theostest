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
        UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, bg.bounds.size.width - 40, bg.bounds.size.height)];
        msgLabel.text = [NSString stringWithFormat:@"%@\n%@", title, message];
        msgLabel.textColor = UIColor.whiteColor;
        msgLabel.textAlignment = NSTextAlignmentCenter;
        msgLabel.numberOfLines = 0;
        [bg addSubview:msgLabel];
        g_alertWindow.hidden = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            g_alertWindow.hidden = YES;
            g_alertWindow = nil;
        });
    });
}

// ═══════════════════════════════════════════════════════════════
// HARCODE OFFSETS - DÙNG KHI API LỖI, ĐẢM BẢO KHÔNG CRASH
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
    Offsets::Physics_Raycast = 0x5580870;
    Offsets::set_aim = 0x4A1C91C;
    Offsets::HipPosition = 0x4AA1BD8;
    Offsets::LeftAnklePosition = 0x4AA2028;
    Offsets::RightAnklePosition = 0x4AA2134;
    Offsets::LeftToePosition = 0x4AA2240;
    Offsets::RightToePosition = 0x4AA234C;
    Offsets::LeftHandPosition = 0x4A1B9B4;
    Offsets::RightHandPosition = 0x4A1BAB8;
    Offsets::RightForeArmPosition = 0x4A1BCC0;
    Offsets::LeftForeArmPosition = 0x4A1BBBC;
    Offsets::CameraMain = 0x84E7148;
    Offsets::MatchPlayers = 0x4C869DC;
    // Các offset = 0 vẫn giữ 0, Esp.h đã check an toàn
    Offsets::GetAnimator = 0x0;
    Offsets::IsClientBot = 0x0;
    Offsets::IsAvatarInit = 0x0;
    Offsets::LeftShoulderPosition = 0x0;
    Offsets::RightShoulderPosition = 0x0;
}

__attribute__((always_inline, visibility("hidden")))
static void fetchAndSaveOffsets(void) {
    // Luôn hardcode trước để đảm bảo không crash
    hardcodeFallbackOffsets();
    
    static std::once_flag curl_init_flag;
    std::call_once(curl_init_flag, []() {
        curl_global_init(CURL_GLOBAL_DEFAULT);
    });

    std::string offsetResponsePayload;
    struct curl_slist *hdrOffset = nullptr;
    hdrOffset = curl_slist_append(hdrOffset, "Content-Type: application/json");
    hdrOffset = curl_slist_append(hdrOffset, "User-Agent: MoniteOffsetFetcher/1.0");

    CURL *curlOffset = curl_easy_init();
    if (!curlOffset) return; // Đã hardcode, không cần fetch nữa

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

    if (offsetRes != CURLE_OK) return; // Giữ hardcode

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
        // Giữ hardcode, không làm gì
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

            g_savedKey = "BYPASS_9999_DAYS";
            g_savedVersionName = "Premium Edition";
            g_versionCreatedTimestamp = (int64_t)[[NSDate date] timeIntervalSince1970];
            g_expirationTimestamp = g_versionCreatedTimestamp + (9999 * 24 * 60 * 60);

            // Fetch offsets (có hardcode fallback)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                fetchAndSaveOffsets();
                
                // Đợi fetch xong mới mở menu
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

// ... (giữ nguyên các hàm __sub_SetupOverlay, __sub_TouchGestureInit, __sub_VjQZKjgZ, __ZZeTgkAiCj, oxr_fj28dj_4ud93 từ bản gốc)
