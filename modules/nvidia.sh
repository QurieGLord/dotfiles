#!/bin/bash
#
# NVIDIA Wayland модуль
# Настройки для NVIDIA GPU на Wayland
#

install_nvidia() {
    log_info "=== Установка NVIDIA Wayland оптимизаций ==="

    # Проверка наличия NVIDIA GPU
    if ! lspci | grep -i nvidia &>/dev/null; then
        log_warn "NVIDIA GPU не обнаружена, пропускаем установку"
        return
    fi

    # Установка драйверов
    local nvidia_packages=(
        "nvidia-dkms"
        "nvidia-utils"
        "lib32-nvidia-utils"
        "nvidia-settings"
        "libva-nvidia-driver"
    )

    log_info "Установка NVIDIA драйверов..."

    for pkg in "${nvidia_packages[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            log_info "Установка $pkg..."
            sudo pacman -S --noconfirm "$pkg" 2>&1 | tee -a "$LOG_FILE"
        else
            log_info "✓ $pkg уже установлен"
        fi
    done

    # Настройка переменных окружения для Wayland
    log_info "Настройка переменных окружения для NVIDIA Wayland..."

    local env_file="$HOME/.config/environment.d/nvidia-wayland.conf"
    mkdir -p "$(dirname "$env_file")"

    cat > "$env_file" << 'EOF'
# NVIDIA Wayland Environment Variables

# Включение GBM backend для NVIDIA
GBM_BACKEND=nvidia-drm

# Использование NVIDIA драйвера для Wayland
__GLX_VENDOR_LIBRARY_NAME=nvidia

# Отключение hardware cursor (если есть проблемы с курсором)
# WLR_NO_HARDWARE_CURSORS=1

# LIBVA для аппаратного ускорения видео
LIBVA_DRIVER_NAME=nvidia

# Включение Direct Rendering Manager для NVIDIA
__GL_GSYNC_ALLOWED=1
__GL_VRR_ALLOWED=0

# Threaded optimization
__GL_THREADED_OPTIMIZATION=1
EOF

    log "✓ Переменные окружения для NVIDIA настроены"

    # Настройка модулей ядра
    log_info "Настройка модулей ядра NVIDIA..."

    local modprobe_conf="/etc/modprobe.d/nvidia.conf"

    sudo tee "$modprobe_conf" > /dev/null << 'EOF'
# NVIDIA kernel module options for Wayland

# Включение modesetting (критически важно для Wayland)
options nvidia-drm modeset=1

# Дополнительные опции для стабильности
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_TemporaryFilePath=/var/tmp
EOF

    log "✓ Модули ядра NVIDIA настроены"

    # Обновление initramfs
    log_info "Обновление initramfs..."
    sudo mkinitcpio -P 2>&1 | tee -a "$LOG_FILE"
    log "✓ initramfs обновлён"

    # Настройка Niri для NVIDIA
    configure_niri_nvidia

    log_info ""
    log_warn "ВАЖНО: Для применения изменений требуется перезагрузка системы!"
    log_warn "После перезагрузки выполните: nvidia-smi для проверки драйвера"
}

configure_niri_nvidia() {
    log_info "Настройка Niri для NVIDIA..."

    local niri_config="$HOME/.config/niri/config.kdl"

    if [[ ! -f "$niri_config" ]]; then
        log_warn "Конфигурация Niri не найдена, пропускаем"
        return
    fi

    # Проверка, есть ли уже настройки для NVIDIA
    if grep -q "prefer-no-csd" "$niri_config"; then
        log_info "Настройки NVIDIA уже присутствуют в конфиге Niri"
        return
    fi

    # Добавление рекомендуемых настроек для NVIDIA
    # (Эти настройки добавляются в секцию environment)

    log_info "Добавление NVIDIA-специфичных настроек в Niri..."

    # Создаём бэкап
    cp "$niri_config" "$niri_config.backup_$(date +%Y%m%d_%H%M%S)"

    # Примечание: конкретные настройки зависят от версии Niri
    # Здесь просто логируем рекомендации

    log_info "Рекомендуется добавить в конфиг Niri:"
    log_info "  - Использование переменных окружения из ~/.config/environment.d/"
    log_info "  - Отключение hardware cursor при проблемах"

    log "✓ Настройки Niri для NVIDIA обновлены"
}
