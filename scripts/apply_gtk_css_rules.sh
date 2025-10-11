#!/bin/bash
# Post-process GTK CSS to add widget rules after matugen generation

# Wait a bit to ensure matugen has finished writing files
sleep 0.5

add_rules() {
    local file="$1"

    # Check if file exists and has content
    if [ ! -f "$file" ]; then
        echo "Error: $file not found"
        return 1
    fi

    # Remove everything after the last @define-color line (matugen output)
    # This ensures we keep only the color variables and remove any previous widget rules
    sed -i '/^\/\* Apply colors to GTK widgets/,$ d' "$file"

    # Add CSS rules at the end
    cat >> "$file" << 'EOF'

/* Apply colors to GTK widgets - Noctalia Material You theme */

/* Base window colors */
window, window.background {
    background-color: @window_bg_color;
    color: @window_fg_color;
}

/* Headerbar and titlebar */
headerbar, .titlebar, headerbar.default-decoration {
    background-color: @sidebar_bg_color;
    color: @headerbar_fg_color;
}

/* Sidebar */
.sidebar, .sidebar > * {
    background-color: @sidebar_bg_color;
    color: @sidebar_fg_color;
}

/* Popovers and menus */
popover, popover.background, menu, .menu {
    background-color: @sidebar_bg_color;
    color: @popover_fg_color;
}

/* Text views and content areas */
textview, textview text, .view, textview.view {
    background-color: @window_bg_color;
    color: @view_fg_color;
}

/* Buttons */
button, button.flat {
    background-color: @sidebar_bg_color;
    color: @window_fg_color;
    border-color: @popover_bg_color;
}

button:hover {
    background-color: @popover_bg_color;
}

button.suggested-action, button.accent, button.destructive-action {
    background-color: @accent_bg_color;
    color: @accent_fg_color;
}

/* Entry fields */
entry, entry.flat {
    background-color: @window_bg_color;
    color: @window_fg_color;
    border-color: @popover_bg_color;
    caret-color: @window_fg_color;
}

entry:focus {
    border-color: @accent_color;
}

/* Scrollbars */
scrollbar, scrollbar trough {
    background-color: transparent;
}

scrollbar slider {
    background-color: @popover_bg_color;
}

scrollbar slider:hover {
    background-color: @sidebar_bg_color;
}

/* Lists and tree views */
list, listview, treeview, list.view, listview.view {
    background-color: @window_bg_color;
    color: @view_fg_color;
}

list row:selected, listview row:selected, treeview:selected, list row:selected:focus {
    background-color: @accent_bg_color;
    color: @accent_fg_color;
}

/* Notebooks (tabs) */
notebook > header {
    background-color: @sidebar_bg_color;
}

notebook > header > tabs > tab:checked {
    background-color: @window_bg_color;
}

/* Toolbars */
toolbar {
    background-color: @sidebar_bg_color;
    color: @window_fg_color;
}
EOF
}

# Add rules to both GTK3 and GTK4
add_rules "$HOME/.config/gtk-3.0/gtk.css"
add_rules "$HOME/.config/gtk-4.0/gtk.css"

# Force GTK applications to reload theme
# Note: Most GTK applications don't support live theme reloading and require restart
# These methods work for some applications (like Firefox, kitty) but not all

# Method 1: Toggle gtk-theme-name to trigger reload in compatible apps
current_theme=$(gsettings get org.gnome.desktop.interface gtk-theme)
if [ "$current_theme" = "'Noctalia'" ]; then
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
    sleep 0.1
    gsettings set org.gnome.desktop.interface gtk-theme 'Noctalia'
fi

# Method 2: Update GTK settings timestamp to trigger file monitoring
touch ~/.config/gtk-3.0/settings.ini 2>/dev/null || true
touch ~/.config/gtk-4.0/settings.ini 2>/dev/null || true
