"""Pick the image preview backend that actually works in the current terminal.

ranger's `preview_images_method` is a static string in rc.conf, but the right
answer depends on where ranger happens to be running: the same config gets used
inside and outside tmux, over ssh, and in whatever terminal emulator is at hand.
This plugin resolves it once at startup instead.

Everything here draws real pixels. Nothing renders images as text or ASCII art -
in particular ueberzugpp's "chafa" output, which does exactly that, is never
selected: the -o backend is always pinned explicitly.

The awkward case is kitty inside tmux, and it drives the whole design:

  * kitty has no SIXEL support whatsoever (verified: zero occurrences of
    "sixel" anywhere in kitty.app, against 98 graphics-protocol strings). Its
    only image protocol is its own APC-based graphics protocol.
  * tmux consumes APC sequences it does not understand, so a bare kitty
    graphics escape never reaches the terminal from inside a pane. tmux's only
    native image protocol is SIXEL - which kitty cannot draw.
  * ueberzugpp does not implement tmux's DCS passthrough (no passthrough code
    in the binary), so it cannot bridge that gap either.

The way out is tmux's `allow-passthrough`: wrap the kitty escape in a
`DCS tmux; ... ST` envelope and tmux forwards the inner bytes untouched, as
KittyGraphicsImageDisplayer below does, and it is used for kitty-protocol
terminals inside tmux. Outside tmux, ueberzugpp handles the same terminals
natively and is left in charge.

Resulting matrix:

  terminal speaks kitty graphics, in tmux    -> kitty  (this plugin's displayer)
  terminal speaks kitty graphics, no tmux    -> ueberzug -o kitty
  SIXEL-capable terminal, in or out of tmux  -> ueberzug -o sixel
  iTerm2, outside tmux                       -> ueberzug -o iterm2
  nothing usable                             -> image previews off
"""

from __future__ import absolute_import, division, print_function

import base64
import hashlib
import logging
import os
import re
import select
import subprocess
import sys
import termios
import time
import tty

import ranger
import ranger.api
from ranger.core.shared import FileManagerAware
from ranger.ext import img_display
from ranger.ext.which import which


DA1_TIMEOUT = 0.35

# Terminals that implement the kitty graphics protocol.
KITTY_GRAPHICS_TERMINALS = re.compile(r"kitty|ghostty|wezterm", re.IGNORECASE)

# Terminals known to render SIXEL. Note that kitty is deliberately absent.
SIXEL_TERMINALS = re.compile(
    r"ghostty|wezterm|foot|contour|mlterm|yaft|iterm2?|darktile|xterm-direct",
    re.IGNORECASE,
)

LOG = logging.getLogger(__name__)
HOOK_INIT_OLD = ranger.api.hook_init


def _magick_cmd():
    return ["magick"] if which("magick") else ["convert"]


