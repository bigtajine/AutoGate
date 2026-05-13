# Convenience targets (GNU make). Requires SDK at ./SDK (override with SDK=...).
# Typical: unzip XPSDK430.zip so AutoGate/SDK/ exists, then from repo root: make linux
.PHONY: linux mac windows
linux:
	$(MAKE) -C src -f Makefile.lin64 SDK="$(abspath $(SDK))" NO_OPENAL="$(NO_OPENAL)"

mac:
	$(MAKE) -C src -f Makefile.mac SDK="$(abspath $(SDK))" NO_OPENAL="$(NO_OPENAL)"

windows:
	$(MAKE) -C src -f Makefile.mgw64 SDK="$(abspath $(SDK))" NO_OPENAL="$(NO_OPENAL)"

SDK?=SDK
