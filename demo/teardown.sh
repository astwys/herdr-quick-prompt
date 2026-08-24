#!/usr/bin/env bash
# Remove the isolated Herdr session created by setup.sh.
set -euo pipefail

session=hqp-gif
herdr session stop "$session" >/dev/null 2>&1 || true
herdr session delete "$session" >/dev/null 2>&1 || true
