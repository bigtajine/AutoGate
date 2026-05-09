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

## Original README
This kit allows [X-Plane](http://www.x-plane.com/) scenery designers to add animated jetways and docking guidance systems (DGS) to scenery packages. Two types of jetway and four types of DGS are included.
 
The jetway animates to dock with the plane's main door when the pilot shuts down the plane's engines with the plane within ½m of the correct stopping position. The DGS guides the pilot to the correct stopping position.

An example scenery package that uses these boarding bridges and DGSs can be found [here](http://marginal.org.uk/x-planescenery/tutorials.html#autogate).
 
## License

The plugin code in the `src` directory is licensed under the GNU [LGPL v2.1](http://www.gnu.org/licenses/lgpl-2.1-standalone.html) license.

The rest of the kit is licensed under the Creative Commons [Attribution](http://creativecommons.org/licenses/by/3.0/) license. In short, you can use any part of this kit (including the 3D objects and their textures) in original or modified form in a free or commerical scenery package, but you must give the author credit.
