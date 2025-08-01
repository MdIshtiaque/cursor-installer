# <img src="https://www.cursor.com/assets/images/logo.svg" width="30" height="30" style="vertical-align: middle;"> Cursor Editor Updater/Installer

<div align="center">

![Cursor Editor](https://www.cursor.com/assets/images/logo.svg)

<h3>Enterprise-Grade Automatic Updater/Installer for Cursor AI Code Editor on Linux</h3>

[![Bash](https://img.shields.io/badge/Shell-Bash_4.4+-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Cursor](https://img.shields.io/badge/Cursor-0.48.9+-8A2BE2?style=for-the-badge&logo=cursor&logoColor=white)](https://cursor.sh)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)

</div>

## 📋 Overview

The Cursor Updater is a sophisticated bash utility designed to automate the deployment and maintenance of the [Cursor AI Code Editor](https://cursor.sh) on Linux systems. Featuring an elegant terminal interface with real-time progress visualization, the tool handles the entire update lifecycle with enterprise-level reliability.

<details open>
<summary><b>🔍 Key Features</b></summary>
<br>

| Feature                    | Description                                                                              |
| -------------------------- | ---------------------------------------------------------------------------------------- |
| 🔄 **API-Based Updates**   | Queries the official Cursor API to ensure you always get the genuine latest release      |
| 🎨 **Terminal UI**         | Rich terminal interface with color-coded sections, progress bars, and process animations |
| 🖥️ **System Integration**  | Seamlessly integrates with Linux desktop environments via `.desktop` entry creation      |
| 🛡️ **Security Controls**   | Manages file permissions and ownership with proper user context                          |
| 📦 **AppImage Management** | Handles extraction, cleanup, and execution preparation automatically                     |
| 🔧 **Configurable**        | Customizable installation paths and icon selection                                       |
| 🖼️ **Auto Icon Download** | Automatically fetches and applies the official Cursor icon for desktop integration       |
| 🔗 **URL Handler Setup**   | Registers cursor:// URL scheme handler for seamless deep-linking integration            |

</details>

## 🚀 Installation & Usage

### System Requirements

- Linux operating system (Ubuntu, Debian, Fedora, Arch, etc.)
- `bash` shell version 4.4 or higher
- `wget` and `curl` utilities installed
- Sufficient permissions to create application directories

### Quick Setup

1. **Download the script** directly from our repository:

```bash
curl -LO https://raw.githubusercontent.com/MdIshtiaque/cursor-installer/main/install-update-cursor.sh
```

2. **Make the script executable**:

```bash
chmod +x install-update-cursor.sh
```

3. **Execute the updater**:

```bash
./install-update-cursor.sh
```

## ⚙️ Technical Details

### Architecture

The updater follows a modular workflow:

1. **Initialization**: Sets up environment variables and colorized UI functions
2. **Icon Management**: Downloads and prepares the official Cursor icon for desktop integration
3. **API Query**: Performs a GET request to Cursor's API endpoint to fetch metadata
4. **Download Management**: Retrieves the AppImage with progress monitoring
5. **Extraction**: Unpacks the AppImage in the target directory
6. **Desktop Integration**: Creates/updates XDG-compliant desktop entries with the downloaded icon
7. **Permission Handling**: Sets appropriate file permissions and ownership

### Configuration Options

The script uses the following configurable paths:

```bash
APP_DIR="$HOME/Applications/cursor"     # Base installation directory
APP_IMAGE="$APP_DIR/cursor.AppImage"    # AppImage executable location
EXTRACT_DIR="$APP_DIR/squashfs-root"    # Extraction directory
ICON_DIR="$APP_DIR/icons"               # Directory for icon storage
ICON_PATH="$ICON_DIR/cursor_icon.png"   # Path to the downloaded icon
```

To modify these paths, edit the variables at the top of the script.

### API Endpoint

The updater connects to Cursor's official update API:

```
https://api2.cursor.sh/updates/api/update/linux-x64/cursor/0.48.9/[HASH]/stable
```

This ensures you receive authentic updates directly from the vendor's distribution channel.

## 🛠️ Advanced Usage

### Command Line Options

| Option            | Description                             |
| ----------------- | --------------------------------------- |
| `-d, --directory` | Specify a custom installation directory |
| `-q, --quiet`     | Run in quiet mode with minimal output   |
| `-h, --help`      | Display help information                |

### Customizing the Desktop Shortcut

The desktop integration creates a standard `.desktop` entry with these parameters:

```ini
[Desktop Entry]
Name=Cursor
Comment=Cursor Code Editor
Exec=/path/to/cursor/AppRun --no-sandbox
Icon=/path/to/icon.png
Terminal=false
Type=Application
Categories=Development;IDE;
StartupWMClass=Cursor
```

The installer now automatically downloads and uses the official Cursor icon for the desktop shortcut. If the download fails, you'll be prompted to provide a custom icon path or use the default icon included in the AppImage.

### URL Handler Integration

The installer automatically sets up a URL handler for `cursor://` links, enabling seamless deep-linking functionality:

```ini
[Desktop Entry]
Name=Cursor URL Handler
Comment=Handle cursor:// URLs
Exec=/path/to/cursor/AppRun --no-sandbox --open-url %U
Icon=/path/to/icon.png
Terminal=false
Type=Application
Categories=Development;IDE;
NoDisplay=true
MimeType=x-scheme-handler/cursor;
StartupWMClass=Cursor
```

**Benefits:**
- **Direct File Opening**: Links like `cursor://file/path/to/file.js` open files directly in Cursor
- **Project Integration**: Web applications and documentation can link directly to code files
- **Browser Integration**: Cursor links in web pages open seamlessly in the editor

The URL handler is automatically registered with the system using `xdg-mime` and the desktop database is updated for immediate availability.

## 🔍 Troubleshooting

### Diagnostics

For detailed logging and troubleshooting:

```bash
bash -x ./install-update-cursor.sh > update-log.txt 2>&1
```

### Common Issues

<details>
<summary><b>Error: "Failed to extract the AppImage URL"</b></summary>
<p>This typically indicates network connectivity issues or API changes. Verify your internet connection and check for script updates.</p>
</details>

<details>
<summary><b>Permission denied errors</b></summary>
<p>Some operations may require elevated privileges. Use <code>sudo</code> selectively for the commands that need it:</p>

```bash
sudo chown -R $USER:$USER /path/to/installation
```

</details>

<details>
<summary><b>Desktop shortcut not appearing</b></summary>
<p>Run the following to refresh the application menu:</p>

```bash
update-desktop-database ~/.local/share/applications
```

</details>

<details>
<summary><b>cursor:// links not opening in Cursor</b></summary>
<p>If cursor:// URLs don't open properly, try these steps:</p>

1. **Check URL handler registration:**
   ```bash
   xdg-mime query default x-scheme-handler/cursor
   ```
   Should return: `cursor-url-handler.desktop`

2. **Re-register the handler manually:**
   ```bash
   xdg-mime default cursor-url-handler.desktop x-scheme-handler/cursor
   update-desktop-database ~/.local/share/applications
   ```

3. **Test the handler:**
   ```bash
   xdg-open "cursor://file/test.js"
   ```

<p>If issues persist, you may need to log out and back in for system-wide recognition.</p>
</details>

## 📈 Future Enhancements

- [ ] Implement version comparison logic to skip unnecessary updates
- [ ] Add command-line parameters for silent/headless operation
- [ ] Create a configuration file for persistent settings
- [ ] Add backup/restore functionality for safe upgrades
- [ ] Support for custom icon themes and alternative icon sources

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

<div align="center">
  <sub>Built with precision by <a href="https://github.com/MdIshtiaque">MdIshtiaque</a></sub>
  <br>
  <sub>For professional support, contact <a href="mailto:ishtiaqueferdous109@gmail.com">via email</a></sub>
</div>
