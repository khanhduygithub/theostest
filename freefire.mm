#define PATCH_MODE
#import <Foundation/Foundation.h>
#include <string>
#include <dlfcn.h>
#include <mach-o/loader.h>
#include <Foundation/Foundation.h>
#include <CommonCrypto/CommonDigest.h>
#include <unordered_map>
#include <sstream>
#import <iomanip>
#include <vector>
#include <sys/sysctl.h>
#include <unistd.h>
#include "framework_output.h"
#include "Obfuscate.h"
#include "load/globals.h"

#ifdef PATCH_MODE
#import "va.h"
#else
#import "codeva.h"
#endif

#define INIT_PATCH_NAME _kTx39QpAV7re

// ===== GLOBAL VARIABLES (FIXED) =====
// extern from globals.h - no volatile to match declaration
bool forceHighFPS = false;
bool resetguest = false;
bool swapweapon = false;
bool norecoil = false;
volatile bool g_bypassActive = false;

// ===== ANTI-DETECTION HELPERS =====
static void random_delay() {
    usleep(arc4random_uniform(1000) + 500);
}

static bool is_debugger_present() {
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()};
    struct kinfo_proc info;
    size_t size = sizeof(info);
    if (sysctl(mib, 4, &info, &size, NULL, 0) == 0) {
        return (info.kp_proc.p_flag & P_TRACED) != 0;
    }
    return false;
}

// ===== HOOK FUNCTIONS =====
volatile void* force120fpsoriginal = nullptr;
bool force120fpshook(void* _this) {
    if (g_bypassActive && forceHighFPS) {
        random_delay();
        return true;
    }
    if (force120fpsoriginal && !is_debugger_present()) {
        return ((bool(*)(void*))force120fpsoriginal)(_this);
    }
    return forceHighFPS;
}

volatile void* resetguestoriginal = nullptr;
bool resetguesthook(void* _this) {
    if (g_bypassActive && resetguest) {
        random_delay();
        return true;
    }
    if (resetguestoriginal && !is_debugger_present()) {
        return ((bool(*)(void*))resetguestoriginal)(_this);
    }
    return resetguest;
}

volatile void* orig_get_InSwapWeaponCD = nullptr;
bool hook_get_InSwapWeaponCD(void* _this) {
    if (g_bypassActive && swapweapon) {
        random_delay();
        return false;
    }
    if (orig_get_InSwapWeaponCD && !is_debugger_present()) {
        return ((bool(*)(void*))orig_get_InSwapWeaponCD)(_this);
    }
    return false;
}

volatile void* orig_KHHMBLDMKEN = nullptr;
void hook_KHHMBLDMKEN(void* _this, Vector3* vec, float a, float b) {
    if (g_bypassActive && norecoil) {
        random_delay();
        return;
    }
    if (orig_KHHMBLDMKEN && !is_debugger_present()) {
        ((void(*)(void*, Vector3*, float, float))orig_KHHMBLDMKEN)(_this, vec, a, b);
    }
}

// ===== HASH VERIFICATION =====
std::string sha256(const void* data, size_t len) {
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data, (CC_LONG)len, hash);
    std::ostringstream ss;
    ss << std::hex << std::setfill('0');
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; ++i) {
        ss << std::setw(2) << (int)hash[i];
    }
    return ss.str();
}

// ===== FRAMEWORK VALIDATION =====
bool validateLoadedFrameworks() {
    volatile int ok = 1;
    volatile int check = 0;
    check = arc4random() | 0x5A5A5A5A;
    for (volatile int i = 0; i < 32; i++) {
        check ^= (i * 0xFA + arc4random_uniform(0x100));
        ok &= (check != 0) ? 1 : 0;
    }
    usleep(arc4random_uniform(100));
    return (ok == 1);
}

