# Notion AppImage

![Screenshot](https://i.redd.it/vlp26kemu3wb1.png)

**THIS IS AN UNOFFICIAL REPACK, USE AT YOUR OWN RISK**

> **Note**: This is a personal fork of [kidonng/notion-appimage](https://github.com/kidonng/notion-appimage) with fixes to make it work on Manjaro Linux. The original build script had issues that I didn't know how to fix, but with help from Antigravity AI, the build process was updated to work correctly on my system.
>
> This fork includes manual AppImage construction to bypass `electron-builder` dependency issues. I won't be updating this repository unless something breaks with the installed application.

Build the [Notion desktop app](https://www.notion.so/desktop) as [AppImage](https://appimage.org/).

> **Status**: Working on Manjaro Linux with manual AppImage packaging.

## Installation

### Prerequisites

Install required dependencies:

```bash
sudo pacman -S p7zip nodejs npm unzip
```

### Build the AppImage

```bash
# Clone this repository
git clone https://github.com/Novav20/notion-appimage.git
cd notion-appimage

# Run the build script
./build.sh
```

The build will:
- Download Notion from official source
- Extract and patch the application
- Rebuild native modules for Linux
- Create the AppImage (takes ~2-3 minutes)

### Install the AppImage

```bash
# Create directories
mkdir -p ~/.local/bin ~/.local/share/applications ~/.local/share/icons/hicolor/256x256/apps

# Install AppImage
cp build/Notion-37.6.0-x86_64.AppImage ~/.local/bin/Notion.AppImage
chmod +x ~/.local/bin/Notion.AppImage

# Install icon
cp assets/icon.png ~/.local/share/icons/hicolor/256x256/apps/notion.png

# Create desktop entry
cat > ~/.local/share/applications/notion.desktop << 'EOF'
[Desktop Entry]
Name=Notion
Comment=All-in-one workspace for notes and collaboration
Exec=/home/$USER/.local/bin/Notion.AppImage
Icon=notion
Type=Application
Categories=Office;Productivity;
Terminal=false
StartupWMClass=Notion
EOF

# Update desktop database
chmod +x ~/.local/share/applications/notion.desktop
update-desktop-database ~/.local/share/applications

# Create terminal shortcut
ln -sf ~/.local/bin/Notion.AppImage ~/.local/bin/notion
```

### Launch Notion

- **From app menu**: Search for "Notion"
- **From terminal**: Type `notion`

### Cleanup (optional)

After installation, you can remove build files:

```bash
rm -rf build/
```

## Q&A

### Why this over alternatives (e.g. web version)?

The desktop app provides essential features not available in the web version:

- **Tabs**: Navigate between multiple Notion pages in tabs, just like a browser
- **Offline availability**: Access your workspace without an internet connection
- **Native desktop integration**: Better system integration and keyboard shortcuts

### Why AppImage?

AppImage is a portable format that works across Linux distributions without requiring installation or dependencies. It's self-contained and easy to use - just download, make executable, and run.

### What about [notion-enhancer](https://github.com/notion-enhancer/notion-repackaged)?

notion-enhancer's development is snailing and last release was almost two years ago, at the end of 2021. There are several showstoppers even if you use the vanilla repacked version without notion-enhancer.

This project is inspired by notion-enhancer, albeit sharing no code.
