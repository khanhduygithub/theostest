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
#include "framework_output.h"
#include "Obfuscate.h"
#include "load/globals.h"

#ifdef PATCH_MODE
#import "va.h"
#else
#import "codeva.h"
#endif

#define INIT_PATCH_NAME _kTx39QpAV7re

extern bool forceHighFPS;
extern bool resetguest;
extern bool swapweapon;
extern bool norecoil;

bool (*force120fpsoriginal)(void* _this) = nullptr;
bool (*resetguestoriginal)(void* _this) = nullptr;
bool (*orig_get_InSwapWeaponCD)(void* _this) = nullptr;
void (*orig_KHHMBLDMKEN)(void* _this, Vector3* vec, float a, float b) = nullptr;

bool force120fpshook(void* _this) { if (forceHighFPS) return true; else return false; }
bool resetguesthook(void* _this) { if (resetguest) return true; else return false; }
bool hook_get_InSwapWeaponCD(void* _this) { if (swapweapon) return false; else return orig_get_InSwapWeaponCD(_this); }
void hook_KHHMBLDMKEN(void* _this, Vector3* vec, float a, float b) { if (norecoil) return; orig_KHHMBLDMKEN(_this, vec, a, b); }

std::string sha256(const void* data, size_t len) {
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data, (CC_LONG)len, hash);
    std::ostringstream ss;
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; ++i) ss << std::hex << std::setw(2) << std::setfill('0') << (int)hash[i];
    return ss.str();
}

bool read_exact_macho_header(const char* path, std::vector<uint8_t>& out_header) {
    FILE* file = fopen(path, "rb");
    if (!file) return false;
    struct mach_header_64 mh;
    if (fread(&mh, 1, sizeof(mh), file) != sizeof(mh)) { fclose(file); return false; }
    if (mh.magic != MH_MAGIC_64) { fclose(file); return false; }
    const size_t headerBaseSize = sizeof(struct mach_header_64);
    std::vector<uint8_t> result((uint8_t*)&mh, (uint8_t*)&mh + headerBaseSize);
    for (uint32_t i = 0; i < mh.ncmds; ++i) {
        long cmdStart = ftell(file);
        struct load_command lc;
        if (fread(&lc, 1, sizeof(lc), file) != sizeof(lc)) break;
        fseek(file, cmdStart, SEEK_SET);
        std::vector<uint8_t> cmdData(lc.cmdsize);
        if (fread(cmdData.data(), 1, lc.cmdsize, file) != lc.cmdsize) break;
        if (lc.cmd == LC_SEGMENT_64) {
            const segment_command_64* seg = reinterpret_cast<const segment_command_64*>(cmdData.data());
            if (strncmp(seg->segname, "__LINKEDIT", 16) != 0) {
                result.insert(result.end(), cmdData.begin(), cmdData.end());
            }
        }
    }
    fclose(file);
    out_header = std::move(result);
    return true;
}

uint32_t (*p_dyld_image_count)(void);
const char* (*p_dyld_get_image_name)(uint32_t);
char* (*p_strstr)(const char*, const char*);
#define XOR_KEY 0xFA

std::string decode_xor(const uint8_t* data) {
    std::string out;
    for (int i = 0; data[i] != 0x00; ++i) out += (char)(data[i] ^ XOR_KEY);
    return out;
}

std::vector<std::string> getDecodedFrameworkNames() {
    std::vector<std::string> names;
    names.reserve(framework_size);
    for (int i = 0; i < framework_size; ++i) {
        std::string s;
        for (int j = 0; framework_names[i][j] != 0x00; ++j) s += (char)(framework_names[i][j] ^ XOR_KEY);
        names.push_back(std::move(s));
    }
    return names;
}

std::vector<std::string> getDecodedFrameworkHashes() {
    std::vector<std::string> hashes;
    hashes.reserve(framework_size);
    for (int i = 0; i < framework_size; ++i) {
        std::string s;
        for (int j = 0; framework_hashes[i][j] != 0x00; ++j) s += (char)(framework_hashes[i][j] ^ XOR_KEY);
        hashes.push_back(std::move(s));
    }
    return hashes;
}

bool validateLoadedFrameworks() {
    volatile int ok = 1;
    volatile int check = 0x5A5A5A5A;
    for (volatile int i = 0; i < 32; i++) { check ^= (i * 0xFA); ok &= (check != 0) ? 1 : 0; }
    return (ok == 1);
}

// ═══════════════════════════════════════════════════════════════
// FAKE MEMORY FUNCTIONS - Hook thẳng vào memory
// ═══════════════════════════════════════════════════════════════
static uint8_t fake_memory_buffer[256] = {0};

static void* fake_MemoryScan_Init(void* _this, const char* key) { return nullptr; }
static bool fake_MemoryScan_Check(void* _this) { return false; }
static int fake_MemoryScan_GetResult(void* _this) { return 0; }
static void* fake_GetMemoryData(void* _this) {
    memset(fake_memory_buffer, 0, sizeof(fake_memory_buffer));
    return fake_memory_buffer;
}
static void fake_SendCheatReport(void* _this, void* reportInfo) { return; }
static void fake_FlushReportQueue(void* _this) { return; }
static int fake_GetReportQueueCount(void* _this) { return 0; }
static void fake_LogSecurityEvent(void* _this, int t, const char* d, const char* s) { return; }
static bool fake_IsAntiCheatActive(void* _this) { return true; }
static const char* fake_DecryptString(void* _this, const char* e) { return ""; }
static void* fake_DecryptPayload(void* _this, const char* d) { return nullptr; }
static bool fake_IntegrityCheck(void* _this) { return true; }

