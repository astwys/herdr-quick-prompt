#!/usr/bin/env bash
# Shared logic for the post-to-agent action and its picker pane.

set -euo pipefail

HERDR="${HERDR_BIN_PATH:-herdr}"

context="${HERDR_PLUGIN_CONTEXT_JSON-}"
if [[ -z "$context" ]]; then
  context='{}'
fi

notify() {
  "$HERDR" notification show "send-to-agent: $1" >/dev/null 2>&1 || true
}

# Agents whose tab matches the given tab id, as TSV:
# pane_id \t status \t agent \t title \t cwd
agents_in_tab() {
  local tab="$1"
  "$HERDR" agent list 2>/dev/null |
    jq -r --arg tab "$tab" '
      .result.agents[]
      | select(.tab_id == $tab)
      | [.pane_id, (.agent_status // "unknown"), (.agent // "agent"),
         (.terminal_title_stripped // .cwd // ""), (.cwd // "")]
      | @tsv'
}

# Agents in the given workspace, same TSV shape.
agents_in_workspace() {
  local ws="$1"
  "$HERDR" agent list 2>/dev/null |
    jq -r --arg ws "$ws" '
      .result.agents[]
      | select(.workspace_id == $ws)
      | [.pane_id, (.agent_status // "unknown"), (.agent // "agent"),
         (.terminal_title_stripped // .cwd // ""), (.cwd // "")]
      | @tsv'
}

# Every live agent, same TSV shape.
agents_all() {
  "$HERDR" agent list 2>/dev/null |
    jq -r '
      .result.agents[]
      | [.pane_id, (.agent_status // "unknown"), (.agent // "agent"),
         (.terminal_title_stripped // .cwd // ""), (.cwd // "")]
      | @tsv'
}

# Agent rows for a scope: tab | workspace | all.
agents_for_scope() {
  local scope="$1" tab="$2" ws="$3"
  case "$scope" in
    tab)       agents_in_tab "$tab" ;;
    workspace) agents_in_workspace "$ws" ;;
    *)         agents_all ;;
  esac
}

# Submit text. $1 = pane id, $2 = agent label, $3 = text.
send_to_agent() {
  local pane="$1" label="$2" text="$3"
  local out
  if ! out=$("$HERDR" agent prompt "$pane" "$text" 2>&1); then
    notify "not delivered to ${label}: ${out}"
    return 1
  fi
  notify "sent to ${label}"
}

# Open the picker pane pre-loaded with text (skips prompt selection).
# $1 = tab id, $2 = workspace id, $3 = text.
open_agent_picker() {
  exec "$HERDR" plugin pane open \
    --plugin "${HERDR_PLUGIN_ID:-herdr-quick-prompt}" \
    --entrypoint picker \
    --placement popup \
    --width 70% \
    --height 12 \
    --env "POST_TAB=$1" \
    --env "POST_WORKSPACE=$2" \
    --env "POST_TEXT=$3" \
    --focus
}