class KittyGraphicsImageDisplayer(img_display.ImageDisplayer, FileManagerAware):
    """Kitty graphics protocol, with identical behaviour in and out of tmux.

    Replaces ranger's own kitty displayer, which refuses to run under tmux and
    additionally requires Pillow. This one shells out to ImageMagick (already
    needed for the sixel path) to produce a PNG scaled to the preview box, then
    transmits it inline with f=100,t=d so no temporary files are involved.

    Two details make in-tmux output match out-of-tmux output exactly:

    * Position. Drawing is split in two: the image is transmitted and stored
      first (a=t), then placed by a separate, single escape (a=p). Kitty puts
      an image where the cursor is when the *last* chunk arrives, so placing
      it as part of a multi-chunk transfer lets any interleaved ncurses or
      tmux output move the cursor mid-flight - which is why big photos would
      land at the terminal origin while small ones happened to survive. The
      placement escape carries its own absolute cursor move, computed here
      from the pane's offset on screen, and goes out as one write so nothing
      can slip between the move and the put. Inside tmux it travels through
      the passthrough envelope, so kitty - not tmux - acts on it, and
      DECSC/DECRC put the cursor back so neither tmux nor ncurses notices.
    * Aspect ratio. No c=/r= cell box is sent. Those make kitty stretch the
      image to fill the box; instead ImageMagick has already scaled the PNG to
      fit inside the box with "-geometry WxH>", which only ever shrinks and
      preserves the ratio. Kitty then draws it at its natural size.
    """

    # Kitty accepts at most 4096 bytes of base64 per escape.
    CHUNK = 4096
    # Fallback cell size if the terminal does not report pixel dimensions.
    DEFAULT_CELL = (8, 16)
    # How long a looked-up tmux pane offset stays good for.
    OFFSET_TTL = 1.0
    # On-disk cache of converted PNGs, under ranger's cache dir.
    CACHE_SUBDIR = "kitty_previews"
    CACHE_LIMIT = 256 * 1024 * 1024

    def __init__(self):
        self.in_tmux = bool(os.environ.get("TMUX"))
        self.stdbout = getattr(sys.stdout, "buffer", sys.stdout)
        self.image_id = 0
        self._sent_key = None
        self._offset = (0, 0)
        self._offset_at = 0.0

    def _pane_offset(self):
        """Screen coordinates of this tmux pane's top-left cell, as (row, col).

        Outside tmux the offset is always (0, 0): ranger already owns the
        whole terminal, so its own coordinates are the screen's.
        """
        if not self.in_tmux:
            return (0, 0)

        now = time.time()
        if now - self._offset_at < self.OFFSET_TTL:
            return self._offset

        row, col = self._offset
        pane = os.environ.get("TMUX_PANE", "")
        try:
            raw = subprocess.check_output(
                ["tmux", "display-message", "-p"]
                + (["-t", pane] if pane else [])
                + ["#{pane_top},#{pane_left},#{status},#{status-position}"],
                stderr=subprocess.DEVNULL,
            ).decode("utf-8", "replace").strip()
            top, left, status, position = raw.split(",")
            # `status` is off/on or a line count; only a top status line pushes
            # the pane area down, and pane_top is relative to that area.
            if status == "off":
                lines = 0
            elif status.isdigit():
                lines = int(status)
            else:
                lines = 1
            row = int(top) + (lines if position == "top" else 0)
            col = int(left)
        except (OSError, ValueError, subprocess.CalledProcessError):
            pass

        self._offset = (row, col)
        self._offset_at = now
        return self._offset

    def _write(self, data):
        if self.in_tmux:
            # tmux strips one level of escaping, so ESC must be doubled.
            data = b"\x1bPtmux;" + data.replace(b"\x1b", b"\x1b\x1b") + b"\x1b\\"
        self.stdbout.write(data)

    @staticmethod
    def _apc(control, payload=b""):
        ctrl = ",".join(
            "{0}={1}".format(key, value) for key, value in control.items()
        ).encode("ascii")
        return b"\x1b_G" + ctrl + b";" + payload + b"\x1b\\"

    def _transmit(self, control, payload):
        chunks = [payload[i:i + self.CHUNK]
                  for i in range(0, len(payload), self.CHUNK)] or [b""]
        for index, chunk in enumerate(chunks):
            more = 0 if index == len(chunks) - 1 else 1
            if index == 0:
                head = dict(control)
                head["m"] = more
                self._write(self._apc(head, chunk))
            else:
                self._write(self._apc({"m": more}, chunk))

    def _cell_size(self):
        try:
            cell_w, cell_h = img_display.get_font_dimensions()
        except (OSError, IOError, ValueError, ZeroDivisionError):
            cell_w, cell_h = (0, 0)
        if not cell_w or not cell_h:
            cell_w, cell_h = self.DEFAULT_CELL
        return cell_w, cell_h

    def _image_key(self, path, width, height):
        """Identity of the scaled image for `path` in a width x height box."""
        cell_w, cell_h = self._cell_size()
        box = (cell_w * width, cell_h * height)
        stat = os.stat(path)
        return (path, stat.st_ino, stat.st_mtime, stat.st_size, box), box

    def _cache_dir(self):
        """Directory holding converted PNGs, under ranger's own cache dir."""
        base = getattr(getattr(ranger, "args", None), "cachedir", None)
        if not base:
            base = os.path.expanduser("~/.cache/ranger")
        path = os.path.join(base, self.CACHE_SUBDIR)
        os.makedirs(path, exist_ok=True)
        return path

    @staticmethod
    def _content_digest(path):
        """SHA-256 of the file's contents.

        Keyed on content rather than path and mtime so a moved, renamed or
        duplicated image reuses the same entry, and so a file edited back to
        a previous state does not resurrect a stale preview.
        """
        digest = hashlib.sha256()
        with open(path, "rb") as handle:
            for block in iter(lambda: handle.read(1 << 20), b""):
                digest.update(block)
        return digest.hexdigest()

    def _convert(self, path, box):
        """Run ImageMagick to produce a PNG scaled to fit inside `box`."""
        try:
            proc = subprocess.Popen(
                _magick_cmd() + [
                    path + "[0]",
                    # ">" only ever shrinks, and keeps the aspect ratio.
                    "-geometry", "{0}x{1}>".format(*box),
                    # Cheap compression: encoding dominates the cost here, and
                    # the extra bytes are sent once and then live in kitty.
                    # Measured on a 2000x1333 photo: 157ms/4.1MB at level 1
                    # against 678ms/3.7MB at the default.
                    "-define", "png:compression-level=1",
                    "png:-",
                ],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
            )
            png, _ = proc.communicate()
        except OSError:
            raise img_display.ImageDisplayError(
                "kitty graphics previews require ImageMagick")
        if proc.returncode != 0 or not png:
            raise img_display.ImageDisplayError(
                "ImageMagick could not render {0}".format(os.path.basename(path)))
        return png

    def _prune_cache(self, directory, keep=None):
        """Drop the least recently modified entries once over CACHE_LIMIT."""
        entries, total = [], 0
        try:
            names = os.listdir(directory)
        except OSError:
            return
        for name in names:
            full = os.path.join(directory, name)
            try:
                stat = os.stat(full)
            except OSError:
                continue
            entries.append((stat.st_mtime, stat.st_size, full))
            total += stat.st_size
        if total <= self.CACHE_LIMIT:
            return
        for _, size, full in sorted(entries):
            if full == keep:
                continue
            try:
                os.unlink(full)
            except OSError:
                continue
            total -= size
            if total <= self.CACHE_LIMIT:
                return

    def _png(self, path, box):
        """PNG bytes for `path`, scaled to fit inside `box` pixels.

        Converted PNGs are cached on disk, because the conversion is the
        expensive part of showing a preview - ~157ms for a 2000x1333 photo
        against ~1ms to hash the source and read the result back. The cache
        survives across ranger sessions and is capped at CACHE_LIMIT.
        """
        cached = None
        try:
            cached = os.path.join(
                self._cache_dir(),
                "{0}-{1}x{2}.png".format(self._content_digest(path), *box))
        except (OSError, IOError):
            cached = None  # unreadable cache dir: just convert every time

        if cached:
            try:
                with open(cached, "rb") as handle:
                    png = handle.read()
                if png:
                    return png
            except (OSError, IOError):
                pass

        png = self._convert(path, box)

        if cached:
            # Write via a temporary name so a half-written file is never
            # mistaken for a valid cache entry by a concurrent ranger.
            tmp = "{0}.{1}.tmp".format(cached, os.getpid())
            try:
                with open(tmp, "wb") as handle:
                    handle.write(png)
                os.replace(tmp, cached)
            except (OSError, IOError):
                try:
                    os.unlink(tmp)
                except OSError:
                    pass
            else:
                self._prune_cache(os.path.dirname(cached), keep=cached)
        return png

    def _unplace(self):
        """Hide the image but leave its data loaded in the terminal.

        Lowercase d=i deletes only the placements; the pixels stay in kitty,
        so showing it again is one short escape rather than a retransmission.
        """
        if self.image_id:
            self._write(self._apc({"a": "d", "d": "i", "i": self.image_id, "q": 2}))

    def _free(self):
        """Drop the image from the terminal entirely (uppercase D frees data)."""
        if self.image_id:
            self._write(self._apc({"a": "d", "d": "I", "i": self.image_id, "q": 2}))
        self.image_id = 0
        self._sent_key = None

    # pylint: disable=too-many-positional-arguments
    def draw(self, path, start_x, start_y, width, height):
        key, box = self._image_key(path, width, height)

        sent = 0
        if key != self._sent_key or not self.image_id:
            # Phase 1: store the image in the terminal without displaying it.
            # a=t transmits only, so this can span however many chunks a large
            # photo needs without the cursor mattering at all.
            #
            # Only done when the image actually changed. ranger redraws on a
            # timer - directory polling, VCS status - and re-sending a
            # multi-megabyte PNG each time is slow enough to show up as the
            # preview blanking out and coming back.
            png = self._png(path, box)
            self._free()
            self.image_id = (self.image_id % 4294967290) + 1
            self._transmit(
                {"a": "t", "f": 100, "t": "d", "i": self.image_id, "q": 2},
                base64.standard_b64encode(png),
            )
            self._sent_key = key
            sent = len(png)

        offset_row, offset_col = self._pane_offset()
        row = offset_row + start_y + 1  # CUP is 1-based
        col = offset_col + start_x + 1

        # Flush whatever ncurses has queued so the placement lands after it.
        try:
            sys.stdout.flush()
        except (OSError, IOError, ValueError):
            pass

        # Phase 2: place the stored image, atomically. Cursor save, move, put
        # and restore go out as one write - a single passthrough envelope
        # under tmux - so no ncurses or tmux output can slip in between the
        # move and the put and drag the image somewhere else. C=1 keeps the
        # cursor put, q=2 suppresses replies that would land in ranger's
        # input, and DECSC/DECRC keep the move invisible to ncurses and tmux.
        self._write(
            b"\x1b7"
            + "\x1b[{0};{1}H".format(row, col).encode("ascii")
            + self._apc({"a": "p", "i": self.image_id, "q": 2, "C": 1})
            + b"\x1b8"
        )
        self.stdbout.flush()
        LOG.debug("placed image %d at row=%d col=%d (%s)", self.image_id, row, col,
                  "sent %d png bytes" % sent if sent else "already loaded")

    def clear(self, start_x, start_y, width, height):
        self._unplace()
        try:
            self.stdbout.flush()
        except (OSError, IOError, ValueError):
            pass

    def quit(self):
        self._free()
        try:
            self.stdbout.flush()
        except (OSError, IOError, ValueError):
            pass


