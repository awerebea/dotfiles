# My config files and settings

Managed with [GNU stow](https://www.gnu.org/software/stow/). Each top-level
directory is a stow package mirroring the layout it should take under `$HOME`,
so `stow <package>` from the repository root symlinks it into place.

## Scripts

Most scripts in `scripts/.local/bin/` stand alone. The three that maintain the
photo archive share a package, `scripts/.local/bin/photo_archive/`, and reach
`$PATH` through symlinks beside it:

```
scripts/.local/bin/
    normalize_names_nfc.py -> photo_archive/normalize_names_nfc.py
    video_face_tagger.py   -> photo_archive/video_face_tagger.py
    video_geo_tagger.py    -> photo_archive/video_geo_tagger.py
    photo_archive/
        bootstrap.py     virtualenv detection and re-exec
        util.py          NFC, logging, counters, formatting
        exif.py          exiftool wrapper, private XMP namespaces, mtime
        media.py         archive walking, sidecar naming, video probing
        settings.py      TOML config and dependency checks
        requirements.txt
        Dockerfile       container image for video_face_tagger.py
```

The symlinks matter: stow folds a bare directory into a single link, which
would leave the entry points off `$PATH`. Each of them is executable on its
own and can also be run by full path or as `python3 -m
photo_archive.video_geo_tagger`.

Every tool writes only to `.xmp` sidecars named `<full filename>.xmp`, which is
digiKam's default and Immich's preferred form. Original media files are never
modified, and file modification times are preserved exactly, to the nanosecond.

### [video_face_tagger.py](scripts/.local/bin/photo_archive/video_face_tagger.py)

Tag video files with people's names by running digiKam's face recognition on
frames extracted from those videos.

digiKam cannot detect faces in video files at all. This tool works around that
by sampling still frames out of each video into a scratch directory, which you
add to digiKam as a temporary collection. digiKam does the detection and
recognition there against its already-trained model, you confirm the faces, and
the tool reads the confirmed names back and merges them into the source videos'
XMP sidecars.

Original media files are never modified. Every write goes to a `.xmp` sidecar
named `<full filename>.xmp`, which is digiKam's default and Immich's preferred
form. File modification times are preserved exactly.

#### Requirements

Required:

- `exiftool`
- `ffmpeg` and `ffprobe`
- Python 3 (3.11 or newer to use the config file, which needs `tomllib`;
  on older versions the config is reported and ignored, and everything else
  works)

```sh
brew install exiftool ffmpeg
```

Optional, and only for the face pre-filter described below: `opencv-python-headless`
and `numpy`, listed in
[requirements.txt](scripts/.local/bin/photo_archive/requirements.txt).

#### Install

```sh
# from the repository root, symlink the scripts into ~/.local/bin
stow scripts

# optional: face pre-filter dependencies, in a venv beside the package
cd scripts/.local/bin
python3 -m venv .venv
.venv/bin/pip install -r photo_archive/requirements.txt

# optional: the face detection model (a separate step)
video_face_tagger.py fetch-model
```

The script re-executes itself under a virtualenv interpreter when it finds
one, so there is no shebang to edit and nothing to activate.

It never imposes a particular location. If a virtualenv is already active, that
one is used and nothing is overridden. Otherwise it looks for `.venv` or `venv`
inside `photo_archive/` or beside it, then
`~/.local/share/photo_archive/venv`. Setting `PHOTO_ARCHIVE_PYTHON`, or
`VIDEO_FACE_TAGGER_PYTHON` for just that tool, overrides all of it.

To confirm which interpreter is in use, pass `--verbose` and look for the
`interpreter:` line.

Without the optional dependencies the tool works normally, just with a larger
working set. It warns when the filter is off but could be enabled, and prints
the exact commands still missing. Pass `--face-filter off` to silence that.

#### The pipeline

Four phases, three of them scripted:

| Phase | Command     | What happens                                                               |
| ----- | ----------- | -------------------------------------------------------------------------- |
| 1     | `extract`   | Sample frames from videos into the work directory                          |
| 2     | _manual_    | In digiKam: detect, recognise, and confirm faces                           |
| -     | `propagate` | _(optional)_ Spread each video's confirmed names to all of its frames      |
| -     | `prune`     | _(optional)_ Park frames of already-identified videos out of digiKam's way |
| 3     | `collect`   | Merge confirmed names into the video sidecars                              |
| 4     | `clean`     | Drop work frames for processed videos                                      |

There is also `status` to report where things stand, `config` to manage
defaults, and `fetch-model` to download the face model.

Every phase that writes supports `--dry-run`. Every phase logs to stdout and to
a file, is resumable after an interrupt, and prints a summary of counts when it
finishes.

#### Phase 1: extract

Walks `--path`, finds videos, and samples frames into `--work`.

```sh
video_face_tagger.py extract \
  --path ~/Photo/_Inbox \
  --work ~/video_face_tagger_work \
  --jobs 6 \
  --interval 5 \
  --max-frames 40 \
  --min-samples 1 \
  --long-edge 1280 \
  --quality 2 \
  --select sharpest \
  --candidates 3 \
  --candidate-window 1.0 \
  --face-filter auto \
  --face-threshold 0.6 \
  --keep-min 1 \
  --people-root People \
  --progress-every 25 \
  --log ~/video_face_tagger_work/logs/extract.log \
  --config ~/.config/video_face_tagger/config.toml
```

Also accepts `--probe-all` to run ffprobe over every file rather than trusting
known extensions, `--force` to redo videos that already carry the processing
marker, and `--dry-run`.

Videos are discovered by extension where the extension is conclusive, and by
probing with ffprobe where it is not, so unusual containers and extensionless
files are still found. Videos already carrying the marker are skipped unless
`--force` is given.

The number of frames per video is `duration / interval`, at least
`--min-samples` (default 1) and at most `--max-frames` (`0`: no cap), and the
samples are spread evenly across the whole clip. A long video therefore gets
`--max-frames` samples spanning its full length rather than a dense burst at the
start, and a clip shorter than one interval still yields `--min-samples` frames,
the first from the middle. `--min-samples 4` gives a 9 s clip four frames,
2.25 s apart, instead of one. When ffprobe reports no duration for the container
it falls back to the video stream's; with none at all, frames at 0.5, 2 and 5 s
are taken (previously only t=0, which is often black). The same sampling is
vendored in the Immich stack's `immich-video-faces` (truenas repository,
`Dockge/stacks/immich/sidecar-sync/frames.py`), which uses
`--min-samples 4` and no cap; keep the two in step.

