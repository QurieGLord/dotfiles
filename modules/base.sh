#!/bin/bash
#
# Базовый модуль установки
# Устанавливает Noctalia Shell, Niri и основные компоненты
#

install_base() {
    log_info "=== Установка базовых компонентов ==="

    # Проверка зависимостей
    local packages=(
        "niri"
        "kitty"
        "nautilus"
        "brightnessctl"
        "ddcutil"
        "gpu-screen-recorder"
        "matugen-bin"
        "cliphist"
        "wlsunset"
        "tela-icon-theme"
        "papirus-icon-theme"
        "ttf-roboto"
        "inter-font"
        "ttf-jetbrains-mono-nerd"
    )

    log_info "Установка зависимостей..."

    for pkg in "${packages[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            log_info "Установка $pkg..."
            if yay -S --noconfirm "$pkg" 2>&1 | tee -a "$LOG_FILE"; then
                log "✓ $pkg установлен"
            else
                log_warn "Не удалось установить $pkg (возможно уже установлен или недоступен)"
            fi
        else
            log_info "✓ $pkg уже установлен"
        fi
    done

    # Установка Noctalia Shell
    install_noctalia_shell

    # Копирование конфигураций
    log_info "Копирование конфигурационных файлов..."

    # Niri
    if [[ -d "$CONFIG_DIR/niri" ]]; then
        mkdir -p "$HOME/.config/niri"
        cp -r "$CONFIG_DIR/niri/"* "$HOME/.config/niri/"
        log "✓ Конфигурация Niri скопирована"

        # Валидация конфига Niri
        if command -v niri &>/dev/null; then
            if niri validate; then
                log "✓ Конфигурация Niri валидна"
            else
                log_error "Конфигурация Niri содержит ошибки!"
            fi
        fi
    fi

    # Kitty
    if [[ -d "$CONFIG_DIR/kitty" ]]; then
        mkdir -p "$HOME/.config/kitty"
        cp -r "$CONFIG_DIR/kitty/"* "$HOME/.config/kitty/"
        log "✓ Конфигурация Kitty скопирована"
    fi

    # Noctalia settings
    if [[ -d "$CONFIG_DIR/noctalia" ]]; then
        mkdir -p "$HOME/.config/noctalia"
        # Не перезаписываем settings.json если уже существует
        if [[ ! -f "$HOME/.config/noctalia/settings.json" ]]; then
            cp "$CONFIG_DIR/noctalia/settings.json" "$HOME/.config/noctalia/"
            log "✓ Конфигурация Noctalia скопирована"
        else
            log_info "settings.json уже существует, пропускаем"
        fi
    fi

    # Скрипты
    if [[ -d "$SCRIPTS_DIR" ]]; then
        mkdir -p "$HOME/.local/bin"
        cp "$SCRIPTS_DIR/"*.sh "$HOME/.local/bin/"
        chmod +x "$HOME/.local/bin/"*.sh
        log "✓ Вспомогательные скрипты установлены в ~/.local/bin"
    fi

    # Темы
    mkdir -p "$HOME/.themes"
    log "✓ Директория тем создана"

    # Включение systemd сервиса
    if systemctl --user list-unit-files | grep -q noctalia.service; then
        systemctl --user enable noctalia.service
        log "✓ Noctalia service включен"
    fi
}

install_noctalia_shell() {
    log_info "Установка Noctalia Shell..."

    # Проверка наличия в AUR
    if yay -Ss noctalia-shell &>/dev/null; then
        log_info "Установка noctalia-shell из AUR..."
        yay -S --noconfirm noctalia-shell

        log "✓ Noctalia Shell установлен"

        # Применение патчей
        apply_noctalia_patches
    else
        log_error "noctalia-shell не найден в AUR"
        log_info "Пропускаем установку (возможно установлен вручную)"
    fi
}

apply_noctalia_patches() {
    log_info "Применение патчей для Noctalia..."

    if [[ -f "$PATCHES_DIR/noctalia-shell/AppThemeService.qml" ]]; then
        local target="/etc/xdg/quickshell/noctalia-shell/Services/AppThemeService.qml"

        if [[ -f "$target" ]]; then
            # Бэкап оригинала
            sudo cp "$target" "$target.backup_$(date +%Y%m%d_%H%M%S)"

            # Применение патча
            sudo cp "$PATCHES_DIR/noctalia-shell/AppThemeService.qml" "$target"

            log "✓ Патч AppThemeService.qml применён"
            log_info "  - Добавлена поддержка GTK3 с хардкод-цветами"
            log_info "  - Исправлен недостающий цвет scrim"
        else
            log_warn "Целевой файл не найден, патч не применён"
        fi
    fi
}
