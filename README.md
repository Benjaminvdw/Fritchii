<!--
# SPDX-FileCopyrightText: Copyright 2025 Eden Emulator Project
# SPDX-License-Identifier: GPL-3.0-or-later

# SPDX-FileCopyrightText: 2018 yuzu Emulator Project
# SPDX-License-Identifier: GPL-2.0-or-later
-->

<p align="center">
  <img src="dist/fritchii.png" alt="Fritchii" width="200">
</p>

# Fritchii for Linux

An unofficial Linux AppImage of [Fritchii](https://github.com/Frizti/Fritchii), the Switch 2-focused fork of Lichii. Fritchii's own releases are Windows-only. This fork makes it build and run on Linux.

**It works.** Fritchii v5.3 runs The Legend of Zelda: Ocarina of Time great on Linux, on a Ryzen 7 7800X3D and RTX 4070 SUPER under CachyOS. On the earlier v5 build it ran as well as it does on Windows.

That's one game on one PC so far. Other games and AMD or Intel GPUs are untested, and rendering bugs or stutters are still possible.

**White patches in Ocarina of Time:** on v5.3, large glowing white patches could appear at random and cause big lag spikes. Some lighting calculations produce invalid pixels, and the game's bloom spreads them across the screen. Linux builds from v5.4 on stop that spreading, but this fix is still being tested. The bad lighting data behind it isn't solved, so an affected solid object can turn black instead. Restarting the game clears it for a while. If you still get white patches or black shapes on v5.4 or newer, please report where it happened, along with your GPU and driver version.

## Download

**[Get the latest release](https://github.com/Benjaminvdw/Fritchii/releases/tag/fritchii-linux-v5.6)**

```bash
chmod +x Fritchii-v5.6-Linux-x86_64.AppImage
./Fritchii-v5.6-Linux-x86_64.AppImage
```

Linux v5.6 is Fritchii v5.5 plus a Linux-only updater change. There is no Fritchii v5.6 for Windows behind it, so Linux version numbers can run ahead of Fritchii's.

The first start prepares shaders once, which takes about 15 minutes.

Games, keys and firmware are not included. Only use ones you have legally obtained.

On a Wayland desktop the first start shows a "Wayland Detected!" warning. Fritchii recommends **Use X11**, then restart it.

### Requirements

- x86_64 Linux about as new as Ubuntu 24.04, or newer
- A working Vulkan driver
- Normal desktop audio (ALSA)

The v5 AppImage started on Ubuntu 24.04, Debian 13, Fedora 45 and Arch. The v5.3 AppImage has been started on Debian 13 and CachyOS, v5.4 on CachyOS, and v5.5 and v5.6 in an Ubuntu 24.04 container.

## Updates

From v5.3 on, Fritchii offers new Linux releases when it starts. It checks the download against GitHub's checksum, replaces the AppImage and restarts. The previous version stays next to it as `.old`, and your settings and saves are not touched.

The file keeps its original name after an update, so check the title bar to see which version you're running.

## What's different from the Windows build

- A few small fixes to Windows-only code that stopped it compiling on Linux
- The updater installs Linux AppImages from this fork instead of the Windows package
- Built with clang and the repo's PGO profile, on Ubuntu 24.04
- Includes the Ocarina of Time shader recipe from the Windows release
- Fragment shaders clear pixels that come out invalid (NaN), so bloom can't spread them into white patches. Based on the workaround by PantACRO4life and the investigation by justin-wq1337 in Lichii issues 849 and 867

## Build it yourself

You only need Docker:

```bash
tools/appimage/build.sh
```

The AppImage appears in the repository root. Use `JOBS=<n>` to limit the compile jobs.

## Reporting problems

Please don't report bugs from this build to the Fritchii or Lichii developers. When reporting one here, include your distro, GPU and driver version, the game, and whether you're on X11 or Wayland. The log is under Help > Export Log. Check it for personal information first, and don't upload game files, keys or firmware.

## Credits and license

All the emulator work belongs to [Frizti](https://github.com/Frizti/Fritchii) and the Lichii, Eglantine, Eden, yuzu and Sudachi projects and their contributors, including Eglantine's original developer Camille LaVey. Art by YOB (yobslab).

This is an independent fork, not an official release of those projects, and it is not affiliated with Nintendo. Original copyright notices and third-party licenses are retained. See [LICENSE.txt](LICENSE.txt) and the source files for the terms.