With `--select sharpest` the tool takes `--candidates` frames within a window of
`--candidate-window` seconds around each sample point and keeps the sharpest.
Sharpness is scored by encoded JPEG size, which ranks candidates almost
identically to a variance-of-Laplacian measure (Spearman rho 0.99 measured on
this archive) and costs nothing extra to compute. Use `--select uniform` to take
a single frame per sample point instead.

When the optional dependencies are installed, `--face-filter` discards frames
containing no detectable face before digiKam ever indexes them. At the default
`--face-threshold` of 0.6 this removed about 55% of frames on a sample of this
archive while still finding a face in every photo digiKam had confirmed face
regions for. `--keep-min` retains that many frames for videos where nothing is
detected, so such a video still appears in the work directory and can be marked
as processed in phase 3.

Result: flat, collision-proof filenames in the work directory.

```
2024-03-17_09-08-21__4bb8338d88_002.jpg
2024-03-17_09-08-21__4bb8338d88_002.jpg.xmp
```

`4bb8338d88` is a short hash of the video's absolute path. Frame indices may
have gaps where the face filter dropped frames, which is expected. Each frame
sidecar records the source video in `XMP-xmpMM:DerivedFromFilePath` and
`XMP-vidfaces:SourceVideo`.

Nothing under the archive is touched in this phase.

#### Phase 2: digiKam (manual)

1. In Settings -> Configure digiKam -> Metadata, confirm that writing to XMP
   sidecars is enabled. The rest of the pipeline depends on it: confirmations
   held only in the digiKam database are invisible to phase 3.
2. Add the work directory as a collection: Album -> Import -> Add Collection.
3. Let digiKam finish scanning it.
4. In the People view, run face detection scoped to the new collection only, so
   the existing library is not rescanned.
5. Recognition proposes names using the model already trained on your photos.
6. Confirm the proposals. This step is load-bearing: digiKam writes a face to
   the sidecar only once it is confirmed, so an unconfirmed suggestion lives in
   the digiKam database alone and is invisible to phase 3. Faces you explicitly
   ignore are written out as the name `Ignored`, which phase 3 discards.
7. Apply any pending metadata changes so everything is flushed to the sidecars.
8. Remove the collection from digiKam once you are done.

Result: frame sidecars gain `XMP-mwg-rs:RegionName` entries and `People/<Name>`
tag entries.

#### Optional: propagate

digiKam confirms faces one frame at a time, so a person recognised in a few
frames of a video stays unrecognised in the rest and keeps being offered for
confirmation. This spreads the names sideways instead.

```sh
video_face_tagger.py propagate \
  --work ~/video_face_tagger_work \
  --people-root People \
  --dry-run
```

