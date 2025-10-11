#!/bin/bash
#
# Qurie's Noctalia CachyOS Dotfiles Installer
#
# Интерактивный установщик с модульной архитектурой
#

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Пути
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$DOTFILES_DIR/modules"
CONFIG_DIR="$DOTFILES_DIR/config"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"
PATCHES_DIR="$DOTFILES_DIR/patches"

# Лог файл
LOG_FILE="$DOTFILES_DIR/install.log"

# Функции логирования
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARNING]${NC} $*" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${CYAN}[INFO]${NC} $*" | tee -a "$LOG_FILE"
}

# Функция для диалогов
ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"

    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi

    read -p "$(echo -e ${BLUE}$prompt${NC})" response
    response=${response:-$default}

    [[ "$response" =~ ^[Yy]$ ]]
}

# Функция выбора из списка
select_option() {
    local prompt="$1"
    shift
    local options=("$@")

    echo -e "${MAGENTA}$prompt${NC}"
    select opt in "${options[@]}"; do
        if [[ -n "$opt" ]]; then
            echo "$opt"
            return
        fi
    done
}

# Проверка sudo
check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        log_info "Требуется sudo доступ. Введите пароль:"
        sudo -v

        # Обновляем sudo timestamp каждые 5 минут
        while true; do
            sudo -n true
            sleep 300
            kill -0 "$$" || exit
        done 2>/dev/null &
    fi
}

# Баннер
print_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   ██████╗ ██╗   ██╗██████╗ ██╗███████╗    ██████╗  ███████╗ ║
║  ██╔═══██╗██║   ██║██╔══██╗██║██╔════╝    ██╔══██╗██╔════╝ ║
║  ██║   ██║██║   ██║██████╔╝██║█████╗      ██║  ██║█████╗   ║
║  ██║▄▄ ██║██║   ██║██╔══██╗██║██╔══╝      ██║  ██║██╔══╝   ║
║  ╚██████╔╝╚██████╔╝██║  ██║██║███████╗    ██████╔╝██║      ║
║   ╚══▀▀═╝  ╚═════╝ ╚═╝  ╚═╝╚═╝╚══════╝    ╚═════╝ ╚═╝      ║
║                                                              ║
║         Noctalia CachyOS Dotfiles Installer v1.0            ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Главное меню
main_menu() {
    print_banner

    echo -e "${GREEN}Добро пожаловать в установщик Qurie's Dotfiles!${NC}\n"

    log_info "Начало установки в $DOTFILES_DIR"

    # Проверка системы
    if ! grep -q "CachyOS\|Arch Linux" /etc/os-release 2>/dev/null; then
        log_warn "Обнаружена не Arch-based система. Продолжить?"
        if ! ask_yes_no "Некоторые пакеты могут быть недоступны"; then
            exit 1
        fi
    fi

    check_sudo

    echo ""
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Выберите режим установки:${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo "  1) Полная установка (рекомендуется)"
    echo "  2) Выборочная установка (модули по выбору)"
    echo "  3) Только обновить конфигурации"
    echo "  4) Выход"
    echo ""

    read -p "$(echo -e ${BLUE}Ваш выбор [1-4]: ${NC})" choice

    case $choice in
        1) full_install ;;
        2) selective_install ;;
        3) update_configs ;;
        4) exit 0 ;;
        *)
            log_error "Неверный выбор"
            sleep 1
            main_menu
            ;;
    esac
}

# Полная установка
full_install() {
    clear
    echo -e "${GREEN}═══ Полная установка ═══${NC}\n"

    # Опрос о GPU
    local gpu_type=""
    if lspci | grep -i nvidia &>/dev/null; then
        log_info "Обнаружена NVIDIA GPU"
        if ask_yes_no "Установить NVIDIA Wayland оптимизации?" "y"; then
            gpu_type="nvidia"
        fi
    fi

    # Установка модулей
    install_module "base" "required"

    if [[ "$gpu_type" == "nvidia" ]]; then
        install_module "nvidia" "optional"
    fi

    install_module "qt-integration" "required"
    install_module "gtk-integration" "required"

    if ask_yes_no "Установить конфигурации для developer tools (micro, git, fish)?" "y"; then
        install_module "developer-tools" "optional"
    fi

    finalize_installation
}