class UeberzugPPImageDisplayer(img_display.UeberzugImageDisplayer):
    """ueberzug displayer that pins ueberzugpp's output backend.

    ranger spawns a bare `ueberzug layer --silent` and lets ueberzugpp guess how
    to draw. A wrong guess can land on the "chafa" backend, which paints the
    image as coloured text. Passing -o explicitly removes the guesswork.
    """

    output = None

    def initialize(self):
        if (self.is_initialized and self.process.poll() is None
                and not self.process.stdin.closed):
            return

        cmd = ["ueberzug", "layer", "--silent"]
        if self.output:
            cmd += ["-o", self.output]

        # pylint: disable=consider-using-with
        with open(os.devnull, "wb") as devnull:
            self.process = subprocess.Popen(
                cmd,
                cwd=self.working_dir,
                stderr=devnull,
                stdin=subprocess.PIPE,
                universal_newlines=True,
            )
        self.is_initialized = True
        LOG.info("started: %s", " ".join(cmd))


# `preview_images_method` is validated against a fixed list, so these have to
# reuse existing names rather than introduce new ones.
img_display.IMAGE_DISPLAYER_REGISTRY["kitty"] = KittyGraphicsImageDisplayer
img_display.IMAGE_DISPLAYER_REGISTRY["ueberzug"] = UeberzugPPImageDisplayer


