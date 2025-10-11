#!/bin/bash
# Auto-update Qt color scheme after theme generation

# Update qt5ct.conf
if [ -f ~/.config/qt5ct/qt5ct.conf ]; then
    if grep -q '^color_scheme_path=' ~/.config/qt5ct/qt5ct.conf; then
        sed -i 's|^color_scheme_path=.*|color_scheme_path='"$HOME"'/.config/qt5ct/colors/noctalia.conf|' ~/.config/qt5ct/qt5ct.conf
    else
        sed -i '/^icon_theme=/a color_scheme_path='"$HOME"'/.config/qt5ct/colors/noctalia.conf' ~/.config/qt5ct/qt5ct.conf
    fi
fi

# Update qt6ct.conf
if [ -f ~/.config/qt6ct/qt6ct.conf ]; then
    if grep -q '^color_scheme_path=' ~/.config/qt6ct/qt6ct.conf; then
        sed -i 's|^color_scheme_path=.*|color_scheme_path='"$HOME"'/.config/qt6ct/colors/noctalia.conf|' ~/.config/qt6ct/qt6ct.conf
    else
        sed -i '/^icon_theme=/a color_scheme_path='"$HOME"'/.config/qt6ct/colors/noctalia.conf' ~/.config/qt6ct/qt6ct.conf
    fi
fi
