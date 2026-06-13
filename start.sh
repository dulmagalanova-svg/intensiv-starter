#!/usr/bin/env bash
# ───────────────────────────────────────────────────────────────────
# start.sh — запуск твоего личного агента.
#
# Что делает: загружает настройки из secrets/channel.env и запускает
# Claude Code с подключённым Telegram-мостом (dashi-channel).
# Пока это окно открыто — агент «бодрствует» и отвечает в Telegram.
# Закрыл окно → агент «уснул» (для работы 24/7 см. README, раздел
# «Где держать агента»).
#
# Запуск:  ./start.sh
# ───────────────────────────────────────────────────────────────────
set -euo pipefail

# Папка, где лежит этот скрипт (корень репозитория).
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$ROOT/secrets/channel.env"
PLUGIN_DIR="$ROOT/dashi-plugin-claude-code/plugin"

# 1. Проверяем, что файл с настройками создан.
if [ ! -f "$ENV_FILE" ]; then
  echo "ОШИБКА: не найден файл secrets/channel.env"
  echo
  echo "Сделай так:"
  echo "  1. Скопируй secrets/channel.env.example → secrets/channel.env"
  echo "  2. Впиши в него токен бота и свой Telegram ID"
  echo "  3. Запусти ./start.sh снова"
  exit 1
fi

# 2. Проверяем, что зависимости установлены (Шаг 5 в README).
if [ ! -d "$PLUGIN_DIR/node_modules" ]; then
  echo "ОШИБКА: не установлены зависимости плагина."
  echo "Выполни один раз:"
  echo "  cd dashi-plugin-claude-code/plugin && bun install"
  echo "Потом запусти ./start.sh снова."
  exit 1
fi

# 3. Загружаем настройки из channel.env в окружение.
echo "Загружаю настройки из secrets/channel.env ..."
set -a
# shellcheck disable=SC1090
. "$ENV_FILE"
set +a

# 4. Запускаем агента из папки plugin (чтобы Claude Code нашёл CLAUDE.md
#    в корне репозитория, поднявшись вверх по дереву).
echo "Запускаю агента... (для остановки нажми Ctrl+C)"
echo "Теперь напиши своему боту в Telegram — он ответит."
cd "$PLUGIN_DIR"
exec claude --dangerously-load-development-channels server:dashi-channel