# Выборочная установка
selective_install() {
    clear
    echo -e "${GREEN}═══ Выборочная установка ═══${NC}\n"

    local modules=()

    if ask_yes_no "Установить базовые компоненты (Noctalia + Niri)?" "y"; then
        modules+=("base")
    fi

    if lspci | grep -i nvidia &>/dev/null; then
        if ask_yes_no "Установить NVIDIA Wayland оптимизации?" "n"; then
            modules+=("nvidia")
        fi
    fi

    if ask_yes_no "Установить Qt5/Qt6 интеграцию?" "y"; then
        modules+=("qt-integration")
    fi

    if ask_yes_no "Установить GTK3/GTK4 интеграцию?" "y"; then
        modules+=("gtk-integration")
    fi

    if ask_yes_no "Установить конфигурации для developer tools?" "n"; then
        modules+=("developer-tools")
    fi

    echo ""
    echo -e "${CYAN}Будут установлены следующие модули:${NC}"
    for module in "${modules[@]}"; do
        echo "  - $module"
    done
    echo ""

    if ask_yes_no "Продолжить установку?" "y"; then
        for module in "${modules[@]}"; do
            install_module "$module" "selected"
        done
        finalize_installation
    else
        main_menu
    fi
}

# Обновление конфигураций
update_configs() {
    clear
    echo -e "${GREEN}═══ Обновление конфигураций ═══${NC}\n"

    log_info "Копирование конфигурационных файлов..."

    # Бэкап существующих конфигов
    local backup_dir="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    for config in niri kitty noctalia qt5ct qt6ct gtk-3.0 gtk-4.0; do
        if [[ -d "$HOME/.config/$config" ]]; then
            log_info "Создание бэкапа $config..."
            cp -r "$HOME/.config/$config" "$backup_dir/"
        fi
    done

    log "Бэкап сохранён в $backup_dir"

    # Копирование новых конфигов
    rsync -av "$CONFIG_DIR/" "$HOME/.config/" --exclude='.git'

    log "Конфигурации обновлены!"

    if ask_yes_no "Перезапустить Noctalia сейчас?" "y"; then
        systemctl --user restart noctalia.service
        log "Noctalia перезапущен"
    fi

    read -p "$(echo -e ${GREEN}Нажмите Enter для возврата в меню...${NC})"
    main_menu
}

# Установка модуля
install_module() {
    local module="$1"
    local mode="${2:-optional}"

    log_info "Установка модуля: $module"

    if [[ -f "$MODULES_DIR/$module.sh" ]]; then
        source "$MODULES_DIR/$module.sh"

        if type -t "install_$module" &>/dev/null; then
            "install_$module"
            log "✓ Модуль $module установлен успешно"
        else
            log_error "Функция install_$module не найдена в модуле"
        fi
    else
        log_error "Модуль $module не найден в $MODULES_DIR"

        if [[ "$mode" == "required" ]]; then
            log_error "Критический модуль отсутствует, прерывание установки"
            exit 1
        fi
    fi
}

# Финализация установки
finalize_installation() {
    clear
    echo -e "${GREEN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║                  ✓ Установка завершена!                     ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    log "Установка завершена успешно!"

    echo -e "${CYAN}Следующие шаги:${NC}\n"
    echo "  1. Перезагрузите систему или композитор"
    echo "  2. Проверьте настройки Noctalia в Control Center"
    echo "  3. Настройте цветовые схемы под себя"
    echo ""
    echo -e "${YELLOW}Документация:${NC} $DOTFILES_DIR/README.md"
    echo -e "${YELLOW}Логи установки:${NC} $LOG_FILE"
    echo ""

    if ask_yes_no "Перезапустить Noctalia сейчас?" "y"; then
        systemctl --user restart noctalia.service
        log "Noctalia перезапущен"
    fi

    echo ""
    read -p "$(echo -e ${GREEN}Нажмите Enter для выхода...${NC})"
}

# Запуск
main_menu
