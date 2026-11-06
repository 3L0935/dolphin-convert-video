# Convert video (Dolphin service menu)

Right-click any video in Dolphin and turn it into an MP4 that plays everywhere,
in two clicks.

Built for screen recordings (OBS, GPU Screen Recorder, Spectacle...) saved in
AV1, HEVC, MKV or other formats that many websites can't preview. The default
preset produces files that show an inline video preview when attached to
**Jira**, and that play in Discord, Slack and any browser.

```
Right-click a video
└── Convert video
    ├── For sharing (plays everywhere)
    ├── For sharing, faster (uses GPU)
    ├── Smaller file (720p)
    ├── Best quality (big file)
    └── Fit to size...
```

## Presets

| Menu entry | Output file | What you get |
| --- | --- | --- |
| For sharing (plays everywhere) | `name.share.mp4` | Up to 1080p, 30 fps. The safe choice for Jira, Discord, Slack, web. |
| For sharing, faster (uses GPU) | `name.share-fast.mp4` | Same as above, encoded on the graphics card. Much faster, slightly bigger file. |
| Smaller file (720p) | `name.small.mp4` | 720p, 30 fps. Good for quick bug reports and chat apps. |
| Best quality (big file) | `name.best.mp4` | Original resolution and frame rate, high quality. Websites may not preview it. |
| Fit to size... | `name.10MB.mp4` | Asks for a size in MB and aims just under it (e.g. Discord's upload limit). |

- The original file is never modified, deleted or overwritten.
- Select several files at once to convert them all.
- A progress bar shows up, with a Cancel button. A notification tells you when it's done.

## Install

Requirements: KDE Plasma 6 (Dolphin), `ffmpeg`, `kdialog`, `notify-send`
(libnotify) and `qdbus` from the Qt 6 tools (for the progress bar).

On Arch / CachyOS / Manjaro:

```sh
sudo pacman -S --needed ffmpeg kdialog libnotify qt6-tools
```

On other distros, install the same tools from your package manager. Your
ffmpeg build needs `libx264` (on Fedora, use the RPM Fusion ffmpeg, not
`ffmpeg-free`). `./install.sh` warns about anything missing.

Then:

```sh
git clone https://github.com/3L0935/dolphin-convert-video.git
cd dolphin-convert-video
./install.sh
```

Restart Dolphin. That's it.

It installs two files for your user only (no root needed):

- `~/.local/bin/convert-video` (the script)
- `~/.local/share/kio/servicemenus/convert-video.desktop` (the menu)

Uninstall with `./install.sh --uninstall`.

## Command line

The script works without Dolphin too:

```sh
convert-video share recording.mkv
convert-video small *.mp4
convert-video size clip.webm        # asks for the size in a dialog
```

## Technical details

Why the "sharing" preset previews where a plain `ffmpeg -c:v libx264` does not:

- **`-movflags +faststart`**: puts the MP4 index at the start of the file, so
  a browser can start playing before downloading everything. Without it, Jira
  shows *Preview unavailable*.
- **H.264 Main profile, level 4.1, 8-bit 4:2:0 (`yuv420p`)**: decodable by every
  browser and phone. 10-bit sources (HEVC/AV1 Main 10) would otherwise produce
  "High 10" H.264, which browsers don't play.
- **Width and height cropped to a multiple of 8**: some recorders produce sizes
  like 1920x1082. The odd lines are cropped (1082 -> 1080), not stretched.
- **30 fps max, 1080p max** (the short side is capped, so portrait phone videos
  stay portrait).
- **AAC stereo audio**: Opus or other codecs are re-encoded, AAC is the one
  every MP4 player supports.

Other notes:

- Any input ffmpeg can read works: MKV, MP4, MOV, AVI, WebM, TS... with AV1,
  HEVC, VP9, ProRes, MPEG-2, etc. Rotated phone videos are straightened.
- The GPU preset uses VAAPI (AMD and Intel). Set `CONVERT_VIDEO_VAAPI_DEVICE`
  if your render node isn't `/dev/dri/renderD128`. NVIDIA users: VAAPI usually
  isn't available, use the regular preset.
- HDR videos are converted but not tone-mapped, colors will look washed out.
- "Fit to size" uses a 2-pass encode and drops the resolution (720p, then 480p)
  when the target is too small for 1080p to look decent.

## License

MIT