Every frame of a video receives the union of the names confirmed on any of its
frames. A video whose 100 frames had two people confirmed across nine of them
ends with all 100 frames carrying both names.

Only already-confirmed identities are copied. No face region is invented and
`XMP-mwg-rs` regions are left untouched, so this is not a substitute for
recognition. What it buys is a filter: once it has run, frames with no person
tag are exactly those from videos where nobody has been identified yet, which
is where the remaining manual effort belongs.

Frames are grouped by the hash in their filename, so this needs no access to
the archive at all and is safe to run with the archive unmounted or read-only.
It is idempotent, and re-running reports videos that are already consistent.

Note that frames keep any unconfirmed face regions they had, so digiKam will
still offer those regions for confirmation. Propagating tags makes the
redundant ones easy to identify and skip, rather than removing them.

#### Optional: prune

`propagate` adds tags but deliberately leaves face regions alone, so digiKam
still offers those frames for confirmation. `prune` shrinks what it asks about.

```sh
video_face_tagger.py prune --work ~/video_face_tagger_work --dry-run
video_face_tagger.py prune --work ~/video_face_tagger_work
```

For every video where at least one person is identified, frames are moved to a
`<work>-parked` sibling directory. Videos nobody has been identified in are
left completely alone, since those are where the remaining attention belongs.

Frames carrying a confirmed face region are always kept: a confirmed face is
not queued again, so they cost nothing. `--keep N` (default 1) sets a floor on
how many frames survive per video, which also guarantees a video is never
emptied -- phase 3 finds videos through their frames, so one with none left
would never be marked.

A name that exists only as a tag, with no face region anywhere, keeps the frame
that carries it, so pruning never loses a person even when run without
`propagate` first.

Parking is reversible: move the files back into the work directory to
reconsider a video. `--park-dir` chooses the destination, which must lie
outside `--work` because digiKam scans recursively. `--delete` removes frames
outright instead, which is not reversible.

Have digiKam rescan the collection afterwards to drop the parked frames from
its queue.

#### Phase 3: collect

Reads every frame sidecar, groups frames by source video, and merges the union
of the names found into each video's sidecar.

```sh
video_face_tagger.py collect \
  --path ~/Photo/_Inbox \
  --work ~/video_face_tagger_work \
  --jobs 6 \
  --people-root People \
  --extra-tag-fields \
  --log ~/video_face_tagger_work/logs/collect.log \
  --config ~/.config/video_face_tagger/config.toml
```

Names are read from both `XMP-mwg-rs:RegionName` and tag entries under the
people root, because which of the two digiKam writes depends on its metadata
settings. Placeholders are filtered out, `Ignored` being the one this archive
actually contains, and a
nested face tag such as `People/Family/Ivan Petrov` contributes only the leaf
name.

Each frame is matched to its video by the absolute path recorded in its own
sidecar, which needs no archive scan. If that field is missing, because another
tool rewrote the sidecar and dropped it, the hash embedded in the frame filename
is matched against the videos found under `--path` instead. A metadata tool
cannot alter a filename, so the two routes fail independently.

Result, appended to the video's existing sidecar:

| Field                        | Example value              |
| ---------------------------- | -------------------------- |
| `XMP-digiKam:TagsList`       | `People/Иван Петров`       |
| `XMP-lr:HierarchicalSubject` | `People\|Иван Петров`      |
| `XMP-dc:Subject`             | `Иван Петров`              |
| `XMP-vidfaces:FacesScanned`  | `faces-scanned:2026-08-25` |
| `XMP-vidfaces:FacesFound`    | `1`                        |

`--extra-tag-fields` additionally updates `XMP-microsoft:LastKeywordXMP` and
`XMP-mediapro:CatalogSets`, which digiKam also maintains.

Tags already present are left alone and new names are deduplicated against them,
so everything else in the sidecar survives untouched. A video whose frames
yielded no faces still receives the marker, with no tags added, so that it is not
reprocessed on the next run.

#### Phase 4: clean

```sh
video_face_tagger.py clean \
  --path ~/Photo/_Inbox \
  --work ~/video_face_tagger_work \
  --config ~/.config/video_face_tagger/config.toml
```

Removes frames and frame sidecars only for videos that carry the processing
marker. Frames belonging to videos that have not been through phase 3 are kept.
`--all` removes everything regardless.

#### Typical run

```sh
video_face_tagger.py status  --path ~/Photo/_Inbox
video_face_tagger.py extract --path ~/Photo/_Inbox --dry-run
video_face_tagger.py extract --path ~/Photo/_Inbox
#   ... phase 2 in digiKam ...
video_face_tagger.py collect --path ~/Photo/_Inbox --dry-run
video_face_tagger.py collect --path ~/Photo/_Inbox
video_face_tagger.py clean   --path ~/Photo/_Inbox
```

