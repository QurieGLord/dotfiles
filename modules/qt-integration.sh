#!/bin/bash
#
# Qt Integration модуль
# Полная интеграция Qt5/Qt6 с цветовыми схемами Noctalia
#

install_qt-integration() {
    log_info "=== Установка Qt5/Qt6 интеграции ==="

    # Установка Qt пакетов
    local qt_packages=(
        "qt5-base"
        "qt6-base"
        "qt5ct"
        "qt6ct"
        "qalculate-gtk"  # Для тестирования
    )

    log_info "Установка Qt пакетов..."

    for pkg in "${qt_packages[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            log_info "Установка $pkg..."
            sudo pacman -S --noconfirm "$pkg" 2>&1 | tee -a "$LOG_FILE"
        else
            log_info "✓ $pkg уже установлен"
        fi
    done

    # Копирование конфигураций Qt
    log_info "Копирование конфигураций Qt..."

    # Qt5ct
    if [[ -d "$CONFIG_DIR/qt5ct" ]]; then
        mkdir -p "$HOME/.config/qt5ct/colors"
        cp -r "$CONFIG_DIR/qt5ct/"* "$HOME/.config/qt5ct/"

        # КРИТИЧЕСКИ ВАЖНО: Установка custom_palette=true
        sed -i 's/custom_palette=false/custom_palette=true/' "$HOME/.config/qt5ct/qt5ct.conf" 2>/dev/null || true

        log "✓ Конфигурация Qt5ct скопирована"
    fi

    # Qt6ct
    if [[ -d "$CONFIG_DIR/qt6ct" ]]; then
        mkdir -p "$HOME/.config/qt6ct/colors"
        cp -r "$CONFIG_DIR/qt6ct/"* "$HOME/.config/qt6ct/"

        # КРИТИЧЕСКИ ВАЖНО: Установка custom_palette=true
        if ! grep -q "custom_palette" "$HOME/.config/qt6ct/qt6ct.conf"; then
            sed -i '/\[Appearance\]/a custom_palette=true' "$HOME/.config/qt6ct/qt6ct.conf"
        else
            sed -i 's/custom_palette=false/custom_palette=true/' "$HOME/.config/qt6ct/qt6ct.conf"
        fi

        log "✓ Конфигурация Qt6ct скопирована"
    fi

    # Установка переменных окружения
    configure_qt_environment

    # Проверка настроек
    verify_qt_config

    log "✓ Qt интеграция завершена"
}

configure_qt_environment() {
    log_info "Настройка переменных окружения для Qt..."

    local env_file="$HOME/.config/environment.d/qt-theme.conf"
    mkdir -p "$(dirname "$env_file")"

    cat > "$env_file" << 'EOF'
# Qt Theme Configuration

# Использование qt6ct для Qt6 приложений
QT_QPA_PLATFORMTHEME=qt6ct

# Для Qt5 приложений (если нужно)
# QT_QPA_PLATFORMTHEME=qt5ct

# Альтернативно можно использовать:
# QT_STYLE_OVERRIDE=Fusion
EOF

    log "✓ Переменные окружения Qt настроены"

    # Обновление systemd user environment
    if [[ -f "$env_file" ]]; then
        systemctl --user import-environment QT_QPA_PLATFORMTHEME 2>/dev/null || true
    fi
}

verify_qt_config() {
    log_info "Проверка конфигурации Qt..."

    local issues=0

    # Проверка Qt5ct
    if [[ -f "$HOME/.config/qt5ct/qt5ct.conf" ]]; then
        if grep -q "custom_palette=true" "$HOME/.config/qt5ct/qt5ct.conf"; then
            log "✓ Qt5ct: custom_palette=true установлен"
        else
            log_error "Qt5ct: custom_palette НЕ установлен в true!"
            issues=$((issues + 1))
        fi

        if grep -q "color_scheme_path.*noctalia.conf" "$HOME/.config/qt5ct/qt5ct.conf"; then
            log "✓ Qt5ct: color_scheme_path указывает на noctalia.conf"
        else
            log_warn "Qt5ct: color_scheme_path не настроен"
        fi
    fi

    # Проверка Qt6ct
    if [[ -f "$HOME/.config/qt6ct/qt6ct.conf" ]]; then
        if grep -q "custom_palette=true" "$HOME/.config/qt6ct/qt6ct.conf"; then
            log "✓ Qt6ct: custom_palette=true установлен"
        else
            log_error "Qt6ct: custom_palette НЕ установлен в true!"
            issues=$((issues + 1))
        fi

        if grep -q "color_scheme_path.*noctalia.conf" "$HOME/.config/qt6ct/qt6ct.conf"; then
            log "✓ Qt6ct: color_scheme_path указывает на noctalia.conf"
        else
            log_warn "Qt6ct: color_scheme_path не настроен"
        fi
    fi

    if [[ $issues -gt 0 ]]; then
        log_warn "Обнаружены проблемы в конфигурации Qt ($issues)"
        log_warn "Qt приложения могут не подхватывать цветовые схемы!"
    else
        log "✓ Конфигурация Qt проверена, проблем не обнаружено"
    fi
}
