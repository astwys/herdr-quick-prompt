# herdr-quick-prompt

A Herdr plugin that sends predefined prompts to an agent pane with one
keypress — no typing, no focus switch. Ad-hoc text works the same way: type
it in the picker instead of selecting a saved prompt.

## Demo

![demo](demo/demo.gif)

## Why

I review agent-authored diffs in [Hunk](https://hunk.dev). When I'm done, my
comments live in the Hunk session, and the agent needs to read them. That
used to mean: leave Hunk, find the right agent pane, focus it, and type some
version of "run the hunk-review skill and address my comments" — every single
time.

With this plugin, that whole detour is one keystroke from wherever I am,
agent pane included:

```text
before:
  hunk (leave comments)
    → switch focus to agent pane
    → type "look at my hunk comments"
    → switch back

after:
  hunk (leave comments)
    → keybinding, Enter
    → keep reviewing
```

The prompt that flies out is one line:

> Run the hunk-review skill and address all my review comments.

The agent loads its own skill, finds the session, and reads the comments
natively. Nothing is inlined into the message.

## The general shape

That use case is one instance of a boring pattern: there are sentences you
type into agents over and over. This plugin turns any of them into a file:

```text
~/.config/herdr/plugins/config/herdr-quick-prompt/prompts/
├── hunk-review      # the reason this plugin exists
├── explain-diff     # whatever you type repeatedly
└── run-tests
```

Filename is the picker label, content is the text, multi-line works. Adding
a prompt is adding a file; nothing else in the plugin knows or cares.

## How a send works

```text
defined keybinding
  → pick a prompt            (or type new text; Enter sends it)
  → pick an agent            (skipped when the tab has exactly one)
       scope: current tab → current space → all   [ctrl-t]
       context card: task, branch, status, output [ctrl-p]
  → herdr agent prompt <pane> <text>
```

Agents are listed with live status; blocked agents are marked red because
Herdr rejects prompts to them, working agents get the message as a
follow-up, like one typed by hand.

## Picker keys

| Key | Effect |
| --- | --- |
| `Enter` | Select the highlighted prompt, or — when nothing matches — send the text you typed |
| `ctrl-t` | Cycle target scope: current tab → current space → all. The border label always shows the active scope |
| `ctrl-p` | Toggle the context card (task, branch, status, recent output) |
| `esc` | Cancel |

## Prompts

```bash
mkdir -p "$(herdr plugin config-dir herdr-quick-prompt)/prompts"
$EDITOR "$(herdr plugin config-dir herdr-quick-prompt)/prompts/my-prompt"
```

## Requirements

- Herdr 0.8.0+
- Bash, [`jq`](https://jqlang.github.io/jq/), [`fzf`](https://github.com/junegunn/fzf)

## Install

```bash
herdr plugin install astwys/herdr-quick-prompt
```

Or while developing:

```bash
herdr plugin link /path/to/herdr-quick-prompt
```

### Keybindings

Herdr doesn't bind keys for plugins; you own the keys in
`~/.config/herdr/config.toml`. The picker itself is one binding:

```toml
[[keys.command]]
key = "prefix+alt+s"        # mine; pick any free chord — option+s on macOS without prefix, for example
type = "plugin_action"
command = "herdr-quick-prompt.send-prompt"
description = "send prompt to agent"
```

Any single prompt can also get its own binding that skips prompt selection
entirely:

```toml
[[keys.command]]
key = "prefix+alt+1"
type = "shell"
command = "bash /path/to/herdr-quick-prompt/bin/run-prompt hunk-review"
description = "prompt: hunk review"
```

One agent in the tab → sent immediately. Several → the popup opens straight
at the agent list.

Then `herdr server reload-config`.
