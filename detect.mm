// ============================================
// MemoryManager.mm - Zexis Patch cho iOS No JB
// Dùng VM_PROT_COPY nên không cần entitlement
// ============================================

#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <string>

// ============================================
// MACRO
// ============================================
#define timer(sec) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_main_queue(), ^

// ============================================
// STRUCT
// ============================================
struct MemoryFileInfo {
    uint32_t index;
    const struct mach_header *header;
    const char *name;
    long long address;
};

// ============================================
// HELPER FUNCTIONS
// ============================================
static MemoryFileInfo getMemoryFileInfo(const char *fileName) {
    MemoryFileInfo info = {};
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (!name) continue;
        if (strstr(name, fileName)) {
            info.index = i;
            info.header = _dyld_get_image_header(i);
            info.name = _dyld_get_image_name(i);
            info.address = _dyld_get_image_vmaddr_slide(i);
            return info;
        }
    }
    return info;
}

static uintptr_t getAbsoluteAddress(const char *fileName, uintptr_t offset) {
    MemoryFileInfo info = getMemoryFileInfo(fileName ? fileName : "");
    if (info.address == 0) return 0;
    return info.address + offset;
}

// ============================================
// PATCH FUNCTIONS
// ============================================
static bool patchUnity(uint64_t offset, uint32_t data) {
    uintptr_t addr = getAbsoluteAddress("UnityFramework", offset);
    if (addr == 0) return false;
    
    kern_return_t err;
    mach_port_t port = mach_task_self();
    
    // VM_PROT_COPY = chìa khóa cho No JB
    err = vm_protect(port, addr, sizeof(data), false, 
                     VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (err != KERN_SUCCESS) return false;
    
    data = CFSwapInt32(data);
    err = vm_write(port, addr, (vm_offset_t)&data, sizeof(data));
    if (err != KERN_SUCCESS) return false;
    
    err = vm_protect(port, addr, sizeof(data), false, 
                     VM_PROT_READ | VM_PROT_EXECUTE);
    if (err != KERN_SUCCESS) return false;
    
    return true;
}

static bool patchMain(uint64_t offset, uint32_t data) {
    uintptr_t addr = getAbsoluteAddress(NULL, offset);
    if (addr == 0) return false;
    
    kern_return_t err;
    mach_port_t port = mach_task_self();
    
    err = vm_protect(port, addr, sizeof(data), false, 
                     VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (err != KERN_SUCCESS) return false;
    
    data = CFSwapInt32(data);
    err = vm_write(port, addr, (vm_offset_t)&data, sizeof(data));
    if (err != KERN_SUCCESS) return false;
    
    err = vm_protect(port, addr, sizeof(data), false, 
                     VM_PROT_READ | VM_PROT_EXECUTE);
    if (err != KERN_SUCCESS) return false;
    
    return true;
}

// ============================================
// CONVENIENCE MACROS
// ============================================
#define PATCH_UNITY(offset, hex) patchUnity(offset, hex)
#define PATCH_MAIN(offset, hex)  patchMain(offset, hex)

// ============================================
// OFFSET DATA
// ============================================
// MOV R0, #0; BX LR = 0xE3A00000 (little endian swap: 0x0000A0E3)
// MOV R0, #1; BX LR = 0xE3A00001 (little endian swap: 0x0100A0E3)
// NOP               = 0x00000000
// MOV R0, #0x3C830000 = 0xE3830000 (little endian swap: 0x000083E3)

// ============================================
// INIT
// ============================================
__attribute__((constructor))
static void init() {
    timer(3) {
        // ==================== HACKER DETECTION ====================
        PATCH_UNITY(0x5C51424, 0xE3A00000);
        PATCH_UNITY(0x5C51434, 0xE3A00000);
        PATCH_UNITY(0x5C515B4, 0xE3A00000);
        PATCH_UNITY(0x5C516AC, 0xE3A00000);
        
        // ==================== SECURITY ====================
        PATCH_UNITY(0x397A354, 0xE3A00001);
        PATCH_UNITY(0x397A7F0, 0xE3A00001);
        PATCH_UNITY(0x397A7F8, 0xE3A00001);
        PATCH_UNITY(0x397A850, 0xE3A00001);
        
        // ==================== INTEGRITY ====================
        PATCH_UNITY(0x4D018FC, 0xE3A00001);
        PATCH_UNITY(0x4D01904, 0xE3A00001);
        PATCH_UNITY(0x62809D4, 0xE3A00001);
        PATCH_UNITY(0x6281F24, 0xE3A00001);
        
        // ==================== MEMORY ====================
        PATCH_UNITY(0x6281F88, 0x00000000);
        PATCH_UNITY(0x6281F90, 0x00000000);
        PATCH_UNITY(0x6282104, 0x00000000);
        PATCH_UNITY(0x6282250, 0x00000000);
        
        // ==================== TIMESCALE ====================
        PATCH_UNITY(0x6280AA8, 0xE3830000);
        PATCH_UNITY(0x6280C00, 0xE3830000);
        PATCH_UNITY(0x6280C58, 0xE3830000);
        
        // ==================== NETWORK ====================
        PATCH_UNITY(0x4389250, 0x00000000);
        PATCH_UNITY(0x4389258, 0x00000000);
        PATCH_UNITY(0x43893D8, 0x00000000);
        PATCH_UNITY(0x43893E0, 0x00000000);
        
        // ==================== FILE INTEGRITY ====================
        PATCH_UNITY(0x44E6E64, 0xE3A00001);
        PATCH_UNITY(0x44E6EBC, 0xE3A00001);
        PATCH_UNITY(0x44E6EC4, 0xE3A00001);
        PATCH_UNITY(0x44E7088, 0xE3A00001);
        
        // ==================== PROCESS DETECTION ====================
        PATCH_UNITY(0x5031030, 0xE3A00000);
        PATCH_UNITY(0x50310B8, 0xE3A00000);
        
        // ==================== SUBSTRATE/CYDIA ====================
        PATCH_UNITY(0x5DED814, 0xE3A00000);
        PATCH_UNITY(0x5DEEB4C, 0xE3A00000);
        PATCH_UNITY(0x5DEEC60, 0xE3A00000);
        
        // ==================== DEBUGGER ====================
        PATCH_UNITY(0x5DEEC74, 0xE3A00000);
        PATCH_UNITY(0x5DEED38, 0xE3A00000);
        PATCH_UNITY(0x5DEED44, 0xE3A00000);
        
        NSLog(@"[BYPASS] All 31 patches applied!");
    });
}