Run a small subdirectory end to end before turning it loose on the whole
archive.

#### Running in Docker on the NAS

Extracting frames and rewriting sidecars over SMB is slow, so the scripted
phases can run in a container on the server that holds the archive, while
phase 2 stays in digiKam on the desktop.
[Dockerfile](scripts/.local/bin/photo_archive/Dockerfile) builds an image with
ffmpeg, exiftool, the face pre-filter dependencies and the face model baked in,
and with the tool as its entry point. The package directory is the build
context.

```sh
# from the repository root: copy the package to the server
rsync -av --exclude __pycache__ --exclude .venv --exclude '*.csv' \
  scripts/.local/bin/photo_archive/ truenas:tools/video_face_tagger/photo_archive/

# on the server
cd ~/tools/video_face_tagger
sudo docker build -t video-face-tagger photo_archive
```

Two bind mounts are needed:

| Host                                          | Container       | Contents                                                  |
| --------------------------------------------- | --------------- | --------------------------------------------------------- |
| `/mnt/tank/photo/_Inbox`                      | `/photo/_Inbox` | The videos to process. Mount only what is to be processed |
| `/mnt/tank/data/Share/video_face_tagger_work` | `/work`         | Frames and logs. Must be reachable from digiKam over SMB  |

Create the work directory on the host before the first run. A bind mount
source that does not exist is created by Docker owned by root, and the
container cannot write to it.

```sh
mkdir -p /mnt/tank/data/Share/video_face_tagger_work
```

Every phase is then the same command with a different subcommand:

```sh
sudo docker run --rm -it --user 3000:3000 \
  -v /mnt/tank/photo/_Inbox:/photo/_Inbox \
  -v /mnt/tank/data/Share/video_face_tagger_work:/work \
  video-face-tagger extract --path /photo/_Inbox --work /work --jobs "$(nproc)"
```

| Phase | Subcommand and options                                        | Mounts                    |
| ----- | ------------------------------------------------------------- | ------------------------- |
| -     | `status --path /photo/_Inbox --work /work`                    | archive, work             |
| 1     | `extract --path /photo/_Inbox --work /work --jobs "$(nproc)"` | archive, work             |
| -     | `propagate --work /work`                                      | work                      |
| -     | `prune --work /work`                                          | work, plus `/work-parked` |
| 3     | `collect --path /photo/_Inbox --work /work --jobs "$(nproc)"` | archive, work             |
| 4     | `clean --path /photo/_Inbox --work /work`                     | archive, work             |

Add `--dry-run` to any of them first. `prune` parks frames in `/work-parked`,
which only survives the container if it is mounted too, from a host directory
created in advance:
`-v /mnt/tank/data/Share/video_face_tagger_work-parked:/work-parked`.

Things that matter:

- **Run as the owner of the archive** (`--user 3000:3000` here). exiftool
  replaces a sidecar rather than editing it in place, so a container running
  as root leaves every sidecar it touches owned by root.
- **Keep the archive's container path identical across phases.** Each frame
  records its video by absolute path as the container sees it, and the
  fallback hash in the frame filename is derived from that same path, so a
  different mount point in phase 3 matches nothing.
- **Do not move or rename videos between `extract` and `collect`**, for the
  same reason. Rename files only after `collect` has run.
- **Always pass `--path`.** Its default, `~/Photo`, does not exist in the
  container.
- **digiKam works on the work directory itself, not a copy.** Phase 3 reads the
  confirmations digiKam writes into the frame sidecars, so a copy would leave
  it with nothing to collect. On the Mac, add
  `/Volumes/data/Share/video_face_tagger_work` as a collection via Settings ->
  Configure digiKam -> Collections -> Add network share. Keep it outside the
  share digiKam's main collection lives in, or the frames get indexed into the
  library. Files edited over SMB are written as the share user, so ownership
  stays consistent with the container's.
- **Run inside tmux** (`tmux new -s vft`, later `tmux attach -t vft`), so that
  an SSH disconnect does not kill a long `extract`.

Logs land in `logs/` under the work directory on the host.

#### Where things are stored