def _query_da1(timeout=DA1_TIMEOUT):
    """Send a Primary Device Attributes query, return the raw reply."""
    try:
        in_fd = sys.stdin.fileno()
        out = sys.stdout
        if not (os.isatty(in_fd) and out.isatty()):
            return b""
        saved = termios.tcgetattr(in_fd)
    except (AttributeError, ValueError, termios.error, IOError):
        return b""

    try:
        tty.setraw(in_fd)
        out.write("\x1b[c")
        out.flush()
        reply = b""
        # DA1 replies look like ESC [ ? 1 ; 2 ; 4 c - read until the final "c".
        while len(reply) < 64 and select.select([in_fd], [], [], timeout)[0]:
            char = os.read(in_fd, 1)
            if not char:
                break
            reply += char
            if char == b"c":
                break
        return reply
    except (OSError, IOError, ValueError):
        return b""
    finally:
        try:
            termios.tcsetattr(in_fd, termios.TCSADRAIN, saved)
        except (termios.error, ValueError):
            pass


def _da1_has_sixel(reply):
    """True if a DA1 reply advertises attribute 4 (sixel graphics).

    Inside tmux this reflects tmux, not the terminal behind it: tmux claims
    sixel whenever it was built with sixel support, even when the outer
    terminal cannot draw it. So it is only trusted outside tmux.
    """
    match = re.match(br"\x1b\[\?([0-9;]+)c", reply)
    if not match:
        return False
    return b"4" in match.group(1).split(b";")


