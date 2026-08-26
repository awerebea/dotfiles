# My config files and settings

Managed with [GNU stow](https://www.gnu.org/software/stow/). Each top-level
directory is a stow package mirroring the layout it should take under `$HOME`,
so `stow <package>` from the repository root symlinks it into place.

## Scripts

### [video_face_tagger.py](scripts/.local/bin/video_face_tagger.py)

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
[requirements_video_face_tagger.txt](scripts/.local/bin/requirements_video_face_tagger.txt).

#### Install

```sh
# from the repository root, symlink the script into ~/.local/bin
stow scripts

# optional: face pre-filter dependencies, in a venv beside the script
cd scripts/.local/bin
python3 -m venv .venv
.venv/bin/pip install -r requirements_video_face_tagger.txt

# optional: the face detection model (a separate step)
video_face_tagger.py fetch-model
```

The script re-executes itself under a virtualenv interpreter when it finds
one, so there is no shebang to edit and nothing to activate.

It never imposes a particular location. If a virtualenv is already active, that
one is used and nothing is overridden. Otherwise it looks for `.venv` or `venv`
beside the script, then `~/.local/share/video_face_tagger/venv`. Setting
`VIDEO_FACE_TAGGER_PYTHON` to an interpreter overrides all of it.

To confirm which interpreter is in use, pass `--verbose` and look for the
`interpreter:` line.

Without the optional dependencies the tool works normally, just with a larger
working set. It warns when the filter is off but could be enabled, and prints
the exact commands still missing. Pass `--face-filter off` to silence that.

#### The pipeline

Four phases, three of them scripted:

| Phase | Command | What happens |
| --- | --- | --- |
| 1 | `extract` | Sample frames from videos into the work directory |
| 2 | *manual* | In digiKam: detect, recognise, and confirm faces |
| 3 | `collect` | Merge confirmed names into the video sidecars |
| 4 | `clean` | Drop work frames for processed videos |

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

The number of frames per video is `duration / interval`, clamped between 1 and
`--max-frames`, and the samples are spread evenly across the whole clip. A long
video therefore gets `--max-frames` samples spanning its full length rather than
a dense burst at the start, and a clip shorter than one interval still yields
one frame taken from the middle.

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

| Field | Example value |
| --- | --- |
| `XMP-digiKam:TagsList` | `People/Иван Петров` |
| `XMP-lr:HierarchicalSubject` | `People\|Иван Петров` |
| `XMP-dc:Subject` | `Иван Петров` |
| `XMP-vidfaces:FacesScanned` | `faces-scanned:2026-08-25` |
| `XMP-vidfaces:FacesFound` | `1` |

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

#### Where things are stored

| Path | Contents |
| --- | --- |
| `~/Photo/**/*.xmp` | The real output: person tags and processing markers |
| `~/video_face_tagger_work/` | Extracted frames and their sidecars (disposable) |
| `~/video_face_tagger_work/logs/<phase>.log` | Per-phase logs |
| `~/.config/video_face_tagger/config.toml` | Defaults |
| `~/.config/video_face_tagger/ExifTool_config` | Private XMP namespace, generated automatically |
| `~/.config/video_face_tagger/face_detection_yunet.onnx` | Face detection model |
| `scripts/.local/bin/.venv/` | Optional dependencies (git-ignored) |

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