| Path                                                    | Contents                                            |
| ------------------------------------------------------- | --------------------------------------------------- |
| `~/Photo/**/*.xmp`                                      | The real output: person tags and processing markers |
| `~/video_face_tagger_work/`                             | Extracted frames and their sidecars (disposable)    |
| `~/video_face_tagger_work/logs/<phase>.log`             | Per-phase logs                                      |
| `~/.config/video_face_tagger/config.toml`               | Defaults                                            |
| `~/.config/video_face_tagger/ExifTool_config`           | Private XMP namespace, generated automatically      |
| `~/.config/video_face_tagger/face_detection_yunet.onnx` | Face detection model                                |
| `scripts/.local/bin/.venv/`                             | Optional dependencies (git-ignored)                 |

#### Configuration

Defaults can be set in `~/.config/video_face_tagger/config.toml`. Command-line
arguments always win over the file.

```sh
video_face_tagger.py config --init   # write a commented template
video_face_tagger.py config          # show what is actually loaded
```

Keys are the long option names with dashes replaced by underscores. A
`[defaults]` table applies to every subcommand, and per-subcommand tables
override it.

```toml
[defaults]
path = "~/Photo"
work = "~/video_face_tagger_work"
jobs = 6

[extract]
interval = 10.0
max_frames = 12
select = "sharpest"

[collect]
extra_tag_fields = true
```

A setting that no subcommand accepts is reported as a warning, so a typo does
not silently look as though it took effect. A config file that fails to parse is
reported and ignored rather than aborting a long run.

#### Notes

- The processing marker lives in a private XMP namespace that nothing else
  writes. It can be read back by any exiftool, with or without the generated
  config file, because exiftool parses unknown XMP namespaces generically. The
  config is only needed in order to write it.
- exiftool rewrites a sidecar's structure when it edits it, converting attribute
  form to element form and splitting `rdf:Description` per namespace. This is
  not data loss: every tag value survives, and digiKam rewrites the file into
  its own style the next time it saves.
- exiftool's `-P` preserves whole seconds but truncates the sub-second part of a
  timestamp, so the tool captures and restores modification times itself at
  nanosecond precision.
- Person names are normalised to Unicode NFC before comparison, so the
  decomposed forms macOS tends to produce do not create duplicate tags.

### [video_geo_tagger.py](scripts/.local/bin/photo_archive/video_geo_tagger.py)

Infer GPS coordinates for videos by correlating them, in time, with geotagged
photos taken nearby in the archive.

About 8% of the videos here carry no coordinates. Those were usually shot
alongside photos that do, minutes apart and in the same place, so the
surrounding photos can supply a position good enough to put the video on a map.

#### Which timestamp is trusted

`FileModifyDate` is the authoritative capture time for videos, and QuickTime
`CreateDate` is ignored outright. `CreateDate` is stored in UTC per spec, files
re-encoded through Tdarr had local time written into that UTC field, and GoPro
footage carries a 2016 date because the camera clock was never set. mtime has
been curated across the whole archive instead, and the same timestamp is
encoded in every filename.

That makes mtime load-bearing, with two consequences. Every write preserves it
at nanosecond precision. And each video's mtime is cross-checked against the
timestamp in its own filename: a disagreement means something touched the file,
and the video is held back for review rather than geotagged.

The cross-check is also a timezone guard. mtime is stored as an epoch, so it
only renders back to the curated wall-clock time in the timezone the archive
was curated in. Run this somewhere else and essentially every video reports a
mismatch, which is loud and obvious rather than silently wrong.

For photos, `exif:DateTimeOriginal` is used: local time, and reliable.

#### The algorithm

For each video lacking coordinates:

1. Take its mtime as the capture time.
2. Collect geotagged photos within `--window` of that time, from the directory
   chosen by `--scope`.
3. Take the median latitude and the median longitude independently. A mean
   would put two photos on opposite sides of a bay into the water; a median
   picks a real place. Candidates further than `--radius` from that median are
   discarded as outliers and the median is recomputed.
4. Measure the spread: the furthest any candidate sits from the median. Beyond
   `--radius` the subject was moving, so no position is claimed.
5. Measure the implied speed between the nearest photo before and the nearest
   photo after. Walking pace means stationary and safe.
6. Emit coordinates rounded to `--precision` decimals, about 10 m at the
   default of 4, so the result cannot be mistaken for a measured fix.

Devices are deliberately not filtered on. Phones sync their clocks over the
network, and requiring the same camera would throw away every case where one
person shoots video while another shoots photos. The matched photos' devices
are reported as context instead. The clearest confirmation of that choice in
this archive is a pair of Disney World videos matched from a Pixel 6 and an
iPhone 16 Pro at once.

#### Result categories

Every video lands in exactly one bucket.

