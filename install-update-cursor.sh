#!/bin/bash

# Define colors and styling
RED='\e[1;31m'
GREEN='\e[1;32m'
BLUE='\e[1;34m'
YELLOW='\e[1;33m'
CYAN='\e[1;36m'
PURPLE='\e[1;35m'
NC='\e[0m' # No Color
BOLD='\e[1m'
UNDERLINE='\e[4m'

# Define variables
APP_DIR="$HOME/Applications/cursor"
APP_IMAGE="$APP_DIR/cursor.AppImage"
EXTRACT_DIR="$APP_DIR/squashfs-root"
ICON_DIR="$APP_DIR/icons"
ICON_PATH="$ICON_DIR/cursor_icon.png"
ICON_URL="https://camo.githubusercontent.com/a0307a3865517874a8d9f9904ef532de5f0600a16cbbb4c6f0204904e0e4e172/68747470733a2f2f6d696e746c6966792e73332d75732d776573742d312e616d617a6f6e6177732e636f6d2f637572736f722f696d616765732f6c6f676f2f6170702d6c6f676f2e737667"
API_URL="https://api2.cursor.sh/updates/api/update/linux-x64/cursor/0.48.9/d024087b1e0e0d0110800b253e063c65497b77a95213eb7e063df2bf7e8f6a07/stable"

# Function to display messages
function info {
    echo -e "${BLUE}[INFO]${NC} $1"
}