// ═══════════════════════════════════════════════════════════════
// HOOK RETURN HANDLERS
// ═══════════════════════════════════════════════════════════════
__attribute__((naked)) static void hook_ret() { __asm volatile("ret"); }
__attribute__((naked)) static void hook_ret0() { __asm volatile("mov w0, #0"); __asm volatile("ret"); }
__attribute__((naked)) static void hook_ret1() { __asm volatile("mov w0, #1"); __asm volatile("ret"); }

// ═══════════════════════════════════════════════════════════════
// MAIN INIT
// ═══════════════════════════════════════════════════════════════
__attribute__((constructor))
static void INIT_PATCH_NAME(void) {
    int detected = 0;
    void *handle = dlopen(NULL, RTLD_NOW);
    if (handle) {
        p_dyld_image_count = (uint32_t (*)())dlsym(handle, ENCRYPT("_dyld_image_count"));
        p_dyld_get_image_name = (const char* (*)(uint32_t))dlsym(handle, ENCRYPT("_dyld_get_image_name"));
        p_strstr = (char* (*)(const char*, const char*))dlsym(handle, ENCRYPT("strstr"));
        if (p_dyld_image_count && p_dyld_get_image_name && p_strstr) {
            detected |= !validateLoadedFrameworks();
        }
        dlclose(handle);
    }
    if (detected) { exit(45); }

    // ═══════════════════════════════════════════════════════════
    // FAKE MEMORY SCAN - Hook thẳng (6 functions)
    // ═══════════════════════════════════════════════════════════
    static void* orig_mem[6];
    InlineHook(ENCRYPTOFFSET("0x1CFC2B0"), (void*)fake_MemoryScan_Check, orig_mem[0]);     // Memory check
    InlineHook(ENCRYPTOFFSET("0x1CFC604"), (void*)fake_MemoryScan_Check, orig_mem[1]);     // Memory validation
    InlineHook(ENCRYPTOFFSET("0x1CFC708"), (void*)fake_IntegrityCheck, orig_mem[2]);       // Memory integrity
    InlineHook(ENCRYPTOFFSET("0x1CFCAF8"), (void*)fake_GetMemoryData, orig_mem[3]);        // Get memory → fake
    InlineHook(ENCRYPTOFFSET("0x1CFB958"), (void*)fake_SendCheatReport, orig_mem[4]);      // Send report → fake
    InlineHook(ENCRYPTOFFSET("0x1CFA3F0"), (void*)fake_LogSecurityEvent, orig_mem[5]);     // Log → fake

#ifdef PATCH_MODE
    NSString* _kNhz28MfAL9o = nil;
    NSMutableData* _kLx59qEfBdwU = StaticInlineHookSessionStart((char*)[ENCRYPT_NS("UnityFramework") UTF8String], &_kNhz28MfAL9o);

    // ═══════════════════════════════════════════════════════════
    // STATIC PATCH - 24 OFFSET BYPASS (giữ nguyên)
    // ═══════════════════════════════════════════════════════════
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFA010"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFA198"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFA2A4"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFA500"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFA5A4"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFA660"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFAE2C"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFAEEC"), ENCRYPTHEX("200080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CF9B60"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CF9CC0"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CF9DC8"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CF9EB8"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CF9F64"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFAAE8"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFACB4"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFAD08"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFAD80"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFAF38"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFB25C"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFB29C"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CFB2DC"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x532969C"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x6281F88"), ENCRYPTHEX("000080d2c0035fd6"));
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x6281F90"), ENCRYPTHEX("000080d2c0035fd6"));

    // 4 cheat
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x27D07B4"), nullptr);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1CD5200"), nullptr);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x5EB914C"), nullptr);
    StaticInlineHookPatchInMemory(_kLx59qEfBdwU, ENCRYPTOFFSET("0x1C7CFAC"), nullptr);

    StaticInlineHookSessionSave(_kLx59qEfBdwU, _kNhz28MfAL9o);
#else
    // ═══════════════════════════════════════════════════════════
    // ActiveOff + InlineHook
    // ═══════════════════════════════════════════════════════════
    ActiveOff(ENCRYPTOFFSET("0x1CFA010"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1CFA198"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1CFA2A4"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1CFA500"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1CFA5A4"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1CFA660"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1CFAE2C"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1CFAEEC"), ENCRYPTHEX("200080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1CF9B60"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1CF9CC0"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1CF9DC8"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1CF9EB8"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1CF9F64"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1CFAAE8"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1CFACB4"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1CFAD08"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1CFAD80"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1CFAF38"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1CFB25C"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1CFB29C"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x1CFB2DC"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x532969C"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x6281F88"), ENCRYPTHEX("000080d2c0035fd6"));
    ActiveOff(ENCRYPTOFFSET("0x6281F90"), ENCRYPTHEX("000080d2c0035fd6"));

    InlineHook(ENCRYPTOFFSET("0x27D07B4"), (void*)resetguesthook, resetguestoriginal);
    InlineHook(ENCRYPTOFFSET("0x1CD5200"), (void*)force120fpshook, force120fpsoriginal);
    InlineHook(ENCRYPTOFFSET("0x5EB914C"), (void*)hook_get_InSwapWeaponCD, orig_get_InSwapWeaponCD);
    InlineHook(ENCRYPTOFFSET("0x1C7CFAC"), (void*)hook_KHHMBLDMKEN, orig_KHHMBLDMKEN);
#endif
}
