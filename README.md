# flutter_synced_lyrics

<p align="center">
  <a href="https://pub.dev/packages/flutter_synced_lyrics"><img src="https://img.shields.io/pub/v/flutter_synced_lyrics.svg?style=flat-square&color=00E676" alt="Pub Version"></a>
  <a href="https://pub.dev/packages/flutter_synced_lyrics/score"><img src="https://img.shields.io/pub/points/flutter_synced_lyrics?style=flat-square&color=00B0FF" alt="Pub Points"></a>
  <a href="https://govindtank.github.io/flutter_synced_lyrics/"><img src="https://img.shields.io/badge/Live_Demo-Try_in_Browser-00E676?style=flat-square&logo=googlechrome&logoColor=white" alt="Live Demo"></a>
  <a href="https://github.com/govindtank/flutter_synced_lyrics"><img src="https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20web%20%7C%20macos%20%7C%20windows%20%7C%20linux-blue?style=flat-square" alt="Platform"></a>
  <a href="https://github.com/govindtank/flutter_synced_lyrics/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=flat-square" alt="License"></a>
  <a href="https://buymeacoffee.com/govindtanko"><img src="https://img.shields.io/badge/Donate-Buy%20Me%20A%20Coffee-yellow.svg?style=flat-square&logo=buymeacoffee" alt="Buy Me A Coffee"></a>
  <a href="https://github.com/sponsors/govindtank"><img src="https://img.shields.io/badge/Sponsor-GitHub-ea4aaa.svg?style=flat-square&logo=githubsponsors" alt="GitHub Sponsors"></a>
</p>

<p align="center">
  <strong>High-performance 120 FPS synchronized lyrics and karaoke engine for Flutter.</strong><br>
  Character-wise &amp; word-wise fluid flowing, Apple Music &amp; Spotify presets, Hindi &amp; multilingual dual-track subtitles, complete pure-Dart TTML XML parser, and ambient mesh backdrops.
</p>

---

<p align="center">
  <a href="https://govindtank.github.io/flutter_synced_lyrics/">
    <img src="https://raw.githubusercontent.com/govindtank/flutter_synced_lyrics/main/doc/assets/showcase.gif" alt="flutter_synced_lyrics in action" width="100%" />
  </a>
</p>

<p align="center">
  <a href="https://govindtank.github.io/flutter_synced_lyrics/">
    <img src="https://img.shields.io/badge/🚀_LAUNCH_LIVE_DEMO_STUDIO-00E676?style=for-the-badge&logoColor=white" alt="Live Web Studio" />
  </a>
</p>

---

## ⚡ Highlights & Real Capabilities

* 🌊 **Character-Wise & Word-Wise Flowing**: Choose between continuous liquid character sweep (`LyricFlowMode.characterSmooth`), stepped arcade KTV reveal (`LyricFlowMode.characterStepped`), or word/syllable timing (`LyricFlowMode.word`).
* 📜 **Full-Featured Pure-Dart TTML XML Parser**: Native W3C and Apple Music TTML XML parser supporting `<p begin="" end="">` lines, `<span begin="" end="">` word tokens, and clock/offset timestamps (`00:01:23.450`, `4.5s`, `4500ms`).
* 🪔 **Hindi & Multilingual Dual-Track Support**: Native 3-tier track rendering per line: **Devanagari Hindi (हिंदी) / Original Lyric + Romanization/Hinglish (Romaji, Pinyin, Furigana) + Translated Meaning**.
* ⏱️ **Standard & Enhanced Syllable LRC**: Seamlessly parses `[mm:ss.xx]` lines, fine-grained `<mm:ss.xx> word <mm:ss.xx>` timestamps, metadata tags (`[ti:]`, `[ar:]`, `[offset:]`), and repeated timestamps.
* 🎨 **6 Trending Visual Presets**:
  * **Bollywood Royal**: Saffron and warm amber gold glow with Devanagari typography.
  * **Apple Music**: Syllable gradient wipe, 1.10x active spring zoom, and frosted blur on inactive lines.
  * **Spotify**: High-contrast bold typography, center snap alignment, and dimmed inactive lines.
  * **Musixmatch**: High-energy neon yellow/green fill, word bounce & glow.
  * **Cyberpunk HUD**: Monospace typography, cyan neon bloom, and magenta accents.
  * **Minimalist Hi-Fi Vinyl**: Refined editorial serif typography with relaxed rhythm.