| category                         | meaning                                                   |
| -------------------------------- | --------------------------------------------------------- |
| `confident`                      | both sides, tight, slow, enough candidates. Safe to apply |
| `review: one-sided`              | candidates only before, or only after                     |
| `review: scattered`              | spread exceeds `--radius`                                 |
| `review: moving`                 | implied speed exceeds `--max-speed`                       |
| `review: below-minimum`          | fewer candidates than `--min-candidates`                  |
| `review: single-candidate`       | exactly one geotagged photo in the window                 |
| `review: filename-time-mismatch` | mtime disagrees with the filename                         |
| `review: no-filename-time`       | filename carries no timestamp to check                    |
| `skipped: no candidates`         | nothing geotagged in the window                           |
| `skipped: already geotagged`     | the video already has coordinates                         |
| `skipped: already inferred`      | carries this tool's marker; use `--force`                 |

Only `confident` is ever applied automatically, and only when `--apply` is
given. Everything else is reported for a human to approve.

#### Defaults, and where they came from

The defaults were chosen by running `validate` over the 2881 videos in this
archive that already have coordinates, and measuring the error between the real
and inferred positions:

| category                   |   n | median |     p90 |     p99 | within 1 km |
| -------------------------- | --: | -----: | ------: | ------: | ----------: |
| `confident`                | 251 |   11 m |   198 m |  7.1 km |       97.2% |
| `review: one-sided`        | 346 |   20 m |  5.6 km |  204 km |       84.4% |
| `review: below-minimum`    | 138 |   14 m |  7.1 km |  109 km |       79.7% |
| `review: single-candidate` | 318 |   20 m | 11.4 km | 42.4 km |       78.0% |
| `review: scattered`        | 831 |  412 m | 16.0 km | 1804 km |       61.3% |

Two things that measurement settled:

- `--radius`, not `--window`, is what protects the result. Widening the window
  does not degrade the confident bucket, because extra candidates that
  disagree push a video into `scattered` rather than into a wrong answer.
- `--min-candidates` defaults to 3 rather than 2. Split by candidate count,
  every gross error in the confident bucket came from a two-photo match, whose
  p90 error was 49.9 km against 267 m for three or more. Two photos that happen
  to agree with each other prove very little.

`--max-speed` is close to inert at the default radius, where the candidates
cannot be far apart by construction: it fired once in 2881 videos. It earns its
keep only when two photos sit seconds apart but hundreds of metres apart, and
it is reported as a column regardless.

#### Usage

```sh
# analyse; writes the CSV report, touches no sidecar
video_geo_tagger.py analyze --path ~/Photo --csv ~/geo.csv

# review the CSV, then apply the rows whose 'apply' column says yes
video_geo_tagger.py apply --path ~/Photo --from-csv ~/geo.csv --dry-run
video_geo_tagger.py apply --path ~/Photo --from-csv ~/geo.csv

# or apply the confident rows straight away
video_geo_tagger.py analyze --path ~/Photo --apply

# calibrate: infer for videos that already have coordinates, worst error first
video_geo_tagger.py validate --path ~/Photo --csv ~/validate.csv

# routine run over new imports
video_geo_tagger.py analyze --path ~/Photo/_Inbox
```

Every threshold is a flag:

```sh
video_geo_tagger.py analyze \
  --path ~/Photo \
  --scope dir \
  --window 4 \
  --radius 300 \
  --min-candidates 3 \
  --max-speed 10 \
  --precision 4 \
  --time-tolerance 1 \
  --csv ~/geo.csv \
  --max-rows 60 \
  --config ~/.config/video_geo_tagger/config.toml
```

`--scope` decides where candidate photos come from: `dir` (default) is the
video's own directory, `dir+siblings` is everything under its parent, `tree` is
the whole `--path`. `dir+siblings` is what reaches videos filed in video-only
folders such as `Video_GoPro/` or `_Inbox/Video/iPhone/`, which no
same-directory search can ever match. Measured over this archive it takes the
confident count from 3 to 8 and cuts the no-candidate count from 92 to 78, at
the cost of more `scattered` results to review.

#### What gets written

Only the video's XMP sidecar, and only when it has no coordinates already. A
video that already has a position is never overwritten; the disagreement is
reported instead.

```
XMP-exif:GPSLatitude      27.8526
XMP-exif:GPSLongitude     -82.8465
XMP-vidgeo:GeoInferred    geo-inferred:2026-08-31
XMP-vidgeo:GeoConfidence  confident
XMP-vidgeo:GeoCandidates  4
XMP-vidgeo:GeoSpread      13
```

`XMP-exif:GPSLatitude` and `GPSLongitude` are what Immich reads. The `vidgeo`
fields are a private namespace, declared by a generated
`~/.config/video_geo_tagger/ExifTool_config`, and are chosen so that nothing
else in the pipeline has any reason to touch them.

