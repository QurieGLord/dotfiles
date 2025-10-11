# Qurie's Noctalia CachyOS Dotfiles

Полностью кастомизированный setup на основе **Noctalia Shell** с улучшениями и исправлениями для CachyOS (Arch Linux).

## 🎨 Особенности

- **Noctalia Shell** — современный Wayland desktop shell на базе Quickshell/QML
- **Niri** — тайловый Wayland композитор
- **Автоматическая генерация цветовых схем** для Qt5, Qt6, GTK3, GTK4
- **NVIDIA Wayland оптимизации** (опционально)
- **Полная интеграция тем** между всеми приложениями

## 📦 Что включено

### Основные компоненты
- Noctalia Shell с исправлениями для Qt/GTK интеграции
- Niri compositor конфигурация
- Kitty terminal с автоматическими темами
- Nautilus file manager с интеграцией цветовых схем

### Исправления и улучшения
- ✅ Исправлена поддержка Qt5/Qt6 цветовых схем (`custom_palette=true`)
- ✅ Добавлена автогенерация GTK3 темы (GTK3 не поддерживает Material Design переменные)
- ✅ Исправлен недостающий цвет `scrim` для predefined схем
- ✅ Настроена иконочная тема Tela-nord-dark с полной поддержкой scalable SVG

### Кастомизации
- Автоматические хуки для синхронизации тем между приложениями
- Скрипты обновления тем для micro editor, Qt приложений
- GTK CSS правила для консистентного оформления

## 🚀 Быстрая установка

```bash
git clone https://github.com/QurieGLord/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

## 📋 Модули установки

Установочный скрипт поддерживает модульную установку:

- **Base** — базовая конфигурация Noctalia + Niri
- **NVIDIA** — оптимизации для NVIDIA GPU на Wayland
- **Qt Integration** — полная интеграция Qt5/Qt6 с цветовыми схемами
- **GTK Integration** — полная интеграция GTK3/GTK4 с цветовыми схемами
- **Developer Tools** — конфигурации для micro, git, fish

## 🛠️ Структура репозитория

```
dotfiles/
├── README.md                 # Этот файл
├── install.sh                # Главный установочный скрипт
├── modules/                  # Модули установки
│   ├── base.sh              # Базовая установка
│   ├── nvidia.sh            # NVIDIA настройки
│   ├── qt-integration.sh    # Qt интеграция
│   └── gtk-integration.sh   # GTK интеграция
├── config/                   # Конфигурационные файлы
│   ├── niri/                # Niri compositor
│   ├── kitty/               # Kitty terminal
│   ├── noctalia/            # Noctalia settings
│   ├── qt5ct/               # Qt5 настройки
│   ├── qt6ct/               # Qt6 настройки
│   └── gtk-3.0/             # GTK3 настройки
├── scripts/                  # Вспомогательные скрипты
│   ├── update_micro_theme.sh
│   ├── update_qt_colorscheme.sh
│   └── apply_gtk_css_rules.sh
└── patches/                  # Патчи для Noctalia
    └── noctalia-shell/
        └── AppThemeService.qml  # Исправленный сервис тем

```

## 📝 Документация

### Изменения в Noctalia Shell

#### AppThemeService.qml
- **Строки 200-201**: Добавлен недостающий цвет `scrim = "#000000"`
- **Строки 234**: Добавлен ключ `"scrim": c(scrim)` в палитру
- **Строки 247-289**: Добавлена функция `generateGtk3Theme()` для автогенерации GTK3 темы с хардкод-цветами

### Конфигурация Qt
- `custom_palette=true` в qt5ct.conf и qt6ct.conf (критически важно!)
- `color_scheme_path` указывает на автогенерируемые noctalia.conf

### Конфигурация GTK3
- Кастомная тема `~/.themes/Noctalia/gtk-3.0/gtk.css` с прямыми цветами (без переменных)
- Автоматическое переключение через `gsettings set gtk-theme "Noctalia"`

## 🔧 Требования

- **OS**: CachyOS / Arch Linux
- **Display Server**: Wayland
- **Compositor**: Niri
- **Shell**: Noctalia Shell (будет установлен автоматически)

## 🤝 Вклад

Основано на [Noctalia Shell](https://github.com/noctalia-dev/noctalia-shell) с кастомными исправлениями и улучшениями.

## 📄 Лицензия

MIT License (для моих кастомизаций)

Noctalia Shell имеет собственную лицензию — см. upstream репозиторий.
