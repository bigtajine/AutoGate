# AutoGate animated jetway and docking guidance system kit

## Fork status
This repository is based on [Marginal/AutoGate](https://github.com/Marginal/AutoGate) and later community fork work.

The original project effectively stopped at AutoGate 1.72 (2017). This fork continues maintenance for modern X-Plane, especially XP12 compatibility and Windows build/runtime stability.

- Fork base: `Marginal/AutoGate`
- Starting code snapshot used here: `hotbso/AutoGate` release `1.82`
- Fork versioning starts at `1.80` (original upstream ended at `1.72`)
- Historical reference fork: `hotbso/AutoGate`

This project is community-maintained and is not officially affiliated with Laminar Research, Marginal, hotbso, or GitHub account owners referenced above.

## Recent changes

### 1.90
- Fork release **1.90** (`version.mak`).
- **Alert sound:** fixed jetway moving without beep when X‑Plane evaluated **`vert`** or **`moving`** before **`lat`** the first frame in range (`gate_autogate` never armed); any of **`lat` / `vert` / `moving`** now arms alerts.
- **Windows build:** `Makefile.mgw64` links OpenAL from bundled **`openal-soft-1.25.1-bin`** when present (otherwise `../libOpenAL32` or **`NO_OPENAL=1`**).

### 1.89
- Fork release **1.89** (`version.mak`).
- **Linux** (`lin.xpl`) and **macOS** (`mac.xpl`, universal arm64 + x86_64) are first-class build targets via `src/Makefile.lin64` and `src/Makefile.mac`; GitHub Actions builds **win**, **lin**, and **mac** `.xpl` files and packages a fat **`64`** layout zip.
- **Windows:** `Makefile.mgw64` expects the official SDK under repo **`SDK/`**; use `scripts/fetch-sdk.ps1` and `scripts/build-win-xpl.ps1` for a quick local **win.xpl** build.
- **Docker:** `Dockerfile.lin` and `scripts/build-lin-xpl-docker.ps1` compile **lin.xpl** on Windows when Docker is working (Ubuntu base from AWS Public ECR to reduce Docker Hub TLS issues on some networks).

### 1.88
- **Plugin Admin disable/enable:** If you turn AutoGate off and on at the same stand with the same aircraft (`acf_ICAO` unchanged), gate session state (including **DOCKED** and jetway `lat`/`vert`/`moving`) is restored instead of resetting to a fresh **NEWPLANE** / full re-dock sequence.

### 1.87
- During **replay** (`sim/time/is_in_replay`), the jetway pose is frozen and the gate/DGS state machine does not run, so replayed beacon/engine data cannot disconnect or drive the bridge.

### 1.86
- Fixed jetway re-dock behavior after undocking while still parked on stand.
- Resolved a state-machine edge case where AutoGate could remain in a non-rearm state
  until the aircraft moved far forward/sideways before docking could trigger again.

### 1.85
- Kept alert audio enabled by default on XP12/Windows.
- Added optional troubleshooting override: `AUTOGATE_SAFE_NO_AUDIO=1` to disable alert audio at startup.
- Added runtime OpenAL fail-closed guards: if OpenAL calls start failing, alert audio is disabled for the session to prioritize sim stability.

### 1.84

These Makefile updates shipped in the same first **1.84** tagged build as **1.83** below (fork `version.mak` jumped from **1.82**); the split is documentation-only.

- Improved Windows build reliability in `src/Makefile.mgw64`:
  - Windows-friendly `clean` target.
  - Optional OpenAL build fallback (`NO_OPENAL`) when OpenAL dev files are missing.
  - Updated local SDK/OpenAL path defaults used in this repository layout.

### 1.83
- Fixed intermittent X-Plane freeze on exit on Windows by avoiding OpenAL shutdown calls during plugin unload.
- Added startup guard against duplicate AutoGate plugin instances.
- Added stricter DataRef validation at startup to avoid partial/unsafe initialization.
- Added defensive null checks and safer fallback handling in gate/aircraft state logic.
- Hardened WAV/OpenAL loading path checks to avoid invalid file/path edge-case crashes.

### Hints for developers
**X-Plane SDK:** Download the current [Plugin SDK ZIP](https://developer.x-plane.com/sdk/plugin-sdk-downloads) and unpack so this repo has a top-level `SDK/` directory (`SDK/CHeaders/XPLM`, `SDK/Libraries/...`). The same headers build all platforms.

**Windows:** From `src/`, use `Makefile.mgw64` with mingw-w64 (see comments in that file for OpenAL paths and optional `NO_OPENAL=1`). Quick PowerShell: `powershell -File scripts/fetch-sdk.ps1` then `powershell -File scripts/build-win-xpl.ps1` — output is `src/win.xpl`.

**Linux:** Install a toolchain plus OpenAL headers (e.g. Debian/Ubuntu: `build-essential`, `libopenal-dev`). From `src/`: `make -f Makefile.lin64` (or `make -f Makefile.lin64 SDK=/path/to/SDK`). Use `NO_OPENAL=1` if you have no OpenAL dev package.

**macOS:** Install Xcode command-line tools. From `src/`: `make -f Makefile.mac` for a universal **arm64 + x86_64** `mac.xpl`. Optional `NO_OPENAL=1`. Cross-building macOS binaries from Linux is not covered here; see `Makefile.osxcross` if you maintain that toolchain.

**From repo root:** With `SDK/` beside `Makefile`, run `make linux`, `make mac`, or `make windows` (GNU make; optional `SDK=...`, `NO_OPENAL=1`).

**CI:** GitHub Actions workflow `.github/workflows/build.yml` downloads SDK 4.3.0, builds **`win.xpl`**, **`lin.xpl`**, and **`mac.xpl`**, uploads each as an artifact, and zips all three into **`AutoGate-fat64.zip`** (layout `AutoGate/64/{win,lin,mac}.xpl`) as **`AutoGate-fat64-all-xpl`** for a ready-to-drop fat plugin `64` folder.

**Getting `lin.xpl` on Windows:** Install [Docker Desktop](https://www.docker.com/products/docker-desktop/), then run `powershell -File scripts/build-lin-xpl-docker.ps1`. That uses `Dockerfile.lin` to compile Linux binaries and copies **`src/lin.xpl`** into your tree.

**Getting `mac.xpl` without a Mac:** Apple binaries cannot be produced on Windows. Push the repo to GitHub (include `.github/workflows/build.yml`), open **Actions → Build**, and download the **`mac-xpl`** artifact (or **`AutoGate-fat64-all-xpl`** for all three). With [GitHub CLI](https://cli.github.com/): `gh run download -n mac-xpl`.

A linkable OpenAL32.dll for Windows was obtained as follows:
- get copy of libOpenAL32.dll e.g. from FlyWithLua
- pick libOpenAL's *include/AL* header files, e.g. from the msys2 system
- run within a mgw64 shell:
```
gendef OpenAL32.dll
dlltool -d OpenAL32.def -D OpenAL32.dll -k -a -l libopenal32.a -v
```
- link against libopenal32.a and put OpenAL32.dll into the plugin

### Troubleshooting audio issues (Windows)
If you get crackling, freezes, or startup issues that may be related to alert audio,
disable AutoGate audio for testing:
- Temporary (current terminal session only):
  - PowerShell: `$env:AUTOGATE_SAFE_NO_AUDIO="1"`
  - CMD: `set AUTOGATE_SAFE_NO_AUDIO=1`
- Persistent (new terminals after restart):
  - PowerShell: `setx AUTOGATE_SAFE_NO_AUDIO 1`

After setting it, restart X-Plane and test again.
To re-enable normal audio behavior, remove/unset the variable or set it to `0`.

## Original README
This kit allows [X-Plane](http://www.x-plane.com/) scenery designers to add animated jetways and docking guidance systems (DGS) to scenery packages. Two types of jetway and four types of DGS are included.
 
The jetway animates to dock with the plane's main door when the pilot shuts down the plane's engines with the plane within ½m of the correct stopping position. The DGS guides the pilot to the correct stopping position.

An example scenery package that uses these boarding bridges and DGSs can be found [here](http://marginal.org.uk/x-planescenery/tutorials.html#autogate).
 
## License

The plugin code in the `src` directory is licensed under the GNU [LGPL v2.1](http://www.gnu.org/licenses/lgpl-2.1-standalone.html) license.

The rest of the kit is licensed under the Creative Commons [Attribution](http://creativecommons.org/licenses/by/3.0/) license. In short, you can use any part of this kit (including the 3D objects and their textures) in original or modified form in a free or commerical scenery package, but you must give the author credit.
