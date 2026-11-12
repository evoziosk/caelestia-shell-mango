<h1 align=center>caelestia-shell (MangoWC Port)</h1>

<div align=center>

![GitHub last commit](https://img.shields.io/github/last-commit/evoziosk/caelestia-shell-mango?style=for-the-badge&labelColor=101418&color=9ccbfb)
![GitHub Repo stars](https://img.shields.io/github/stars/evoziosk/caelestia-shell-mango?style=for-the-badge&labelColor=101418&color=b9c8da)
![GitHub repo size](https://img.shields.io/github/repo-size/evoziosk/caelestia-shell-mango?style=for-the-badge&labelColor=101418&color=d3bfe6)
[![Ko-Fi donate](https://img.shields.io/badge/donate-kofi?style=for-the-badge&logo=ko-fi&logoColor=ffffff&label=ko-fi&labelColor=101418&color=f16061&link=https%3A%2F%2Fko-fi.com%2Fsoramane)](https://ko-fi.com/soramane)
[![Discord invite](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fdiscordapp.com%2Fapi%2Finvites%2FBGDCFCmMBk%3Fwith_counts%3Dtrue&query=approximate_member_count&style=for-the-badge&logo=discord&logoColor=ffffff&label=discord&labelColor=101418&color=96f1f1&link=https%3A%2F%2Fdiscord.gg%2FBGDCFCmMBk)][discord]

</div>

https://github.com/user-attachments/assets/0840f496-575c-4ca6-83a8-87bb01a85c5f

## About This Fork

This is a community port of the beautiful Caelestia shell to work with **MangoWC compositor** instead of Hyprland! 🎉

The original shell was designed exclusively for Hyprland, but through some careful adaptation, it now runs smoothly on MangoWC while maintaining all the core functionality and gorgeous aesthetics that make Caelestia special.

**This is a personal project** that I'm actively maintaining and improving. If you find this port useful and want to support continued development and maintenance, I'd be grateful for any contributions! Beer money is always appreciated 🍺

<details>
<summary>Support via Cryptocurrency</summary>

If you'd like to buy me a beer (or coffee!) for the work on this port, here are my crypto addresses:

- **Bitcoin (BTC)**: `1C1CrcRjPCYXzoXYLtCg8Zu7e1DZ4nyKDL`
- **USDT (TRX)**: `TR4vtxKGmxYJsXQDF2sfLx8W6pztyZKWVT`
- **Ethereum (ETH ERC20)**: `0xeb2031515c8ddacc94e5d0ceba6d22016e6de3da`
- **BINANCE PAY ID**: `765117963`

Every contribution helps keep this project maintained and supports future improvements. Thank you! 🙏

</details>

### What Changed?

- **MangoWC Integration**: Complete rewrite of the compositor backend to use MangoWC's `mmsg` IPC instead of Hyprland's socket protocol
- **Window Management**: Workspace, monitor, and client state comes from persistent `mmsg watch` streams. Mango objects replace Hyprland-specific QML types.
- **Input Masking**: Carefully tuned Region-based input masks to maintain click-through transparency on the desktop while keeping panels and bars interactive
- **Blur Control**: Caelestia translates transparency changes into a managed Mango drawer blur rule. Changed rules recreate the native drawer surface while keeping panel state and typing focus.
- **Feature Adaptation**: Direct `gpu-screen-recorder` integration with MangoWC monitor output, plus native Wayland window previews with a `grim -T` compatibility fallback.

### Recent fixes

- Keyboard-change toasts now honor the Caps Lock, Num Lock, and layout notification settings. The lock screen compares the active layout against the first configured layout.
- Fullscreen behavior and visualiser auto-hide use visible Mango clients across all selected tags, including pinned windows. The workspace bar highlights every selected tag.
- Special-tag actions retain their target monitor, and notification fullscreen checks use visible windows on the focused output.
- Workspace labels retain all digits on secondary monitors (for example, tag 10 displays as 10).
- Native reload hooks refresh shell options and reapply game mode; shell-initiated reloads wait for successful IPC completion.
- Workspace clicks use native `viewcrossmon,<tag>,<output>` (or `view,<tag>` for unresolved tags) so repeated switches work without a keyboard shortcut resetting combination state.
- Workspace indicators respect the compositor's tag count; window occupancy uses Mango client data.
- Fullscreen notification checks accept Mango monitor objects, and drawer clicks use the current screen state.
- The launcher acquires keyboard focus on open and refocuses search on subsequent opens. Focus requests wait for the Wayland window to be active and skip an already focused field. Mango keybinding examples call Quickshell directly.
- Transparency settings synchronize Mango drawer blur through a managed config fragment, with optional alpha-threshold translation when supported by the compositor.
- The network password dialog uses the current appearance tokens instead of the removed `Appearance` singleton.
- Missing application icons use a checked theme fallback or bundled application icon, including when `image-missing` itself is unavailable. Network tray icons retain a bundled network fallback.
- File-picker MIME and special-folder icons use checked theme fallbacks and bundled file/folder images when the theme lacks them.
- A missing `~/.face` keeps the dashboard and lock screen's person icon visible without repeated image warnings.
- First launch saves the built-in colour palette when `scheme.json` is missing. The launcher creates its database directory and falls back to memory if persistent storage cannot be opened.
- Native window previews use Mango's `foreign_toplevel_id` and the standard Wayland image-capture protocols, refresh at up to ten frames per second while visible, and stop when closed. Older compositors fall back to `grim -T`.
- Each output has stable monitor objects and unique workspace IDs. Hotplug creates screen state synchronously and tolerates disappearing screens; cross-output workspace and window moves use native Mango commands.
- Pin/unpin maps to Mango global windows. The native special-tag overlay is exposed in the workspace UI and window move controls.
- Keyboard layouts come from the Wayland keymap; layout selection uses Mango's one-based switch command. Caps Lock and Num Lock use keyboard modifiers and Linux LED state.
- Game mode translates animation, blur, shadow, gap, border, rounding, and tearing settings into Mango options and restores the configured values when disabled.
- Original shell shortcut actions are exposed through a native IPC registry, and the bundled Mango bindings include screenshot, sidebar, session, game-mode, nexus, and idle-inhibition actions.
- An optional full Caelestia-style profile adds workspace groups, window/group actions, application shortcuts, clipboard, recording, media, and shell controls. The installer previews conflicts and can replace matching keys using a backed-up local snapshot.
- Outside clicks dismiss modal drawers and detached popouts; clicks inside their controls remain interactive.
- Wallpaper selection and persistence work without caelestia-cli. A direct Matugen backend generates dynamic Material palettes, previews, light/dark modes, and variants; queued requests discard outdated results.
- Dynamic colours also follow changes to the saved wallpaper path without the CLI, including changes made outside the shell. Reapplying the same wallpaper regenerates its palette.
- Nix packaging and Home Manager now use Mango and the required capture/keyboard dependencies instead of Hyprland.

### Features

The shell provides the following features on MangoWC. See [compatibility and known limits](#compatibility-and-known-limits) for remaining differences and requirements:

- ✅ Panels: bar, dashboard, utilities, OSD, sidebar, and session controls
- ✅ Screen recording (fullscreen & region capture via `gpu-screen-recorder` + `slurp`)
- ✅ Hover detection and auto-hide behaviors
- ✅ Multi-monitor tags, window tracking, native previews, and window actions
- ✅ Media controls (MPRIS)
- ✅ Network, battery, brightness, audio controls
- ✅ Launcher with app search
- ✅ Notification system
- ✅ Lock screen
- ✅ System tray
- ✅ Wallpaper management
- ✅ Built-in colour schemes, Matugen wallpaper palettes, and application themes
- ✅ Searchable keyboard shortcut sheet and Nexus settings
- ✅ Runtime window rule manager on Super+Ctrl+R, with persistent rules and immediate Mango reloads
- ✅ Game mode, keyboard indicators, and keyboard-change toasts
- ✅ Area zoom magnifier

### Area zoom

Press **Super + Z** to zoom into a screen area. The screen dims with a
crosshair cursor: drag a rectangle, or hover to snap to the window under the
cursor and click it. A floating panel then shows the selected region
magnified **live** (not a frozen snapshot), with scroll wheel or
<kbd>+</kbd>/<kbd>−</kbd> zoom (1–8×) and a draggable header. The panel is
sized to fit beside the selection; zooming past that shows a magnified
portion of the region instead, so the panel never covers the area it is
magnifying. Only the panel itself takes input, so the rest of the desktop
stays usable while the zoom is open, and Escape or Super+Z closes it.

For a manually managed config, add:

```ini
bind=SUPER,z,spawn,qs ipc -c caelestia call areazoom toggle
```

IPC: `qs ipc -c caelestia call areazoom open|close|toggle`, plus
`isOpen` and `setZoom <level>`.

### Keyboard shortcut sheet

Press **Super + /** to toggle the shell's floating keyboard shortcut sheet.
Search by key, application or action; filter by category. Escape closes the sheet
and Ctrl+F focuses search. The sheet reads the active Mango config and its sources
on each open or refresh, including custom bindings, release bindings, mouse
shortcuts and key modes. Plain-conf and TOML configurations are supported.

Both bundled shortcut profiles include the binding and a floating window rule.
For a manually managed config, add:

```ini
bind=SUPER,slash,spawn,qs ipc -c caelestia call keybindings toggle
window_rule=title:^Caelestia Keybindings$,is_floating:1
```

### Window rule manager

Press **Super + Ctrl + R** to configure the focused window. The manager captures
it before opening, and also lets you choose another open window. Match its app ID,
title, or both; configure floating, fullscreen, pinning, always-on-top, decorations,
opacity, size, position, monitor and workspace tags. Options have Default/On/Off
states so an omitted option keeps the compositor default. Saved rules can be
edited or deleted in the same window. Choose your options and click **Save and
reload Mango** to persist the rule and reload the compositor immediately.

Both bundled profiles include:

```ini
bind=SUPER+CTRL,r,spawn,qs ipc -c caelestia call windowRules toggle
window_rule=title:^Caelestia Window Rules$,is_floating:1
```

Saving or deleting writes `~/.config/mango/caelestia-window-rules.conf` and
immediately dispatches `reload_config`. The first save adds its source to the
Mango config and keeps a backup. Rules survive shell updates and restarts.
Floating, fullscreen, pinning, always-on-top and floating pixel sizes also apply
to the selected window through IPC. Other properties apply on the next matching
window open; Mango does not reapply all window rules during a reload. Deleting
a rule removes the persistent default without undoing an existing window's state.

For a symlink-managed or TOML config, include the rule fragment declaratively
first (`source=/absolute/path/to/caelestia-window-rules.conf`, or add it to
`[global].source` for TOML). Set `CAELESTIA_MANGO_CONFIG` in the shell environment
when using a custom Mango config path. The editor manages its own fragment;
existing manually written rules remain in their original files.

### Compositor reload synchronization

The bundled binding profiles and managed blur fragment include this Mango hook:

```ini
exec=qs ipc -c caelestia call mango configReloaded
```

Keep it in manually managed configurations too (`exec`, not `exec_once`). It
refreshes shell options and reapplies game mode after native, manual, or automatic
Mango reloads. Re-running the keybinding installer adds the hook to existing
plain-conf installations; sourced hooks are detected to avoid duplicates.
For TOML configurations, add the command to the existing `exec` list under
`[global]`. Shell-initiated reloads also synchronize directly after IPC success.

### Port regression checks

From a configured checkout with Quickshell and the built plugin available:

```sh
cmake --build build --parallel 2
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -p 'test_*.py'
node tests/test_mango_model.js
python3 tests/check_mango_service.py
python3 tests/check_window_rules.py
python3 tests/check_recorder_service.py
```

The QML service check runs offscreen with mocked compositor commands and isolated
configuration/state directories. It checks multi-monitor visibility, special-tag
command ordering, and game-mode restoration after both reload paths without
changing the desktop. The recorder check covers region/audio flags, pause/resume,
cancellation, rapid start/stop requests and missing-program recovery using fake
capture programs. Hardware-specific behavior still requires live testing.

### Compatibility and known limits

The core shell is ported, but it is not identical to upstream in every behavior:

- Mango has one native special-tag overlay per output. It does not provide independent Hyprland-style named special workspaces; the adapter exposes the native overlay as `special:special`.
- Workspace groups are bounded by Mango's maximum of 31 tags. Group locking, extra Super+Z/X mouse aliases, and lock-surface restoration shortcuts remain unmapped; see [the full profile](#full-caelestia-style-keybindings).
- Window details retain first-observed titles/app IDs, not necessarily the original creation-time metadata for windows open before the shell starts. Bar filtering tags are assigned locally through `tagRules` rather than compositor window tags.
- Native window previews need `foreign_toplevel_id` plus supported Wayland image-capture protocols. The fallback needs `grim -T` and still requires a client identifier; titles and metadata remain available when capture is unsupported.
- Alpha-threshold blur rules depend on the installed Mango version; older builds use their native transparency mask. The remaining Qt text-input warning is documented below.
- Notifications require Caelestia to own `org.freedesktop.Notifications`; another running notification server can prevent registration.

## Components

-   Widgets: [`Quickshell`](https://quickshell.outfoxxed.me)
-   Compositor: [`MangoWC`](https://github.com/mangowm/mango) (originally [`Hyprland`](https://hyprland.org))
-   Original Dots: [`caelestia`](https://github.com/caelestia-dots)

## Special Thanks

**Huge shoutout and massive thanks to [@Soramane](https://github.com/soramane)** and the entire Caelestia project for creating such an incredible, polished, and beautiful shell! This port wouldn't exist without their amazing work. If you love this shell, please consider [supporting them on Ko-Fi](https://ko-fi.com/soramane)! 💙

Also huge thanks to:
- [@outfoxxed](https://github.com/outfoxxed) for creating and maintaining Quickshell
- The MangoWC developers for building a solid wlroots compositor
- The Hyprland discord community for ongoing inspiration and help

## Installation

> [!IMPORTANT]
> Build this fork, or use its Nix flake. The upstream AUR shell package targets Hyprland and will not install these Mango changes. The Nix files pass parsing, package evaluation, and build-plan resolution; a full Nix build has not been run in the current Arch environment.

### Prerequisites for MangoWC

Before installing the shell, make sure you have MangoWC properly set up:

1. **MangoWC Compositor**: Install and configure MangoWC ([GitHub repo](https://github.com/mangowm/mango))
2. **Blur**: Disabling Mango blur is not an installation requirement. To let Caelestia manage
   drawer blur, follow [automatic blur integration](#automatic-blur-integration) after installation.

### Guided installation (recommended)

Run the installer as your normal user in a terminal:

```sh
git clone https://github.com/evoziosk/caelestia-shell-mango.git "$HOME/caelestia-shell-mango"
cd "$HOME/caelestia-shell-mango"
./install.sh
```

If already cloned, skip cloning and run `./install.sh` from your checkout.
The installer checks prerequisites, offers missing dependency installation on Arch-based systems
using Pacman and an existing Yay or Paru helper, then configures, builds, and installs the shell.
Package managers retain their normal confirmation prompts. On other distributions, install the
dependencies below first. The installer does not bootstrap an AUR helper or perform a system upgrade.

**Enter your sudo password at sudo's normal terminal prompt when requested.** Password characters
will not be shown. The script never reads, stores, or passes your password as an argument.
Builds run as your normal user; sudo is used for system packages and the final installation.

After installation, optional prompts add shortcuts, autostart, and blur integration. Config changes
are backed up. Existing shortcuts are preserved; conflicting keys are reported without changing the
config unless you choose the full-profile conflict-replacement option. TOML and symlink-managed Mango configs require declarative/manual setup. The installer does
not stop another shell or launch a second instance: close the old Caelestia instance and run `qs -c caelestia`.

Useful options:

```sh
./install.sh --check                 # Read-only prerequisite check
./install.sh --jobs 1                # Use less memory during compilation
./install.sh --build-dir build-local # Use a separate build directory
./install.sh --help
```

Rerun after updating the checkout to rebuild and reinstall. If compilation or installation fails,
the installer stops; correct the displayed error and rerun. “No work to do” means compilation is current;
the installation step still copies updated QML and assets.

### Compatibility requirements

Live previews—the thumbnail shown when hovering over the bar's window title, also used by window info—
work on the tested Mango setup. They require Mango client `foreign_toplevel_id` support and the standard image-capture protocols. `grim -T` is used only by the compatibility fallback.
Older versions keep window titles and metadata available; upgrade those dependencies for live capture.
This is a version requirement, rather than an unfinished port feature.

### Manual Installation (MangoWC)

Dependencies:

-   [`caelestia-cli`](https://github.com/caelestia-dots/cli) (optional; used by the emoji picker and custom CLI commands)
-   [`matugen`](https://github.com/InioX/matugen) (for native dynamic colours)
-   [`quickshell-git`](https://git.outfoxxed.me/quickshell/quickshell) - **must be the git version**, not the latest tagged version
-   `mangowc` - The MangoWC compositor with `mmsg` IPC support
-   `python` (Python 3.11 or newer, for Mango config helpers)
-   `wayland` and `libxkbcommon` (native keyboard state)
-   `glibc`
-   `gcc-libs`
-   [`ddcutil`](https://github.com/rockowitz/ddcutil)
-   [`brightnessctl`](https://github.com/Hummer12007/brightnessctl)
-   [`app2unit`](https://github.com/Vladimir-csp/app2unit)
-   [`libcava`](https://github.com/LukashonakV/cava)
-   [`networkmanager`](https://gitlab.freedesktop.org/NetworkManager/NetworkManager)
-   [`lm_sensors`](https://github.com/lm-sensors/lm-sensors)
-   [`aubio`](https://github.com/aubio/aubio)
-   [`libpipewire`](https://github.com/PipeWire/pipewire)
-   [`libqalculate`](https://github.com/Qalculate/libqalculate)
-   [`power-profiles-daemon`](https://gitlab.freedesktop.org/upower/power-profiles-daemon)
-   [`ttf-material-symbols-variable`](https://github.com/google/material-design-icons)
-   [`ttf-rubik-vf`](https://github.com/googlefonts/rubik)
-   [`ttf-cascadia-code-nerd`](https://github.com/ryanoasis/nerd-fonts)
-   `qt6-base`
-   `qt6-declarative`
-   `qt6-imageformats`
-   [`qt6-m3shapes-git`](https://github.com/soramanew/m3shapes)
-   [`swappy`](https://github.com/jtheoof/swappy)
-   [`gpu-screen-recorder`](https://git.dec05eba.com/gpu-screen-recorder/) (for screen recording)
-   [`slurp`](https://github.com/emersion/slurp) (for region selection)
-   [`grim`](https://gitlab.freedesktop.org/emersion/grim) (for screenshots; `-T` enables the preview compatibility fallback)
-   [`fish`](https://github.com/fish-shell/fish-shell)
-   [`bash`](https://www.gnu.org/software/bash)

Build dependencies:

- [`cmake`](https://gitlab.kitware.com/cmake/cmake)
- [`ninja`](https://github.com/ninja-build/ninja)
- `qt6-shadertools`
- `pkgconf` (provides `pkg-config`)

The plugin requires Qt **6.9 or newer** and development files for the libraries above.

### Build and install

Run these commands in a terminal inside your Mango session after installing the dependencies:

```sh
# Download this fork into your home directory.
git clone https://github.com/evoziosk/caelestia-shell-mango.git "$HOME/caelestia-shell-mango"
cd "$HOME/caelestia-shell-mango"

# Configure once, then compile using two jobs to keep memory usage modest.
cmake -S . -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/
cmake --build build --parallel 2

# Install the shell and its compiled QML plugins; sudo may ask for your password.
sudo cmake --install build

# Start the installed shell.
qs -c caelestia
```

Already cloned this repository? Start at `cd` using your checkout's actual location and skip `git clone`.
On systems with enough memory, increase `--parallel 2` to build faster. If compilation is killed due to low memory, use `--parallel 1`.

The default install puts the shell in `/etc/xdg/quickshell/caelestia`, QML plugins in
`/usr/lib/qt6/qml`, and helper executables in `/usr/lib/caelestia`. Configure and build as your regular user;
only installation needs sudo. No username substitution or `XDG_CONFIG_HOME` setup is required.

For source changes, install the compiled plugins once, then preview your checkout with:

```sh
qs -p "$HOME/caelestia-shell-mango/shell.qml"
```

Stop the other Caelestia instance before previewing. Changes to C++ plugins require rebuilding,
installing, and restarting Quickshell; editing QML alone can be previewed from the checkout.

> [!TIP]
> CMake also accepts `INSTALL_LIBDIR`, `INSTALL_QMLDIR`, and `INSTALL_QSCONFDIR` to override installation paths.
> If you change `INSTALL_LIBDIR`, set `CAELESTIA_LIB_DIR` to the same absolute directory in your session.
> A config at `${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/caelestia` takes precedence over the system config;
> an old copy there can hide newly installed fixes. Use `qs -p /etc/xdg/quickshell/caelestia/shell.qml`
> to explicitly launch the system installation.

## Usage

The shell can be started via `qs -c caelestia` or by launching Quickshell with the config path.

### Starting with MangoWC

To autostart the shell with MangoWC, add this to your MangoWC config:

```
exec_once= qs -c caelestia
```

Or if using caelestia-cli:

```
exec_once= caelestia shell -d
```

### Automatic blur integration

Run this once **inside your Mango session**, after installing the shell:

```sh
python3 /etc/xdg/quickshell/caelestia/assets/mango_blur.py --setup --enabled 0 --alpha 0.85
```

The helper backs up an existing `~/.config/mango/config.conf` to `config.conf.before-caelestia-blur`,
enables Mango's `blur` and `blur_layer`, replaces this fork's exact legacy `caelestia.*` no-blur rule,
and sources a generated fragment at `${XDG_STATE_HOME:-$HOME/.local/state}/caelestia/mango-blur.conf`.
It preserves other config entries. With no user config, it sources `/etc/mango/config.conf` first.
The setup command targets writable `.conf` files. For TOML or Home Manager/symlink-managed configs,
add `blur=1`, `blur_layer=1`, and the generated fragment to your existing global source list declaratively
instead of running setup. Create the fragment initially with the rule below, then the shell maintains it:

```ini
layer_rule=layer_name:^caelestia-drawers$,no_blur:1
```

Set `CAELESTIA_MANGO_CONFIG` in the shell's environment if Mango uses a config outside the default
`~/.config/mango/config.conf` or `config.toml` paths.
Enabling the global blur switches can also enable blur for other apps allowed by your Mango rules.

Caelestia's transparency is disabled by default. Enable it in `~/.config/caelestia/shell.json`
(merge this into your existing settings):

```json
{
    "appearance": {
        "transparency": {
            "enabled": true,
            "base": 0.85,
            "layers": 0.4
        }
    }
}
```

Once the updated shell is running, it translates transparency on/off to the drawer's `no_blur` rule,
coalesces setting changes, and reloads Mango only when the generated rule changes. Mango applies
layer rules at surface creation, so the shell briefly recreates its native drawer surface while
keeping QML panel state. Do not edit the generated fragment; the shell maintains it.

If the installed Mango supports `blur_ignore_alpha`, the helper also translates the base opacity
into `max(0, base - 0.03)`. Older Mango builds lack that option and use their native transparency mask;
they do not receive an unsupported rule. Alpha-threshold behavior is therefore version-dependent.
See [Mango's layer rules](https://mangowm.github.io/docs/window-management/rules/).

To disable the integration, remove the marked `CAELESTIA BLUR` block from your Mango config and reload
Mango. Runtime synchronization skips configs that do not source its fragment. Restore your previous
global blur settings if desired.

### Shortcuts/IPC

#### Full Caelestia-style keybindings

The original Caelestia keybinding list belongs to its compositor configuration, rather than the shell
itself. This fork provides two profiles: [minimal shell controls](assets/mango-keybinds.conf) and an
optional [full upstream-style profile](assets/mango-keybinds-full.conf). Choose **full upstream-style**
during `./install.sh` shortcut setup. The installer shows conflicts before offering replacement;
do not source both profiles together.

Replacement backs up your config and snapshots included files containing matching profile keys,
removing those old bindings from the snapshot. Original system/source files are preserved. Unrelated
sources, including the generated blur fragment, remain live. Snapshot sections do not inherit future
edits to their original files; rerun setup or merge those updates manually. TOML/managed configs need
declarative setup. Mouse, scroll, release, and common-mode bindings are included in conflict checks.

| Category | Full profile behavior |
|---|---|
| Workspaces | Super+1–9/0 selects a slot in the current ten-tag group; Super+Alt moves the window. Ctrl+Super selects a group while preserving the slot; add Alt to move the window. Arrow/Page Up/Page Down/scroll variants follow the listed upstream modifiers. |
| Special overlay | Super+S toggles the native overlay. Super+Alt+S or Ctrl+Super+Shift+Up moves a window in; Ctrl+Super+Shift+Down returns a special window to its previous normal tag. |
| Window groups | Alt+Tab / Shift+Alt+Tab cycles group members; Ctrl+Alt+Tab variants cycle visible stacks, including ungrouped windows. Super+U leaves the group; Super+Comma joins the right neighbor or leaves the current group. |
| Window actions | Directional focus/movement, Super+mouse drag/resize, center, normalize to 55×70%, picture-in-picture, pin, fullscreen, maximize, floating, and close. Split-movement keys map to Mango's layout-dependent `move_client`, rather than Hyprland split-tree operations. Picture-in-picture enables a floating, pinned window at 30% size in the lower-right corner. |
| Named app toggles | Ctrl+Shift+Escape: `foot`/`btop`; Super+M: `foot`/`ncspot`; Super+D: `vesktop`; Super+R: `foot`/`taskwarrior-tui`. These use named single-app scratchpads, rather than separate multi-window special workspaces. Edit the profile's commands/app IDs to use your preferred apps. |
| Applications | Super+T/W/C/E launches `foot`/`firefox`/`codium`/`thunar`; Ctrl+Alt+V launches `pwvucontrol`. Set the corresponding `CAELESTIA_APP_*` variable (suffix `TERMINAL`, `BROWSER`, `EDITOR`, `FILES`, or `AUDIO`) in Mango's environment before session startup to override these commands. |
| Utilities | Print saves/copies a screenshot of the focused output; Super+Shift+S opens the frozen picker; add Alt for the region picker. Ctrl+Alt+R / Super+Alt+R / Super+Shift+Alt+R toggles fullscreen/sound/region recording. Super+Shift+C copies a picked colour. |
| Media | Ctrl+Super+Space/Equal/Minus/Backspace controls play/pause, next, previous, stop; Super+Shift+M toggles audio mute. |
| Shell | Ctrl+Alt+Delete opens session; Super+N toggles sidebar; Ctrl+Alt+C clears notifications; Super+K toggles panels; Super+L locks; Super+Shift+L runs `systemctl suspend`. Ctrl+Super+Alt+R restarts Caelestia; Ctrl+Super+Shift+R closes its instances. |
| Clipboard/emoji | Super+V opens history, Super+Alt+V deletes entries, Ctrl+Shift+Alt+V pastes the newest entry, Super+Period opens the emoji picker. Clipboard history requires an existing collector such as `wl-paste --watch cliphist store`; the installer does not start one implicitly. |

The full profile reserves **Super+U for ungrouping**, **Super+D for communication**, and
**Ctrl+Super+Space for media**. Dashboard and utilities move to Super+B and Super+Y.
Mango supports up to 31 tags: enable 31 in the installer for group navigation, or choose your own
`tag_num` (at least 10 for Super+0). Out-of-range group requests show feedback instead of selecting an
unrelated tag. The ten-slot scheme supports three complete groups and tag 31; it cannot provide
Hyprland's unbounded workspace groups.

Unmapped upstream features: group locking (Super+Shift+Comma), the extra Super+Z/X mouse aliases,
and lock-surface restoration (Super+Alt+L). Standard Super+left/right mouse drag/resize remains available;
the full profile does not bypass authentication or recreate a lock surface by unlocking it.

Optional tools: `cliphist`, `fuzzel`, `wl-clipboard`, `wtype` (latest-entry paste), `hyprpicker`
(a Wayland colour picker that also works outside Hyprland), and your chosen apps. The installer can
install the clipboard/colour-picker tools on Arch. Emoji selection uses the optional `caelestia-cli`
emoji picker, which has no Hyprland compositor dependency. Recording uses the shell's native recorder.

Preview the full profile without changing your config:

```sh
python3 scripts/install-mango-config.py --keybinds \
  --bindings-file assets/mango-keybinds-full.conf --check
```

For custom installation paths, update the helper path in the profile. Nix packaging rewrites it to
the package's installed asset directory. Native command mappings follow
[Mango's dispatcher reference](https://mangowm.github.io/docs/bindings/keys/).

#### Minimal shell controls

> [!NOTE]
> Mango bindings invoke Quickshell IPC. Original shell actions are also available with `qs ipc -c caelestia call shortcuts trigger <name>`; list them with `qs ipc -c caelestia call shortcuts list`.

The shell does not automatically register Mango keybindings. Add these to `~/.config/mango/config.conf`:

```ini
# Tap Super to toggle the launcher; Super+Space also works.
bindr=SUPER,Super_L,spawn,qs ipc -c caelestia call drawers toggle launcher
bindr=SUPER,Super_R,spawn,qs ipc -c caelestia call drawers toggle launcher
bind=SUPER,space,spawn,qs ipc -c caelestia call drawers toggle launcher

bind=SUPER,d,spawn,qs ipc -c caelestia call drawers toggle dashboard
bind=SUPER,u,spawn,qs ipc -c caelestia call drawers toggle utilities
bind=SUPER,l,spawn,qs ipc -c caelestia call lock lock
```

These commands use Quickshell directly and do not require `caelestia-cli`. A ready-to-source copy is in
[`assets/mango-keybinds.conf`](assets/mango-keybinds.conf). Remove conflicting bindings for the same keys,
and reload Mango with `mmsg dispatch reload_config`. Super-only bindings run on key release;
see [Mango's modifier-key binding syntax](https://mangowm.github.io/docs/bindings/keys/).
If you prefer only Super+Space, omit the two `bindr` lines.

If you have no user config and Mango uses `/etc/mango/config.conf`, preserve those defaults by starting
`~/.config/mango/config.conf` with `source=/etc/mango/config.conf`, then add the bindings above.
The launcher requests keyboard focus and focuses its search field whenever opened, including through IPC.
Clicking outside a modal drawer or detached popout closes it; that dismissal click is consumed by the shell.
The bundled bindings use Super+Ctrl+I for idle inhibition, preserving Mango's default Super+Shift+I restore-minimized action.

For a systemd-started shell, import the compositor environment from your Mango session before starting it:

```ini
exec_once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP MANGO_INSTANCE_SIGNATURE
```

This gives the service access to Mango's IPC socket and the correct Wayland display.

All IPC commands can be accessed via `caelestia shell ...` if you have caelestia-cli installed. For example:

```sh
caelestia shell mpris getActive trackTitle
```

You can view the list of available IPC commands by running `caelestia shell -s`.

### PFP/Wallpapers

The dashboard and lock screen read the profile picture from `~/.face`. If it does not exist, they show a person icon. You can set it by clicking it in the dashboard,
or by manually copying or symlinking your image to the path.

The wallpapers for the wallpaper switcher are read from `~/Pictures/Wallpapers`
by default. To change it, modify `paths.wallpaperDir` in `~/.config/caelestia/shell.json`.

To set the wallpaper, you can type `>wallpaper` in the launcher to open the wallpaper switcher.
Alternatively, you can also use `caelestia wallpaper -f <path_to_wallpaper>` to set the wallpaper directly.
Use `caelestia wallpaper -h` for more info about this command.

## Updating

From your checkout, pull updates, reconfigure, rebuild, and install:

```sh
cd "$HOME/caelestia-shell-mango"
git pull --ff-only
cmake -S . -B build
cmake --build build --parallel 2
sudo cmake --install build
```

Reconfiguration keeps your existing installation settings and refreshes build metadata.
If Git reports local changes or divergent history, resolve those before updating.
Stop the running Caelestia instance with Ctrl+C in its terminal, then run `qs -c caelestia` again.
Restart after updates to compiled plugins as well as QML files. If you use a user copy at `~/.config/quickshell/caelestia`, update that copy too or explicitly launch the system path; it takes precedence over system-wide installs. Re-run shortcut setup when an update adds integration hooks such as the Mango reload hook.

## Configuring

All configuration options belong in `~/.config/caelestia/shell.json`. This file can be created manually or saved by changes made in Nexus settings. Options that you omit use their default values.

### Per-monitor configuration

You can configure per-monitor options in `~/.config/caelestia/monitors/<monitor_name>/shell.json`.
List the names of your available monitors by running:

```sh
mmsg get all-monitors | jq -r '.monitors[].name'
```

Options set in these files will **override** the respective options in the global config. Any options not present in
per-monitor configs will inherit their values from the global config.

For example, to automatically hide the bar on the monitor named `DP-1`:

**`~/.config/caelestia/monitors/DP-1/shell.json`**

```json
{
    "bar": {
        "persistent": false
    }
}
```

> [!NOTE]
> Not all options respect per-monitor overrides. Most notably, the following options will only read
> from the global config, and ignore the respective option in per-monitor config files.
>
> <details><summary>Ignored options</summary>
>
> - `appearance`: `anim.*`, `transparency.*`
> - `bar.tray`: `hiddenIcons`, `iconSubs`
> - `bar.workspaces`: `ignoredTags`, `tagRules`, `specialWorkspaceIcons`, `windowIcons`, `workspaceIcons`
> - `dashboard`: `mediaUpdateInterval`, `resourceUpdateInterval`
> - `general`: `apps.*`, `battery.*`, `idle.*`, `logo`
> - `launcher`: `actionPrefix`, `actions`, `enableDangerousActions`, `favouriteApps`, `hiddenApps`, `specialPrefix`, `useFuzzy.*`, `vimKeybinds`
> - `lock`: `enableFprint`, `enableHowdy`, `maxFprintTries`, `maxHowdyTries`, `triggerHowdyOnWake`
> - `nexus`: `networkRescanInterval`
> - `notifs`: `actionOnClick`, `defaultExpireTimeout`, `expire`, `fullscreen`, `fullscreenExpireTimeout`
> - `paths`: `lyricsDir`, `wallpaperDir`
> - `services`: `audioIncrement`, `brightnessIncrement`, `clockFormat`, `dataUnits`, `defaultPlayer`, `gpuType`, `lyricsBackend`, `maxVolume`, `playerAliases`, `sensorUnits`, `smartScheme`, `visualiserBars`, `weatherLocation`, `weatherUnits`
> - `utilities`: `toasts.*`, `vpn.*`
>
> </details>

### Example configuration

> [!NOTE]
> This is a representative configuration, not an exhaustive schema or a promise of current defaults.
> Add only the settings you want to override. Nexus exposes settings interactively;
> the definitions in [`plugin/src/Caelestia/Config`](plugin/src/Caelestia/Config) are the source of truth.

<details><summary>Example config</summary>

```json
{
    "enabled": true,
    "appearance": {
        "deformScale": 1,
        "rounding": {
            "scale": 1
        },
        "spacing": {
            "scale": 1
        },
        "padding": {
            "scale": 1
        },
        "font": {
            "scale": 1,
            "clock": "Rubik",
            "workspaces": "Rubik",
            "headline": {
                "family": "GoogleSansFlex",
                "large": {
                    "size": 32,
                    "weight": 500,
                    "italic": false,
                    "vaxes": { "ROND": 25 }
                },
                "medium": {
                    "size": 28,
                    "weight": 500,
                    "italic": false,
                    "vaxes": { "ROND": 25 }
                },
                "small": {
                    "size": 24,
                    "weight": 500,
                    "italic": false,
                    "vaxes": { "ROND": 25 }
                }
            },
            "title": {
                "family": "GoogleSansFlex",
                "large": {
                    "size": 22,
                    "weight": 500,
                    "italic": false,
                    "vaxes": { "ROND": 25 }
                },
                "medium": {
                    "size": 16,
                    "weight": 500,
                    "italic": false,
                    "vaxes": { "ROND": 25 }
                },
                "small": {
                    "size": 14,
                    "weight": 500,
                    "italic": false,
                    "vaxes": { "ROND": 25 }
                }
            },
            "body": {
                "family": "GoogleSansFlex",
                "large": {
                    "size": 16,
                    "weight": 400,
                    "italic": false,
                    "vaxes": { "ROND": 25 }
                },
                "medium": {
                    "size": 14,
                    "weight": 400,
                    "italic": false,
                    "vaxes": { "ROND": 25 }
                },
                "small": {
                    "size": 12,
                    "weight": 400,
                    "italic": false,
                    "vaxes": { "ROND": 25 }
                }
            },
            "label": {
                "family": "GoogleSansFlex",
                "large": {
                    "size": 14,
                    "weight": 500,
                    "italic": false,
                    "vaxes": { "ROND": 25 }
                },
                "medium": {
                    "size": 12,
                    "weight": 500,
                    "italic": false,
                    "vaxes": { "ROND": 25 }
                },
                "small": {
                    "size": 11,
                    "weight": 400,
                    "italic": false,
                    "vaxes": { "ROND": 25 }
                }
            },
            "mono": {
                "family": "CaskaydiaCove NF",
                "large": {
                    "size": 16,
                    "weight": 400,
                    "italic": false,
                    "vaxes": {}
                },
                "medium": {
                    "size": 14,
                    "weight": 400,
                    "italic": false,
                    "vaxes": {}
                },
                "small": {
                    "size": 12,
                    "weight": 400,
                    "italic": false,
                    "vaxes": {}
                }
            },
            "icon": {
                "family": "Material Symbols Rounded",
                "extraLarge": {
                    "size": 36,
                    "weight": 400,
                    "italic": false,
                    "vaxes": {}
                },
                "large": {
                    "size": 24,
                    "weight": 400,
                    "italic": false,
                    "vaxes": {}
                },
                "medium": {
                    "size": 18,
                    "weight": 400,
                    "italic": false,
                    "vaxes": {}
                },
                "small": {
                    "size": 15,
                    "weight": 400,
                    "italic": false,
                    "vaxes": {}
                }
            }
        },
        "anim": {
            "durations": {
                "scale": 1
            }
        },
        "transparency": {
            "enabled": false,
            "base": 0.85,
            "layers": 0.4
        }
    },
    "general": {
        "logo": "",
        "showOverFullscreen": false,
        "mediaGifSpeedAdjustment": 300,
        "sessionGifSpeed": 0.7,
        "apps": {
            "terminal": ["foot"],
            "audio": ["pwvucontrol"],
            "playback": ["mpv"],
            "explorer": ["thunar"]
        },
        "idle": {
            "lockBeforeSleep": true,
            "inhibitWhenAudio": true,
            "inhibitWhenCharging": false,
            "timeouts": [
                {
                    "timeout": 180,
                    "idleAction": "lock",
                    "inhibitWhenAudio": false,
                    "inhibitWhenCharging": false,
                    "respectInhibitors": true
                },
                {
                    "timeout": 300,
                    "idleAction": "dpms off",
                    "returnAction": "dpms on"
                },
                {
                    "timeout": 600,
                    "idleAction": ["suspendThenHibernate"]
                }
            ]
        },
        "battery": {
            "warnLevels": [
                {
                    "level": 20,
                    "title": "Low battery",
                    "message": "You might want to plug in a charger",
                    "icon": "battery_android_frame_2"
                },
                {
                    "level": 10,
                    "title": "Did you see the previous message?",
                    "message": "You should probably plug in a charger <b>now</b>",
                    "icon": "battery_android_frame_1"
                },
                {
                    "level": 5,
                    "title": "Critical battery level",
                    "message": "PLUG THE CHARGER RIGHT NOW!!",
                    "icon": "battery_android_alert",
                    "critical": true
                }
            ],
            "criticalLevel": 3
        }
    },
    "background": {
        "enabled": true,
        "wallpaperEnabled": true,
        "desktopClock": {
            "enabled": false,
            "scale": 1.0,
            "position": "bottom-right",
            "invertColors": false,
            "background": {
                "enabled": false,
                "opacity": 0.7,
                "blur": true
            },
            "shadow": {
                "enabled": true,
                "opacity": 0.7,
                "blur": 0.4
            }
        },
        "visualiser": {
            "enabled": false,
            "autoHide": true,
            "blur": false,
            "rounding": 1,
            "spacing": 1
        }
    },
    "bar": {
        "persistent": true,
        "showOnHover": true,
        "dragThreshold": 20,
        "scrollActions": {
            "workspaces": true,
            "volume": true,
            "brightness": true
        },
        "popouts": {
            "activeWindow": true,
            "tray": true,
            "statusIcons": true
        },
        "workspaces": {
            "shown": 5,
            "activeIndicator": true,
            "occupiedBg": false,
            "showUnoccupied": true,
            "perMonitor": true,
            "showWindows": true,
            "showWindowsOnSpecialWorkspaces": true,
            "maxWindowIcons": 5,
            "activeTrail": false,
            "displayType": "shapes",
            "specialDisplayType": "icons",
            "label": "  ",
            "occupiedLabel": "󰮯",
            "activeLabel": "󰮯",
            "capitalisation": "preserve",
            "workspaceIcons": [],
            "specialWorkspaceIcons": [
                {
                    "name": "special",
                    "icon": "star"
                },
                {
                    "name": "communication",
                    "icon": "forum"
                },
                {
                    "name": "music",
                    "icon": "music_cast"
                },
                {
                    "name": "todo",
                    "icon": "checklist"
                },
                {
                    "name": "sysmon",
                    "icon": "monitor_heart"
                }
            ],
            "ignoredTags": ["hide_in_bar", "xwl_popup"],
            "windowIcons": [
                {
                    "regex": "steam(_app_(default|[0-9]+))?",
                    "icon": "sports_esports"
                }
            ]
        },
        "activeWindow": {
            "compact": false,
            "inverted": false,
            "showOnHover": true
        },
        "tray": {
            "background": false,
            "recolour": false,
            "compact": false,
            "iconSubs": [],
            "hiddenIcons": []
        },
        "clock": {
            "background": false,
            "showDate": false,
            "showIcon": true
        },
        "statusIcons": [
            {
                "id": "lockStatus",
                "enabled": true
            },
            {
                "id": "audio",
                "enabled": false
            },
            {
                "id": "microphone",
                "enabled": false
            },
            {
                "id": "kbLayout",
                "enabled": false
            },
            {
                "id": "network",
                "enabled": true
            },
            {
                "id": "bluetooth",
                "enabled": true
            },
            {
                "id": "battery",
                "enabled": true
            }
        ],
        "entries": [
            {
                "id": "logo",
                "enabled": true
            },
            {
                "id": "workspaces",
                "enabled": true
            },
            {
                "id": "spacer",
                "enabled": true
            },
            {
                "id": "activeWindow",
                "enabled": true
            },
            {
                "id": "spacer",
                "enabled": true
            },
            {
                "id": "tray",
                "enabled": true
            },
            {
                "id": "clock",
                "enabled": true
            },
            {
                "id": "statusIcons",
                "enabled": true
            },
            {
                "id": "power",
                "enabled": true
            }
        ],
        "excludedScreens": []
    },
    "border": {
        "thickness": 10,
        "rounding": 25,
        "smoothing": 20
    },
    "dashboard": {
        "enabled": true,
        "showOnHover": true,
        "showDashboard": true,
        "showMedia": true,
        "showPerformance": true,
        "showWeather": true,
        "mediaUpdateInterval": 500,
        "resourceUpdateInterval": 1000,
        "dragThreshold": 50,
        "performance": {
            "showBattery": true,
            "showGpu": true,
            "showCpu": true,
            "showMemory": true,
            "showStorage": true,
            "showNetwork": true
        }
    },
    "launcher": {
        "enabled": true,
        "showOnHover": false,
        "maxShown": 7,
        "maxWallpapers": 9,
        "specialPrefix": "@",
        "actionPrefix": ">",
        "enableDangerousActions": false,
        "dragThreshold": 50,
        "vimKeybinds": false,
        "favouriteApps": [],
        "hiddenApps": [],
        "useFuzzy": {
            "apps": false,
            "actions": false,
            "schemes": false,
            "variants": false,
            "wallpapers": false
        },
        "actions": [
            {
                "name": "Calculator",
                "icon": "calculate",
                "description": "Do simple math equations (powered by Qalc)",
                "command": ["autocomplete", "calc"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Scheme",
                "icon": "palette",
                "description": "Change the current colour scheme",
                "command": ["autocomplete", "scheme"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Wallpaper",
                "icon": "image",
                "description": "Change the current wallpaper",
                "command": ["autocomplete", "wallpaper"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Variant",
                "icon": "colors",
                "description": "Change the current scheme variant",
                "command": ["autocomplete", "variant"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Random",
                "icon": "casino",
                "description": "Switch to a random wallpaper",
                "command": ["caelestia", "wallpaper", "-r"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Light",
                "icon": "light_mode",
                "description": "Change the scheme to light mode",
                "command": ["setMode", "light"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Dark",
                "icon": "dark_mode",
                "description": "Change the scheme to dark mode",
                "command": ["setMode", "dark"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Shutdown",
                "icon": "power_settings_new",
                "description": "Shutdown the system",
                "command": ["poweroff"],
                "enabled": true,
                "dangerous": true
            },
            {
                "name": "Reboot",
                "icon": "cached",
                "description": "Reboot the system",
                "command": ["reboot"],
                "enabled": true,
                "dangerous": true
            },
            {
                "name": "Logout",
                "icon": "exit_to_app",
                "description": "Log out of the current session",
                "command": ["logout"],
                "enabled": true,
                "dangerous": true
            },
            {
                "name": "Lock",
                "icon": "lock",
                "description": "Lock the current session",
                "command": ["loginctl", "lock-session"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Sleep",
                "icon": "bedtime",
                "description": "Suspend then hibernate",
                "command": ["suspendThenHibernate"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Settings",
                "icon": "settings",
                "description": "Configure the shell",
                "command": ["caelestia", "shell", "nexus", "open"],
                "enabled": true,
                "dangerous": false
            }
        ]
    },
    "lock": {
        "enabled": true,
        "useWallpaper": false,
        "recolourLogo": true,
        "enableFprint": true,
        "maxFprintTries": 3,
        "enableHowdy": true,
        "maxHowdyTries": 3,
        "triggerHowdyOnWake": true,
        "hideNotifs": false,
        "enableSessionControls": true
    },
    "nexus": {
        "wallpapersPerRow": 4,
        "networkRescanInterval": 15000
    },
    "notifs": {
        "expire": true,
        "fullscreen": "On",
        "defaultExpireTimeout": 5000,
        "fullscreenExpireTimeout": 2000,
        "clearThreshold": 0.3,
        "expandThreshold": 20,
        "actionOnClick": false,
        "groupPreviewNum": 3,
        "openExpanded": false
    },
    "osd": {
        "enabled": true,
        "hideDelay": 2000,
        "enableBrightness": true,
        "enableMicrophone": false
    },
    "services": {
        "weatherLocation": "",
        "weatherUnits": "Auto",
        "sensorUnits": "Celsius",
        "dataUnits": "Binary",
        "clockFormat": "Auto",
        "gpuType": "Auto",
        "visualiserBars": 60,
        "audioIncrement": 0.1,
        "brightnessIncrement": 0.1,
        "maxVolume": 1.0,
        "smartScheme": true,
        "defaultPlayer": "Spotify",
        "playerAliases": [
            { "from": "com.github.th_ch.youtube_music", "to": "YT Music" }
        ],
        "lyricsBackend": "Auto"
    },
    "session": {
        "enabled": true,
        "dragThreshold": 30,
        "vimKeybinds": false,
        "icons": {
            "logout": "logout",
            "shutdown": "power_settings_new",
            "hibernate": "downloading",
            "reboot": "cached"
        },
        "commands": {
            "logout": ["logout"],
            "shutdown": ["poweroff"],
            "hibernate": ["hibernate"],
            "reboot": ["reboot"]
        }
    },
    "sidebar": {
        "enabled": true,
        "showOnHover": false,
        "minHoverThreshold": 200,
        "dragThreshold": 80
    },
    "utilities": {
        "enabled": true,
        "maxToasts": 4,
        "toasts": {
            "fullscreen": "off",
            "configLoaded": true,
            "chargingChanged": true,
            "gameModeChanged": true,
            "dndChanged": true,
            "audioOutputChanged": true,
            "audioInputChanged": true,
            "capsLockChanged": true,
            "numLockChanged": true,
            "kbLayoutChanged": true,
            "kbLimit": true,
            "vpnChanged": true,
            "nowPlaying": false
        },
        "vpn": {
            "enabled": false,
            "provider": [
                {
                    "name": "wireguard",
                    "interface": "your-connection-name",
                    "displayName": "WireGuard (Your VPN)"
                }
            ]
        },
        "quickToggles": [
            {
                "id": "wifi",
                "enabled": true
            },
            {
                "id": "bluetooth",
                "enabled": true
            },
            {
                "id": "mic",
                "enabled": true
            },
            {
                "id": "settings",
                "enabled": true
            },
            {
                "id": "gameMode",
                "enabled": true
            },
            {
                "id": "dnd",
                "enabled": true
            },
            {
                "id": "vpn",
                "enabled": false
            }
        ]
    },
    "paths": {
        "wallpaperDir": "~/Pictures/Wallpapers",
        "lyricsDir": "~/Music/lyrics/",
        "sessionGif": "root:/assets/kurukuru.gif",
        "mediaGif": "root:/assets/bongocat.gif",
        "noNotifsPic": "root:/assets/dino.png",
        "lockNoNotifsPic": "root:/assets/dino.png"
    }
}
```

</details>

### Advanced configuration

> [!CAUTION]
> Do NOT change any of these options unless you know what you are doing. These options control the
> tokens used internally within the shell, and can cause visual issues if modified incorrectly.
> The available options may change or be removed without notice across versions.

A separate `~/.config/caelestia/shell-tokens.json` file allows editing the internal tokens without
touching the source code of the shell. These tokens affect the dimensions and appearance of visual elements,
including individual rounding, spacing, padding, font size, animation durations and curves, and the sizes of
certain components. The appearance scale values in `shell.json` are multiplied against these base
token values to produce the final computed values.

Per-monitor token overrides are also available at
`~/.config/caelestia/monitors/<monitor_name>/shell-tokens.json`.

### Home Manager Module

This fork's flake provides a Mango package and Home Manager module. Add this repository as a flake input
and import its `homeManagerModules.default`. The module exposes the named `quickshell/caelestia` config,
so bundled IPC keybindings can find the running shell. Configure Mango separately and import the session
environment as shown above. Nix parsing, package evaluation, and build-plan resolution have been checked; a full Nix build has not been completed.

<details><summary><code>home.nix</code></summary>

```nix
programs.caelestia = {
  enable = true;
  systemd = {
    enable = false; # if you prefer starting from your compositor
    target = "graphical-session.target";
    environment = [];
  };
  settings = {
    bar.statusIcons = [
      { id = "lockStatus"; enabled = true; }
      { id = "network"; enabled = true; }
      { id = "bluetooth"; enabled = true; }
      { id = "battery"; enabled = false; }
    ];
    paths.wallpaperDir = "~/Images";
  };
  cli = {
    enable = true; # Also add caelestia-cli to path
    settings = {
      theme.enableGtk = false;
    };
  };
};
```

The module installs this fork's shell package. Its CLI support remains optional.

</details>

## FAQ

### Why MangoWC instead of Hyprland?

Great question! Some folks prefer MangoWC's wlroots-based approach, simpler architecture, or just want to try something different. This port makes Caelestia accessible to the MangoWC community while keeping all the beautiful design intact.

### Can I use this with Hyprland?

Nope! This fork is specifically adapted for MangoWC. If you want to use Hyprland, grab the [original Caelestia shell](https://github.com/caelestia-dots/shell) instead - it's fantastic!

### Window previews don't show live thumbnails!

The bar popout and window-info panel capture the selected window directly through Mango's standard Wayland capture protocols. Frames refresh at up to ten per second while visible; capture stops when it closes. `grim -T` remains a compatibility fallback at up to five frames per second. This captures window content directly, including content obscured by other windows.

Check that `mmsg get all-clients` includes `foreign_toplevel_id`. For the compatibility fallback, also check that `grim -h` lists `-T` for clients. Rebuild, install, and restart the shell after updating: the previews use a compiled `Caelestia.Images` component. If capture is unavailable, window titles and metadata still work. Older Mango or grim versions may need an upgrade.

### Notifications say a server is already registered

Only one process can own `org.freedesktop.Notifications`. Check the current owner:

```sh
busctl --user status org.freedesktop.Notifications
```

If it reports `dms.service`, Dank Linux Shell already owns notifications. To use Caelestia as your shell,
stop DMS with `systemctl --user stop dms.service` and remove its autostart entry if you no longer want it.
For other owners such as Mako, Dunst, or SwayNC, stop the corresponding notification daemon.
Quickshell retries registration when the existing owner exits.

### Audio shows only Dummy Output

Check `wpctl status` and `pactl list cards`. If the hardware card exists but its active profile is `off`,
select an available speaker or headphone profile, then select that output as the default.
Caelestia displays the outputs provided by PipeWire; it cannot create missing hardware outputs.
If profile activation fails, check `journalctl --user -u pipewire -u wireplumber` and the login session's
permissions on `/dev/snd`. A previous permission failure can leave the card switched off even after
access has been restored.

### Qt text-input warnings on focus changes

A `qt.qpa.wayland.textinput` warning can still appear when Qt's text-input surface state and keyboard
focus change at different times. The launcher avoids redundant focus requests and has been tested
for automatic typing focus on first open and reopen. The remaining `disableSurface` warning was
reproduced during testing; it has not been eliminated. Do not disable input-method support just to hide it.

The same warning reproduces with a plain Qt `TextInput` in a minimal Quickshell layer window,
without Caelestia components, both with a persistent input and with one recreated on each open.
Run `qs -p tests/qt-text-input-repro.qml` in Mango to reproduce it (it briefly acquires keyboard focus).

The upstream [Qt input context](https://github.com/qt/qtbase/blob/dev/src/plugins/platforms/wayland/qwaylandinputcontext.cpp)
disables the previous surface when the focus object changes; the
[text-input-v3 implementation](https://github.com/qt/qtbase/blob/dev/src/plugins/platforms/wayland/qwaylandtextinputv3.cpp)
warns when its tracked focused surface differs. This points to Qt/Wayland focus ordering rather than a missing Mango binding.

### Workspace clicks work only once

Update and reinstall this fork, then restart Caelestia. The adapter uses `viewcrossmon` to target known workspaces and `view` as a fallback;
`comboview` retains keyboard-combination state and can accumulate tags across mouse clicks.
See the [Mango dispatcher reference](https://mangowm.github.io/docs/bindings/keys/).

### Updates are installed but the old warnings remain

Check the configuration path printed at launch. A user copy can override the system installation.
Also rebuild and install the C++ plugins, then restart Quickshell; copying QML alone does not update them.

### How does screen recording work?

Screen recording uses `gpu-screen-recorder` and `slurp` for region selection. The Utilities drawer supports fullscreen or region recording, each with optional system audio. Escape cancels region selection; starting and selecting states prevent duplicate recordings. Pause/resume and stop controls appear while recording. Ensure `gpu-screen-recorder` and `slurp` are installed. Recordings are saved to `~/Videos/Recordings` (configurable via `CAELESTIA_RECORDINGS_DIR`) and can be managed or played back directly from the Utilities drawer.

The helper detects the system-audio device alias supported by the installed
`gpu-screen-recorder`, including both `default_output` and the older
`defaultoutput` spelling.

IPC also supports region recording with sound:

```sh
qs ipc -c caelestia call recorder toggle region-sound
```

### My screen is flickering!

Try tweaking MangoWC's refresh rate settings or disabling any compositor effects that might conflict with the shell's layer surfaces.

### I want to make my own changes!

The shell is installed to `/etc/xdg/quickshell/caelestia`. You can edit these files directly (you'll need sudo access) or copy the entire directory to `~/.config/quickshell/caelestia` for user-specific modifications. Quickshell will prefer the user config if it exists.

### I want to disable \_\_\_ feature!

Please read the [configuring](#configuring) section.
If there is no corresponding option, make a [feature request](https://github.com/evoziosk/caelestia-shell-mango/issues/new).

### How do I make my colour scheme change to match my wallpaper?

Select **dynamic** through `>scheme` in the launcher. Fixed schemes such as Catppuccin Mocha
intentionally keep their colours when the wallpaper changes. Installing Matugen alone does not
switch a previously selected fixed scheme to dynamic.

Set a wallpaper via `>wallpaper` in the launcher or `caelestia wallpaper`, and set the scheme to the dynamic scheme via
`>scheme` in the launcher or `caelestia scheme set`, e.g.:

```sh
caelestia wallpaper -f <path_to_wallpaper>
caelestia scheme set -n dynamic
```

Without caelestia-cli, install Matugen and select `dynamic` through `>scheme` in the launcher.
Wallpaper changes and previews then generate Material colours directly. Use `>variant` to choose a
Material variant and the dashboard's light/dark control to change mode. The helper runs Matugen with
`--dry-run`, so it does not execute your Matugen templates, hooks, or wallpaper commands.
Built-in named schemes and application theme generation work without caelestia-cli.
The native backend also accepts user palettes in
`~/.config/caelestia/schemes/*.json` (the same `name`, `flavour`, `mode`, `colours`
format as `scheme.json`). It generates GTK, Alacritty, Kitty, foot, fuzzel and btop
themes in `~/.config/caelestia/themes` and adds includes to existing app configs (or creates defaults for installed apps).
Original configs are backed up once with `.before-caelestia-theme`; managed
symlink configs are preserved. Generated GTK colour definitions are imported by
GTK 3 and GTK 4. Local app colour overrides retain precedence. Apps may require
reopening to load a changed palette. This does not modify browser or editor themes.

The launcher Settings and Random wallpaper actions use native shell functions.
Display idle off/on uses Wayland output power management, without `hyprctl` or an
extra power-control utility. Recorder state is tracked even with drawers closed;
stop/pause signals only the recorder started by this shell, including after reload.

Mango has no Hyprland window-tag API. The bar supports app IDs (including trailing
`*` prefix matches) in `bar.workspaces.ignoredTags`. To assign filtering tags,
configure `bar.workspaces.tagRules` globally, for example:

```json
{"bar": {"workspaces": {"tagRules": {"steam_app_*": ["hide_in_bar"]}}}}
```

Window details show first-observed metadata: windows already open when the shell
starts cannot provide their original creation-time title. Named special workspaces
remain one native special overlay per output; named scratchpads contain individual
apps. Alpha-threshold blur remains conditional on compositor protocol/features.

### My wallpapers aren't showing up in the launcher!

The launcher reads wallpapers from `~/Pictures/Wallpapers` by default; change `paths.wallpaperDir` to use another directory. The carousel shows an odd number of previews at once. With two matching files it shows one preview at a time; both files remain selectable.

## Validation

Previous integration checks on Mango 0.18.0 and the development Quickshell/Qt stack are listed below. These describe the tested setup, not a guarantee for every compositor version or hardware configuration:

- Build and native keyboard tests covering two layouts, layout-group changes, Caps Lock, and Num Lock.
- Native pin/unpin on a disposable window, repeated workspace switching, special-overlay move/return,
  and cross-output moves using a temporary virtual output.
- Multi-output hotplug, unique workspace IDs, focused-screen routing, and shortcut registry discovery.
- Game-mode gap changes confirmed through window geometry and restored to configured values.
- Real pointer clicks inside the launcher and outside the launcher/detached window-info popout.
- Live blur enable/disable updates, native surface recreation, and preserved launcher state/focus.
- Native window capture, missing-icon fallbacks, and first-open/reopen launcher focus.
- Dynamic palettes with the CLI unavailable: saved dark/light modes, wallpaper previews, variant
  changes, and replacement of outdated requests. Both legacy and current Matugen JSON formats are tested.
- A change to the saved wallpaper path regenerated a visibly different palette without the CLI;
  a subsequent light-mode request stayed applied after debounce. All 14 reported file/folder icons loaded
  without missing-icon warnings. The standalone Qt focus warning remains reproducible.
- Installer prerequisite checks and a mocked interactive build/install flow; Mango config backups,
  repeated setup, source-file bindings, key conflicts, and managed-config preservation.
- Full-profile workspace arithmetic/bounds, native dispatch encoding, common-mode/mouse/scroll
  conflict replacement, snapshot idempotence, and preserved dynamic sources. Mango's `-p` config
  checker accepts a full-profile migration of the tested configuration; recording IPC loads without errors.
- Window normalization and picture-in-picture were verified on a disposable Mango window, including
  size, floating state, pinning, and placement. Native group joining, member cycling, and leaving
  were verified on two disposable windows in an otherwise empty tag.

The latest port regression run passed 37 Python tests, the JavaScript model checks, and the headless QML service check. See [port regression checks](#port-regression-checks) for commands. The QML check covers simulated multiple outputs, visible/pinned clients, monitor-targeted special-tag commands, and game-mode restoration after both reload notification paths.

`tests/test_keyboardstate.cpp` also tests the compiled keyboard component with synthetic XKB keymaps.
Nix parsing, package evaluation, and build-plan resolution have been checked. The earlier full-build attempt was blocked by space in the temporary test store; download and unpacked sizes depend on the flake revision and cache. A full Nix build and all hardware configurations have not been verified.

## Credits & Appreciation

### The Real MVPs

**MASSIVE thanks to [@Soramane](https://github.com/soramane)** for creating the original Caelestia shell! This project is absolutely stunning, and it's been an honor to adapt it for MangoWC. Seriously, if you appreciate this work, go [support them on Ko-Fi](https://ko-fi.com/soramane) - they deserve all the love! ❤️

The entire [Caelestia project](https://github.com/caelestia-dots) is a masterclass in design and polish. Check out their work!

### Technology & Community

Huge thanks to:

- **[@outfoxxed](https://github.com/outfoxxed)** for creating and maintaining [Quickshell](https://quickshell.outfoxxed.me), and for patiently implementing features and fixing bugs that make projects like this possible
- **The MangoWC developers** for building a solid wlroots-based compositor
- **[@end_4](https://github.com/end-4)** for their [config](https://github.com/end-4/dots-hyprland) which served as inspiration for the original Caelestia
- **The Hyprland discord community** (especially the homies in #rice-discussion) for all the help, feedback, and ongoing inspiration

### Original Inspirations

The original Caelestia shell took inspiration from:
- [Axenide/Ax-Shell](https://github.com/Axenide/Ax-Shell)

---

> [!NOTE]
> This MangoWC port is a community effort and is **not officially affiliated** with the Caelestia project. For the original, Hyprland-optimized version, please visit [caelestia-dots/shell](https://github.com/caelestia-dots/shell).

## Stonks 📈

<a href="https://www.star-history.com/#evoziosk/caelestia-shell-mango&Date">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=evoziosk/caelestia-shell-mango&type=Date&theme=dark" />
        <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=evoziosk/caelestia-shell-mango&type=Date" />
        <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=evoziosk/caelestia-shell-mango&type=Date" />
    </picture>
</a>

[dots-repo]: https://github.com/caelestia-dots/caelestia
[discord]: https://caelestiashell.com/discord
