<h1 align=center>caelestia-shell (MangoWC Port)</h1>

<div align=center>

![GitHub last commit](https://img.shields.io/github/last-commit/caelestia-dots/shell?style=for-the-badge&labelColor=101418&color=9ccbfb)
![GitHub Repo stars](https://img.shields.io/github/stars/caelestia-dots/shell?style=for-the-badge&labelColor=101418&color=b9c8da)
![GitHub repo size](https://img.shields.io/github/repo-size/caelestia-dots/shell?style=for-the-badge&labelColor=101418&color=d3bfe6)
[![Ko-Fi donate](https://img.shields.io/badge/donate-kofi?style=for-the-badge&logo=ko-fi&logoColor=ffffff&label=ko-fi&labelColor=101418&color=f16061&link=https%3A%2F%2Fko-fi.com%2Fsoramane)](https://ko-fi.com/soramane)

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
- **Window Management**: Replaced Hyprland's native window tracking with Wayland's `ToplevelManager` protocol for workspace and window information
- **Input Masking**: Carefully tuned Region-based input masks to maintain click-through transparency on the desktop while keeping panels and bars interactive
- **Blur Control**: Disabled blur effects for crisp rendering with MangoWC's layer shell
- **Feature Adaptation**: Disabled features that rely on Hyprland-specific protocols (like screencopy-based window previews and gpu-screen-recorder integration)

### What Still Works?

Pretty much everything! 🚀

- ✅ All panels (bar, dashboard, utilities, OSD, sidebar)
- ✅ Hover detection and auto-hide behaviors
- ✅ Workspaces and window tracking
- ✅ Media controls (MPRIS)
- ✅ Network, battery, brightness, audio controls
- ✅ Launcher with app search
- ✅ Notification system
- ✅ Lock screen
- ✅ System tray
- ✅ Wallpaper management
- ✅ Color scheme switching

### What Doesn't Work (Yet)?

- ❌ Window preview thumbnails (MangoWC's screencopy protocol needs work)
- ❌ Screen recording feature (gpu-screen-recorder configuration needs adaptation)

## Components

-   Widgets: [`Quickshell`](https://quickshell.outfoxxed.me)
-   Compositor: [`MangoWC`](https://github.com/jvl-13/MangoWC) (originally [`Hyprland`](https://hyprland.org))
-   Original Dots: [`caelestia`](https://github.com/caelestia-dots)

## Special Thanks

**Huge shoutout and massive thanks to [@Soramane](https://github.com/soramane)** and the entire Caelestia project for creating such an incredible, polished, and beautiful shell! This port wouldn't exist without their amazing work. If you love this shell, please consider [supporting them on Ko-Fi](https://ko-fi.com/soramane)! 💙

Also huge thanks to:
- [@outfoxxed](https://github.com/outfoxxed) for creating and maintaining Quickshell
- The MangoWC developers for building a solid wlroots compositor
- The Hyprland discord community for ongoing inspiration and help

## Installation

> [!IMPORTANT]
> This MangoWC port requires manual installation. The AUR package and Nix flake from the original project are **not compatible** with this fork as they're designed for Hyprland.

### Prerequisites for MangoWC

Before installing the shell, make sure you have MangoWC properly set up:

1. **MangoWC Compositor**: Install and configure MangoWC ([GitHub repo](https://github.com/jvl-13/MangoWC))
2. **MangoWC Layer Rules**: Add these to your `~/.config/mango/rule.conf` to disable blur on shell surfaces:
   ```
   noblur:1 caelestia
   ```

### Manual Installation (MangoWC)

Dependencies:

-   [`caelestia-cli`](https://github.com/caelestia-dots/cli) (optional but recommended)
-   [`quickshell-git`](https://quickshell.outfoxxed.me) - **must be the git version**, not the latest tagged version
-   `mangowc` - The MangoWC compositor with `mmsg` IPC support
-   [`ddcutil`](https://github.com/rockowitz/ddcutil)
-   [`brightnessctl`](https://github.com/Hummer12007/brightnessctl)
-   [`app2unit`](https://github.com/Vladimir-csp/app2unit)
-   [`libcava`](https://github.com/LukashonakV/cava)
-   [`networkmanager`](https://networkmanager.dev)
-   [`lm-sensors`](https://github.com/lm-sensors/lm-sensors)
-   [`fish`](https://github.com/fish-shell/fish-shell)
-   [`aubio`](https://github.com/aubio/aubio)
-   [`libpipewire`](https://pipewire.org)
-   `glibc`
-   `qt6-declarative`
-   `gcc-libs`
-   [`material-symbols`](https://fonts.google.com/icons)
-   [`caskaydia-cove-nerd`](https://www.nerdfonts.com/font-downloads)
-   [`swappy`](https://github.com/jtheoof/swappy)
-   [`libqalculate`](https://github.com/Qalculate/libqalculate)
-   [`bash`](https://www.gnu.org/software/bash)
-   `qt6-base`
-   `qt6-declarative`

Build dependencies:

-   [`cmake`](https://cmake.org)
-   [`ninja`](https://github.com/ninja-build/ninja)

To install the shell manually, install all dependencies and clone this repo (or your fork). Then build and install using `cmake`.

```sh
# Clone the repository
git clone https://github.com/YOUR-USERNAME/caelestia.git
cd caelestia

# Build and install
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/
cmake --build build
sudo cmake --install build
```

This will install the shell to `/etc/xdg/quickshell/caelestia` systemwide.

> [!TIP]
> You can customise the installation location via the `cmake` flags `INSTALL_LIBDIR`, `INSTALL_QMLDIR` and
> `INSTALL_QSCONFDIR` for the libraries (the beat detector), QML plugin and Quickshell config directories
> respectively. If changing the library directory, remember to set the `CAELESTIA_LIB_DIR` environment
> variable to the custom directory when launching the shell.
>
> e.g. installing to `~/.config/quickshell/caelestia` for easy local changes:
>
> ```sh
> mkdir -p ~/.config/quickshell/caelestia
> cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/ -DINSTALL_QSCONFDIR=~/.config/quickshell/caelestia
> cmake --build build
> sudo cmake --install build
> sudo chown -R $USER ~/.config/quickshell/caelestia
> ```

## Usage

The shell can be started via `qs -c caelestia` or by launching Quickshell with the config path.

### Starting with MangoWC

To autostart the shell with MangoWC, add this to your MangoWC config:

```
exec-once = qs -c caelestia
```

Or if using caelestia-cli:

```
exec-once = caelestia shell -d
```

### Shortcuts/IPC

> [!NOTE]
> MangoWC doesn't support Hyprland's global shortcuts via DBus. You'll need to configure keybinds directly in your MangoWC config using `mmsg` commands or by invoking the caelestia CLI.

Example MangoWC keybinds for common shell functions:

```
# Toggle launcher
bind = SUPER, SPACE, exec, caelestia shell drawers toggle launcher

# Toggle dashboard
bind = SUPER, D, exec, caelestia shell drawers toggle dashboard

# Toggle utilities
bind = SUPER, U, exec, caelestia shell drawers toggle utilities

# Lock screen
bind = SUPER, L, exec, caelestia shell lock lock

# Screenshot picker
bind = , PRINT, exec, caelestia shell picker open
```

All IPC commands can be accessed via `caelestia shell ...` if you have caelestia-cli installed. For example:

```sh
caelestia shell mpris getActive trackTitle
```

The list of IPC commands can be shown via `caelestia shell -s`:

```
$ caelestia shell -s
target drawers
  function toggle(drawer: string): void
  function list(): string
target notifs
  function clear(): void
target lock
  function lock(): void
  function unlock(): void
  function isLocked(): bool
target mpris
  function playPause(): void
  function getActive(prop: string): string
  function next(): void
  function stop(): void
  function play(): void
  function list(): string
  function pause(): void
  function previous(): void
target picker
  function openFreeze(): void
  function open(): void
target wallpaper
  function set(path: string): void
  function get(): string
  function list(): string
```

### PFP/Wallpapers

The profile picture for the dashboard is read from the file `~/.face`, so to set
it you can copy your image to there or set it via the dashboard.

The wallpapers for the wallpaper switcher are read from `~/Pictures/Wallpapers`
by default. To change it, change the wallpapers path in `~/.config/caelestia/shell.json`.

To set the wallpaper, you can use the command `caelestia wallpaper`. Use `caelestia wallpaper -h` for more info about
the command.

## Updating

To update your installation, pull the latest changes and rebuild:

```sh
cd /path/to/caelestia
git pull
cmake --build build
sudo cmake --install build
```

Then restart Quickshell to load the updated shell.

## Configuring

All configuration options should be put in `~/.config/caelestia/shell.json`. This file is _not_ created by
default, you must create it manually.

### Example configuration

> [!NOTE]
> The example configuration only includes recommended configuration options. For more advanced customisation
> such as modifying the size of individual items or changing constants in the code, there are some other
> options which can be found in the source files in the `config` directory.

<details><summary>Example</summary>

```json
{
    "appearance": {
        "anim": {
            "durations": {
                "scale": 1
            }
        },
        "font": {
            "family": {
                "clock": "Rubik",
                "material": "Material Symbols Rounded",
                "mono": "CaskaydiaCove NF",
                "sans": "Rubik"
            },
            "size": {
                "scale": 1
            }
        },
        "padding": {
            "scale": 1
        },
        "rounding": {
            "scale": 1
        },
        "spacing": {
            "scale": 1
        },
        "transparency": {
            "enabled": false,
            "base": 0.85,
            "layers": 0.4
        }
    },
    "general": {
        "apps": {
            "terminal": ["foot"],
            "audio": ["pavucontrol"],
            "playback": ["mpv"],
            "explorer": ["thunar"]
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
        },
        "idle": {
            "lockBeforeSleep": true,
            "inhibitWhenAudio": true,
            "timeouts": [
                {
                    "timeout": 180,
                    "idleAction": "lock"
                },
                {
                    "timeout": 300,
                    "idleAction": "dpms off",
                    "returnAction": "dpms on"
                },
                {
                    "timeout": 600,
                    "idleAction": ["systemctl", "suspend-then-hibernate"]
                }
            ]
        }
    },
    "background": {
        "desktopClock": {
            "enabled": false
        },
        "enabled": true,
        "visualiser": {
            "blur": false,
            "enabled": false,
            "autoHide": true,
            "rounding": 1,
            "spacing": 1
        }
    },
    "bar": {
        "clock": {
            "showIcon": true
        },
        "dragThreshold": 20,
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
        "persistent": true,
        "popouts": {
            "activeWindow": true,
            "statusIcons": true,
            "tray": true
        },
        "scrollActions": {
            "brightness": true,
            "workspaces": true,
            "volume": true
        },
        "showOnHover": true,
        "status": {
            "showAudio": false,
            "showBattery": true,
            "showBluetooth": true,
            "showKbLayout": false,
            "showMicrophone": false,
            "showNetwork": true,
            "showLockStatus": true
        },
        "tray": {
            "background": false,
            "compact": false,
            "iconSubs": [],
            "recolour": false
        },
        "workspaces": {
            "activeIndicator": true,
            "activeLabel": "󰮯",
            "activeTrail": false,
            "label": "  ",
            "occupiedBg": false,
            "occupiedLabel": "󰮯",
            "perMonitorWorkspaces": true,
            "showWindows": true,
            "shown": 5,
            "specialWorkspaceIcons": [
                {
                    "name": "steam",
                    "icon": "sports_esports"
                }
            ]
        }
    },
    "border": {
        "rounding": 25,
        "thickness": 10
    },
    "dashboard": {
        "enabled": true,
        "dragThreshold": 50,
        "mediaUpdateInterval": 500,
        "showOnHover": true
    },
    "launcher": {
        "actionPrefix": ">",
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
                "name": "Transparency",
                "icon": "opacity",
                "description": "Change shell transparency",
                "command": ["autocomplete", "transparency"],
                "enabled": false,
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
                "command": ["systemctl", "poweroff"],
                "enabled": true,
                "dangerous": true
            },
            {
                "name": "Reboot",
                "icon": "cached",
                "description": "Reboot the system",
                "command": ["systemctl", "reboot"],
                "enabled": true,
                "dangerous": true
            },
            {
                "name": "Logout",
                "icon": "exit_to_app",
                "description": "Log out of the current session",
                "command": ["loginctl", "terminate-user", ""],
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
                "command": ["systemctl", "suspend-then-hibernate"],
                "enabled": true,
                "dangerous": false
            }
        ],
        "dragThreshold": 50,
        "vimKeybinds": false,
        "enableDangerousActions": false,
        "maxShown": 7,
        "maxWallpapers": 9,
        "specialPrefix": "@",
        "useFuzzy": {
            "apps": false,
            "actions": false,
            "schemes": false,
            "variants": false,
            "wallpapers": false
        },
        "showOnHover": false,
        "hiddenApps": []
    },
    "lock": {
        "recolourLogo": false
    },
    "notifs": {
        "actionOnClick": false,
        "clearThreshold": 0.3,
        "defaultExpireTimeout": 5000,
        "expandThreshold": 20,
        "expire": false
    },
    "osd": {
        "enabled": true,
        "enableBrightness": true,
        "enableMicrophone": false,
        "hideDelay": 2000
    },
    "paths": {
        "mediaGif": "root:/assets/bongocat.gif",
        "sessionGif": "root:/assets/kurukuru.gif",
        "wallpaperDir": "~/Pictures/Wallpapers"
    },
    "services": {
        "audioIncrement": 0.1,
        "maxVolume": 1.0,
        "defaultPlayer": "Spotify",
        "gpuType": "",
        "playerAliases": [{ "from": "com.github.th_ch.youtube_music", "to": "YT Music" }],
        "weatherLocation": "",
        "useFahrenheit": false,
        "useTwelveHourClock": false,
        "smartScheme": true,
        "visualiserBars": 45
    },
    "session": {
        "dragThreshold": 30,
        "enabled": true,
        "vimKeybinds": false,
        "commands": {
            "logout": ["loginctl", "terminate-user", ""],
            "shutdown": ["systemctl", "poweroff"],
            "hibernate": ["systemctl", "hibernate"],
            "reboot": ["systemctl", "reboot"]
        }
    },
    "sidebar": {
        "dragThreshold": 80,
        "enabled": true
    },
    "utilities": {
        "enabled": true,
        "maxToasts": 4,
        "toasts": {
            "audioInputChanged": true,
            "audioOutputChanged": true,
            "capsLockChanged": true,
            "chargingChanged": true,
            "configLoaded": true,
            "dndChanged": true,
            "gameModeChanged": true,
            "kbLayoutChanged": true,
            "numLockChanged": true,
            "vpnChanged": true,
            "nowPlaying": false
        },
        "vpn": {
            "enabled": false,
            "provider": [
                {
                    "name": "wireguard",
                    "interface": "your-connection-name",
                    "displayName": "Wireguard (Your VPN)"
                }
            ]
        }
    }
}
```

</details>

### Home Manager Module

For NixOS users, a home manager module is also available.

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
    bar.status = {
      showBattery = false;
    };
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

The module automatically adds Caelestia shell to the path with **full functionality**. The CLI is not required, however you have the option to enable and configure it.

</details>

## FAQ

### Why MangoWC instead of Hyprland?

Great question! Some folks prefer MangoWC's wlroots-based approach, simpler architecture, or just want to try something different. This port makes Caelestia accessible to the MangoWC community while keeping all the beautiful design intact.

### Can I use this with Hyprland?

Nope! This fork is specifically adapted for MangoWC. If you want to use Hyprland, grab the [original Caelestia shell](https://github.com/caelestia-dots/shell) instead - it's fantastic!

### Window previews don't work!

Yeah, that's a known limitation. MangoWC's screencopy protocol implementation needs more work before window previews can function properly. The window info panel is still there, just without thumbnails.

### Screen recording button is missing!

I've disabled the screen recording feature since gpu-screen-recorder configuration for MangoWC needs adaptation. This might come in a future update!

### My screen is flickering!

Try tweaking MangoWC's refresh rate settings or disabling any compositor effects that might conflict with the shell's layer surfaces.

### I want to make my own changes!

The shell is installed to `/etc/xdg/quickshell/caelestia`. You can edit these files directly (you'll need sudo access) or copy the entire directory to `~/.config/quickshell/caelestia` for user-specific modifications. Quickshell will prefer the user config if it exists.

### I want to disable XXX feature!

Please read the [configuring](https://github.com/caelestia-dots/shell?tab=readme-ov-file#configuring) section in the readme.
If there is no corresponding option, make feature request.

### How do I make my colour scheme change with my wallpaper?

Set a wallpaper via the launcher and set the scheme to the dynamic scheme. If you have caelestia-cli installed:

```sh
caelestia wallpaper -f <path/to/file>
caelestia scheme set -n dynamic
```

Without caelestia-cli, you can use the launcher (Super + Space) to search for wallpapers and schemes!

### My wallpapers aren't showing up in the launcher!

The launcher pulls wallpapers from `~/Pictures/Wallpapers` by default. You can change this in the config. Additionally,
the launcher only shows an odd number of wallpapers at one time. If you only have 2 wallpapers, consider getting more
(or just putting one).

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
-   [Axenide/Ax-Shell](https://github.com/Axenide/Ax-Shell)

---

> [!NOTE]
> This MangoWC port is a community effort and is **not officially affiliated** with the Caelestia project. For the original, Hyprland-optimized version, please visit [caelestia-dots/shell](https://github.com/caelestia-dots/shell).

## Stonks 📈

<a href="https://www.star-history.com/#caelestia-dots/shell&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=caelestia-dots/shell&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=caelestia-dots/shell&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=caelestia-dots/shell&type=Date" />
 </picture>
</a>
