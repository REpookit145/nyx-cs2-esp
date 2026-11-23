# CS2 ESP — nyx

A self-contained internal ESP (wallhack) for Counter-Strike 2, plus a 4x4
ImGui toggle grid. Built to be *maintained by you*, not downloaded-and-forgotten.

> Reality check, straight up: **"undetected forever" is not a thing for CS2.**
> VAC Live + Trusted Mode + kernel scanning + every-patch offset churn means any
> public/static cheat dies. This is a private tool you re-dump offsets for after
> updates. Using it carries ban risk on your account. That's the tradeoff — no
> magic download removes it.

## What's inside

| File | Job |
|------|-----|
| `src/dllmain.cpp` | DLL entry, loads `offsets.ini`, starts hook thread |
| `src/hooks.cpp`   | Hooks `IDXGISwapChain::Present`, owns ImGui + WndProc |
| `src/esp.cpp`     | Entity scan, world-to-screen, box/skeleton/health drawing |
| `src/menu.cpp`    | 4x4 toggle grid |
| `src/offsets.cpp` | Runtime offset loader |
| `offsets.ini`     | Offset table you edit per patch |

## Setup

1. Open **Steam**, right-click **Counter-Strike 2**, and select **Properties**.
2. Under **General -> Launch Options**, add `-allow_third_party_software`.
3. Make sure `offsets.ini` sits right next to the compiled DLL (`build\Release\cs2_esp.dll`).

## Build

```bat
build.bat
```

Requirements: **Visual Studio 2022 (Desktop C++)**, **CMake**, **Git**.
Output: `build\Release\cs2_esp.dll`.

`build.bat` clones ImGui into `third_party/imgui` on first run.

## Use

1. Your `offsets.ini` is **already filled** for the 2026-11-20 build and sits next to the dll.
2. Launch CS2, get in a match (or bot server).
3. **Double-click `START.bat`** (it's in `build\Release` beside the dll). It checks
   CS2 is running, then injects with the correct full path.
4. **INSERT** toggles the menu. The 4x4 grid controls every ESP element.

Manual equivalent (if you prefer a terminal):
```bat
build\Release\injector.exe cs2.exe "C:\full\path\to\build\Release\cs2_esp.dll"
```

## Menu grid (4x4)

```
ESP        Box       Corner    Fill
Skeleton   Health    Head Dot  Snapline
Distance   Name      Team Chk  Dormant
Visible    Thick+    Reset     Hide
```

## Getting offsets for your build

Offsets change every CS2 update. `offsets.ini` already contains the current values
(build dumped 2026-11-20). After a patch, refresh these:

- `dwLocalPlayerController`, `dwEntityList`, `dwViewMatrix` — client.dll globals
- netvars: `m_iTeamNum`, `m_iHealth`, `m_lifeState`, `m_hPlayerPawn`,
  `m_pGameSceneNode`, `m_modelState`, `m_vecAbsOrigin`, `m_bDormant`

Grab them from any current dumper (e.g. a2x/cs2-dumper `output/offsets.json` +
`client_dll.json` schema). Paste hex values into `offsets.ini`. No rebuild needed —
the loader reads the ini at attach time.

## Tuning if it looks wrong

- **Boxes offset from body** → view matrix or `m_vecAbsOrigin` wrong, or W2S
  orientation (rare). Confirm `dwViewMatrix`.
- **No boxes at all** → `dwEntityList` / `dwLocalPlayerController` wrong, or
  `entity_list_*` geometry changed. These structure constants are in `offsets.ini`
  too.
- **Skeleton connects wrong joints** → bone indices in `esp.cpp` (`bone_id` enum)
  shifted for this build. Update indices against a bone viewer.

## Notes

- Purely client-side draw. No aimbot, no triggerbot, no movement — ESP only, as asked.
- Everything is guarded against bad pointers; worst case it draws nothing.
- `Visible` is a reserved toggle (needs a ray-trace/visibility check to be wired up).
- This is a scaffold meant to be understood and maintained. Read `esp.cpp` — every
  memory read is one line and editable.