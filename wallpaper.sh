#!/bin/bash

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/wallpapers"

# Function to list wallpapers
menu() {
    # Find all image files in the wallpaper directory and format them for selection
    find "${WALLPAPER_DIR}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \)
}

# Main function
main() {
    echo "Listing wallpapers..."
    menu_output=$(menu)

    # Use rofi to display the list of wallpapers and allow selection
    choice=$(echo "$menu_output" | rofi -dmenu -i -p "Select Wallpaper:")

    # Exit if no wallpaper was selected
    if [[ -z "$choice" ]]; then
        echo "No wallpaper selected."
        exit 1
    fi

    selected_wallpaper="$choice"

    echo "Setting wallpaper: $selected_wallpaper"

    # Set the wallpaper using `swww`
    swww img "$selected_wallpaper" --transition-type any --transition-fps 60 --transition-duration 1.5

    # Generate a color scheme using `wal`
    wal -i "$selected_wallpaper" -n --cols16

    # Update Kitty terminal colors
    cat ~/.cache/wal/colors-kitty.conf > ~/.config/kitty/current-theme.conf
    kitty @ set-colors -a ~/.config/kitty/current-theme.conf

    # Reload Waybar to apply new colors
    swaymsg reload
    swaymsg exec "killall waybar; waybar &"

    # Update pywalfox theme for Firefox
    pywalfox update

    # Update Cava visualizer colors
    color1=$(awk 'match($0, /color2=\47(.*)\47/,a) { print a[1] }' ~/.cache/wal/colors.sh)
    color2=$(awk 'match($0, /color3=\47(.*)\47/,a) { print a[1] }' ~/.cache/wal/colors.sh)
    cava_config="$HOME/.config/cava/config"
    sed -i "s/^gradient_color_1 = .*/gradient_color_1 = '$color1'/" $cava_config
    sed -i "s/^gradient_color_2 = .*/gradient_color_2 = '$color2'/" $cava_config
    pkill -USR2 cava || cava -p $cava_config

    # Copy the selected wallpaper to a common location for other uses
    cp "$selected_wallpaper" ~/wallpapers/pywallpaper.jpg

    # Notify the user of the changes
    notify-send "Wallpaper Changed" "New wallpaper and colors applied successfully!"
}

# Run the main function
main