function success {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

function error {
    echo -e "${RED}[ERROR]${NC} $1"
}

function warning {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Spinner animation for processes
function show_spinner {
    local pid=$1
    local message=$2
    local spin='-\|/'
    local i=0

    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r${YELLOW}[%c]${NC} ${message}" "${spin:$i:1}"
        sleep .1
    done
    printf "\r    \r"
}

# Display banner
clear
echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                   ║${NC}"
echo -e "${CYAN}║${BOLD}   🚀 CURSOR EDITOR - AUTOMATIC UPDATER ${NC}${CYAN}          ║${NC}"
echo -e "${CYAN}║                                                   ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

# Start update process
info "Starting Cursor update process..."

# Create application directory if it doesn't exist
if [ ! -d "$APP_DIR" ]; then
    mkdir -p "$APP_DIR"
    success "Created application directory: $APP_DIR"
fi

# Navigate to application directory
cd "$APP_DIR" || { error "Failed to navigate to $APP_DIR"; exit 1; }

# Create icons directory if it doesn't exist
if [ ! -d "$ICON_DIR" ]; then
    mkdir -p "$ICON_DIR"
fi

# Download icon
info "${UNDERLINE}Downloading Cursor icon...${NC}"
if wget -q "$ICON_URL" -O "$ICON_PATH" 2>&1; then
    success "Icon downloaded successfully."
else
    warning "Failed to download icon from URL. Will use default icon instead."
    ICON_PATH=""
fi

# Fetch the latest version information from the API
echo ""
info "${UNDERLINE}Fetching the latest version information...${NC}"
echo ""
response=$(curl -s "$API_URL")

# Extract the download URL from the response
download_url=$(echo "$response" | grep -oP '(?<="url":")[^"]+')
appimage_url="${download_url%.zsync}"
version=$(echo "$appimage_url" | grep -oP 'Cursor-\K[0-9.]+')

if [[ -z "$appimage_url" ]]; then
    error "Failed to extract the AppImage URL from the API response."
    read -p "$(echo -e "${CYAN}Press Enter to exit...${NC}")"
    exit 1
fi

echo -e "${PURPLE}┌─ Version Info ───────────────────────────┐${NC}"
echo -e "${PURPLE}│${NC} Latest version detected: ${BOLD}$version${NC}"
echo -e "${PURPLE}└─────────────────────────────────────────┘${NC}"
echo ""

info "${UNDERLINE}Downloading Cursor version $version...${NC}"
echo ""

echo -e "${CYAN}┌─ Download Progress ──────────────────────┐${NC}"
if wget --progress=bar:force --show-progress "$appimage_url" -O "$APP_IMAGE" 2>&1; then
    echo -e "${CYAN}└─────────────────────────────────────────┘${NC}"
    echo ""
    success "Download completed successfully."
else
    echo -e "${CYAN}└─────────────────────────────────────────┘${NC}"
    echo ""
    error "Failed to download the latest AppImage."
    read -p "$(echo -e "${CYAN}Press Enter to exit...${NC}")"
    exit 1
fi

echo ""
info "${UNDERLINE}Setting up permissions...${NC}"
# Make the AppImage executable
chmod +x "$APP_IMAGE"
chown $USER:$USER "$APP_IMAGE"
success "Permissions set."

# Fix ownership and remove previous extracted files
if [ -d "$EXTRACT_DIR" ]; then
    warning "Previous installation detected."
    echo -e "${YELLOW}┌─ Cleanup Process ─────────────────────────┐${NC}"
    echo -e "${YELLOW}│${NC} Fixing permissions and removing old files..."
    echo -e "${YELLOW}└─────────────────────────────────────────┘${NC}"

    sudo chown -R $USER:$USER "$EXTRACT_DIR"
    rm -rf "$EXTRACT_DIR"
    success "Cleanup completed."
fi

echo ""
info "${UNDERLINE}Extracting the AppImage...${NC}"
echo -e "${YELLOW}┌─ Extraction Process ───────────────────────┐${NC}"
echo -e "${YELLOW}│${NC} This may take a moment. Please wait..."
echo -e "${YELLOW}└─────────────────────────────────────────┘${NC}"

# Add a simple animation during extraction
echo -n "  "
for i in {1..30}; do
    echo -n "${CYAN}▓${NC}"
    "$APP_IMAGE" --appimage-extract > /dev/null 2>&1 &
    extract_pid=$!
    sleep 0.1
    if [ ! -d "$EXTRACT_DIR" ]; then
        continue
    else
        # Fill the rest of the progress bar
        remaining=$((30 - i))
        for j in $(seq 1 $remaining); do
            echo -n "${CYAN}▓${NC}"
        done
        break
    fi
done
echo ""

if [ -d "$EXTRACT_DIR" ]; then
    echo ""
    success "Extraction completed successfully."
else
    echo ""
    error "Failed to extract the AppImage."
    read -p "$(echo -e "${CYAN}Press Enter to exit...${NC}")"
    exit 1
fi

# Create desktop shortcut
DESKTOP_FILE="$HOME/.local/share/applications/cursor.desktop"
echo ""

if [ -f "$DESKTOP_FILE" ]; then
    warning "Desktop shortcut already exists."
    echo -e "${YELLOW}┌─ Shortcut Options ─────────────────────────┐${NC}"
    echo -e "${YELLOW}│${NC} Do you want to update the existing shortcut?"
    echo -e "${YELLOW}└─────────────────────────────────────────┘${NC}"

    read -p "$(echo -e "${CYAN}Update shortcut? (y/n):${NC} ")" update_shortcut

    if [[ "$update_shortcut" != "y" && "$update_shortcut" != "Y" ]]; then
        info "Skipping shortcut update."
    else
        info "${UNDERLINE}Creating/updating desktop shortcut...${NC}"

        # Use downloaded icon or ask for custom path if download failed
        if [[ -z "$ICON_PATH" || ! -f "$ICON_PATH" ]]; then
            # Ask for icon path
            echo -e "${PURPLE}┌─ Icon Selection ─────────────────────────┐${NC}"
            echo -e "${PURPLE}│${NC} Enter a custom path or use the default icon"
            echo -e "${PURPLE}└─────────────────────────────────────────┘${NC}"

            read -p "$(echo -e "${CYAN}Icon path (or press Enter for default):${NC} ")" user_icon_path

            # Use default icon if none provided
            if [[ -z "$user_icon_path" ]]; then
                icon_path="$EXTRACT_DIR/resources/app/resources/app.asar.unpacked/static/icon.png"
                info "Using default icon: $icon_path"
            else
                icon_path="$user_icon_path"
            fi
        else
            icon_path="$ICON_PATH"
            info "Using downloaded icon: $icon_path"
        fi

        # Create desktop entry file
        cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Cursor
Comment=Cursor Code Editor
Exec=$EXTRACT_DIR/AppRun --no-sandbox
Icon=$icon_path
Terminal=false
Type=Application
Categories=Development;IDE;
StartupWMClass=Cursor
EOF

        # Make desktop file executable
        chmod +x "$DESKTOP_FILE"

        success "Desktop shortcut updated successfully!"
    fi
else
    info "${UNDERLINE}Creating desktop shortcut...${NC}"

    # Use downloaded icon or ask for custom path if download failed
    if [[ -z "$ICON_PATH" || ! -f "$ICON_PATH" ]]; then
        # Ask for icon path
        echo -e "${PURPLE}┌─ Icon Selection ─────────────────────────┐${NC}"
        echo -e "${PURPLE}│${NC} Enter a custom path or use the default icon"
        echo -e "${PURPLE}└─────────────────────────────────────────┘${NC}"

        read -p "$(echo -e "${CYAN}Icon path (or press Enter for default):${NC} ")" user_icon_path

        # Use default icon if none provided
        if [[ -z "$user_icon_path" ]]; then
            icon_path="$EXTRACT_DIR/resources/app/resources/app.asar.unpacked/static/icon.png"
            info "Using default icon: $icon_path"
        else
            icon_path="$user_icon_path"
        fi
    else
        icon_path="$ICON_PATH"
        info "Using downloaded icon: $icon_path"
    fi

    # Create desktop entry file
    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Cursor
Comment=Cursor Code Editor
Exec=$EXTRACT_DIR/AppRun --no-sandbox
Icon=$icon_path
Terminal=false
Type=Application
Categories=Development;IDE;
StartupWMClass=Cursor
EOF

    # Make desktop file executable
    chmod +x "$DESKTOP_FILE"

    success "Desktop shortcut created successfully!"
fi

# Final completion message with centered version number
version_display="v$version"
padding=$(( (49 - ${#version_display} - 4) / 2 ))
left_spaces=$(printf '%*s' $padding '')
right_spaces=$(printf '%*s' $(( 49 - ${#version_display} - 4 - padding )) '')

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                   ║${NC}"
echo -e "${GREEN}║${BOLD}   ✓ CURSOR UPDATED SUCCESSFULLY TO $left_spaces$version_display$right_spaces${NC}${GREEN}   ║${NC}"
echo -e "${GREEN}║                                                   ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

read -p "$(echo -e "${CYAN}Press Enter to exit...${NC}")"
