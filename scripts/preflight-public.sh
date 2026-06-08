#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SURGE_CLI="${SURGE_CLI:-/Applications/Surge.app/Contents/Applications/surge-cli}"
RG="${RG:-rg}"

if [[ ! -x "$SURGE_CLI" ]]; then
  echo "missing surge-cli: $SURGE_CLI" >&2
  exit 1
fi

if ! command -v "$RG" >/dev/null 2>&1; then
  echo "missing ripgrep; set RG=/path/to/rg" >&2
  exit 1
fi

echo "[1/6] Surge template check"
"$SURGE_CLI" -c surge/Surge.clean.conf

echo "[2/6] Mihomo YAML check"
/usr/bin/ruby -e 'require "yaml"; YAML.load_file("mihomo/mihomo-override.yaml")'

echo "[3/6] public sensitivity scan"
if "$RG" -n --glob '!scripts/preflight-public.sh' "(psk=|ca-p12 = [A-Za-z0-9+/]{40,}|sub\\.store/download|/Users/[^/]+|iCloud~com~nssurge|Mobile Documents|http-api =|external-controller-access =|snell, *[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+)" README.md Rules surge shadowrocket mihomo scripts; then
  echo "sensitive pattern found in public files" >&2
  exit 1
fi

echo "[4/6] private Emby rule guard"
if "$RG" -n "emby-meta|Emby/Jellyfin metadata" README.md Rules surge shadowrocket mihomo; then
  echo "public Emby metadata reference found" >&2
  exit 1
fi
if [[ -e surge/rules/emby-meta.list ]]; then
  echo "surge/rules/emby-meta.list must stay private" >&2
  exit 1
fi

echo "[5/6] custom icon artifact guard"
if [[ -d icons ]] || compgen -G "scripts/generate-*policy*icon*.py" >/dev/null; then
  echo "custom policy icon artifact found" >&2
  exit 1
fi
if "$RG" -n --glob '!scripts/preflight-public.sh' "proxy-configs@main/.*/.*icon|qidewei2004/proxy-configs.*/.*icon" README.md Rules surge shadowrocket mihomo scripts; then
  echo "repo-hosted policy icon reference found" >&2
  exit 1
fi

echo "[6/6] required public rule files"
for path in \
  surge/rules/ai-major.list \
  surge/rules/pre-ai-infra.list \
  surge/rules/direct-cn.list \
  Rules/Surge/AI.txt \
  Rules/Surge/Pre-AI.txt \
  surge/modules/google-redirect.sgmodule \
  surge/modules/redirect-enhance.sgmodule \
  surge/modules/dns-mapping.sgmodule \
  mihomo/mihomo-override.yaml \
  shadowrocket/shadowrocket.conf \
  surge/Surge.clean.conf; do
  [[ -s "$path" ]] || { echo "missing or empty: $path" >&2; exit 1; }
done

echo "preflight-ok"
