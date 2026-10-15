#!/usr/bin/env python3
"""Build an icon font from the agent SVGs published on herdr.dev.

Terminals render text cells, so the only way to show these logos in the Herdr
sidebar is to put them in a font and address them by codepoint. SVG cannot be
used directly; this rasterises it, traces the alpha channel to outlines with
potrace, converts cubics to quadratics, and emits a TTF with the logos mapped
into the Private Use Area.

Usage:
    ./build.py [--out DIR] [--size PX]

Requires: rsvg-convert, potrace (both on PATH).
"""

from __future__ import annotations

import argparse
import subprocess
import sys
import tempfile
import urllib.request
from pathlib import Path

from fontTools.fontBuilder import FontBuilder
from fontTools.pens.cu2quPen import Cu2QuPen
from fontTools.pens.recordingPen import RecordingPen
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.svgLib.path import SVGPath
from fontTools.ttLib.tables._g_l_y_f import GlyphCoordinates

BASE = "https://herdr.dev/assets/agent-icons"

# Agent slug on herdr.dev -> (glyph suffix, PUA codepoint).
#
# Codepoints start at U+E00B, in a block Nerd Fonts leaves free. An earlier
# revision used U+E000-U+E007, which Nerd Fonts already occupies with its pom-*
# timer icons -- and because terminals resolve PUA codepoints through the font
# stack in order, any Nerd Font listed before this one (e.g. Maple Mono NF)
# shadowed our logos with its own glyphs there. The terminal showed the wrong
# icon even though Font Book displayed the right one, because Font Book renders
# the font in isolation.
#
# Assigned in a stable order so regenerating does not silently remap an icon a
# user's config already refers to. Check any new range against Nerd Fonts'
# glyphnames.json before using it.
AGENTS: list[tuple[str, str, int]] = [
    ("claude", "claude", 0xE00B),
    ("codex-mask", "codex", 0xE00C),
    ("cursor", "cursor", 0xE00D),
    ("github-copilot", "copilot", 0xE00E),
    ("grok", "grok", 0xE00F),
    ("hermes", "hermes", 0xE010),
    ("opencode", "opencode", 0xE011),
    ("pi", "pi", 0xE012),
]

UPM = 1000
# Vertical metrics of the line box terminals lay out. The glyph must be
# centred on the *line* centre, not the em centre: an earlier revision centred
# on UPM/2 = 500 while the line box (-200..800) is centred on 300, so every
# logo sat 200 units too high and read as top-aligned next to text.
ASCENT = 800
DESCENT = -200
LINE_CENTRE = (ASCENT + DESCENT) / 2
# The glyph is drawn into the font's em box with this much side bearing, so the
# logo does not touch the cell edge in a 26-column sidebar.
SIDE_BEARING = 60


def fetch(slug: str, dest: Path) -> None:
    if dest.exists():
        return
    url = f"{BASE}/{slug}.svg"
    # herdr.dev rejects the default urllib User-Agent with a 403.
    request = urllib.request.Request(url, headers={"User-Agent": "herdr-agent-icons/1.0"})
    with urllib.request.urlopen(request) as response:  # noqa: S310 - fixed host
        dest.write_bytes(response.read())


def to_outline(svg: Path, size: int) -> RecordingPen:
    """Rasterise the SVG, then trace it back to a vector outline."""
    with tempfile.TemporaryDirectory() as tmp:
        tmpdir = Path(tmp)
        png = tmpdir / "icon.png"
        pbm = tmpdir / "icon.pbm"
        traced = tmpdir / "icon.svg"

        subprocess.run(
            ["rsvg-convert", "-w", str(size), "-h", str(size), str(svg), "-o", str(png)],
            check=True,
        )
        # Flatten alpha onto white: potrace thresholds luminance, and the SVG
        # logos are single-colour so their alpha *is* the shape.
        subprocess.run(
            [
                sys.executable,
                "-c",
                (
                    # Threshold the alpha channel, not the colour. The
                    # published SVGs are inconsistent: most are dark on
                    # transparent, but codex-mask is fill="white" with no
                    # alpha, so luminance is uniformly 255 and tracing it
                    # yields nothing. Alpha is the shape for every one of them.
                    # The result is hard black-on-white because potrace
                    # thresholds luminance; inverting instead would flood
                    # thin-stroke marks such as Claude's, where the negative
                    # space dominates the bounding box and the shape fills
                    # solid.
                    "import sys;from PIL import Image;"
                    "a=Image.open(sys.argv[1]).convert('RGBA').getchannel('A')"
                    ".point(lambda v: 0 if v > 127 else 255, mode='L')"
                    ".resize((%d,%d),Image.LANCZOS).save(sys.argv[2])"
                )
                % (size, size),
                str(png),
                str(pbm),
            ],
            check=True,
        )
        subprocess.run(
            [
                "potrace",
                "--backend",
                "svg",
                "-t",
                "black",
                "--output",
                str(traced),
                "--turdsize",
                "4",
                "--alphamax",
                "1.0",
                "--opttolerance",
                "0.2",
                str(pbm),
            ],
            check=True,
        )
        pen = RecordingPen()
        SVGPath(str(traced)).draw(pen)
        return pen


def _fit_transform(pen: RecordingPen) -> tuple[float, float, float, float, float]:
    """Return (scale, min_x, min_y, width, height) for fitting the outline.

    SVGPath records potrace's raw coordinates, which are y-*down* (raster
    order): small y is the top of the logo. Font space is y-*up*, so callers
    must flip vertically when mapping -- mapping without the flip renders
    every logo upside down, which is easy to miss on symmetric marks like
    opencode's square.
    """
    xs: list[float] = []
    ys: list[float] = []
    for _, points in pen.value:
        for point in points:
            xs.append(float(point[0]))
            ys.append(float(point[1]))
    if not xs:
        raise ValueError("traced outline is empty")
    min_x, max_x = min(xs), max(xs)
    min_y, max_y = min(ys), max(ys)
    width = max_x - min_x
    height = max_y - min_y
    span = max(width, height)
    if span <= 0:
        raise ValueError("traced outline has no extent")
    target = UPM - 2 * SIDE_BEARING
    return target / span, min_x, min_y, width, height


