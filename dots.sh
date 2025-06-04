#!/bin/bash
set -e

# Color
RED='\e[1;31m'
WHITE='\e[1;37m'
BOLD_RED='\e[1;91m'
BRIGHT_WHITE='\e[1;97m'
DIM_RED='\e[2;31m'
BG_RED='\e[41m'
BG_WHITE='\e[47m'
GREEN='\e[1;32m'
BOLD_GREEN='\e[1;92m'
DIM_GREEN='\e[2;32m'
YELLOW='\e[1;33m'
BOLD_YELLOW='\e[1;93m'
BG_YELLOW='\e[43m'
RESET='\e[0m'
BLINK='\e[5m'

# Globals
DOTFILES_DIR="$HOME/dots"
CONFIG_DIR="$HOME/.config"

# ASCII Banner
show_banner() {
    clear
    echo -e "${BOLD_RED}"
    echo "            __      __                  "
    echo "           / /___ _/ /_____ ____  ____ _"
    echo "          / / __ \`/ __/ __ \`/ _ \\/ __ \`/"
    echo "         / / /_/ / /_/ /_/ /  __/ /_/ / "
    echo "        /_/\\__,_/\\__/\\__,_/\\___/\\__, /  "
    echo "                                  /_/   "
    echo -e "${RESET}"
    echo -e "${WHITE}=================================================${RESET}"
    echo -e "${BOLD_RED}            DOTFILES INSTALLER SYSTEM${RESET}"
    echo -e "${DIM_RED}           Advanced Configuration Tool${RESET}"
    echo -e "${WHITE}=================================================${RESET}"
    echo
}