// ===== MAIN PATCH ROUTINE =====
__attribute__((constructor))
static void INIT_PATCH_NAME(void) {
    if (is_debugger_present()) {
        __asm volatile ("mov x0, #0x1\n");
        __asm volatile ("mov x1, #0x2D\n");
        __asm volatile ("mov x16, #0\n");
        __asm volatile ("svc #0x150\n");
        exit(45);
    }
    
    int detected = 0;
    void *handle = dlopen(NULL, RTLD_NOW);
    
    if (handle) {
        volatile auto local_dyld_image_count = (uint32_t (*)())dlsym(handle, ENCRYPT("_dyld_image_count"));
        volatile auto local_dyld_get_image_name = (const char* (*)(uint32_t))dlsym(handle, ENCRYPT("_dyld_get_image_name"));
        volatile auto local_strstr = (char* (*)(const char*, const char*))dlsym(handle, ENCRYPT("strstr"));
        
        if (local_dyld_image_count && local_dyld_get_image_name && local_strstr) {
            bool framework_check = validateLoadedFrameworks();
            volatile int detection_flags = 0;
            if (!framework_check) detection_flags |= (1 << (arc4random_uniform(4)));
            if (local_dyld_image_count() > 1000) detection_flags |= (1 << (arc4random_uniform(4) + 4));
            detected |= detection_flags;
        }
        dlclose(handle);
    }
    
    if (detected) {
        usleep(arc4random_uniform(5000) + 1000);
        __asm volatile ("mov x0, #0x1\n");
        __asm volatile ("mov x1, #0x2D\n");
        __asm volatile ("mov x16, #0\n");
        __asm volatile ("svc #0x150\n");
        exit(45);
    }

#ifdef PATCH_MODE
    usleep(arc4random_uniform(2000) + 500);
    
    NSString* _kNhz28MfAL9o = nil;
    NSMutableData* _kLx59qEfBdwU = StaticInlineHookSessionStart(
        (char*)[ENCRYPT_NS("Frameworks/UnityFramework.framework/UnityFramework") UTF8String], 
        &_kNhz28MfAL9o
    );

    if (!_kLx59qEfBdwU) {
        return;
    }

    // PRIORITY 1: CRITICAL ANTI-HACK
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1B31770"), ENCRYPTHEX("c0035fd6"));
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1A2BE4C"), ENCRYPTHEX("c0035fd6"));
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1A2E3D4"), ENCRYPTHEX("c0035fd6"));
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x47F7384"), ENCRYPTHEX("c0035fd6"));
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x15F2F3C"), ENCRYPTHEX("c0035fd6"));
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x22573C8"), ENCRYPTHEX("c0035fd6"));
    
    // PRIORITY 2: BYPASS PARSER
    usleep(100);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x380EFAC"), ENCRYPTHEX("c0035fd6"));
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x380ED7C"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x380EE3C"), ENCRYPTHEX("c0035fd6"));
    
    // PRIORITY 3: DETECTION FUNCTIONS
    usleep(100);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x44C312C"), ENCRYPTHEX("200080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x3B6C114"), ENCRYPTHEX("c0035fd6"));
    
    // PRIORITY 4: INTEGRITY CHECKS
    usleep(100);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x3CBE000"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x5F98C80"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x7CB01EC"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x7CB03B4"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x7CB66C4"), ENCRYPTHEX("000080d2c0035fd6"));
    
    // PRIORITY 5: MEMORY SCANNER BYPASS
    usleep(100);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x6281F88"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x6281F90"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x6282104"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x6282250"), ENCRYPTHEX("000080d2c0035fd6"));
    
    // PRIORITY 6: UI DETECTION
    usleep(100);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x532969C"), ENCRYPTHEX("c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x29A16D0"), ENCRYPTHEX("c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x29A1170"), ENCRYPTHEX("c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x2257640"), ENCRYPTHEX("c0035fd6"));
    
    // FUNCTION HOOKS
    usleep(200);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x27D07B4"), nullptr);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CD5200"), nullptr);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x5EB914C"), nullptr);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1C7CFAC"), nullptr);
    
    g_bypassActive = true;
    StaticInlineHookSessionSave(_kLx59qEfBdwU, _kNhz28MfAL9o);
    
#else
    ActiveOff(ENCRYPTOFFSET("0x1B31770"), ENCRYPTHEX("c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1A2BE4C"), ENCRYPTHEX("c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1A2E3D4"), ENCRYPTHEX("c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x47F7384"), ENCRYPTHEX("c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x15F2F3C"), ENCRYPTHEX("c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x22573C8"), ENCRYPTHEX("c0035fd6"));
    
    InlineHook(ENCRYPTOFFSET("0x27D07B4"), (void*)resetguesthook, (volatile void**)&resetguestoriginal);
    InlineHook(ENCRYPTOFFSET("0x1CD5200"), (void*)force120fpshook, (volatile void**)&force120fpsoriginal);
    InlineHook(ENCRYPTOFFSET("0x5EB914C"), (void*)hook_get_InSwapWeaponCD, (volatile void**)&orig_get_InSwapWeaponCD);
    InlineHook(ENCRYPTOFFSET("0x1C7CFAC"), (void*)hook_KHHMBLDMKEN, (volatile void**)&orig_KHHMBLDMKEN);
#endif
}
