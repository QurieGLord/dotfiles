<div align="center">

# 🌙 Qurie's Noctalia-Niri Rice

**Fully customized Wayland desktop based on Noctalia Shell + Niri for CachyOS**

![Screenshot 1](qn1.png)

[![Made with Claude](https://img.shields.io/badge/Made%20with-Claude-7C3AED?style=flat-square&logo=anthropic)](https://claude.ai/claude-code)
[![Noctalia Shell](https://img.shields.io/badge/Shell-Noctalia-blue?style=flat-square)](https://github.com/noctalia-dev/noctalia-shell)
[![Niri](https://img.shields.io/badge/Compositor-Niri-orange?style=flat-square)](https://github.com/YaLTeR/niri)
[![CachyOS](https://img.shields.io/badge/OS-CachyOS-green?style=flat-square)](https://cachyos.org/)

</div>

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🎨 Theming
- **Automatic color scheme generation** from wallpapers via matugen
- **Universal support** for Qt5, Qt6, GTK3, GTK4, Firefox/Zen (Pywalfox), Kitty
- **10+ preset schemes**: Kanagawa, Catppuccin, Gruvbox, Solarized, Monochrome, and more
- **Instant application** when changing wallpapers or schemes

</td>
<td width="50%">

### 🚀 Performance
- **Niri compositor** — modern tiling Wayland window manager
- **GPU Screen Recorder** — built-in hardware-accelerated screen recording
- **NVIDIA Wayland optimizations** — full NVIDIA GPU support on Wayland
- **Fast animations** and smooth performance on any hardware

</td>
</tr>
<tr>
<td width="50%">

### 🛠️ Fixes and Improvements
- ✅ **Fixed Qt integration** — added `custom_palette=true` to qt5ct/qt6ct
- ✅ **Fixed GTK3 theming** — auto-generation of custom theme with hardcoded colors
- ✅ **Added missing `scrim` color** for predefined schemes
- ✅ **Universal GTK template** — works for both GTK3 and GTK4 without artifacts

</td>
<td width="50%">

### 🎯 UI/UX
- **Widget-based bar system** — fully customizable top panel
- **Application dock** — beautiful dock with auto-hide
- **Advanced launcher** — fuzzy search, launch history, pinned apps
- **Control Center** — quick settings for Wi-Fi, Bluetooth, Brightness, Power Profile

</td>
</tr>
</table>

---

## 🖼️ Screenshots

<details>
<summary><b>Click to view screenshots</b></summary>

![Screenshot 1](qn1.png)
*Main desktop with Noctalia Bar and active windows*

![Screenshot 2](qn2.png)
*Application launcher with fuzzy search*

![Screenshot 3](qn3.png)
*Control Center with quick settings*

</details>

---

## 🚀 Quick Installation

```bash
# Clone the repository
git clone https://github.com/QurieGLord/Quries-Noctalia-Niri.git ~/dotfiles
cd ~/dotfiles

# Make installer executable
chmod +x install.sh

# Run the installer
./install.sh
```

The installer supports **3 modes**:
1. **Full installation** — install all modules (base + NVIDIA + Qt + GTK)
2. **Selective installation** — choose individual modules
3. **Config update only** — update configs without reinstalling packages

---

## 📦 Installation Modules

### 🔹 Base Module
Base installation of Noctalia Shell + Niri + dependencies:
- Noctalia Shell (AUR), Niri compositor
- Kitty terminal, Nautilus file manager
- Brightnessctl, ddcutil, gpu-screen-recorder
- Matugen-bin, cliphist, wlsunset
- Icon themes: Tela-nord-dark, Papirus-Dark
- Fonts: Roboto, Inter, JetBrains Mono Nerd Font, DejaVu Sans Mono

**Includes applying patches**:
- `AppThemeService.qml` — fixed theme service with GTK3 generation
- `gtk.css` — universal template with CSS selectors for GTK3/GTK4

### 🔹 NVIDIA Module
NVIDIA Wayland optimizations:
- Drivers: nvidia-dkms, nvidia-utils, nvidia-settings, libva-nvidia-driver
- Environment variables: `GBM_BACKEND=nvidia-drm`, `__GLX_VENDOR_LIBRARY_NAME=nvidia`
- Kernel modules: `nvidia-drm modeset=1`, `NVreg_PreserveVideoMemoryAllocations=1`
- Automatic initramfs update

### 🔹 Qt Integration Module
Qt5/Qt6 installation and configuration:
- Packages: qt5-base, qt6-base, qt5ct, qt6ct
- **Critical fix**: `custom_palette=true` in both configs
- Environment variables setup: `QT_QPA_PLATFORMTHEME=qt6ct`
- Config verification

### 🔹 GTK Integration Module
GTK3/GTK4 installation:
- Packages: gtk3, gtk4, libadwaita
- Test applications: qalculate-gtk, gnome-calculator
- Config copying, creating custom Noctalia GTK3 theme
- Gsettings configuration: gtk-theme, icon-theme, color-scheme
- Verification

---

## 🛠️ Technical Details

### Fixes in Noctalia Shell

#### 1. AppThemeService.qml
**Location**: `patches/noctalia-shell/AppThemeService.qml`

**Changes**:
- **Lines 200-201**: Added missing `scrim = "#000000"` color (critical for predefined schemes)
- **Line 234**: Added `"scrim": c(scrim)` key to palette object
- **Lines 255-289**: New `generateGtk3Theme()` function — auto-generates custom GTK3 theme with hardcoded colors (without CSS variables, as GTK3 doesn't understand them)

**Effect**: Now when changing color scheme, `~/.themes/Noctalia/gtk-3.0/gtk.css` is automatically created with direct colors for all widgets (window, sidebar, headerbar, buttons, entries, lists, menus, notebooks, tabs, frames, scrollbars, toolbars, switches, checkboxes, progress bars, dialogs, labels).

#### 2. Assets/MatugenTemplates/gtk.css
**Change**: Extended GTK template with ~30 types of CSS selectors for GTK3 widgets.

**Critical**: Styles for `popover, popover.background` are **NOT added** — they break backdrop rendering in GTK4!

**Size**: 339 lines (CSS variables for GTK4 + direct selectors for GTK3)

**Effect**: One template works for both GTK3 and GTK4 without artifacts and white squares behind context menus.

#### 3. Qt5ct/Qt6ct configuration
**Change**: Set `custom_palette=true` in `qt5ct.conf` and `qt6ct.conf`.

**Root cause of the problem**: By default `custom_palette=false`, which made Qt apps ignore `color_scheme_path` and not apply colors from `~/.config/qt{5,6}ct/colors/noctalia.conf`.

**Effect**: Qt5/Qt6 apps now correctly apply colors from Noctalia on launch.

---

### Supported Applications

| Type | Applications | Theming Mechanism |
|-----|-----------|-------------------|
| **Qt6** | Noctalia Shell, qt6ct | `~/.config/qt6ct/colors/noctalia.conf` + `custom_palette=true` |
| **Qt5** | Telegram Desktop, qt5ct | `~/.config/qt5ct/colors/noctalia.conf` + `custom_palette=true` |
| **GTK4** | Nautilus, Calculator, pwvucontrol | Material Design variables + `org.gnome.desktop.interface color-scheme` via xdg-desktop-portal-gnome |
| **GTK3** | Lutris, qalculate-gtk | Custom theme `~/.themes/Noctalia/gtk-3.0/gtk.css` with hardcoded colors |
| **Firefox/Zen** | Zen Browser, Firefox | Pywalfox + `~/.cache/wal/colors.json` (requires extension installation) |
| **Kitty** | Kitty Terminal | `~/.config/kitty/current-theme.conf` (monitors changes via inotify) |

---

## 🎨 Color Schemes

### Preset Schemes
- **Kanagawa** — dark scheme inspired by Japanese paintings
- **Catppuccin** — soft pastel tones
- **Gruvbox** — retro warm palette
- **Solarized** — classic dark/light scheme
- **Monochrome** — minimalist black and white scheme
- **Material Design** — Google Material Design
- **Nord** — cold arctic tones
- **Dracula** — dark scheme with bright accents

### Generating from Wallpapers
1. Open Noctalia Settings → Color Schemes
2. Enable "Use Wallpaper Colors"
3. Select wallpaper via Wallpaper Selector
4. Noctalia will automatically call `matugen` to generate palette
5. Colors will be applied to all applications via templates

---

## 🔧 Requirements

- **OS**: CachyOS / Arch Linux (or other Arch-based distribution)
- **Display Server**: Wayland
- **Compositor**: Niri (will be installed automatically)
- **Shell**: Noctalia Shell (will be installed from AUR)

**Optional**:
- NVIDIA GPU for installing NVIDIA module
- Pywalfox for theming Firefox/Zen Browser

---

## 📁 Repository Structure

```
Quries-Noctalia-Niri/
├── README.md                       # This file
├── install.sh                      # Main installation script
├── modules/                        # Installation modules
│   ├── base.sh                    # Base installation (Noctalia + Niri + dependencies)
│   ├── nvidia.sh                  # NVIDIA Wayland optimizations
│   ├── qt-integration.sh          # Qt5/Qt6 integration with color schemes
│   └── gtk-integration.sh         # GTK3/GTK4 integration with color schemes
├── config/                         # Configuration files
│   ├── niri/                      # Niri compositor configuration
│   │   └── config.kdl             # Keybindings, workspaces, settings
│   ├── kitty/                     # Kitty terminal
│   │   └── kitty.conf             # JetBrains Mono Nerd Font + dynamic themes
│   ├── noctalia/                  # Noctalia settings
│   │   ├── settings.json          # Main settings
│   │   └── colors.json            # Active color scheme
│   ├── qt5ct/                     # Qt5 settings
│   │   ├── qt5ct.conf             # custom_palette=true, icon_theme, fonts
│   │   └── colors/noctalia.conf   # Auto-generated palette
│   ├── qt6ct/                     # Qt6 settings
│   │   ├── qt6ct.conf             # custom_palette=true, icon_theme, fonts
│   │   └── colors/noctalia.conf   # Auto-generated palette
│   ├── gtk-3.0/                   # GTK3 settings
│   │   ├── settings.ini           # gtk-theme, icon-theme, cursor-theme
│   │   └── gtk.css                # Auto-generated styles
│   ├── gtk-4.0/                   # GTK4 settings
│   │   ├── settings.ini           # gtk-theme, icon-theme, cursor-theme
│   │   └── gtk.css                # Auto-generated styles (Material Design variables)
│   └── .face                      # User avatar
├── scripts/                        # Helper scripts
│   ├── update_micro_theme.sh      # Sync colors with micro editor
│   ├── update_qt_colorscheme.sh   # Manual Qt color scheme update
│   └── fetch-centered             # Custom system info script
├── patches/                        # Patches for Noctalia Shell
│   └── noctalia-shell/
│       ├── AppThemeService.qml    # Fixed theme service (GTK3 generation + scrim fix)
│       └── gtk.css                # Universal GTK template (GTK3 + GTK4)
├── qn1.png                         # Screenshot 1
├── qn2.png                         # Screenshot 2
└── qn3.png                         # Screenshot 3
```

---

## 🐛 Known Issues and Solutions

### GTK4 apps don't pick up color scheme changes
**Problem**: GTK4/libadwaita apps (Nautilus, Calculator) only pick up new colors after restart.

**Cause**: `AdwStyleManager` reads `org.gnome.desktop.interface color-scheme` via portal only on initialization, without subscribing to changes.

**Solution**: Restart GTK4 apps after changing color scheme. Nautilus can be restarted via `MOD+E` keybinding in Niri (includes `killall nautilus`).

### White square behind context menus in Nautilus
**Problem**: When opening context menu (right click), a large white rectangular artifact appears.

**Cause**: Custom CSS rules for `popover, popover.background` break GTK4 backdrop rendering.

**Solution**: **DO NOT ADD** styles for `popover, popover.background, .context-menu` in `~/.config/gtk-4.0/gtk.css`. Only use styles for `menu, .menu` (for GTK3 context menus).

### Hook script apply_gtk_css_rules.sh adds problematic styles
**Solution**: Hook script `apply_gtk_css_rules.sh` is **disabled** in `~/.config/noctalia/settings.json`. If you see issues with GTK4 menus, remove old CSS files and switch color scheme for regeneration:
```bash
rm ~/.config/gtk-3.0/gtk.css ~/.config/gtk-4.0/gtk.css
systemctl --user restart noctalia.service
# Then switch color scheme in Noctalia Settings
```

---

## 🤝 Credits

- **[Noctalia Shell](https://github.com/noctalia-dev/noctalia-shell)** — for the amazing Wayland shell based on Quickshell/QML
- **[Niri](https://github.com/YaLTeR/niri)** — for the modern tiling Wayland compositor
- **[Matugen](https://github.com/InioX/matugen)** — for generating Material Design color schemes from wallpapers
- **[Claude Code](https://claude.ai/claude-code)** — for help with writing code, fixing bugs, and creating this repository

---

## 📄 License

**MIT License** (for my customizations and scripts)

Noctalia Shell, Niri, and other upstream projects have their own licenses — see their repositories.

---

<div align="center">

**Made with ❤️ and [Claude Code](https://claude.ai/claude-code) by Qurie**

⭐ Star this repo if you like it!

</div>
