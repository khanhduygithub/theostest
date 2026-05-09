#ifndef ESP_H
#define ESP_H

#define RAD2DEG(x) ((float)(x) * (float)(180.f / IM_PI))
#define DEG2RAD(x) ((float)(x) * (float)(IM_PI / 180.f))
#include <unordered_map>

#include "./load/globals.h"
#include "Offsets.hpp"

ImU32 color = IM_COL32(255, 255, 255, 150);

static inline ImVec2 operator*(const ImVec2& lhs, const float rhs) { return ImVec2(lhs.x * rhs, lhs.y * rhs); }
static inline ImVec2 operator/(const ImVec2& lhs, const float rhs) { return ImVec2(lhs.x / rhs, lhs.y / rhs); }
static inline ImVec2 operator+(const ImVec2& lhs, const float rhs) { return ImVec2(lhs.x + rhs, lhs.y + rhs); }
static inline ImVec2 operator+(const ImVec2& lhs, const ImVec2& rhs) { return ImVec2(lhs.x + rhs.x, lhs.y + rhs.y); }
static inline ImVec2 operator-(const ImVec2& lhs, const ImVec2& rhs) { return ImVec2(lhs.x - rhs.x, lhs.y - rhs.y); }
static inline ImVec2 operator-(const ImVec2& lhs, const float rhs) { return ImVec2(lhs.x - rhs, lhs.y - rhs); }

bool ESPEnable = false, ESPLine = false, ESPBox = false, ESPHealth = false, ESPName = false;
bool ESPDistance = false, ESPSkeleton = false;
bool Aimbot = false, enableESP = false;
float AimbotFOV = 90.0f;
float AimSpeed = 1.0f;
int AimTarget = 0, AimMode = 1, AimWhen = 1;
bool IgnoreBots = false, IgnoreKnocked = false, OnlyVisibleEnemies = false;

// ═══════════════════════════════════════
// SAFE READ - Không crash nếu offset = 0
// ═══════════════════════════════════════
#define SAFE_PTR(addr, type) ((Offsets::addr != 0) ? *(type*)((uintptr_t)player + Offsets::addr) : 0)

void* get_main() {
    if (Offsets::get_main == 0) return nullptr;
    static void* (*func)() = (void *(*)())getRealOffset(Offsets::get_main);
    return func ? func() : nullptr;
}

void* get_transform(void* obj) {
    if (!obj || Offsets::get_transform == 0) return nullptr;
    static void* (*func)(void*) = (void *(*)(void *))getRealOffset(Offsets::get_transform);
    return func ? func(obj) : nullptr;
}

void* get_transformNode(void* obj) {
    if (!obj || Offsets::get_transformNode == 0) return nullptr;
    static void* (*func)(void*) = (void *(*)(void *))getRealOffset(Offsets::get_transformNode);
    return func ? func(obj) : nullptr;
}

Vector3 WorldToViewpoint(void* cam, Vector3 pos, int eye) {
    if (!cam || Offsets::WorldToViewpoint == 0) return Vector3::Zero();
    static Vector3 (*func)(void*, Vector3, int) = (Vector3(*)(void *, Vector3, int))getRealOffset(Offsets::WorldToViewpoint);
    return func ? func(cam, pos, eye) : Vector3::Zero();
}

Vector3 get_position(void* obj) {
    if (!obj || Offsets::get_position == 0) return Vector3::Zero();
    static Vector3 (*func)(void*) = (Vector3(*)(void *))getRealOffset(Offsets::get_position);
    return func ? func(obj) : Vector3::Zero();
}

bool IsTeammate(void* player) {
    if (!player || Offsets::Team == 0) return true; // An toàn: coi là đồng đội
    static bool (*func)(void*) = (bool (*)(void *))getRealOffset(Offsets::Team);
    return func ? func(player) : true;
}

