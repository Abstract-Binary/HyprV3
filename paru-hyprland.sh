#!/bin/bash
# NOTE! IF YOU ADD OR REMOVE PACKAGES, make sure proper spelling as per AUR and official Arch Repo and that are present.
# Adding packages not in AUR or official Arch Repo, this script will fail. 
#
# Enjoy!
#
# Here are list of the packages that would be installed
# hyprland- This is the Hyprland compositor
# foot: This is the default terminal
# waybar-hyprland: This is a fork of waybar with Hyprland workspace support
# swaybg: This is used to set a desktop background image
# swaylock-effects: This allows for the locking of the desktop its a fork that adds some editional visual effects
# wofi: This is an application launcher menu
# wlogout: This is a logout menu that allows for shutdown, reboot and sleep
# mako: This is a graphical notification daemon
# thunar with necessary plugins: This is a graphical file manager. Note, not all plugins included. See readme notes
# ttf-jetbrains-mono-nerd : some nerd fonts needed for proper icons in waybar
# otf-font-awesome-4 and otf-font-awesome # necessary for symbols / weather
# ttf-droid - suggested for international fonts to display properly
# polkit-gnome: needed to get superuser access on some graphical appliaction
# python-requests: needed for the weather module script to execute
# grim: This is a screenshot tool it grabs images from a Wayland compositor
# slurp: This helps with screenshots, it selects a region in a Wayland compositor
# viewnior: for photo viewing
# pamixer: This helps with audio settings such as volume
# brightnessctl: used to control monitor bright level
# nwg-look: used to set GTK theme
# xdg-desktop-portal-hyprland: xdg-desktop-portal backend for hyprland
# mpv: Video player and for wofi-beats to work
# qt5ct: for visual settings for qt-apps
# mousepad: simple text editor

# OPTIONAL - packages to be installed. (you will be asked on the script)
# Bluetooth packages (blueman, bluez, bluez-utils)
# Dracula icons and themes
# Bibata Cursor theme
# Asusctl, Supergfxctl (ASUS ROG laptop stuffs)

# Define color variables
GREEN="$(tput setaf 2)[OK]$(tput sgr0)"
RED="$(tput setaf 1)[ERROR]$(tput sgr0)"
YELLOW="$(tput setaf 3)[NOTE]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"

# Set the script to exit on error
set -e

printf "$(tput setaf 2) Welcome to the Arch Linux PARU Hyprland installer!\n $(tput sgr0)"

sleep 3

printf "$YELLOW PLEASE BACKUP YOUR FILES BEFORE PROCEEDING!
This script will overwrite some of your configs and files!"

sleep 2

printf "\n
$YELLOW  Some commands requires you to enter your password inorder to execute
If you are worried about entering your password, you can cancel the script now with CTRL Q or CTRL C and review contents of this script. \n"

sleep 2
# Check if paru is installed
ISparu=/sbin/paru

if [ -f "$ISparu" ]; then
    printf "\n%s - paru was located, moving on.\n" "$GREEN"
else 
    printf "\n%s - paru was NOT located\n" "$YELLOW"
    read -n1 -rep "${CAT} Would you like to install paru (y,n)" INST
    if [[ $INST =~ ^[Yy]$ ]]; then
        git clone https://aur.archlinux.org/paru-bin.git
        cd paru-bin
        makepkg -si --noconfirm 
        cd ..
    else
        printf "%s - paru is required for this script, now exiting\n" "$RED"
        exit
    fi
# update system before proceed
    printf "${YELLOW} System Update to avoid issue\n" "GREEN"
    paru -Syu --noconfirm
fi

# Prompt user to install packages
# Function to check if a command executed successfully
function check_command_status {
    if [ $? -ne 0 ]; then
        printf "\nError executing command: %s\n" "$1"
        exit 1
    fi
}
# Function to print error messages
print_error() {
    printf " %s%s\n" "$RED" "$1" "$NC" >&2
}

# Function to print success messages
print_success() {
    printf "%s%s%s\n" "$GREEN" "$1" "$NC"
}

# Install necessary packages
read -n1 -rep "${CAT} Would you like to install the packages? (y/n)" inst
echo

if [[ $inst =~ ^[Nn]$ ]]; then
    printf "${YELLOW} No packages installed. Goodbye! \n"
            exit 1
        fi

