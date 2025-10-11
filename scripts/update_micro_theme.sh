#!/bin/bash

# Script to dynamically update micro editor's colorscheme from noctalia/matugen colors.

COLORS_JSON="/home/qurie/.config/noctalia/colors.json"
MICRO_THEME_FILE="/home/qurie/.config/micro/colorschemes/noctalia.micro"

# Check if the source color file exists
if [ ! -f "$COLORS_JSON" ]; then
    exit 1
fi

# Read colors using jq
FG=$(jq -r '.mOnSurface' "$COLORS_JSON")
BG=$(jq -r '.mSurface' "$COLORS_JSON")
COMMENT=$(jq -r '.mOnSurfaceVariant' "$COLORS_JSON")
PRIMARY=$(jq -r '.mPrimary' "$COLORS_JSON")
SECONDARY=$(jq -r '.mSecondary' "$COLORS_JSON")
TERTIARY=$(jq -r '.mTertiary' "$COLORS_JSON")
ERROR=$(jq -r '.mError' "$COLORS_JSON")
SURFACE_VARIANT=$(jq -r '.mSurfaceVariant' "$COLORS_JSON")

# Create the colorscheme content
# We do not set a default background color, allowing micro to use the terminal's background.
cat > "$MICRO_THEME_FILE" << EOF
color-link default "$FG"
color-link comment "$COMMENT"
color-link identifier "$PRIMARY"
color-link constant "$TERTIARY"
color-link constant.string "$SECONDARY"
color-link statement "$ERROR"
color-link type "$PRIMARY"
color-link special "$SECONDARY"
color-link underlined "$PRIMARY"
color-link error "bold $ERROR"
color-link todo "bold $SECONDARY"
color-link gutter-error "$ERROR"
color-link gutter-warning "$SECONDARY"
color-link statusline "$BG,$FG"
color-link tabbar "$BG,$FG"
color-link indent-char "$COMMENT"
color-link line-number "$COMMENT"
color-link current-line-number "$FG"

# For cursor-line and color-column, we set a background color that is a variant of the main surface.
color-link cursor-line "$SURFACE_VARIANT"
color-link color-column "$SURFACE_VARIANT"
EOF