Recording the spread separately is what makes a low-precision inference
revocable later without recomputing anything:

```sh
exiftool -config ~/.config/video_geo_tagger/ExifTool_config \
  -if '$GeoSpread > 100' -p '$FilePath' -r ~/Photo
```

The `-config` option is only honoured when it is the very first argument;
elsewhere on the command line exiftool ignores it silently.

#### The CSV

One row per video, all categories included, sorted by category. Columns:
`video`, `category`, `apply`, `latitude`, `longitude`, `candidates`,
`inliers`, `spread_m`, `speed_kmh`, `capture_time`, `filename_time`,
`before_gap_s`, `after_gap_s`, `nearest_gap_s`, `devices`, `photos`,
`existing_latitude`, `existing_longitude`, `error_m`, `note`.

The `apply` column is the review mechanism: `analyze` pre-fills `yes` for
confident rows and `no` for everything else, and `apply --from-csv` honours
whatever is in it. Editing `latitude` and `longitude` by hand works too, so a
borderline case can be corrected rather than merely approved or rejected.

`nearest_gap_s` is filled in for videos that found nothing, so a run tells you
how much wider a window would have to be before it helped.

### [normalize_names_nfc.py](scripts/.local/bin/photo_archive/normalize_names_nfc.py)

Recursively normalise file and directory names to Unicode NFC.

macOS represents filenames in a decomposed form while Linux filesystems
preserve whatever bytes they are given, so the same name can exist in two
spellings that look identical. rsync then treats them as different files and
recreates them endlessly.

Run it on the machine that owns the storage. The macOS SMB and AFP clients
convert names to NFD on the wire, so names can never be normalised through such
a mount; the script detects this and refuses to continue.

```sh
normalize_names_nfc.py /mnt/tank/photo                  # dry run, the default
normalize_names_nfc.py --apply /mnt/tank/photo
normalize_names_nfc.py --resolve-duplicates --apply /mnt/tank/photo
```

Where both spellings of one name exist side by side, the collision is reported
with a comparison of the two objects. `--resolve-duplicates` deletes a non-NFC
object only when its contents are already present in full under the NFC name.

### [claude_session.py](scripts/.local/bin/claude_session.py)