ImVec2 world2screen_c(Vector3 pos, bool& checker) {
    auto cam = get_main();
    if (!cam) { checker = false; return {0, 0}; }
    Vector3 worldPoint = WorldToViewpoint(cam, pos, 2);
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    Vector3 location;
    location.x = screenWidth * worldPoint.x;
    location.y = screenHeight - (screenHeight * worldPoint.y);
    location.z = worldPoint.z;
    checker = (location.z > 0);
    return {location.x, location.y};
}

ImVec2 world2screen_i(Vector3 pos) {
    bool c; return world2screen_c(pos, c);
}

int get_HP(void* player) {
    if (!player || Offsets::get_HP == 0) return 0;
    static int (*func)(void*) = (int (*)(void*))getRealOffset(Offsets::get_HP);
    return func ? func(player) : 0;
}

int get_maxHP(void* player) {
    if (!player || Offsets::get_maxHP == 0) return 100;
    static int (*func)(void*) = (int (*)(void*))getRealOffset(Offsets::get_maxHP);
    return func ? func(player) : 100;
}

bool get_IsDieing(void* player) {
    if (!player || Offsets::get_IsDieing == 0) return false;
    static bool (*func)(void*) = (bool (*)(void*))getRealOffset(Offsets::get_IsDieing);
    return func ? func(player) : false;
}

void* GetLocalPlayer(void* game) {
    if (!game || Offsets::GetLocalPlayer == 0) return nullptr;
    static void* (*func)(void*) = (void* (*)(void*))getRealOffset(Offsets::GetLocalPlayer);
    return func ? func(game) : nullptr;
}

void* Curent_Match() {
    if (Offsets::CurrentMatch == 0) return nullptr;
    static void* (*func)(void*) = (void* (*)(void*))getRealOffset(Offsets::CurrentMatch);
    return func ? func(nullptr) : nullptr;
}

void* Camera_main() {
    if (Offsets::Camera_main == 0) return nullptr;
    static void* (*func)(void*) = (void* (*)(void*))getRealOffset(Offsets::Camera_main);
    return func ? func(nullptr) : nullptr;
}

Quaternion GetRotation(void* player) {
    if (!player || Offsets::GetRotation == 0) return Quaternion();
    static Quaternion (*func)(void*) = (Quaternion (*)(void*))getRealOffset(Offsets::GetRotation);
    return func ? func(player) : Quaternion();
}

bool get_IsSighting(void* player) {
    if (!player || Offsets::get_IsSighting == 0) return false;
    static bool (*func)(void*) = (bool (*)(void*))getRealOffset(Offsets::get_IsSighting);
    return func ? func(player) : false;
}

bool get_IsFiring(void* player) {
    if (!player || Offsets::get_IsFiring == 0) return false;
    static bool (*func)(void*) = (bool (*)(void*))getRealOffset(Offsets::get_IsFiring);
    return func ? func(player) : false;
}

void* GetHeadPositions(void* player) {
    if (!player || Offsets::GetHeadPositions == 0) return nullptr;
    static void* (*func)(void*) = (void* (*)(void*))getRealOffset(Offsets::GetHeadPositions);
    return func ? func(player) : nullptr;
}

void* Component_GetTransform(void* component) {
    if (!component || Offsets::Component_GetTransform == 0) return nullptr;
    static void* (*func)(void*) = (void* (*)(void*))getRealOffset(Offsets::Component_GetTransform);
    return func ? func(component) : nullptr;
}

static void set_aim(void* player, Quaternion look) {
    if (!player || Offsets::set_aim == 0) return;
    typedef void (*tSetAim)(void*, Quaternion);
    static tSetAim fn = (tSetAim)getRealOffset(Offsets::set_aim);
    if (fn) fn(player, look);
}

static Vector3 GetForward(void* player) {
    if (!player || Offsets::GetForward == 0) return Vector3();
    static Vector3 (*func)(void*) = (Vector3 (*)(void*))getRealOffset(Offsets::GetForward);
    return func ? func(player) : Vector3();
}