def _unused(pen: RecordingPen) -> None:
    """Retained only to keep normalise's docstring discoverable."""
    raise NotImplementedError


def normalise(pen: RecordingPen) -> tuple[GlyphCoordinates, int]:
    """Fit the traced outline into the em box.

    potrace emits coordinates in a space several times the em box, already
    y-flipped by its own transform. This rescales from the outline's own
    bounding box rather than assuming a nominal size, so a logo with different
    padding in its viewBox still lands centred in the cell.
    """
    # RecordingPen replays potrace output as plain (x, y) tuples, including
    # off-curve control points.
    xs: list[float] = []
    ys: list[float] = []
    for _, points in pen.value:
        for point in points:
            xs.append(float(point[0]))
            ys.append(float(point[1]))
    if not xs:
        raise ValueError("traced outline is empty")
    min_x, max_x = min(xs), max(xs)
    min_y, max_y = min(ys), max(ys)
    width = max_x - min_x
    height = max_y - min_y
    span = max(width, height)
    if span <= 0:
        raise ValueError("traced outline has no extent")

    target = UPM - 2 * SIDE_BEARING
    scale = target / span
    # Glyph space is y-up; the traced space is y-down, hence the negation.
    coords = GlyphCoordinates(
        [
            (
                int(round((x - min_x - (span - width) / 2) * scale + SIDE_BEARING)),
                int(round(-(y - min_y - (span - height) / 2) * scale + SIDE_BEARING)),
            )
            for x, y in zip(xs, ys)
        ]
    )
    return coords, target


def glyph_for(svg: Path, size: int):
    traced = to_outline(svg, size)
    scale, min_x, min_y, width, height = _fit_transform(traced)

    # Cu2QuPen wraps the target pen: it converts the cubic ops potrace emits
    # into quadratics and records them into the TTGlyphPen underneath.
    # reverse_direction must stay False: potrace already emits outer contours
    # opposite to their holes, and reversing here flips every contour so the
    # non-zero winding rule fills holes solid.
    pen = TTGlyphPen(None)
    traced.replay(Cu2QuPen(pen, max_err=1.0, reverse_direction=False))
    glyph = pen.glyph()
    # Map into the em explicitly. The x axis just shifts; the y axis flips
    # because the traced space is y-down and the font is y-up. The fitted box
    # is centred on the line centre (DESCENT..ASCENT), not the em centre, or
    # the logo sits 200 units too high and reads as top-aligned.
    # Replacing the table outright would desync it from the flags and
    # contour-end arrays glyph.compile checks, so the existing points are
    # transformed instead.
    y_top = LINE_CENTRE + (UPM - 2 * SIDE_BEARING) / 2
    x_left = SIDE_BEARING + ((UPM - 2 * SIDE_BEARING) - width * scale) / 2
    y_pad = ((UPM - 2 * SIDE_BEARING) - height * scale) / 2
    glyph.coordinates = GlyphCoordinates(
        [
            (
                int(round(x_left + (x - min_x) * scale)),
                int(round(y_top - y_pad - (y - min_y) * scale)),
            )
            for x, y in glyph.coordinates
        ]
    )
    return glyph


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", default=str(Path.home() / "Library/Fonts"), help="output dir for the TTF")
    parser.add_argument("--size", type=int, default=256, help="rasterisation size before tracing")
    parser.add_argument("--cache", default=None, help="directory to cache downloaded SVGs")
    args = parser.parse_args()

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    cache = Path(args.cache) if args.cache else out_dir / ".herdr-icon-cache"
    cache.mkdir(parents=True, exist_ok=True)

    order = [".notdef"] + [f"agent_{suffix}" for _, suffix, _ in AGENTS]
    cmap: dict[int, str] = {}
    glyf: dict[str, object] = {".notdef": TTGlyphPen(None).glyph()}
    metrics: dict[str, tuple[int, int]] = {".notdef": (UPM, 0)}

    for slug, suffix, codepoint in AGENTS:
        svg = cache / f"{slug}.svg"
        fetch(slug, svg)
        glyf[f"agent_{suffix}"] = glyph_for(svg, args.size)
        cmap[codepoint] = f"agent_{suffix}"
        metrics[f"agent_{suffix}"] = (UPM, SIDE_BEARING)
        print(f"  {slug:<16} -> U+{codepoint:04X} agent_{suffix}")

    builder = FontBuilder(UPM, isTTF=True)
    builder.setupGlyphOrder(order)
    builder.setupCharacterMap(cmap)
    builder.setupGlyf(glyf)
    builder.setupHorizontalMetrics(metrics)
    builder.setupHorizontalHeader(ascent=ASCENT, descent=DESCENT)
    builder.setupNameTable(
        {
            "familyName": "Herdr Agent Icons",
            "styleName": "Regular",
            "fullName": "Herdr Agent Icons Regular",
            "psName": "HerdrAgentIcons-Regular",
        }
    )
    builder.setupOS2(sTypoAscender=ASCENT, sTypoDescender=DESCENT, usWinAscent=ASCENT, usWinDescent=-DESCENT)
    builder.setupPost(isFixedPitch=1)
    target = out_dir / "HerdrAgentIcons-Regular.ttf"
    builder.save(str(target))
    print(f"wrote {target}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())