* 🧭 **Smart Auto-Scroll & Exploration**: Automatically pauses auto-scrolling when the user touches or drags the lyrics to browse upcoming verses, and displays a floating **"Return to current line"** snap-back pill with configurable idle resume timeout.
* 🎸 **Instrumental Break Handling**: Automatically detects musical pauses (>4s) between verses and renders animated pulsing visualizer dots and remaining countdown seconds.
* 📱 **Companion Widgets Included**:
  * `MiniLyricsBar`: Compact single or dual-line marquee/flipper for bottom mini-players and car dashboards.
  * `AmbientLyricsBackdrop`: Dynamic reactive blurred ambient mesh canvas that glows behind lyrics.
* 🚀 **Zero Material Coupling & Zero Dependency Lock-In**: Built entirely on foundational `package:flutter/widgets.dart` with zero deprecated imports. Compatible with `just_audio`, `audioplayers`, `flutter_sound`, Web Audio, or custom stream controllers.

---

## 📦 Installation

Add `flutter_synced_lyrics` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_synced_lyrics: ^1.0.1
```

Then import the package:

```dart
import 'package:flutter_synced_lyrics/flutter_synced_lyrics.dart';
```

---

## 🚀 Quick Start

### 1. Initialize Controller & Bind Audio Stream

```dart
// Parse from any format (Standard LRC, Syllable LRC, TTML XML, or JSON)
final controller = LyricsController.fromSource(
  rawLyricsString,
  config: const LyricsConfig(
    autoScroll: true,
    activeLineAnchor: 0.42, // Optimal eye-level reading anchor
    idleTimeoutBeforeResume: Duration(seconds: 3),
  ),
  onSeekRequest: (seekTarget) {
    // Jump audio player when user taps any lyric line or syllable
    audioPlayer.seek(seekTarget);
  },
);

// Stream playback position directly from your player
audioPlayer.positionStream.listen((position) {
  controller.progress = position;
});
```

### 2. Embed `LyricsView`

```dart
LyricsView(
  controller: controller,
  theme: LyricsPreset.appleMusic(),
  flowMode: LyricFlowMode.characterSmooth, // or LyricFlowMode.word
  showTranslation: true,
  showRomanization: true,
)
```

---

## 🌊 Flow Modes: Character-Wise vs Word-Wise

`flutter_synced_lyrics` gives you fine-grained control over how text illuminates as the music plays:

```dart
// 1. Character Smooth (Liquid sub-pixel sweep across characters)
LyricsView(
  controller: controller,
  flowMode: LyricFlowMode.characterSmooth,
);

// 2. Character Stepped (Classic arcade / KTV stepped reveal)
LyricsView(
  controller: controller,
  flowMode: LyricFlowMode.characterStepped,
);

