import 'package:flutter/material.dart';
import '../Services/track_service.dart';
import '../models/track.dart';
import 'favorites_screen.dart'; // Import FavoritesScreen for navigation
import '../utils/responsive_helper.dart';
import '../Widgets/chat_bot_button.dart';
import '../Widgets/base_screen.dart';
import '../Widgets/search_bar_widget.dart';

import '../Screens/language_list_page.dart';

class TracksPage extends StatefulWidget {
  const TracksPage({super.key});

  @override
  State<TracksPage> createState() => _TracksPageState();
}

class _TracksPageState extends State<TracksPage> {
  List<Track> _tracks = [];
  List<Track> _filteredTracks = [];
  Set<int> _favoriteTrackIds = {};
  bool _isLoading = true;
  String? _error;
  bool _showAvailable = true; // Default to show Available tracks
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch both tracks and current favorites simultaneously
      final results = await Future.wait([
        TrackService.getTracks(),
        TrackService.getFavoriteTracks(),
      ]);

      final tracks = results[0];
      final favorites = results[1];

      if (mounted) {
        setState(() {
          _tracks = tracks;
          _filteredTracks = tracks;
          _favoriteTrackIds = favorites.map((e) => e.id).toSet();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load tracks. Please check your connection.';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTracks = _tracks;
      } else {
        _filteredTracks = _tracks.where((track) {
          return track.name.toLowerCase().contains(query.toLowerCase()) ||
                 track.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _filteredTracks = _tracks;
    });
  }

  // Toggles bookmark status locally and calls service
  Future<void> _toggleBookmark(int trackId) async {
    final isCurrentlyFavorite = _favoriteTrackIds.contains(trackId);

    // Optimistically update UI
    if (mounted) {
      setState(() {
        if (isCurrentlyFavorite) {
          _favoriteTrackIds.remove(trackId);
        } else {
          _favoriteTrackIds.add(trackId);
        }
      });
    }

    // Call the service
    bool success;
    if (isCurrentlyFavorite) {
      success = await TrackService.removeFavoriteTrack(trackId);
    } else {
      success = await TrackService.addFavoriteTrack(trackId);
    }

    // If the API call failed, revert the UI change and show message
    if (!success && mounted) {
      setState(() {
        if (isCurrentlyFavorite) {
          _favoriteTrackIds.add(trackId); // Add back if remove failed
        } else {
          _favoriteTrackIds.remove(trackId); // Remove if add failed
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update saved status. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCurrentlyFavorite ? 'Removed from saved tracks.' : 'Track saved!',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // Navigate to track details (placeholder action)
  void _exploreTrack(Track track) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LanguageListPage(trackId: track.id),
      ),
    );
  }

  // Navigate to Favorites Screen
  void _goToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoritesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4B8EF6), Color(0xFFB3D4FF)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -50,
                left: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Text(
                          'Learning Tracks',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, small: 24, medium: 28, large: 32),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SearchBarWidget(
                    controller: _searchController,
                    hintText: 'Search tracks...',
                    onChanged: _onSearchChanged,
                    onClear: _clearSearch,
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : _error != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _error!,
                                      style: const TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _loadData,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(0xFF4B8EF6),
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredTracks.length,
                                itemBuilder: (context, index) {
                                  final track = _filteredTracks[index];
                                  final isFavorite = _favoriteTrackIds.contains(track.id);
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: InkWell(
                                      onTap: () => _exploreTrack(track),
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 48,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF4B8EF6).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Icon(
                                                    Icons.school,
                                                    color: const Color(0xFF4B8EF6),
                                                    size: 24,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        track.name,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        track.description,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey[600],
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    isFavorite ? Icons.bookmark : Icons.bookmark_border,
                                                    color: isFavorite ? const Color(0xFF4B8EF6) : Colors.grey,
                                                  ),
                                                  onPressed: () => _toggleBookmark(track.id),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  onPressed: () => _exploreTrack(track),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: const Color(0xFF4B8EF6),
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text('Explore'),
                                                      SizedBox(width: 4),
                                                      Icon(Icons.arrow_forward, size: 16),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
