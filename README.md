# 💿 HiFi DVD Pro (v1.0.0)

**HiFi DVD Pro** is an interactive Bash script designed for creating and authoring professional **Hi-Fi Audio DVDs** (`VIDEO_TS` folders and/or `.iso` disc images) from lossless (**FLAC**, **WAV**) or compressed (**MP3**, **OGG**, **M4A**, **AAC**) audio files, incorporating album artwork as a static background during playback.

---

## ✨ Key Features

* 🎵 **Multi-format Support:** Processes `.flac`, `.wav`, `.mp3`, `.ogg`, `.m4a`, `.aac`, `.wma`, and `.alac` files.
* 🖼️ **Custom Static Cover Art:** Automatically detects `cover.jpg` (or `.png`) and adapts it to DVD video standards.
* 🎚️ **EBU R128 Volume Normalization:** Integrated option to equalize loudness across tracks while preserving dynamic audio quality.
* 📺 **TV Standards:** Supports **PAL** (Europe/Asia - 720x576 @ 25fps) and **NTSC** (Americas/Japan - 720x480 @ 29.97fps).
* 📊 **Smart Capacity Estimator:** Pre-calculation module that estimates space requirements and alerts if the project needs a **DVD-5 (Single-layer - 4.7 GB)** or a **DVD-9 (Dual-layer - 8.5 GB)**.
* 🌍 **Auto Language Detection (7 Languages):** Adaptive interface for **English (EN)**, **Spanish (ES)**, **Catalan (CA)**, **Portuguese (PT)**, **French (FR)**, **German (DE)**, and **Italian (IT)**.
* ⏱️ **Interactive Progress Bar:** Real-time visual progress tracking during encoding and authoring.
* 🔔 **Desktop Notifications:** System notifications upon completion or in case of errors.

---

## 📋 System Requirements (Dependencies)

To run correctly, the script requires the following tools installed on your Linux system:

* `ffmpeg` (for audio/video encoding)
* `dvdauthor` (for DVD structure generation)
* `genisoimage` or `mkisofs` (for ISO image creation)
* `sox` (for audio analysis and processing)
* `libnotify-bin` (for desktop notifications)

> 💡 **Note:** If any dependency is missing, the script will offer to install it automatically on Debian/Ubuntu-based distributions.

---

## 🚀 Quick Installation

1. **Clone the repository** or download the `hifi-dvd-pro.sh` script:
   ```bash
   git clone [https://github.com/marcopcabrera/hifi-dvd-pro.git](https://github.com/marcopcabrera/hifi-dvd-pro.git)
   cd hifi-dvd-pro

## 📂 Folder Requirements

Before running the script, make sure your album directory contains:
* Your audio files (`.flac`, `.wav`, `.mp3`, etc.).
* A cover image named **`cover`** (e.g., `cover.jpg` or `cover.png`).

Example of a valid album folder:
├── 01-track.flac
├── 02-track.flac
└── cover.jpg