// 3. Word-by-Word / Syllable Wiping (Modern streaming style)
LyricsView(
  controller: controller,
  flowMode: LyricFlowMode.word,
);
```

> **Pro Tip**: Even standard LRC files without explicit syllable tags automatically support `LyricFlowMode.characterSmooth` and `LyricFlowMode.characterStepped` — the engine calculates real-time progress across characters dynamically!

---

## 📜 Deep Dive: Full TTML (Timed Text XML) Integration Guide

### Why TTML Beats Traditional LRC for Modern Music Apps

| Capability | Standard LRC (`.lrc`) | Timed Text Markup Language (`.ttml` / `.xml`) |
| :--- | :--- | :--- |
| **Timing Precision** | Whole line only (`[00:12.34]`) | Sub-millisecond syllable tokens (`<span begin="" end="">`) |
| **Word-Level Karaoke** | Rough line interpolation | Exact word-by-word and character-by-character synchronization |
| **Multilingual Tracks** | Clunky repeated timestamps | Native `<p xml:lang="...">` and translation roles |
| **Industry Adoption** | Legacy MP3 files | **Apple Music, Musixmatch, Spotify, and W3C broadcast standard** |

### Step-by-Step Integration

#### Step 1: Prepare or Fetch TTML XML Content

TTML files structure lyrics into paragraph blocks (`<p>`) with nested word/syllable spans (`<span>`):

```xml
<?xml version="1.0" encoding="utf-8"?>
<tt xmlns="http://www.w3.org/ns/ttml" xmlns:ttm="http://www.w3.org/ns/ttml#metadata">
  <head>
    <metadata>
      <ttm:title>Blinding Lights</ttm:title>
      <ttm:artist>The Weeknd</ttm:artist>
    </metadata>
  </head>
  <body>
    <div>
      <p begin="00:00:03.200" end="00:00:06.500">
        <span begin="00:00:03.200" end="00:00:04.000">I've </span>
        <span begin="00:00:04.000" end="00:00:04.800">been </span>
        <span begin="00:00:04.800" end="00:00:05.600">tryin' </span>
        <span begin="00:00:05.600" end="00:00:06.500">to call</span>
      </p>
    </div>
  </body>
</tt>
```

#### Step 2: Load and Parse with `LyricsParser.fromTtml()`

```dart
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_synced_lyrics/flutter_synced_lyrics.dart';

// Load from bundled asset:
final ttmlXml = await rootBundle.loadString('assets/lyrics/song.ttml');

// Or parse directly from your backend HTTP API response:
final document = LyricsParser.fromTtml(ttmlXml);
```

#### Step 3: Connect to Controller & LyricsView

```dart
final controller = LyricsController(
  document: document,
  config: const LyricsConfig(
    autoScroll: true,
    activeLineAnchor: 0.42,
  ),
  onSeekRequest: (seekTarget) => audioPlayer.seek(seekTarget),
);

// Bind your audio position stream
audioPlayer.positionStream.listen((pos) => controller.progress = pos);

// Render in your UI
LyricsView(
  controller: controller,
  theme: LyricsPreset.appleMusic(),
  flowMode: LyricFlowMode.characterSmooth,
)
```

---

## 🪔 Song Representation in Hindi & Multilingual Subtitles

Display original lyrics in Devanagari Hindi (हिंदी) alongside Hinglish Romanization and English translations:

```
[00:02.00]मुझको इतना बताए कोई
[00:02.00]Mujhko itna bataye koi
[00:02.00]Someone please tell me this
[00:07.50]कैसे तुझसे दिल ना लगाए कोई
[00:07.50]Kaise tujhse dil na lagaye koi
[00:07.50]How could anyone not fall for you?
```

All 3 tracks synchronize automatically:

```dart
LyricsView(
  controller: controller,
  theme: LyricsPreset.bollywoodRoyal(
    gold: Color(0xFFFFD700),
    saffron: Color(0xFFFF9933),
    flowMode: LyricFlowMode.characterSmooth,
  ),
  showTranslation: true,
  showRomanization: true,
)
```

---

## 🎨 Visual Style Presets

Switch between trending designs with one line:

```dart
// 1. Bollywood Royal (Hindi / Devanagari Gold & Saffron)
LyricsView(
  controller: controller,
  theme: LyricsPreset.bollywoodRoyal(),
);

// 2. Apple Music Style (Fluid Karaoke Wipe + Frosted Blur)
LyricsView(
  controller: controller,
  theme: LyricsPreset.appleMusic(
    activeScale: 1.12,
    blurInactive: true,
  ),
);

// 3. Spotify Style (High Contrast Center Snap)
LyricsView(
  controller: controller,
  theme: LyricsPreset.spotify(),
);

// 4. Cyberpunk Synthwave HUD
LyricsView(
  controller: controller,
  theme: LyricsPreset.cyberpunk(),
);

// 5. Musixmatch Stage Neon
LyricsView(
  controller: controller,
  theme: LyricsPreset.musixmatch(),
);

