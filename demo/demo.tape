# Record a real Herdr session. Regenerate with:
#
#   cd <plugin root>
#   ./demo/setup.sh
#   vhs demo/demo.tape
#   ./demo/teardown.sh
#
# setup.sh creates an isolated session, so no real workspace or agent is used.

Output demo/demo.gif
Set FontSize 18
Set Width 2200
Set Height 1100
Set Padding 40

# Attach before recording begins, then start the first pi with hunk-review
# available. The right pane is deliberately not an agent.
Hide
Type "env -u HERDR_ENV HERDR_CONFIG_PATH=$PWD/demo/herdr-config.toml herdr session attach hqp-gif"
Enter
Sleep 1800ms
Show
Sleep 500ms
Type "pi --no-session"
Enter
Sleep 1200ms
Ctrl+A
Type "v"
Sleep 500ms
Type "echo focus-stays-here"
Enter
Sleep 700ms

# Send hunk-review to the only agent. The focused shell remains untouched.
Ctrl+A
Type "q"
Sleep 700ms
Type "hunk"
Sleep 800ms
Enter
Sleep 200ms
Ctrl+A
Type "h"
Escape
Sleep 300ms
Ctrl+A
Type "l"
Sleep 400ms

# Start a second pi in the split, then add an empty pane and keep focus there.
Type "pi --no-session"
Enter
Sleep 1200ms
Ctrl+A
Type "v"
Sleep 500ms
Type "echo focus-stays-here"
Enter
Sleep 700ms

# This time the picker shows both local agents. Cycle through tab, space, and
# all (where pi-other appears), choose the new second pi, and send.
Ctrl+A
Type "q"
Sleep 700ms
Type "hunk"
Sleep 800ms
Enter
Sleep 700ms
Ctrl+T
Sleep 600ms
Ctrl+T
Sleep 900ms
Type "p2"
Sleep 600ms
Enter
Sleep 200ms
Ctrl+A
Type "h"
Escape
Sleep 300ms
Ctrl+A
Type "l"
Sleep 400ms

# Close the second pi. With one agent left, free text skips the agent picker
# and goes straight to the first pi while focus stays in the shell pane.
Ctrl+A
Type "h"
Sleep 400ms
Ctrl+A
Type "x"
Sleep 700ms
Ctrl+A
Type "l"
Sleep 400ms
Ctrl+A
Type "q"
Sleep 700ms
Type "free text also works"
Sleep 800ms
Enter
Sleep 200ms
Ctrl+A
Type "h"
Escape
Sleep 300ms
Ctrl+A
Type "l"
Sleep 600ms