def _outer_terminal():
    """Name of the terminal ranger is ultimately drawing to.

    Inside tmux $TERM is tmux's own, and $TERM_PROGRAM describes the tmux
    server's environment rather than the attached client, so ask tmux which
    terminal the current client is on.
    """
    names = [os.environ.get("TERM", ""), os.environ.get("TERM_PROGRAM", "")]
    if os.environ.get("TMUX"):
        pane = os.environ.get("TMUX_PANE", "")
        try:
            names.append(subprocess.check_output(
                ["tmux", "display-message", "-p"]
                + (["-t", pane] if pane else [])
                + ["#{client_termname}"],
                stderr=subprocess.DEVNULL,
            ).decode("utf-8", "replace"))
        except (OSError, subprocess.CalledProcessError):
            pass
    else:
        # Set by the terminals themselves, and only meaningful outside tmux.
        for var in ("KITTY_WINDOW_ID", "GHOSTTY_RESOURCES_DIR",
                    "WEZTERM_EXECUTABLE", "KONSOLE_VERSION"):
            if os.environ.get(var):
                names.append(var)
    return " ".join(names).strip()


def detect_method():
    """Return (preview_images_method, ueberzug_output, reason)."""
    terminal = _outer_terminal()
    in_tmux = bool(os.environ.get("TMUX"))
    has_magick = bool(which("magick") or which("convert"))
    # DA1 is answered by tmux when multiplexed, so it says nothing about the
    # real terminal there; fall back to the name allowlist instead.
    has_sixel = (not in_tmux) and _da1_has_sixel(_query_da1())

    forced = os.environ.get("RANGER_IMAGE_PREVIEW_METHOD", "").strip()
    if forced:
        return forced, "sixel" if in_tmux else "kitty", \
            "forced by $RANGER_IMAGE_PREVIEW_METHOD"

    kitty_graphics = bool(KITTY_GRAPHICS_TERMINALS.search(terminal))
    sixel_capable = has_sixel or bool(SIXEL_TERMINALS.search(terminal))

    # Same displayer in and out of tmux, so previews land in the same place and
    # keep the same aspect ratio either way. ueberzugpp is not used for these
    # terminals: it cannot reach them through tmux (no passthrough support), so
    # letting it handle only the non-tmux case would mean two different
    # renderers with two different behaviours.
    if kitty_graphics:
        if has_magick:
            return "kitty", None, "kitty graphics%s (terminal: %s)" % (
                " via tmux passthrough" if in_tmux else "", terminal)
        LOG.warning("kitty graphics need ImageMagick; it is missing")

    if which("ueberzug"):
        if sixel_capable:
            return "ueberzug", "sixel", "ueberzugpp -o sixel (terminal: %s)" % terminal
        if re.search(r"iterm", terminal, re.IGNORECASE) and not in_tmux:
            return "ueberzug", "iterm2", "ueberzugpp -o iterm2"

    if sixel_capable and has_magick:
        return "sixel", None, "built-in sixel via ImageMagick (terminal: %s)" % terminal

    if which("w3mimgdisplay"):
        return "w3m", None, "falling back to w3mimgdisplay"

    return None, None, "no graphics protocol detected (terminal: %s)" % terminal


def hook_init(fm):
    method, output, reason = detect_method()
    UeberzugPPImageDisplayer.output = output
    if method:
        fm.settings.preview_images_method = method
        fm.settings.preview_images = True
    else:
        # Leave the text previews from scope.sh working, just no graphics.
        fm.settings.preview_images = False
    # hook_init runs before the curses UI is up, so log rather than notify.
    # Shows up under `ranger --debug` and in `:display_log`.
    LOG.info("image previews: %s (%s)", method or "disabled", reason)
    return HOOK_INIT_OLD(fm)


ranger.api.hook_init = hook_init
