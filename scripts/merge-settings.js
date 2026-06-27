// merge-settings.js
// Сливает permissions из стартера в ~/.claude/settings.json, чтобы агент
// отвечал в Telegram без подтверждений (Claude Code читает права именно оттуда,
// а не из settings.json в корне репозитория).
//
// Слияние безопасное: только ДОБАВЛЯЕТ нужные права (union), ничего из твоих
// существующих настроек не удаляет. Запускается автоматически из start.sh.
//
// Использование: node merge-settings.js <src settings.json> <dst ~/.claude/settings.json> <repo root>

const fs = require('fs');
const path = require('path');

const srcPath = process.argv[2];   // <repo>/settings.json
const dstPath = process.argv[3];   // ~/.claude/settings.json
const repoRoot = process.argv[4];  // абсолютный путь к репозиторию

function readJson(p, fallback) {
  try {
    return JSON.parse(fs.readFileSync(p, 'utf8'));
  } catch (e) {
    return fallback;
  }
}

const union = (a, b) => Array.from(new Set([...(a || []), ...(b || [])]));

const src = readJson(srcPath, {});
const dst = readJson(dstPath, {});

dst.permissions = dst.permissions || {};
const P = dst.permissions;
const S = src.permissions || {};

P.allow = union(P.allow, S.allow);
P.deny = union(P.deny, S.deny);
// Доступ к файлам репозитория — абсолютным путём (вместо относительного ".").
P.additionalDirectories = union(P.additionalDirectories, repoRoot ? [repoRoot] : []);

fs.mkdirSync(path.dirname(dstPath), { recursive: true });
fs.writeFileSync(dstPath, JSON.stringify(dst, null, 2) + '\n');

console.log('Права агента настроены: ' + dstPath);
