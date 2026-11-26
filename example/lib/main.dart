import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_synced_lyrics/flutter_synced_lyrics.dart';
import 'package:flutter_smooth_marquee/flutter_smooth_marquee.dart';
import 'package:ambient_backdrop_glow/ambient_backdrop_glow.dart';
import 'package:waveform_pro/waveform_pro.dart';

void main() {
  runApp(const SyncedLyricsShowcaseApp());
}

class SyncedLyricsShowcaseApp extends StatelessWidget {
  const SyncedLyricsShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_synced_lyrics Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0E15),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LyricsStudioScreen(),
    );
  }
}

enum DemoTrack {
  popSyllable,
  rockInstrumental,
  multilingualAnime,
  cyberpunkTtml,
  custom,
}

enum ThemeStyle {
  appleMusic,
  spotify,
  musixmatch,
  cyberpunk,
  minimalist,
}

class LyricsStudioScreen extends StatefulWidget {
  const LyricsStudioScreen({super.key});

  @override
  State<LyricsStudioScreen> createState() => _LyricsStudioScreenState();
}

class _LyricsStudioScreenState extends State<LyricsStudioScreen>
    with SingleTickerProviderStateMixin {
  late LyricsController _lyricsController;
  DemoTrack _selectedTrack = DemoTrack.popSyllable;
  ThemeStyle _selectedTheme = ThemeStyle.appleMusic;

  bool _isPlaying = true;
  double _playbackSpeed = 1.0;
  Duration _currentPosition = Duration.zero;
  Duration _trackDuration = const Duration(seconds: 45);
  Timer? _playbackTimer;

  bool _showTranslation = true;
  bool _showRomanization = true;
  bool _showMiniBar = true;
  double _fontSize = 25.0;
  double _activeScale = 1.10;
  bool _blurInactive = true;

  final TextEditingController _customInputController = TextEditingController();

  static const String _blindingLightsLrc = '''
[ti:Blinding Lights]
[ar:The Weeknd]
[al:After Hours]
[length:00:45.00]
[00:01.00]<00:01.00>Yeah <00:02.00>
[00:03.50]<00:03.50>I've <00:04.10>been <00:04.80>tryin' <00:05.40>to <00:05.90>call <00:06.80>
[00:07.50]<00:07.50>I've <00:08.10>been <00:08.70>on <00:09.20>my <00:09.80>own <00:10.50>for <00:11.10>long <00:11.80>enough <00:12.60>
[00:13.20]<00:13.20>Maybe <00:14.00>you <00:14.60>can <00:15.20>show <00:15.90>me <00:16.60>how <00:17.30>to <00:18.00>love <00:19.00>
[00:20.00]<00:20.00>I'm <00:20.60>going <00:21.40>through <00:22.20>withdrawals <00:23.50>
[00:24.20]<00:24.20>You <00:24.80>don't <00:25.40>even <00:26.20>have <00:26.90>to <00:27.50>do <00:28.10>too <00:28.80>much <00:29.80>
[00:30.80]<00:30.80>You <00:31.40>can <00:32.00>turn <00:32.60>me <00:33.20>on <00:33.90>with <00:34.50>just <00:35.20>a <00:35.90>touch <00:37.00>
[00:38.00]<00:38.00>I <00:38.60>said, <00:39.30>ooh, <00:40.20>I'm <00:41.00>blinded <00:42.00>by <00:42.80>the <00:43.60>lights <00:45.00>
''';

  static const String _bohemianRhapsodyLrc = '''
[ti:Bohemian Rhapsody]
[ar:Queen]
[al:A Night at the Opera]
[length:00:50.00]
[00:01.00]Is this the real life?
[00:04.50]Is this just fantasy?
[00:08.00]Caught in a landslide, no escape from reality
[00:14.00]Open your eyes, look up to the skies and see
[00:20.50]I'm just a poor boy, I need no sympathy
[00:26.00]Because I'm easy come, easy go, little high, little low
[00:32.00]Any way the wind blows doesn't really matter to me
[00:45.00]Mama, just killed a man
''';

  static const String _animeMultilingualLrc = '''
[ti:Zenzenzense (前前前世)]
[ar:RADWIMPS]
[al:Your Name (君の名は。)]
[length:00:40.00]
[00:02.00]やっと眼を覚ましたかい
[00:02.00]Have you finally woken up?
[00:07.00]それなのになぜ眼も合わせやしないんだい？
[00:07.00]Then why won't you even meet my eyes?
[00:13.00]「遅いよ」と怒る君
[00:13.00]"You're late," you say getting angry
[00:18.00]これでもやれるだけ飛ばしてきたんだよ
[00:18.00]Even so, I sped here as fast as I could
[00:24.00]前前前世から僕は君を探しはじめたよ
[00:24.00]I started searching for you from our past past past life
[00:31.00]そのぶきっちょな笑顔をめがけてやってきたんだよ
[00:31.00]Aiming for that awkward, clumsy smile of yours
''';

  static const String _cyberpunkTtml = '''
<?xml version="1.0" encoding="utf-8"?>
<tt xmlns="http://www.w3.org/ns/ttml" xmlns:ttm="http://www.w3.org/ns/ttml#metadata">
  <head>
    <metadata>
      <ttm:title>Neon Skyline 2077</ttm:title>
      <ttm:artist>CYBERPUNK / SYNTH</ttm:artist>
    </metadata>
  </head>
  <body>
    <div>
      <p begin="00:00:02.000" end="00:00:06.500">
        <span begin="00:00:02.000" end="00:00:03.200">SYSTEM </span>
        <span begin="00:00:03.200" end="00:00:04.500">OVERRIDE </span>
        <span begin="00:00:04.500" end="00:00:05.500">IN </span>
        <span begin="00:00:05.500" end="00:00:06.500">PROGRESS</span>
      </p>
      <p begin="00:00:08.000" end="00:00:13.000">
        <span begin="00:00:08.000" end="00:00:09.500">NEON </span>
        <span begin="00:00:09.500" end="00:00:10.800">LIGHTS </span>
        <span begin="00:00:10.800" end="00:00:11.800">BURN </span>
        <span begin="00:00:11.800" end="00:00:13.000">COLD</span>
      </p>
      <p begin="00:00:15.000" end="00:00:20.000">
        <span begin="00:00:15.000" end="00:00:16.200">SILICONE </span>
        <span begin="00:00:16.200" end="00:00:17.500">DREAMS </span>
        <span begin="00:00:17.500" end="00:00:18.800">NEVER </span>
        <span begin="00:00:18.800" end="00:00:20.000">DIE</span>
      </p>
      <p begin="00:00:22.000" end="00:00:28.000">
        <span begin="00:00:22.000" end="00:00:23.500">JACK </span>
        <span begin="00:00:23.500" end="00:00:24.800">INTO </span>
        <span begin="00:00:24.800" end="00:00:26.200">THE </span>
        <span begin="00:00:26.200" end="00:00:28.000">GRID</span>
      </p>
    </div>
  </body>
</tt>
''';

  @override
  void initState() {
    super.initState();
    _lyricsController = LyricsController.fromLrc(
      _blindingLightsLrc,
      config: const LyricsConfig(
        autoScroll: true,
        activeLineAnchor: 0.42,
        instrumentalBreakThreshold: Duration(seconds: 4),
        idleTimeoutBeforeResume: Duration(seconds: 3),
      ),
      onSeekRequest: (seekPos) {
        setState(() {
          _currentPosition = seekPos;
        });
      },
    );
    _startPlaybackTicker();
  }

  void _startPlaybackTicker() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_isPlaying) {
        setState(() {
          final nextMs =
              _currentPosition.inMilliseconds + (50 * _playbackSpeed).round();
          if (nextMs >= _trackDuration.inMilliseconds) {
            _currentPosition = Duration.zero;
          } else {
            _currentPosition = Duration(milliseconds: nextMs);
          }
          _lyricsController.progress = _currentPosition;
        });
      }
    });
  }

  void _loadTrack(DemoTrack track) {
    setState(() {
      _selectedTrack = track;
      _currentPosition = Duration.zero;

      switch (track) {
        case DemoTrack.popSyllable:
          _lyricsController.setDocument(LyricsParser.parse(_blindingLightsLrc));
          _trackDuration = const Duration(seconds: 45);
          break;
        case DemoTrack.rockInstrumental:
          _lyricsController
              .setDocument(LyricsParser.parse(_bohemianRhapsodyLrc));
          _trackDuration = const Duration(seconds: 50);
          break;
        case DemoTrack.multilingualAnime:
          _lyricsController
              .setDocument(LyricsParser.parse(_animeMultilingualLrc));
          _trackDuration = const Duration(seconds: 40);
          break;
        case DemoTrack.cyberpunkTtml:
          _lyricsController.setDocument(LyricsParser.parse(_cyberpunkTtml));
          _trackDuration = const Duration(seconds: 32);
          _selectedTheme = ThemeStyle.cyberpunk;
          break;
        case DemoTrack.custom:
          if (_customInputController.text.trim().isNotEmpty) {
            _lyricsController.setDocument(
              LyricsParser.parse(_customInputController.text),
            );
          }
          break;
      }
      _lyricsController.progress = Duration.zero;
    });
  }

  LyricsTheme _resolveTheme() {
    switch (_selectedTheme) {
      case ThemeStyle.appleMusic:
        return LyricsPreset.appleMusic(
          baseFontSize: _fontSize,
          activeScale: _activeScale,
          blurInactive: _blurInactive,
        );
      case ThemeStyle.spotify:
        return LyricsPreset.spotify(
          baseFontSize: _fontSize,
        );
      case ThemeStyle.musixmatch:
        return LyricsPreset.musixmatch(
          baseFontSize: _fontSize,
        );
      case ThemeStyle.cyberpunk:
        return LyricsPreset.cyberpunk(
          baseFontSize: _fontSize,
        );
      case ThemeStyle.minimalist:
        return LyricsPreset.minimalistVinyl(
          baseFontSize: _fontSize,
        );
    }
  }

  List<Color> _resolveAmbientColors() {
    switch (_selectedTheme) {
      case ThemeStyle.appleMusic:
        return [
          const Color(0xFF6B21A8),
          const Color(0xFF1E1B4B),
          const Color(0xFF0F172A),
        ];
      case ThemeStyle.spotify:
        return [
          const Color(0xFF065F46),
          const Color(0xFF064E3B),
          const Color(0xFF0A0A0F),
        ];
      case ThemeStyle.musixmatch:
        return [
          const Color(0xFFB45309),
          const Color(0xFF78350F),
          const Color(0xFF18181B),
        ];
      case ThemeStyle.cyberpunk:
        return [
          const Color(0xFF0891B2),
          const Color(0xFF831843),
          const Color(0xFF09090B),
        ];
      case ThemeStyle.minimalist:
        return [
          const Color(0xFF334155),
          const Color(0xFF1E293B),
          const Color(0xFF0F172A),
        ];
    }
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _lyricsController.dispose();
    _customInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _lyricsController.document.title ?? 'Blinding Lights';
    final artist = _lyricsController.document.artist ?? 'The Weeknd';
    final theme = _resolveTheme();
    final ambientColors = _resolveAmbientColors();

    return Scaffold(
      body: AmbientBackdropGlow(
        colors: ambientColors,
        mode: AmbientGlowMode.aurora,
        style: const AmbientGlowStyle(
          blurSigma: 40.0,
          intensity: 0.8,
          speed: 0.6,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with marquee ticker and controls
              _buildHeader(title, artist),

              // Main viewport
              Expanded(
                child: LyricsView(
                  controller: _lyricsController,
                  theme: theme,
                  showTranslation: _showTranslation,
                  showRomanization: _showRomanization,
                  onLineTap: (line, timestamp) {
                    setState(() {
                      _currentPosition = timestamp;
                    });
                  },
                ),
              ),

              // Mini lyrics bar if toggled
              if (_showMiniBar)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: MiniLyricsBar(
                    controller: _lyricsController,
                    showTranslation: _showTranslation,
                    theme: theme,
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: _openCustomizerModal,
                    ),
                  ),
                ),

              // Interactive Audio Player Controls & Waveform
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title, String artist) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.music_note_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Integrated flutter_smooth_marquee for song title ticker!
                SizedBox(
                  height: 22,
                  child: SmoothMarqueeText(
                    '$title — $artist',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                    velocity: 35.0,
                    spacing: 40.0,
                    fadeEdgeWidth: 16.0,
                  ),
                ),
                Text(
                  '120 FPS Synced Karaoke • ${_formatDuration(_currentPosition)} / ${_formatDuration(_trackDuration)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Track Selector',
            icon: const Icon(Icons.queue_music_rounded, color: Colors.white),
            onPressed: _openTrackSelectorModal,
          ),
          IconButton(
            tooltip: 'Style Presets',
            icon: const Icon(Icons.palette_outlined, color: Colors.white),
            onPressed: _openThemeSelectorModal,
          ),
          IconButton(
            tooltip: 'Customizer',
            icon: const Icon(Icons.tune_rounded, color: Colors.white),
            onPressed: _openCustomizerModal,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    final progressVal = (_trackDuration.inMilliseconds > 0)
        ? (_currentPosition.inMilliseconds / _trackDuration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    // Synthetic waveform data for waveform_pro visualization
    final samples = List.generate(
      48,
      (i) => (0.15 + 0.85 * ((i * 7 + 13) % 19) / 19.0),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Waveform bar using waveform_pro
          SizedBox(
            height: 28,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: WaveformTimeline(
                data: WaveformData(
                  samples: samples,
                  durationSeconds: _trackDuration.inSeconds.toDouble(),
                ),
                height: 28,
                showTimeRuler: false,
                enableZoom: false,
                style: const WaveformStyle(
                  playedWaveColor: Colors.white,
                  waveColor: Colors.white24,
                  backgroundColor: Colors.transparent,
                  barWidth: 2.5,
                  barSpacing: 2.0,
                  renderMode: WaveformRenderMode.bars,
                ),
                onTap: (seconds) {
                  final target = Duration(
                    milliseconds: (seconds * 1000).round(),
                  );
                  if (target <= _trackDuration) {
                    setState(() {
                      _currentPosition = target;
                      _lyricsController.seek(target);
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Scrub slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: progressVal,
              onChanged: (val) {
                final targetMs = (_trackDuration.inMilliseconds * val).round();
                final target = Duration(milliseconds: targetMs);
                setState(() {
                  _currentPosition = target;
                  _lyricsController.seek(target);
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.replay_5_rounded, color: Colors.white),
                    onPressed: () {
                      final pos = _currentPosition - const Duration(seconds: 5);
                      final seek = pos < Duration.zero ? Duration.zero : pos;
                      setState(() {
                        _currentPosition = seek;
                        _lyricsController.seek(seek);
                      });
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPlaying = !_isPlaying;
                          _lyricsController.setPlaying(_isPlaying);
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.forward_5_rounded,
                        color: Colors.white),
                    onPressed: () {
                      final pos = _currentPosition + const Duration(seconds: 5);
                      final seek = pos > _trackDuration ? _trackDuration : pos;
                      setState(() {
                        _currentPosition = seek;
                        _lyricsController.seek(seek);
                      });
                    },
                  ),
                ],
              ),
              PopupMenuButton<double>(
                initialValue: _playbackSpeed,
                tooltip: 'Speed',
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_playbackSpeed}x',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onSelected: (spd) {
                  setState(() {
                    _playbackSpeed = spd;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 0.5, child: Text('0.5x Slower')),
                  const PopupMenuItem(value: 1.0, child: Text('1.0x Normal')),
                  const PopupMenuItem(value: 1.5, child: Text('1.5x Faster')),
                  const PopupMenuItem(value: 2.0, child: Text('2.0x Double')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openTrackSelectorModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Song & Lyric Format',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              _buildTrackTile(
                DemoTrack.popSyllable,
                'Blinding Lights (The Weeknd)',
                'Enhanced Syllable LRC • Word-by-word karaoke wipe',
                Icons.lyrics_rounded,
              ),
              _buildTrackTile(
                DemoTrack.rockInstrumental,
                'Bohemian Rhapsody (Queen)',
                'Standard LRC • Instrumental break & guitar solo countdown',
                Icons.graphic_eq_rounded,
              ),
              _buildTrackTile(
                DemoTrack.multilingualAnime,
                'Zenzenzense (RADWIMPS)',
                'Multilingual LRC • Kanji + Romaji + English Translation',
                Icons.translate_rounded,
              ),
              _buildTrackTile(
                DemoTrack.cyberpunkTtml,
                'Neon Skyline 2077 (Synth)',
                'TTML XML Format • Timed Text Markup with spans',
                Icons.code_rounded,
              ),
              _buildTrackTile(
                DemoTrack.custom,
                'Paste Custom Lyrics',
                'Input raw LRC, TTML XML, or JSON text',
                Icons.edit_note_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrackTile(
    DemoTrack track,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedTrack == track;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF00E676) : Colors.white70,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF00E676) : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676))
          : null,
      onTap: () {
        Navigator.pop(context);
        if (track == DemoTrack.custom) {
          _openCustomInputModal();
        } else {
          _loadTrack(track);
        }
      },
    );
  }

  void _openThemeSelectorModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Visual Style Preset',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              _buildThemeTile(
                ThemeStyle.appleMusic,
                'Apple Music (Fluid Karaoke)',
                'Syllable gradient wipe, frosted inactive blur, active zoom',
              ),
              _buildThemeTile(
                ThemeStyle.spotify,
                'Spotify (Active Center Snap)',
                'High-contrast bold white text, dimmed inactive lines',
              ),
              _buildThemeTile(
                ThemeStyle.musixmatch,
                'Musixmatch (Neon Energy)',
                'High-energy neon yellow/green fill, word bounce & glow',
              ),
              _buildThemeTile(
                ThemeStyle.cyberpunk,
                'Cyberpunk HUD (Synthwave)',
                'Monospace typography, cyan neon bloom, magenta accents',
              ),
              _buildThemeTile(
                ThemeStyle.minimalist,
                'Minimalist Hi-Fi Vinyl',
                'Refined serif typography, high-fashion editorial rhythm',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeTile(
    ThemeStyle style,
    String title,
    String subtitle,
  ) {
    final isSelected = _selectedTheme == style;
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF00E676) : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676))
          : null,
      onTap: () {
        setState(() {
          _selectedTheme = style;
        });
        Navigator.pop(context);
      },
    );
  }

  void _openCustomizerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customize Typography & Dynamics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Font Size'),
                      Text('${_fontSize.round()} pt'),
                    ],
                  ),
                  Slider(
                    value: _fontSize,
                    min: 18,
                    max: 36,
                    divisions: 18,
                    onChanged: (v) {
                      setState(() => _fontSize = v);
                      setModalState(() {});
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Active Line Scale'),
                      Text('${_activeScale.toStringAsFixed(2)}x'),
                    ],
                  ),
                  Slider(
                    value: _activeScale,
                    min: 1.0,
                    max: 1.30,
                    divisions: 15,
                    onChanged: (v) {
                      setState(() => _activeScale = v);
                      setModalState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Blur Inactive Lines'),
                    value: _blurInactive,
                    onChanged: (v) {
                      setState(() => _blurInactive = v);
                      setModalState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Show Translation Subtitles'),
                    value: _showTranslation,
                    onChanged: (v) {
                      setState(() => _showTranslation = v);
                      setModalState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Show Romanization / Phonetics'),
                    value: _showRomanization,
                    onChanged: (v) {
                      setState(() => _showRomanization = v);
                      setModalState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Show MiniLyricsBar'),
                    value: _showMiniBar,
                    onChanged: (v) {
                      setState(() => _showMiniBar = v);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 6),
                  const Text(
                    'Companion Packages by Author:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.blur_on, size: 16),
                        label: const Text('ambient_backdrop_glow'),
                      ),
                      Chip(
                        avatar: const Icon(Icons.graphic_eq, size: 16),
                        label: const Text('waveform_pro'),
                      ),
                      Chip(
                        avatar: const Icon(Icons.view_carousel, size: 16),
                        label: const Text('flutter_smooth_marquee'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openCustomInputModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste Custom Lyrics (LRC, TTML, or Text)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _customInputController,
                maxLines: 8,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText:
                      '[00:01.00] Line one\n[00:05.00] Line two\nOr paste <tt> XML...',
                  filled: true,
                  fillColor: Colors.black38,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text(
                  'Load & Sync Now',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  final text = _customInputController.text.trim();
                  if (text.isNotEmpty) {
                    _loadTrack(DemoTrack.custom);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
