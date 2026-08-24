#!/usr/bin/env bash
# Start an isolated Herdr session for the live demo recording.
set -euo pipefail
cd "$(dirname "$0")/.."

session=hqp-gif
config_dir="$PWD/demo/config"
herdr_config="$PWD/demo/herdr-config.toml"

./demo/teardown.sh >/dev/null 2>&1 || true
HERDR_CONFIG_PATH="$herdr_config" nohup herdr --session "$session" server >/tmp/hqp-gif-server.log 2>&1 &

for _ in $(seq 1 50); do
  if HERDR_CONFIG_PATH="$herdr_config" herdr --session "$session" status server 2>&1 | grep -q 'status: running'; then
    break
  fi
  sleep 0.1
done

other=$(HERDR_CONFIG_PATH="$herdr_config" herdr --session "$session" workspace create \
  --cwd "$PWD" --label 'other space' --env "HERDR_PLUGIN_CONFIG_DIR=$config_dir" --no-focus)
other_pane=$(jq -r '.result.root_pane.pane_id' <<<"$other")
HERDR_CONFIG_PATH="$herdr_config" herdr --session "$session" agent start pi-other --kind pi --pane "$other_pane" --timeout 120000 -- --no-session

HERDR_CONFIG_PATH="$herdr_config" herdr --session "$session" workspace create \
  --cwd "$PWD" --label 'review demo' --env "HERDR_PLUGIN_CONFIG_DIR=$config_dir" --focus >/dev/null

echo "live demo session ready: herdr session attach $session"
