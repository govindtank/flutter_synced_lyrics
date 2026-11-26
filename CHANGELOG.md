## 1.0.0

* Initial stable release of `flutter_synced_lyrics` — 120 FPS synchronized lyrics & karaoke engine for Flutter.
* Syllable-by-syllable smooth gradient wiping with sub-frame time interpolation.
* Multi-format parsing:
  - Standard LRC (`[mm:ss.xx]`) with metadata tags and repeated timestamps.
  - Enhanced Syllable LRC (`<mm:ss.xx> word <mm:ss.xx>`) for word-level karaoke synchronization.
  - Full W3C & Apple Music TTML (Timed Text Markup Language) XML parser with `<p>` and nested `<span>` elements.
  - Structured JSON format parser.
  - Plain text fallback with synthetic line pacing.
* Multilingual secondary tracks:
  - Translation subtitles.
  - Phonetic / Romanization readings (Romaji, Pinyin, Furigana).
* Visual Presets:
  - Apple Music (Fluid Syllable Karaoke, active scale 1.10x, frosted inactive blur).
  - Spotify (Active Center Snap, high contrast bold, dimmed inactive lines).
  - Musixmatch (High-energy neon yellow/green fill, word bounce & glow).
  - Cyberpunk HUD (Monospace typography, cyan neon bloom, magenta accents).
  - Minimalist Hi-Fi Vinyl (Refined editorial serif typography).
* Intelligent Auto-Scrolling:
  - Viewport alignment anchor (`activeLineAnchor`).
  - Automatic manual scroll pause when user browses upcoming verses.
  - Floating "Return to current line" snap-back chip with idle timeout resume.
* Musical Break Handling:
  - Instrumental break detection for pauses > 4s.
  - Animated visualizer dots and remaining seconds countdown.
* Companion Widgets:
  - `MiniLyricsBar` for bottom-sheet mini-players and car displays.
  - `AmbientLyricsBackdrop` for reactive dynamic album art aura and fluid mesh gradients.
* Zero external runtime dependencies; 100% pure Flutter and Dart.
