import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:manga_bal/src/model/manga_detail.dart';

class ChapterPage extends StatefulWidget {
  const ChapterPage({
    super.key,
    required this.allChapters,
    required this.initialIndex,
  });

  final List<ChapterSummary> allChapters;
  final int initialIndex;

  @override
  State<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  late int _currentIndex;
  bool _showUI = true;
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  final double _minZoom = 0.5;
  final double _maxZoom = 3.0;
  final TransformationController _transformationController = TransformationController();

  InterstitialAd? _interstitialAd;
  final String _interstitialAdUnitId = 'ca-app-pub-8675873135912570/5605941001';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _enterImmersiveMode();
    _createInterstitialAd();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enterImmersiveMode();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent > 0) {
        setState(() {
          _scrollProgress =
              _scrollController.position.pixels /
              _scrollController.position.maxScrollExtent;
        });
      }
    });
  }

  void _enterImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _exitImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showInterstitialAdAndNavigate(int newIndex) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          _navigateToChapter(newIndex);
          ad.dispose();
          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          _navigateToChapter(newIndex);
          ad.dispose();
          _createInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      _navigateToChapter(newIndex);
    }
  }


  @override
  void dispose() {
    _exitImmersiveMode();
    _scrollController.dispose();
    _transformationController.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _navigateToChapter(int newIndex) {
    if (newIndex >= 0 && newIndex < widget.allChapters.length) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => ChapterPage(
            allChapters: widget.allChapters,
            initialIndex: newIndex,
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _enterImmersiveMode();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentChapter = widget.allChapters[_currentIndex];
    final bool hasPrevious = _currentIndex > 0;
    final bool hasNext = _currentIndex < widget.allChapters.length - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showUI = !_showUI;
          });
        },
        onDoubleTap: () {
          setState(() {
            _transformationController.value = Matrix4.identity();
          });
        },
        child: Stack(
          children: [
            InteractiveViewer(
              transformationController: _transformationController,
              minScale: _minZoom,
              maxScale: _maxZoom,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: List.generate(currentChapter.pages.length, (pageIndex) {
                    return Image.network(
                      currentChapter.pages[pageIndex],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          height: 400,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'Gagal memuat gambar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ),

            AnimatedOpacity(
              opacity: _showUI ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: _buildUIOverlay(currentChapter, hasPrevious, hasNext),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUIOverlay(
    ChapterSummary currentChapter,
    bool hasPrevious,
    bool hasNext,
  ) {
    return IgnorePointer(
      ignoring: !_showUI,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.transparent],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    ChapterDropdown(
                      allChapters: widget.allChapters,
                      currentIndex: _currentIndex,
                      onChapterSelected: _navigateToChapter,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.bookmark_border,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black, Colors.transparent],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _scrollProgress,
                          backgroundColor: Colors.grey.shade700,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${(_scrollProgress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: !hasPrevious
                            ? null
                            : () => _showInterstitialAdAndNavigate(
                                _currentIndex - 1,
                              ),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Prev'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade800,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: !hasNext
                            ? null
                            : () => _showInterstitialAdAndNavigate(
                                _currentIndex + 1,
                              ),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChapterDropdown extends StatelessWidget {
  const ChapterDropdown({
    super.key,
    required this.allChapters,
    required this.currentIndex,
    required this.onChapterSelected,
  });

  final List<ChapterSummary> allChapters;
  final int currentIndex;
  final Function(int) onChapterSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: onChapterSelected,
      color: const Color(0xFF252836),
      itemBuilder: (BuildContext context) {
        return List.generate(allChapters.length, (index) {
          return PopupMenuItem<int>(
            value: index,
            child: Text(
              allChapters[index].title.replaceAll('\n', '').trim(),
              style: const TextStyle(color: Colors.white),
            ),
          );
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            allChapters[currentIndex].title.replaceAll('\n', '').trim(),
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.orange),
        ],
      ),
    );
  }
}