# Animated loading function
loading_animation() {
    local text="$1"
    local delay=0.1
    local spinstr='|/-\'
    echo -ne "${WHITE}[${RESET}"
    for i in {1..20}; do
        local temp=${spinstr#?}
        printf "${BOLD_RED}%c${RESET}" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b"
    done
    echo -e "${WHITE}] ${BRIGHT_WHITE}${text}${RESET}"
}

# Error handler with style
abort() {
    echo
    echo -e "${BG_RED}${WHITE} ✗ OPERATION TERMINATED ${RESET}"
    echo -e "${BOLD_RED}┌─────────────────────────┐${RESET}"
    echo -e "${BOLD_RED}│ Process aborted by user │${RESET}"
    echo -e "${BOLD_RED}└─────────────────────────┘${RESET}"
    exit 1
}

# Success message
success_msg() {
    echo -e "${WHITE}=================================================${RESET}"
    echo -e "${BOLD_GREEN}|| ${WHITE}[${BOLD_GREEN}SUCCESS${WHITE}] ${BRIGHT_WHITE}$1${RESET}"
    echo -e "${WHITE}=================================================${RESET}"
}

# Warning message
warning_msg() {
    echo -e "${BOLD_RED}⚠ WARNING: ${WHITE}$1${RESET}"
}

# Info message
info_msg() {
    echo -e "${WHITE}[${BOLD_RED}INFO${WHITE}] ${BRIGHT_WHITE}$1${RESET}"
}

# Package status check with visual feedback
check_package() {
    local pkg="$1"
    if dpkg -s "$pkg" >/dev/null 2>&1; then
    echo -e "${WHITE}[${BOLD_GREEN}✓${WHITE}] ${BRIGHT_WHITE}$pkg${WHITE} - Already installed${RESET}"
        return 0
    else
    echo -e "${WHITE}[${BOLD_RED}✗${WHITE}] ${BRIGHT_WHITE}$pkg${WHITE} - Not found${RESET}"
        return 1
    fi
}

# Wallpaper setup function
setup_wallpapers() {
    echo -e "${WHITE}=================================================${RESET}"
    echo -e "${BOLD_RED}>> WALLPAPER SELECTION${RESET}"
    echo -e "${WHITE}============================================${RESET}"
    echo
    
    # Create wallpaper directory
    mkdir -p "$HOME/.config/wallpapers"
    
    # Check if wallpapers exist in dotfiles
    if [ -d "$DOTFILES_DIR/wallpapers" ]; then
        info_msg "Available wallpapers:"
        echo
        
        local wallpapers=()
        local counter=1
        
        # List available wallpapers
        shopt -s nullglob
        for wallpaper in "$DOTFILES_DIR/wallpapers"/*.jpg "$DOTFILES_DIR/wallpapers"/*.jpeg "$DOTFILES_DIR/wallpapers"/*.png; do
            if [ -f "$wallpaper" ]; then
                local basename=$(basename "$wallpaper")
                wallpapers+=("$wallpaper")
                echo -e "${BOLD_RED}[$counter]${WHITE} ${basename%.*}${RESET}"
                ((counter++))
            fi
        done
        shopt -u nullglob
        
        if [ ${#wallpapers[@]} -eq 0 ]; then
            warning_msg "No wallpapers found in dotfiles directory"
            info_msg "Checking Downloads directory for selectedwallpaperchoice.jpg..."
            
            if [ -f "$HOME/Downloads/selectedwallpaperchoice.jpg" ]; then
                cp "$HOME/Downloads/selectedwallpaperchoice.jpg" "$HOME/.config/wallpapers/wall.jpg"
                echo -e "${WHITE}>> ${BOLD_GREEN}✓ ${WHITE}Wallpaper copied from Downloads${RESET}"
                feh --bg-scale "$HOME/.config/wallpapers/wall.jpg" 2>/dev/null
                echo -e "${WHITE}>> ${BOLD_GREEN}✓ ${WHITE}Wallpaper set successfully${RESET}"
            else
                warning_msg "No wallpaper found. You can manually add wallpapers to ~/.config/wallpapers/"
            fi
            return 0
        fi
        
        echo
        echo -ne "${BOLD_RED}┌─ ${WHITE}Choose wallpaper (1-$((counter-1))): ${RESET}"
        read -r choice
        
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#wallpapers[@]} ]; then
            local selected_wallpaper="${wallpapers[$((choice-1))]}"
            cp "$selected_wallpaper" "$HOME/.config/wallpapers/wall.jpg"
            
            loading_animation "Setting wallpaper"
            if feh --bg-scale "$HOME/.config/wallpapers/wall.jpg" 2>/dev/null; then
                echo -e "${WHITE}>> ${BOLD_GREEN}✓ ${WHITE}Wallpaper set successfully${RESET}"
            else
                echo -e "${WHITE}>> ${BOLD_RED}✗ ${WHITE}Failed to set wallpaper${RESET}"
            fi
        else
            warning_msg "Invalid selection. Using default wallpaper setup."
            # Fallback to Downloads check
            if [ -f "$HOME/Downloads/selectedwallpaperchoice.jpg" ]; then
                cp "$HOME/Downloads/selectedwallpaperchoice.jpg" "$HOME/.config/wallpapers/wall.jpg"
                feh --bg-scale "$HOME/.config/wallpapers/wall.jpg" 2>/dev/null
            fi
        fi
    else
        info_msg "No wallpapers directory found in dotfiles"
        info_msg "Checking Downloads directory for selectedwallpaperchoice.jpg..."
        
        if [ -f "$HOME/Downloads/selectedwallpaperchoice.jpg" ]; then
            cp "$HOME/Downloads/selectedwallpaperchoice.jpg" "$HOME/.config/wallpapers/wall.jpg"
            loading_animation "Setting wallpaper from Downloads"
            if feh --bg-scale "$HOME/.config/wallpapers/wall.jpg" 2>/dev/null; then
                echo -e "${WHITE}>> ${BOLD_GREEN}✓ ${WHITE}Wallpaper set successfully${RESET}"
            else
                echo -e "${WHITE}>> ${BOLD_RED}✗ ${WHITE}Failed to set wallpaper${RESET}"
            fi
        else
            warning_msg "No wallpaper found. You can manually add wallpapers to ~/.config/wallpapers/"
        fi
    fi
    
    echo
}

trap abort SIGINT

# Main menu display
show_menu() {
    show_banner
    echo -e "${WHITE}=================================================${RESET}"
    echo -e "${BOLD_RED}>> ${WHITE}SELECT TARGET ENVIRONMENT${RESET}"
    echo -e "${WHITE}=================================================${RESET}"
    echo
    echo -e "${BOLD_RED}[1]${WHITE} Kali Linux    ${DIM_RED}- Penetration testing & hacking${RESET}"
    echo -e "${BOLD_RED}[2]${WHITE} Arch Linux    ${DIM_RED}- Daily use & development${RESET}"
    echo -e "${BOLD_RED}[3]${WHITE} Uninstall     ${DIM_RED}- Remove all components${RESET}"
    echo -e "${BOLD_RED}[q]${WHITE} Quit          ${DIM_RED}- Exit installer system${RESET}"
    echo
    echo -e "${WHITE}============================================${RESET}"
    echo
    echo -ne "${BOLD_RED}┌─ ${WHITE}Enter selection${BOLD_RED}: ${RESET}"
    read -r opt
}

# Kali Linux installation
install_kali() {
    echo
    echo -e "${WHITE}=================================================${RESET}"
    echo -e "${BOLD_RED}>> KALI LINUX INSTALLATION INITIATED${RESET}"
    echo -e "${WHITE}=================================================${RESET}"
    echo
    
    info_msg "Scanning system for required packages..."
    echo
    
    local packages=("i3" "polybar" "compton" "feh" "terminator" "rofi" "dunst")
    local to_install=()
    
    # Check all packages first
    for pkg in "${packages[@]}"; do
        if ! check_package "$pkg"; then
            to_install+=("$pkg")
        fi
    done
    
    # Install missing packages
    if [ ${#to_install[@]} -gt 0 ]; then
        echo
        info_msg "Installing missing packages: ${to_install[*]}"
        echo
        
        for pkg in "${to_install[@]}"; do
            echo -e "${BOLD_RED}>> Installing ${WHITE}$pkg${BOLD_RED}...${RESET}"
            loading_animation "Downloading and configuring $pkg"
            if sudo apt install -y "$pkg" >/dev/null 2>&1; then
                echo -e "${WHITE}>> ${BOLD_GREEN}✓ ${WHITE}$pkg installation ${BOLD_GREEN}SUCCESSFUL${RESET}"
            else
                echo -e "${WHITE}>> ${BOLD_RED}✗ ${WHITE}$pkg installation ${BOLD_RED}FAILED${RESET}"
            fi
            echo
        done
    else
        success_msg "All required packages already installed"
        echo
    fi
    
    info_msg "Installing configuration files..."
    echo
    
    mkdir -p "$CONFIG_DIR"
    
    if cp -r "$DOTFILES_DIR/.config/"* "$CONFIG_DIR/" 2>/dev/null; then
        loading_animation "Copying configuration files"
        success_msg "Configuration installation completed"
    else
        warning_msg "Some configuration files could not be copied"
    fi
    
    echo
    info_msg "Setting up wallpapers..."
    setup_wallpapers
    
    echo
    echo -e "${WHITE}=================================================${RESET}"
    echo -e "${BOLD_GREEN}>> INSTALLATION SUCCESSFUL${RESET}"
    echo
    echo -e "${BG_YELLOW}${WHITE}                                        ${RESET}"
    echo -e "${BG_YELLOW}${WHITE}   ⚠  IMPORTANT - ACTION REQUIRED  ⚠    ${RESET}"
    echo -e "${BG_YELLOW}${WHITE}                                        ${RESET}"
    echo
    echo -e "${BOLD_YELLOW}>> Log out and back in to activate i3 window manager${RESET}"
    echo -e "${YELLOW}   Your new desktop environment is ready!${RESET}"
    echo
    echo -e "${WHITE}=================================================${RESET}"
}

# Arch Linux installation (placeholder with style)
install_arch() {
    echo
    echo -e "${WHITE}=================================================${RESET}"
    echo -e "${BOLD_RED}>> ARCH LINUX INSTALLATION${RESET}"
    echo -e "${WHITE}=================================================${RESET}"
    echo
    warning_msg "Arch Linux installation module is under development"
    echo
    echo -e "${DIM_RED}>> Future features:${RESET}"
    echo -e "${DIM_RED}   - Daily development environment setup${RESET}"
    echo -e "${DIM_RED}   - Automated AUR package management${RESET}"
    echo -e "${DIM_RED}   - Productivity-focused configurations${RESET}"
    echo -e "${DIM_RED}   - Minimal and efficient rice setup${RESET}"
    echo
    echo -e "${WHITE}Press ${BOLD_RED}[Enter]${WHITE} to return to main menu...${RESET}"
    read -r
}

# Uninstall function with confirmation
uninstall_all() {
    echo
    echo -e "${BG_RED}${WHITE} ⚠ DANGER ZONE ⚠ ${RESET}"
    echo -e "${WHITE}=================================================${RESET}"
    echo -e "${BOLD_RED}>> COMPLETE SYSTEM REMOVAL${RESET}"
    echo -e "${DIM_RED}   This will remove ALL installed components${RESET}"
    echo -e "${WHITE}=================================================${RESET}"
    echo
    echo -ne "${BOLD_RED}Are you sure? ${WHITE}[Y/N]${BOLD_RED}: ${RESET}"
    read -r confirmation
    
    if [[ "$confirmation" != "Y" && "$confirmation" != "y" ]]; then
        info_msg "Uninstallation cancelled"
        return 0
    fi
    
    echo
    info_msg "Initiating complete removal process..."
    echo
    
    local packages=("i3" "polybar" "compton" "feh")
    
    for pkg in "${packages[@]}"; do
        if dpkg -s "$pkg" >/dev/null 2>&1; then
            echo -e "${BOLD_RED}>> Removing ${WHITE}$pkg${BOLD_RED}...${RESET}"
            loading_animation "Uninstalling $pkg"
            if sudo apt remove --purge -y "$pkg" >/dev/null 2>&1; then
                echo -e "${WHITE}>> ${BOLD_GREEN}✓ ${WHITE}$pkg removal ${BOLD_GREEN}SUCCESSFUL${RESET}"
            else
                echo -e "${WHITE}>> ${BOLD_RED}✗ ${WHITE}$pkg removal ${BOLD_RED}FAILED${RESET}"
            fi
            echo
        fi
    done
    
    info_msg "Cleaning configuration files..."
    loading_animation "Removing configuration directories"
    rm -rf "$CONFIG_DIR/polybar" "$CONFIG_DIR/i3" "$CONFIG_DIR/compton.conf"
    
    echo
    echo -e "${WHITE}=================================================${RESET}"
    echo -e "${BOLD_GREEN}>> REMOVAL COMPLETED${RESET}"
    echo -e "${DIM_GREEN}   All components have been successfully removed${RESET}"
    echo -e "${WHITE}=================================================${RESET}"
}

# Main execution loop
main() {
    while true; do
        show_menu
        
        case "$opt" in
            1)
                install_kali
                echo
                echo -ne "${WHITE}Press ${BOLD_RED}[Enter]${WHITE} to continue...${RESET}"
                read -r
                ;;
            2)
                install_arch
                ;;
            3)
                uninstall_all
                echo
                echo -ne "${WHITE}Press ${BOLD_RED}[Enter]${WHITE} to continue...${RESET}"
                read -r
                ;;
            q|Q)
                echo
                echo -e "${WHITE}=================================================${RESET}"
                echo -e "${BOLD_RED}>> SESSION TERMINATED${RESET}"
                echo -e "${DIM_RED}   Thank you for using LATAEQ Dotfiles Installer${RESET}"
                echo -e "${WHITE}=================================================${RESET}"
                exit 0
                ;;
            *)
                echo
                warning_msg "Invalid selection. Please choose a valid option."
                echo
                echo -ne "${WHITE}Press ${BOLD_RED}[Enter]${WHITE} to continue...${RESET}"
                read -r
                ;;
        esac
    done
}

# Start the application
main