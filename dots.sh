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
    local USER_HOME="${1:-$HOME}"
    DOTFILES_DIR="$USER_HOME/dots"
    CONFIG_DIR="$USER_HOME/.config"

    echo -e "${WHITE}=================================================${RESET}"
    echo -e "${BOLD_RED}>> WALLPAPER SELECTION${RESET}"
    echo -e "${WHITE}============================================${RESET}"
    echo

    # Create wallpaper directory
    mkdir -p "$CONFIG_DIR/wallpapers"

    # Check if wallpapers exist in dotfiles
    if [ -d "$DOTFILES_DIR/wallpapers" ]; then
        info_msg "Available wallpapers:"
        echo

        local wallpapers=()
        local counter=1

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

            if [ -f "$USER_HOME/Downloads/selectedwallpaperchoice.jpg" ]; then
                cp "$USER_HOME/Downloads/selectedwallpaperchoice.jpg" "$CONFIG_DIR/wallpapers/wall.jpg"
                echo -e "${WHITE}>> ${BOLD_GREEN}✓ ${WHITE}Wallpaper copied from Downloads${RESET}"
                feh --bg-scale "$CONFIG_DIR/wallpapers/wall.jpg" 2>/dev/null
                echo -e "${WHITE}>> ${BOLD_GREEN}✓ ${WHITE}Wallpaper set successfully${RESET}"
            else
                warning_msg "No wallpaper found. You can manually add wallpapers to $CONFIG_DIR/wallpapers/"
            fi
            return 0
        fi

        echo
        echo -ne "${BOLD_RED}┌─ ${WHITE}Choose wallpaper (1-$((counter-1))): ${RESET}"
        read -r choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#wallpapers[@]} ]; then
            local selected_wallpaper="${wallpapers[$((choice-1))]}"
            cp "$selected_wallpaper" "$CONFIG_DIR/wallpapers/wall.jpg"

            loading_animation "Setting wallpaper"
            if feh --bg-scale "$CONFIG_DIR/wallpapers/wall.jpg" 2>/dev/null; then
                echo -e "${WHITE}>> ${BOLD_GREEN}✓ ${WHITE}Wallpaper set successfully${RESET}"
            else
                echo -e "${WHITE}>> ${BOLD_RED}✗ ${WHITE}Failed to set wallpaper${RESET}"
            fi
        else
            warning_msg "Invalid selection. Using default wallpaper setup."
            if [ -f "$USER_HOME/Downloads/selectedwallpaperchoice.jpg" ]; then
                cp "$USER_HOME/Downloads/selectedwallpaperchoice.jpg" "$CONFIG_DIR/wallpapers/wall.jpg"
                feh --bg-scale "$CONFIG_DIR/wallpapers/wall.jpg" 2>/dev/null
            fi
        fi
    else
        info_msg "No wallpapers directory found in dotfiles"
        info_msg "Checking Downloads directory for selectedwallpaperchoice.jpg..."

        if [ -f "$USER_HOME/Downloads/selectedwallpaperchoice.jpg" ]; then
            cp "$USER_HOME/Downloads/selectedwallpaperchoice.jpg" "$CONFIG_DIR/wallpapers/wall.jpg"
            loading_animation "Setting wallpaper from Downloads"
            if feh --bg-scale "$CONFIG_DIR/wallpapers/wall.jpg" 2>/dev/null; then
                echo -e "${WHITE}>> ${BOLD_GREEN}✓ ${WHITE}Wallpaper set successfully${RESET}"
            else
                echo -e "${WHITE}>> ${BOLD_RED}✗ ${WHITE}Failed to set wallpaper${RESET}"
            fi
        else
            warning_msg "No wallpaper found. You can manually add wallpapers to $CONFIG_DIR/wallpapers/"
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
    echo -e "${BOLD_RED}[l]${WHITE} Logout        ${DIM_RED}- Terminate session safely${RESET}"
    echo
    echo -e "${WHITE}============================================${RESET}"
    echo
    echo -ne "${BOLD_RED}┌─ ${WHITE}Enter selection${BOLD_RED}: ${RESET}"
    read -r opt
}

# Kali Linux installation
install_kali() {

    local KALI_HOME="/home/kali"
    DOTFILES_DIR="$KALI_HOME/dots"
    CONFIG_DIR="$KALI_HOME/.config"
    
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
        # Also copy and rename Polybar's launch script if it exists
        if [ -f "$DOTFILES_DIR/.config/polybar/launch.sh" ]; then
            mkdir -p "$CONFIG_DIR/polybar"
            cp "$DOTFILES_DIR/.config/polybar/launch.sh" "$CONFIG_DIR/polybar/launch.sh"
            sudo chmod +x "$CONFIG_DIR/polybar/launch.sh"
            info_msg "Polybar launch script copied as 'launch.sh' and made executable"
        fi

        loading_animation "Copying configuration files"
        success_msg "Configuration installation completed"
    else
        warning_msg "Some configuration files could not be copied"
    fi

    # *** Added autostart configuration snippet ***
    info_msg "Configuring autostart for lxpolkit"
    mkdir -p ~/.config/autostart
    cp /etc/xdg/autostart/lxpolkit.desktop ~/.config/autostart/
    echo "Hidden=true" >> ~/.config/autostart/lxpolkit.desktop
    info_msg "Autostart configuration for lxpolkit done"
    replace_configure_prompt

    echo
    info_msg "Setting up wallpapers..."
    setup_wallpapers "$KALI_HOME"

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
    echo
    ask_logout_now
}   