if [[ $inst =~ ^[Yy]$ ]]; then
    read -n1 -rep "${CAT} Would you like to install the Nvidia Hyprland? (y/n)" inst2
    echo

    if [[ $inst2 =~ ^[Yy]$ ]]; then
        # Install Nvidia Hyprland
        if ! paru -S --noconfirm hyprland-nvidia-git; then
            print_error "Failed to install Nvidia Hyprland - pls remove any conflicting package"
            exit 1
        fi
    else
        # Install non-Nvidia Hyprland
        printf "${YELLOW} None Nvidia-Hyprland will be installed.\n"
        if ! paru -S --noconfirm hyprland; then
            print_error " Failed to install Hyprland."
            exit 1
        fi
    fi

    printf "${YELLOW} Installing additional packages. Please wait..."
    sleep 1

    # Install packages
   hypr_pkgs="waybar-hyprland foot swaybg swaylock-effects wofi wlogout mako xdg-desktop-portal-hyprland  grim slurp wl-clipboard polkit-gnome"    
   font_pkgs="otf-font-awesome ttf-jetbrains-mono-nerd otf-font-awesome-4 ttf-fantasque-sans-mono"
   app_pkgs="nwg-look-bin qt5ct btop jq gvfs ffmpegthumbs mousepad mpv"
   app_pkgs2="python-requests pamixer brightnessctl viewnior pavucontrol playerctl network-manager-applet cava"

       
    if ! paru -S --noconfirm $hypr_pkgs $font_pkgs $app_pkgs $app_pkgs2; then
        print_error " Failed to install additional packages.\n"
        exit 1
    fi

    echo
    print_success " All necessary packages installed successfully."
else
    echo
    print_error " Packages not installed."
    sleep 2
fi

# additional packages (File Manager)
read -n1 -rep "${CAT} OPTIONAL - Would you like to install Thunar as file manager? (y/n)" inst4
    echo

    if [[ $inst4 =~ ^[Yy]$ ]]; then
	file_pkgs="thunar thunar-volman tumbler"
        if ! paru -S --noconfirm $file_pkgs; then
            print_error "Failed to install thunar"
            exit 1
	    cp -r config/xfce4 ~/.config/ || { echo "Error: Failed to copy xfce4 config files."; exit 1; }
            cp -r config/Thunar ~/.config/ || { echo "Error: Failed to copy Thunar config files."; exit 1; }
        fi
    else
        printf "${YELLOW} Thunar will not be installed.\n"
        fi
 

# additional packages (themes)
read -n1 -rep "${CAT} OPTIONAL - Would you like to install Dracula Icons and Themes and Bibata Cursor Themes? (y/n)" inst3
    echo

    if [[ $inst3 =~ ^[Yy]$ ]]; then
	theme_pkgs="dracula-gtk-theme dracula-icons-git bibata-cursor-theme-bin"
        if ! paru -S --noconfirm $theme_pkgs; then
            print_error "Failed to install additional themes"
            exit 1
        fi
    else
        printf "${YELLOW} No additional themes installed.\n"
        fi
 
 # Clean out other portals
printf "${YELLOW} Clearing any other xdg-desktop-portal implementations...\n"

# Check if packages are installed and uninstall if present
if pacman -Qs xdg-desktop-portal-gnome > /dev/null ; then
    echo "Removing xdg-desktop-portal-gnome..."
    sudo pacman -R --noconfirm xdg-desktop-portal-gnome
fi

if pacman -Qs xdg-desktop-portal-gtk > /dev/null ; then
    echo "Removing xdg-desktop-portal-gtk..."
    sudo pacman -R --noconfirm xdg-desktop-portal-gtk
fi

if pacman -Qs xdg-desktop-portal-kde > /dev/null ; then
    echo "Removing xdg-desktop-portal-kde..."
    sudo pacman -R --noconfirm xdg-desktop-portal-kde
fi

if pacman -Qs xdg-desktop-portal-wlr > /dev/null ; then
    echo "Removing xdg-desktop-portal-wlr..."
    sudo pacman -R --noconfirm xdg-desktop-portal-wlr
fi

if pacman -Qs xdg-desktop-portal-lxqt > /dev/null ; then
    echo "Removing xdg-desktop-portal-lxqt..."
    sudo pacman -R --noconfirm xdg-desktop-portal-lxqt
fi

print_success " All other XDG-DESKTOP-PORTAL Implementation Cleared"


### Copy Config Files ###
set -e # Exit immediately if a command exits with a non-zero status.

