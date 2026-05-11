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

// ===== GLOBAL VARIABLES =====
// forceHighFPS, resetguest, swapweapon, norecoil defined in menu.mm
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

    // =============================================
    // PRIORITY 1: MEMORY SCAN & INTEGRITY (MỚI)
    // =============================================
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x2A45B80"), ENCRYPTHEX("c0035fd6")); // Memory Scan
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x2A45C10"), ENCRYPTHEX("c0035fd6")); // Memory Integrity
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x4D8A120"), ENCRYPTHEX("c0035fd6")); // Process Check
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x7A4D9C0"), ENCRYPTHEX("c0035fd6")); // Screenshot Block
    
    // =============================================
    // PRIORITY 2: JAILBREAK CHECK (MỚI)
    // =============================================
    usleep(100);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x5E2B390"), ENCRYPTHEX("c0035fd6")); // Jailbreak Check 1
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x5E2B420"), ENCRYPTHEX("c0035fd6")); // Jailbreak Check 2
    
    // =============================================
    // PRIORITY 3: HACKER DETECTED UI (MỚI)
    // =============================================
    usleep(100);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x532969C"), ENCRYPTHEX("c0035fd6")); // ShowHackerDetectedUI
    
    // =============================================
    // PRIORITY 4: INTEGRITY CHECKS (MỚI)
    // =============================================
    usleep(100);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x4D018FC"), ENCRYPTHEX("c0035fd6")); // IntegrityCheck 1
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x4D01904"), ENCRYPTHEX("c0035fd6")); // IntegrityCheck 2
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x62809D4"), ENCRYPTHEX("c0035fd6")); // IntegrityVerify
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x6281F24"), ENCRYPTHEX("c0035fd6")); // IntegrityMonitor
    
    // =============================================
    // PRIORITY 5: SECURITY VALIDATION (MỚI)
    // =============================================
    usleep(100);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x397A354"), ENCRYPTHEX("c0035fd6")); // SecurityMonitor
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x397A7F0"), ENCRYPTHEX("c0035fd6")); // SecurityValidate
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x397A7F8"), ENCRYPTHEX("c0035fd6")); // SecurityCheck
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x397A850"), ENCRYPTHEX("c0035fd6")); // SecurityVerify
    
    // =============================================
    // PRIORITY 6: ADVANCED DETECTION (MỚI)
    // =============================================
    usleep(100);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFC2B0"), ENCRYPTHEX("c0035fd6")); // Advanced Detection 1
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFC604"), ENCRYPTHEX("c0035fd6")); // Advanced Detection 2
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFC708"), ENCRYPTHEX("c0035fd6")); // Advanced Detection 3
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFC82C"), ENCRYPTHEX("c0035fd6")); // Advanced Detection 4
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFC9F4"), ENCRYPTHEX("c0035fd6")); // Advanced Detection 5
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFCAF8"), ENCRYPTHEX("c0035fd6")); // Advanced Detection 6
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFD208"), ENCRYPTHEX("c0035fd6")); // Advanced Detection 7
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFD4FC"), ENCRYPTHEX("c0035fd6")); // Advanced Detection 8
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFDB50"), ENCRYPTHEX("c0035fd6")); // Advanced Detection 9
    usleep(50);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFDC4C"), ENCRYPTHEX("c0035fd6")); // Advanced Detection 10
    
    // =============================================
    // ORIGINAL GAME FEATURES
    // =============================================
    usleep(200);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x27D07B4"), nullptr);  // Reset guest
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CD5200"), nullptr);  // Force 120 FPS
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x5EB914C"), nullptr);  // Swap weapon CD
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1C7CFAC"), nullptr);  // No recoil
    
    g_bypassActive = true;
    StaticInlineHookSessionSave(_kLx59qEfBdwU, _kNhz28MfAL9o);
    
#else
    InlineHook(ENCRYPTOFFSET("0x27D07B4"), (void*)resetguesthook, (volatile void**)&resetguestoriginal);
    InlineHook(ENCRYPTOFFSET("0x1CD5200"), (void*)force120fpshook, (volatile void**)&force120fpsoriginal);
    InlineHook(ENCRYPTOFFSET("0x5EB914C"), (void*)hook_get_InSwapWeaponCD, (volatile void**)&orig_get_InSwapWeaponCD);
    InlineHook(ENCRYPTOFFSET("0x1C7CFAC"), (void*)hook_KHHMBLDMKEN, (volatile void**)&orig_KHHMBLDMKEN);
#endif
}
