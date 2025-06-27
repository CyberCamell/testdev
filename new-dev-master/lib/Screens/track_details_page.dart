import 'package:flutter/material.dart';
import '../models/track.dart';
import '../Services/track_service.dart';
import '../utils/responsive_helper.dart';
import '../Screens/Settings_Screen.dart';
import '../Widgets/base_screen.dart';
import '../Screens/language_list_page.dart';

class TrackDetailsPage extends StatefulWidget {
  final int trackId;

  const TrackDetailsPage({super.key, required this.trackId});

  @override
  State<TrackDetailsPage> createState() => _TrackDetailsPageState();
}

class _TrackDetailsPageState extends State<TrackDetailsPage> {
  Track? _track;
  bool _isLoading = true;
  String? _error;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchTrack();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final favorites = await TrackService.getFavoriteTracks();
      if (mounted) {
        setState(() {
          _isFavorite = favorites.any((track) => track.id == widget.trackId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to check favorite status')),
        );
      }
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      bool success;
      if (_isFavorite) {
        success = await TrackService.removeFavoriteTrack(widget.trackId);
      } else {
        success = await TrackService.addFavoriteTrack(widget.trackId);
      }

      if (success && mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update favorite status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchTrack() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final track = await TrackService.getTrackDetail(widget.trackId);
      setState(() {
        _track = track;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load track details.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchTrack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4DA6FF),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_track == null) {
      return const Scaffold(
        body: Center(child: Text('Track not found.', style: TextStyle(color: Colors.white))),
      );
    }

    return BaseScreen(
      extendBodyBehindAppBar: true,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0087AF), Color(0xFF48BEF6)],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Settings()),
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _track!.imageUrl.isNotEmpty
                      ? Image.network(
                          _track!.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    bottom: MediaQuery.of(context).padding.bottom + 80,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _track!.name,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, small: 24, medium: 28, large: 32),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            _track!.rating?.toStringAsFixed(1) ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.visibility, color: Colors.white70, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${_track!.views ?? 0} views',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _track!.description,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_track!.isAvailable) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LanguageListPage(
                                    trackId: widget.trackId,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0A2540),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Start Track',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