read -n1 -rep "${CAT} Would you like to copy config and wallpaper files? (y,n)" CFG
if [[ $CFG =~ ^[Yy]$ ]]; then
    printf " Copying config files...\n"
    mkdir -p ~/.config
    cp -r config/hypr ~/.config/ || { echo "Error: Failed to copy hypr config files."; exit 1; }
    cp -r config/foot ~/.config/ || { echo "Error: Failed to copy foot config files."; exit 1; }
    cp -r config/swaylock ~/.config/ || { echo "Error: Failed to copy swaylock config files."; exit 1; }
    cp -r config/wlogout ~/.config/ || { echo "Error: Failed to copy wlogout config files."; exit 1; }
    cp -r config/btop ~/.config/ || { echo "Error: Failed to copy btop config files."; exit 1; } 
    cp -r config/cava ~/.config/ || { echo "Error: Failed to copy cava config files."; exit 1; } 
    mkdir -p ~/Pictures
    cp -r wallpapers ~/Pictures/ || { echo "Error: Failed to copy wallpapers."; exit 1; }
    
    # Set some files as executable 
    chmod +x ~/.config/hypr/scripts/airplane-mode.sh
    chmod +x ~/.config/hypr/scripts/brightness
    chmod +x ~/.config/hypr/scripts/changeLayout
    chmod +x ~/.config/hypr/scripts/changeWallpaper
    chmod +x ~/.config/hypr/scripts/fullmenu
    chmod +x ~/.config/hypr/scripts/glassmorphismToggle
    chmod +x ~/.config/hypr/scripts/lockscreen
    chmod +x ~/.config/hypr/scripts/menu
    chmod +x ~/.config/hypr/scripts/notifications
    chmod +x ~/.config/hypr/scripts/portal-arch-hyprland
    chmod +x ~/.config/hypr/scripts/screenshot
    chmod +x ~/.config/hypr/scripts/startup
    chmod +x ~/.config/hypr/scripts/statusbar
    chmod +x ~/.config/hypr/scripts/switch-lid.sh
    chmod +x ~/.config/hypr/scripts/touchpad.sh
    chmod +x ~/.config/hypr/scripts/volume
    chmod +x ~/.config/hypr/scripts/weather.sh
    chmod +x ~/.config/hypr/scripts/wofi-beats
else
   print_error " No Config files and wallpaper files copied"
fi

# BLUETOOTH
read -n1 -rep "${CAT} OPTIONAL - Would you like to install Bluetooth packages? (y/n)" BLUETOOTH
if [[ $BLUETOOTH =~ ^[Yy]$ ]]; then
    printf " Installing Bluetooth Packages...\n"
 blue_pkgs="bluez bluez-utils blueman"
    if ! paru -S --noconfirm $blue_pkgs; then
       	print_error "Failed to install bluetooth packages"    
    printf " Activating Bluetooth Services...\n"
    sudo systemctl enable --now bluetooth.service
    sleep 2
    fi
else
    printf "${YELLOW} No bluetooth packages installed..\n"
	fi
 
### Install software for Asus ROG laptops ###
read -n1 -rep "${CAT} (OPTIONAL - ONLY for ROG Laptops) Would you like to install Asus ROG software support? (y/n)" ROG
if [[ $ROG =~ ^[Yy]$ ]]; then
    printf " Installing ASUS ROG packages...\n"
 ROG_pkgs="asusctl supergfxctl rog-control-center"
    if ! paru -S --noconfirm $ROG_pkgs; then
       	print_error "Failed to install ROG packages"    
    printf " Activating ROG services...\n"
    sudo systemctl daemon-reload && sudo systemctl enable --now supergfxd
    sleep 2
    fi
else
    printf "${YELLOW} Asus ROG software support not installed..\n"
fi

### Disable wifi powersave mode ###
read -n1 -rep "${CAT} Would you like to disable wifi powersave? (y,n)" WIFI
if [[ $WIFI =~ ^[Yy]$ ]]; then
    LOC="/etc/NetworkManager/conf.d/wifi-powersave.conf"
    printf "${YELLOW} The following has been added to $LOC.\n"
    printf "[connection]\nwifi.powersave = 2" | sudo tee -a $LOC
    printf "\n"
    printf "${YELLOW} Restarting NetworkManager service...\n"
    sudo systemctl restart NetworkManager
    sleep 3
fi
### Script is done ###
printf "\n${GREEN} Installation Completed.\n"
printf "\n${YELLOW} You can start Hyprland by typing Hyprland (note the capital H!).\n"
printf "\n${YELLOW} No Login Manager installed. You can start Hyprland by typing Hyprland (note the capital H!).\n"
printf "\n${YELLOW} It is highly recommended to reboot your computer first.\n"
read -n1 -rep "${CAT} Would you like to start Hyprland now? (y,n)" HYP
if [[ $HYP =~ ^[Yy]$ ]]; then
    if command -v Hyprland >/dev/null; then
        exec Hyprland
    else
         print_error " Hyprland not found. Please make sure it is installed and try again.\n"
        exit 1
    fi
else
    exit
fi