static Vector3 GetHeadPosition(void* player) {
    void* head = GetHeadPositions(player);
    return head ? get_position(head) : Vector3::Zero();
}

static Vector3 GetHipPosition(void* player) {
    if (!player || Offsets::HipPosition == 0) return Vector3::Zero();
    void* ITF = *(void**)((uintptr_t)player + Offsets::HipPosition);
    void* TF = get_transformNode(ITF);
    return TF ? get_position(TF) : Vector3::Zero();
}

Vector3 GetPlayerLocation(void* player) {
    void* t = get_transform(player);
    return t ? get_position(t) : Vector3::Zero();
}

static Vector3 CameraMain(void* player) {
    if (!player || Offsets::CameraMain == 0) return Vector3::Zero();
    void* tf = *(void**)((uintptr_t)player + Offsets::CameraMain);
    return tf ? get_position(tf) : Vector3::Zero();
}

bool IsAvatar(void* player) {
    if (!player || Offsets::IsAvatarInit == 0) return true; // Không check nếu ko có offset
    return *(bool*)((uintptr_t)player + Offsets::IsAvatarInit);
}

bool IsClientBot(void* player) {
    if (!player || Offsets::IsClientBot == 0) return false;
    return *(bool*)((uintptr_t)player + Offsets::IsClientBot);
}

bool ShouldIgnoreEnemy(void* enemy) {
    if (!enemy) return true;
    if (IgnoreBots && IsClientBot(enemy)) return true;
    if (IgnoreKnocked && get_IsDieing(enemy)) return true;
    if (get_HP(enemy) <= 0) return true;
    return false;
}

static void* GetTransform(void* player) { return Component_GetTransform(player); }
static void* GetAnimator(void* player) { return (void*)1; } // LUÔN PASS

static bool Physics_Raycast(Vector3 a, Vector3 b, unsigned int c, void* d) { return false; }
bool IsVisible(void* player) { return true; } // LUÔN VISIBLE

static std::unordered_map<void*, int> boneHistory;
void* targetEnemy = nullptr;

std::vector<void*> GetEnemies(void* match) {
    std::vector<void*> enemies;
    if (!match || Offsets::MatchPlayers == 0) return enemies;
    
    void* localPlayer = GetLocalPlayer(match);
    if (!localPlayer) return enemies;

    uintptr_t listPtr = *(uintptr_t*)((uintptr_t)match + Offsets::MatchPlayers);
    if (!listPtr) return enemies;

    void** playerArray = *(void***)(listPtr + 0x10);
    int playerCount = *(int*)(listPtr + 0x18);
    if (!playerArray || playerCount <= 0) return enemies;

    for (int i = 0; i < playerCount; ++i) {
        void* player = playerArray[i];
        if (!player || player == localPlayer) continue;
        if (IsTeammate(player)) continue;
        if (!IsAvatar(player)) continue;
        if (get_HP(player) <= 0) continue;
        if (ShouldIgnoreEnemy(player)) continue;
        enemies.push_back(player);
    }
    return enemies;
}

void ClearBoneHistory() { boneHistory.clear(); }