// 6. Minimalist Hi-Fi Vinyl (Editorial Serif)
LyricsView(
  controller: controller,
  theme: LyricsPreset.minimalistVinyl(),
);
```

---

## 📱 Compact Mini Player Bar

For persistent bottom sheets, car displays, or notification cards:

```dart
MiniLyricsBar(
  controller: controller,
  showTranslation: true,
  onTap: () {
    // Open full-screen lyrics modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => LyricsView(controller: controller),
    );
  },
)
```

---

## ⚙️ API Reference

### `LyricsConfig`

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `autoScroll` | `bool` | `true` | Enables automatic scrolling to keep the active line in view. |
| `activeLineAnchor` | `double` | `0.42` | Viewport alignment anchor (`0.0` top, `0.5` center, `1.0` bottom). |
| `scrollDuration` | `Duration` | `550ms` | Transition duration when animating to the next line. |
| `scrollCurve` | `Curve` | `Curves.easeOutCubic` | Easing curve for smooth scroll transitions. |
| `idleTimeoutBeforeResume` | `Duration?` | `3.5s` | Inactivity timer before manually dragged lyrics snap back. |
| `latencyOffset` | `Duration` | `Duration.zero` | Global calibration offset added to audio timestamps. |
| `instrumentalBreakThreshold`| `Duration` | `4s` | Minimum verse gap before triggering visualizer countdown dots. |
| `enableHaptics` | `bool` | `false` | Triggers subtle haptic feedback clicks on line changes. |

### `LyricsController`

| Method / Getter | Returns | Description |
| :--- | :--- | :--- |
| `setProgress(Duration pos)` | `void` | Sets the current audio position (notifies active line/syllable). |
| `seek(Duration pos)` | `void` | Triggers seek callback and updates internal position. |
| `resumeAutoScroll()` | `void` | Snaps immediately back to the active line. |
| `setDocument(doc)` | `void` | Swaps the lyrics document upon track change. |
| `setLatencyOffset(offset)` | `void` | Updates calibration offset dynamically. |
| `currentLine` | `LyricLine?` | Currently active line object. |
| `currentSyllable` | `LyricSyllable?` | Currently active syllable object. |
| `isInstrumentalBreak` | `bool` | True when in a musical gap exceeding threshold. |

---

## 🔗 Related Packages by Author

* **[waveform_pro](https://pub.dev/packages/waveform_pro)** — Production-grade GPU-accelerated audio waveform timeline and visualizer.
* **[ambient_backdrop_glow](https://pub.dev/packages/ambient_backdrop_glow)** — Dynamic ambient backdrop glow and fluid animated mesh gradients from image artwork with OKLab color blending.
* **[flutter_smooth_marquee](https://pub.dev/packages/flutter_smooth_marquee)** — Performance-first marquee and auto-scrolling ticker with zero CPU waste on static text.
* **[android_island_bar](https://pub.dev/packages/android_island_bar)** — Universal cross-platform island overlay with hardware cutout snapping.
* **[flutter_sonner](https://pub.dev/packages/flutter_sonner)** — Opinionated stacked action toast & notification HUD inspired by Sonner.
* **[ai_voice_orb](https://pub.dev/packages/ai_voice_orb)** — Fluid neural voice orb for Conversational AI & voice agents.
* **[tactile_fluid_slider](https://pub.dev/packages/tactile_fluid_slider)** — Physics-driven tactile fluid slider with spring morphing.

---

## 💖 Support the Project

If you find this package useful in your music players, karaoke apps, or production Flutter projects, consider supporting its active maintenance and future development:

<p align="left">
  <a href="https://buymeacoffee.com/govindtanko"><img src="https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me A Coffee" /></a>
  <a href="https://github.com/sponsors/govindtank"><img src="https://img.shields.io/badge/GitHub%20Sponsors-EA4AAA?style=for-the-badge&logo=github&logoColor=white" alt="GitHub Sponsors" /></a>
  <a href="https://www.patreon.com/govindtank\"><img src="https://img.shields.io/badge/Patreon-F96854?style=for-the-badge&logo=patreon&logoColor=white" alt="Patreon" /></a>
</p>

---

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

*Maintained with ❤️ by [Govind Tank](https://github.com/govindtank).*