Find, resume and manage Claude Code sessions from any directory, by the name
given with `/rename`, in an fzf picker modelled on
[fzf-git-branches](https://github.com/awerebea/fzf-git-branches).

It keeps a registry of named sessions across all projects, shows which ones
are open right now and where, and resumes a session in the directory it was
started in.

#### Requirements

- Python 3.10 or newer, standard library only
- `fzf` (a recent version; tested with 0.75) for the picker
- `tmux`, optionally, to jump to a session that is already open

#### Install

```sh
# from the repository root: the command is claude-session
ln -s "$PWD/scripts/.local/bin/claude_session.py" ~/.local/bin/claude-session
```

Register sessions as they end with a `SessionEnd` hook in
`~/.claude/settings.json`:

```json
"hooks": {
  "SessionEnd": [
    { "hooks": [{ "type": "command", "command": "$HOME/.local/bin/claude-session hook" }] }
  ]
}
```

Then pick up the sessions that ended before the hook existed:

```sh
claude-session sync
```

`zsh/.zshrc` regenerates the zsh completion whenever the script is newer than
it, and defines the aliases `cs`, `csr` (resume) and `csl` (list).

#### How it works

- `/rename` writes a `custom-title` record into the session transcript
  (`~/.claude/projects/<project>/<session id>.jsonl`). The hook reads it when
  the session ends and records the name, the session ID and the directory in
  the registry.
- Open sessions are read from Claude Code's own
  `~/.claude/sessions/<pid>.json`, so a `/rename` shows up at once, together
  with the process ID and tmux pane of the session.
- The registry is keyed by session ID, so names may repeat: two `infra`
  sessions in different repositories are told apart by their directory.
- With `-a/--all` or `-u/--unnamed`, the transcripts themselves are scanned, so
  unnamed sessions can be listed, resumed, named or deleted as well.

#### Usage

```sh
claude-session                 # the picker (same as `claude-session manage`)
claude-session resume infra    # the picker, with "infra" as the query
claude-session resume -1 infra # resume at once if only one session matches
claude-session resume 8c1f2a90 # a session ID or 8+ character prefix: no picker
claude-session resume infra -- --model opus   # arguments after -- go to claude

claude-session list -a -t      # every session, with its AI title
claude-session list -u -s path # unnamed sessions by directory
claude-session list -C always | less -R   # keep the colors in a pipe
claude-session info infra      # everything known about a session
claude-session rename old new
claude-session remove infra    # drop from the list (sync skips it)
claude-session remove -P infra # delete its data for good
```

Resume changes into the session's directory first (`-H/--here` stays put).
Choosing a session that is open in another tmux pane offers to switch to that
pane instead; outside tmux it prints where the session is open, and
`-f/--force` resumes it anyway.

Without fzf or a terminal, NAME is looked up directly: an exact name, a unique
prefix of one, or a session ID. A name shared by several sessions means the one
started in the current directory; anything still ambiguous is an error listing
the candidates.

#### The picker

Named sessions are shown as `[name]` and unnamed ones as `(short ID)`, with
their directory, status (`open`, or `hidden` for removed sessions) and dates.
The query matches the name and directory columns only.

| Key          | Action                                                        |
| ------------ | ------------------------------------------------------------- |
| `enter`      | Resume the session under the cursor                           |
| `ctrl-t`     | Select and move down; selections are for the delete keys      |
| `ctrl-d`     | Remove the selected sessions from the list (asks first)       |
| `ctrl-alt-d` | Delete the selected sessions' data, closing open ones (asks)  |
| `ctrl-r`     | Rename the session under the cursor                           |
| `ctrl-o`     | Show its info                                                 |
| `alt-a`      | Cycle the sessions shown: named, all, unnamed                 |
| `alt-t`      | Show or hide the AI title column                              |
| `alt-c`      | Cycle the date columns: last active, created, both            |
| `alt-s`      | Cycle the sort: last active, created, name, directory, status |
| `alt-r`      | Reverse the sort order                                        |

The view keys last until the picker closes; their defaults come from the
options below. Dates sort newest first, names and directories A-Z, statuses
open first; the sorted column is marked `v` or `^`. Sessions whose name matches
the NAME argument are listed first.

#### Removing and deleting

`remove` (`ctrl-d`) only takes a session off the list: `sync` and the hook skip
it until it is renamed, and its transcript stays where it is, so `claude
--resume` still finds it.

`remove -P` (`ctrl-alt-d`) deletes the transcript, the folder beside it (tool
results, `custom-title.json`), `~/.claude/file-history/<id>` and
`~/.claude/session-env/<id>`, after listing them with their sizes and asking
once, default no. An open session is closed first (SIGTERM, then SIGKILL), and
a session never deletes the one it runs in. The shared prompt history,
`~/.claude/history.jsonl`, is left alone: open sessions append to it.

#### Configuration

Defaults can be set in the environment or in
`~/.config/claude-session/claude-session.conf`, as `KEY=VALUE` lines. The
command line wins over the environment, which wins over the file.

| Setting                       | Meaning                                       |
| ----------------------------- | --------------------------------------------- |
| `CLAUDE_SESSION_SORT`         | `active`, `created`, `name`, `path`, `status` |
| `CLAUDE_SESSION_REVERSE=1`    | Reverse the sort order                        |
| `CLAUDE_SESSION_DATE`         | `active`, `created` or `both`                 |
| `CLAUDE_SESSION_AI_TITLE=1`   | Show the AI title column                      |
| `CLAUDE_SESSION_COLOR`        | `auto`, `always` or `never`                   |
| `CLAUDE_SESSION_KEY_<ACTION>` | Picker key of an action, see below            |
| `CLAUDE_SESSION_CLAUDE_BIN`   | The claude executable                         |
| `CLAUDE_SESSION_REGISTRY`     | The registry file                             |

The picker actions are `REMOVE`, `PURGE`, `RENAME`, `INFO`, `ALL`, `TITLES`,
`DATES`, `SORT` and `REVERSE`, e.g. `CLAUDE_SESSION_KEY_PURGE=ctrl-x`.

Output is colored where it goes to a terminal and plain where it is piped or
redirected (`auto`, the default; stdout and stderr are judged separately).
`-C/--color always` keeps the colors in a pipe, and `never` turns them off
everywhere, the picker included. In `auto` mode, `NO_COLOR` turns them off too.

#### Where things are stored

| Path                                           | Contents                                                       |
| ---------------------------------------------- | -------------------------------------------------------------- |
| `~/.claude/session-registry.json`              | Named sessions by ID, and removed ones                         |
| `~/.claude/projects/<project>/<id>.jsonl`      | Transcripts (Claude Code's; read, and appended to by `rename`) |
| `~/.claude/sessions/<pid>.json`                | Open sessions (Claude Code's; read only)                       |
| `~/.config/claude-session/claude-session.conf` | Defaults                                                       |

`CLAUDE_CONFIG_DIR` moves everything under `~/.claude`, as it does for Claude
Code itself.