replace_configure_prompt() {
    local zshrc="/home/kali/.zshrc"

    echo -e "${BLUE}[*] Replacing configure_prompt() in $zshrc...${RESET}"

    # Backup .zshrc
    [ -f "$zshrc" ] && cp "$zshrc" "${zshrc}.bak" && echo -e "${YELLOW}[!] Backup created at ${zshrc}.bak${RESET}"

    # Remove existing configure_prompt() function
    awk '
    BEGIN { skip=0 }
    /^configure_prompt\(\) *\{/ { print "# --- replaced configure_prompt() ---"; skip=1 }
    skip && /^\}/ { skip=0; next }
    skip == 0 { print }
    ' "$zshrc" > "${zshrc}.tmp"

    # Append your new function definition
    cat >> "${zshrc}.tmp" << 'EOF'

configure_prompt() {
    prompt_symbol=㉿
    # Skull emoji for root terminal
    #[ "$EUID" -eq 0 ] && prompt_symbol=💀
    case "$PROMPT_ALTERNATIVE" in
        twoline)
            PROMPT=$'%F{red}┌──${debian_chroot:+($debian_chroot)─}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))─}(%B%F{white}%n'$prompt_symbol$'%m%b%F{red})-[%B%F{white}%(6~.%-1~/…/%4~.%5~)%b%F{red}]\n└─%B%(#.%F{red}#.%F{white}$)%b%F{reset} '
            ;;
        oneline)
            PROMPT=$'${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%B%F{white}%n@%m%b%F{reset}:%B%F{red}%~%b%F{reset}%(#.#.$) '
            RPROMPT=
            ;;
        backtrack)
            PROMPT=$'${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%B%F{red}%n@%m%b%F{reset}:%B%F{white}%~%b%F{reset}%(#.#.$) '
            RPROMPT=
            ;;
    esac
    unset prompt_symbol
}
EOF

    # Replace original .zshrc
    mv "${zshrc}.tmp" "$zshrc"
    echo -e "${GREEN}[+] configure_prompt() updated successfully!${RESET}"
}

ask_logout_now() {
    echo
    echo -ne "${BOLD_RED}Do you want to log out now? ${WHITE}[Y/N]${BOLD_RED}: ${RESET}"
    read -r logout_confirm
    if [[ "$logout_confirm" == "Y" || "$logout_confirm" == "y" ]]; then
        logout_session
    else
        info_msg "Logout skipped. You can log out manually later."
    fi
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
    
    echo -ne "${BOLD_RED}Uninstall for which system? [kali/arch]: ${RESET}"
    read -r sys
    if [[ "$sys" == "arch" ]]; then
        TARGET_HOME="/home/archuser"
    else
        TARGET_HOME="/home/kali"
    fi
    DOTFILES_DIR="$TARGET_HOME/dots"
    CONFIG_DIR="$TARGET_HOME/.config"

    if [[ "$confirmation" != "Y" && "$confirmation" != "y" ]]; then
        info_msg "Uninstallation cancelled"
        return 0
    fi
    
    echo
    info_msg "Initiating complete removal process..."
    echo
    
    local packages=("i3" "i3-wm" "i3status" "i3lock" "i3blocks" "polybar" "compton" "feh" "terminator" "rofi" "dunst")
    
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
    sudo rm -rf "$CONFIG_DIR/polybar" "$CONFIG_DIR/i3" "$CONFIG_DIR/compton" "$CONFIG_DIR/terminator" "$CONFIG_DIR/rofi" "$CONFIG_DIR/wallpapers"
    
    echo
    echo -e "${WHITE}=================================================${RESET}"
    echo -e "${BOLD_GREEN}>> REMOVAL COMPLETED${RESET}"
    echo -e "${DIM_GREEN}   All components have been successfully removed${RESET}"
    echo -e "${WHITE}=================================================${RESET}"
}

# Logout function with confirmation
logout_session() {
    echo
    echo -e "${BG_YELLOW}${WHITE} ⚠ LOGOUT SESSION ⚠ ${RESET}"
    echo -e "${WHITE}=================================================${RESET}"
    echo -e "${BOLD_RED}>> SESSION TERMINATION REQUESTED${RESET}"
    echo -e "${DIM_RED}   This will log you out of the current session${RESET}"
    echo -e "${WHITE}=================================================${RESET}"
    echo
    echo -ne "${BOLD_RED}Are you sure? ${WHITE}[Y/N]${BOLD_RED}: ${RESET}"
    read -r logout_confirm

    if [[ "$logout_confirm" =~ ^[Yy]$ ]]; then
        echo
        info_msg "Logging out..."
        sleep 1
        if command -v i3-msg &>/dev/null; then
            i3-msg exit
        else
            pkill -KILL -u "$USER"
        fi
    else
        info_msg "Logout cancelled"
    fi
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
            l|L)
                logout_session
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