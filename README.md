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
- Fixed intermittent X-Plane freeze on exit on Windows by avoiding OpenAL shutdown calls during plugin unload.
- Added startup guard against duplicate AutoGate plugin instances.
- Added stricter DataRef validation at startup to avoid partial/unsafe initialization.
- Added defensive null checks and safer fallback handling in gate/aircraft state logic.
- Hardened WAV/OpenAL loading path checks to avoid invalid file/path edge-case crashes.
- Improved Windows build reliability in `src/Makefile.mgw64`:
  - Windows-friendly `clean` target.
  - Optional OpenAL build fallback (`NO_OPENAL`) when OpenAL dev files are missing.
  - Updated local SDK/OpenAL path defaults used in this repository layout.

### Hints for developers
The only verified working part of the build system is *../src/Makefile.mgw64* for the mingw64 system on Windows and *../src/Makefile.lin64* for Linux.
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
