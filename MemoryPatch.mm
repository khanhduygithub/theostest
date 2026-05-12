// MemoryPatch.mm
// Dùng MemoryArena từ Dobby để vô hiệu memory scan
#include "Dobby/dobby.h"
#include <mach-o/dyld.h>
#include <string.h>

// =============================================
// MEMORY PROTECTION OFFSETS
// =============================================
#define OFFSET_MEMORY_SCAN_1    0x6281F88   // Memory Scanner
#define OFFSET_MEMORY_SCAN_2    0x6281F90   // Memory Validator
#define OFFSET_MEMORY_CHECK     0x6282104   // Memory Check
#define OFFSET_MEMORY_PROTECT   0x6282250   // Memory Protection

// =============================================
// INTEGRITY VERIFICATION OFFSETS
// =============================================
#define OFFSET_INTEGRITY_1      0x4D018FC   // Integrity Check 1
#define OFFSET_INTEGRITY_2      0x4D01904   // Integrity Check 2

// =============================================
// ORIGINAL FUNCTIONS
// =============================================
static void *(*orig_memory_scan_1)(void *);
static void *(*orig_memory_scan_2)(void *);
static void *(*orig_memory_check)(void *);
static void *(*orig_memory_protect)(void *);
static void *(*orig_integrity_1)(void *);
static void *(*orig_integrity_2)(void *);

// =============================================
// FAKE FUNCTIONS - VÔ HIỆU HÓA
// =============================================
static void *fake_memory_scan_1(void *a1)   { return nullptr; }
static void *fake_memory_scan_2(void *a1)   { return nullptr; }
static void *fake_memory_check(void *a1)    { return nullptr; }
static void *fake_memory_protect(void *a1)  { return nullptr; }
static void *fake_integrity_1(void *a1)     { return nullptr; }
static void *fake_integrity_2(void *a1)     { return nullptr; }

// =============================================
// CONSTRUCTOR - CHẠY KHI APP LOAD
// =============================================
__attribute__((constructor))
static void patchMemoryDetection() {
    // Lấy base address của UnityFramework
    uintptr_t base = 0;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char *name = _dyld_get_image_name(i);
        if (strstr(name, "UnityFramework")) {
            base = _dyld_get_image_vmaddr_slide(i);
            break;
        }
    }
    
    if (!base) return;
    
    // DobbyHook tự động dùng MemoryArena để cấp code cave
    // Bạn không cần gọi MemoryArena trực tiếp!
    
    DobbyHook((void *)(base + OFFSET_MEMORY_SCAN_1), (void *)fake_memory_scan_1, (void **)&orig_memory_scan_1);
    DobbyHook((void *)(base + OFFSET_MEMORY_SCAN_2), (void *)fake_memory_scan_2, (void **)&orig_memory_scan_2);
    DobbyHook((void *)(base + OFFSET_MEMORY_CHECK),  (void *)fake_memory_check,   (void **)&orig_memory_check);
    DobbyHook((void *)(base + OFFSET_MEMORY_PROTECT),(void *)fake_memory_protect, (void **)&orig_memory_protect);
    DobbyHook((void *)(base + OFFSET_INTEGRITY_1),   (void *)fake_integrity_1,    (void **)&orig_integrity_1);
    DobbyHook((void *)(base + OFFSET_INTEGRITY_2),   (void *)fake_integrity_2,    (void **)&orig_integrity_2);
}
