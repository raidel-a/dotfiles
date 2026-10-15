# herdr-agent-icons

Vendored from `~/Developer/repos/herdr-agent-icons` on 2026-10-14.

An icon font built from the agent logos Herdr publishes at
[herdr.dev/assets/agent-icons](https://herdr.dev).

Terminals render text cells, so the only way to show these logos in the Herdr
sidebar is to put them in a font and address them by codepoint. SVG cannot be
used directly, and the Kitty graphics path exists only for images that an
application *inside a pane* emits, not for the sidebar's own chrome.

The built font is committed at `Fonts/HerdrAgentIcons-Regular.ttf`, so a fresh
clone gets working glyphs without running this script. Rebuild only when
changing the icon set or codepoints.

## Build

```bash
uv venv .venv && uv pip install --python .venv/bin/python fonttools pillow
./.venv/bin/python build.py
```

Requires `rsvg-convert` and `potrace` on `PATH`:

```bash
brew install librsvg potrace
```

By default the font lands in `~/Library/Fonts/HerdrAgentIcons-Regular.ttf`
(override with `--out`). Run `fc-cache -f` if your terminal does not pick it up
immediately. Copy the result to `Fonts/HerdrAgentIcons-Regular.ttf` to commit it.

## Use

In the Ghostty config, list the font last so it only supplies these codepoints
(see `ghostty/config` in this repo):

```
font-family = Maple Mono NF CN
font-family = Symbols Nerd Font
font-family = Herdr Agent Icons
```

Then map the agents in `~/.config/herdr/config-glyphs.toml`. The values are
TOML unicode escapes:

```toml
[ui.sidebar.agents.agent_icons]
claude   = "\ue00b"
codex    = "\ue00c"
cursor   = "\ue00d"
copilot  = "\ue00e"
grok     = "\ue00f"
hermes   = "\ue010"
opencode = "\ue011"
pi       = "\ue012"
```

That file is untracked and machine-local; the `herdrr` shell function in
`zsh/.zshrc` points the patched client at it.

## Codepoints

Assigned in the Private Use Area starting at `U+E00B`, in a fixed order so
regenerating does not silently remap an icon a config already refers to.

| Codepoint | Glyph name       | Agent         |
| --------- | ---------------- | ------------- |
| U+E00B    | `agent_claude`   | Claude Code   |
| U+E00C    | `agent_codex`    | Codex         |
| U+E00D    | `agent_cursor`   | Cursor        |
| U+E00E    | `agent_copilot`  | GitHub Copilot |
| U+E00F    | `agent_grok`     | Grok          |
| U+E010    | `agent_hermes`   | Hermes        |
| U+E011    | `agent_opencode` | opencode      |
| U+E012    | `agent_pi`       | Pi            |

These live in a block Nerd Fonts leaves free. Do not use U+E000-U+E007: Nerd
Fonts already occupies those with its `pom-*` timer icons, and any Nerd Font
earlier in the terminal's font stack will shadow this font there. The terminal
then shows the wrong logo even though Font Book displays the right one, because
Font Book renders the font in isolation.

Check any new range against Nerd Fonts' `glyphnames.json` before using it.

## Notes from building it

Three things in the pipeline are not obvious and are commented in `build.py`:

- **The alpha channel is the shape, not the colour.** Most of the SVGs are dark
  on transparent, but `codex-mask.svg` is `fill="white"` with no alpha, so
  tracing luminance finds a uniformly white image and produces nothing.
- **Threshold, do not invert.** potrace keeps regions darker than its
  threshold. Inverting the flattened logo floods thin-stroke marks such as
  Claude's, where the negative space dominates the bounding box and the shape
  fills solid. Thresholding the alpha channel avoids that.
- **Contour direction must be preserved.** potrace already emits outer contours
  opposite to their holes. Passing `reverse_direction=True` to `Cu2QuPen` flips
  every contour, so the non-zero winding rule fills holes solid.

`--size` controls rasterisation resolution before tracing; the default of 256 is
enough that thin strokes survive `--turdsize 4`.

## Known dead code

`build.py` is vendored verbatim so it stays the exact script that produced the
committed TTF. It contains three leftovers from an earlier revision:
`normalise()` and `_unused()` are never called, and `_fit_transform()` is called
by `glyph_for()` but only its return values are used (the function name no
longer describes what it does). Removing them is safe but was left alone to
keep script and artifact in sync.

## Licensing

The logos are fetched from herdr.dev at build time, which means
`Fonts/HerdrAgentIcons-Regular.ttf` embeds traced copies of them. This
repository is public. Rebuilding or redistributing the TTF further is a
judgement call outside the scope of this vendored copy.
