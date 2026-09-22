<p align="center">
  <img src="opennow-qt/res/brand/opennow-mark.png" alt="GeforceXYZ cloud logo" width="96" height="52" />
</p>

<h1 align="center">GeforceXYZ</h1>

<p align="center"><strong>A desktop client for GeForce NOW, built on the OpenNOW Qt app.</strong></p>

<p align="center">
  <img src="https://img.shields.io/badge/License-MIT-FFD34D?style=for-the-badge&labelColor=0D0D0D" alt="MIT license" />
  <img src="https://img.shields.io/badge/Qt-6.8%2B-FFD34D?style=for-the-badge&labelColor=0D0D0D" alt="Qt 6.8 or newer" />
  <img src="https://img.shields.io/badge/Core-Rust-FFD34D?style=for-the-badge&labelColor=0D0D0D" alt="Rust core" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Design-Black_Grey_Gold_Bright-FFD34D?style=for-the-badge&labelColor=0D0D0D" alt="Design system: black UI, grey text, gold bright accent" />
</p>

GeforceXYZ is a personal fork of the community-built [OpenNOW](https://github.com/OpenCloudGaming/OpenNOW)
client. The interface is Qt Quick, the account services and streaming engine are Rust, and it talks
to your own GeForce NOW account. Use a keyboard and mouse, or switch to the console layout for a
controller. Both layouts run in the same app.

> [!NOTE]
> This fork keeps OpenNOW's MIT license and upstream attribution. The product name, packaging, and
> the visual design are the parts that differ. See [Credits](#credits).

> [!IMPORTANT]
> You need your own GeForce NOW account. Your subscription, region, and hardware determine which
> games and stream settings you can use. GeforceXYZ is not affiliated with, endorsed by, or
> sponsored by NVIDIA. NVIDIA and GeForce NOW are trademarks of NVIDIA Corporation.

> [!WARNING]
> The Qt app is still under development. Expect bugs, including platform-specific streaming and GPU
> issues. It has no Chromium/WebRTC fallback. There are no published GeforceXYZ builds yet — build
> from source.

## Inside the client

- Browse the catalog, save favorites, and organize your library into collections.
- Set the resolution, frame rate, bitrate, and codec your account and device support.
- Open stream menus and statistics without leaving the video.
- Take screenshots and record the source stream to Matroska files. Find both in Media.
- Export a diagnostic report through Settings → About → Copy diagnostics when something breaks.
- Run the same app as a desktop layout or as a controller-first console layout.

The Qt app guide in [`opennow-qt/README.md`](opennow-qt/README.md) lists hardware requirements,
experimental features, and platform limitations.

## Design

This fork restyles both layouts onto one system: a black interface, a grey text ramp, and a single
bright gold accent.

| Role | Value |
| --- | --- |
| Surfaces | `#0D0D0D`, `#141414`, `#1A1A1A` |
| Primary text | `#EDEDED` |
| Secondary text | `#8A8A8A` |
| Accent | `#FFD34D` |
| Fault | `#F87171` |
| Type | Outfit (display), Inter (body) |

Gold marks exactly one thing per screen — the primary action, the current selection, or the focused
surface. Theme packs keep their saved ids but are now tonal variants of the same black/white/gold
family.

The desktop layout is laid out like the cloud client it imitates: a full-width bar with the menu
button, the page name, search, and the account chip; navigation in a drawer that opens below the
bar; flat settings rows that read label-left, action-right; and shelves of wide artwork on the home
page. Every name, tier, playtime figure, and connected-store line on those screens comes from your
own account, never from a fixed list.

- Visual reference: [`docs/design/black-white-gold.html`](docs/design/black-white-gold.html) (open
  it in a browser, no build step)
- Rules and token ownership: [`docs/design/README.md`](docs/design/README.md)
- Tokens live in [`qml/theme/Theme.qml`](opennow-qt/qml/theme/Theme.qml) and
  [`qml/desktop/components/DesktopTokens.qml`](opennow-qt/qml/desktop/components/DesktopTokens.qml)

The screenshots under `docs/assets/readme/` come from upstream OpenNOW's Paper design and show the
pre-restyle interface.

## How it works

Qt draws the interface and handles windows, navigation, focus, and overlays. The Rust core runs in a
separate process. It manages accounts, settings, and catalog requests, then prepares the session.
Qt talks to it over a [versioned JSON protocol](docs/core-protocol.md).

The native Rust streamer handles NVST transport, decoding, audio, gameplay input, and recording. Qt
loads it in the desktop process through a
[versioned C ABI](native/opennow-streamer/crates/opennow-streamer-ffi/README.md). Video stays on
the GPU, and Qt draws menus over it in the same window. The app doesn't embed a browser or open a
separate video window. The [streamer guide](native/opennow-streamer/README.md) explains the
graphics backends and how Qt uses them.

## Build from source

Before building, install:

- Qt 6.8+ with Quick, Multimedia, and ShaderTools.
- CMake 3.24+ and a C++20 toolchain.
- SDL3, Cargo, and the media dependencies for your platform.

Linux also needs `pkg-config`, `libwayland-dev`, and `wayland-protocols`, even for X11 builds. Check
the [Qt app guide](opennow-qt/README.md#build) for platform-specific details.

```sh
git clone https://github.com/Goldodemon-Automation/GeforceXYZ.git
cd GeforceXYZ
cmake -S opennow-qt -B build/opennow-qt -DCMAKE_BUILD_TYPE=Debug
cmake --build build/opennow-qt
ctest --test-dir build/opennow-qt --output-on-failure
```

The repository layout and CMake target names still use `opennow`, so the build produces
`build/opennow-qt` and an `OpenNOW` executable. Renaming the binary is a separate change.

You don't need Node.js or npm to build or run the desktop app. The repository uses JavaScript for
tools such as the localization checker:

```sh
npm run locales:check
```

Testing login and gameplay requires a GeForce NOW account. Without one, you can run the smoke tests,
screenshot fixtures, and performance checks in the Qt app guide and the
[acceptance runbook](docs/qt-acceptance.md).

## Documentation

| Topic | Where |
| --- | --- |
| Qt application | [`opennow-qt/README.md`](opennow-qt/README.md) |
| Design system | [`docs/design/README.md`](docs/design/README.md) |
| Protocol, release, and acceptance docs | [`docs/`](docs/) |
| Upstream player and contributor docs | [opennow.zortos.me](https://opennow.zortos.me) |

### Repository map

```text
opennow-qt/               Qt Quick desktop app, C++ integration, and Qt tests
native/opennow-core/      Rust accounts, settings, catalog, and session services
native/opennow-streamer/  Native NVST transport, media, input, and Qt FFI
locales/                  English source and Crowdin-managed translations
docs/                     Architecture, protocols, acceptance, release, and design docs
scripts/                  Repository-only localization tooling
.github/                  CI workflows and contributor guidance
```

## Contributing

For code changes, read the contributing guide in
[`.github/CONTRIBUTING.md`](.github/CONTRIBUTING.md) and the repository guidance in
[`AGENTS.md`](AGENTS.md). Keep changes focused on one thing.

For translations, edit only `locales/en.json`. Crowdin manages the other locale files, and untranslated
strings fall back to English until they are synced.

Found a bug? Open an issue with your build, OS, GPU, and steps to reproduce it. For streaming bugs,
include a diagnostic export, and check attachments for personal information before posting them.

## Credits

GeforceXYZ is a fork. The client, the streaming engine, and most of this documentation are the work
of the [OpenNOW](https://github.com/OpenCloudGaming/OpenNOW) contributors, used under the MIT
license. Upstream keeps the release process, the
[Discord](https://discord.gg/8EJYaJcNfD), and the documentation site.

## License

MIT. See [LICENSE](LICENSE) and [THIRD_PARTY_NOTICES](THIRD_PARTY_NOTICES).