void DrawEsp() {
    void* CurrentMatch = Curent_Match();
    void* LocalPlayer = GetLocalPlayer(CurrentMatch);
    void* mainCamera = get_main();

    if (!LocalPlayer || !mainCamera) return;

    ImDrawList* drawList = ImGui::GetBackgroundDrawList();
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    std::vector<void*> currentPlayers = GetEnemies(CurrentMatch);
    
    for (void* player : currentPlayers) {
        if (!player || IsTeammate(player)) continue;

        Vector3 pos = GetPlayerLocation(player);
        Vector3 head = pos + Vector3(0, 1.5f, 0);
        Vector3 foot = pos + Vector3(0, -0.15f, 0);

        bool hOn, fOn;
        ImVec2 head2D = world2screen_c(head, hOn);
        ImVec2 foot2D = world2screen_c(foot, fOn);
        if (!hOn || !fOn) continue;

        float boxH = fabs(head2D.y - foot2D.y);
        float boxW = boxH * 0.5f;
        ImVec2 top(foot2D.x - boxW/2, head2D.y);
        ImVec2 bot(foot2D.x + boxW/2, foot2D.y);

        ImColor boxColor = (targetEnemy == player) ? ImColor(0,255,0) : ImColor(255,255,255);

        if (ESPBox) drawList->AddRect(top, bot, boxColor, 0, 0, 1.5f);
        if (ESPLine) drawList->AddLine(ImVec2(screenWidth/2, 0), ImVec2((top.x+bot.x)/2, top.y), boxColor, 1.0f);

        if (ESPHealth) {
            int hp = get_HP(player);
            int maxhp = get_maxHP(player);
            float barW = 3, barH = boxH;
            ImVec2 barTop(top.x - 5, top.y);
            drawList->AddRectFilled(barTop, ImVec2(barTop.x + barW, barTop.y + barH), ImColor(0,0,0,150));
            float hpPct = (float)hp / maxhp;
            ImColor hpColor = hpPct > 0.6f ? ImColor(0,255,0) : hpPct > 0.3f ? ImColor(255,255,0) : ImColor(255,0,0);
            drawList->AddRectFilled(barTop, ImVec2(barTop.x + barW, barTop.y + barH * hpPct), hpColor);
        }

        if (ESPName) {
            std::string name = IsClientBot(player) ? "BOT" : "Player";
            ImVec2 textPos((top.x+bot.x)/2 - 15, top.y - 15);
            drawList->AddText(ImGui::GetFont(), 12, textPos, ImColor(255,255,255), name.c_str());
        }

        if (ESPDistance) {
            Vector3 myPos = GetPlayerLocation(LocalPlayer);
            float dist = Vector3::Distance(pos, myPos);
            char buf[16]; sprintf(buf, "%.0fm", dist);
            ImVec2 dPos((top.x+bot.x)/2 - 12, bot.y + 3);
            drawList->AddText(ImGui::GetFont(), 11, dPos, ImColor(200,200,200), buf);
        }

        if (ESPSkeleton) {
            Vector3 hip = GetHipPosition(player);
            ImVec2 h2D = world2screen_i(head), hp2D = world2screen_i(hip);
            if (h2D.x > 0 && hp2D.x > 0) drawList->AddLine(h2D, hp2D, ImColor(255,255,255), 1.0f);
        }
    }
}

void AimbotRun() {
    if (!Aimbot) return;
    void* CurrentMatch = Curent_Match();
    void* LocalPlayer = GetLocalPlayer(CurrentMatch);
    if (!LocalPlayer) return;

    std::vector<void*> enemies = GetEnemies(CurrentMatch);
    if (enemies.empty()) { targetEnemy = nullptr; return; }

    CGFloat sw = [UIScreen mainScreen].bounds.size.width;
    CGFloat sh = [UIScreen mainScreen].bounds.size.height;
    ImVec2 center(sw/2, sh/2);

    void* best = nullptr;
    float bestDist = FLT_MAX;

    for (void* e : enemies) {
        Vector3 head = GetHeadPosition(e);
        bool onScr; ImVec2 s = world2screen_c(head, onScr);
        if (!onScr) continue;
        float d = sqrt(pow(s.x - center.x, 2) + pow(s.y - center.y, 2));
        if (d < bestDist) { bestDist = d; best = e; }
    }

    if (best && bestDist <= AimbotFOV) {
        targetEnemy = best;
        Vector3 target = GetHeadPosition(best);
        Quaternion look = Quaternion::LookRotation(target - CameraMain(LocalPlayer), Vector3::Up());
        set_aim(LocalPlayer, look);
    } else {
        targetEnemy = nullptr;
    }
}

#endif
