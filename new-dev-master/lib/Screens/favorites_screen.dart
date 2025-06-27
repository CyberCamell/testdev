import 'package:flutter/material.dart';
import '../Services/track_service.dart'; // Import TrackService and Track model
import 'package:flutter/foundation.dart';
import '../models/track.dart'; // For kDebugMode
import '../utils/responsive_helper.dart';
import '../Widgets/chat_bot_button.dart';
import '../Widgets/search_bar_widget.dart';
import 'language_list_page.dart';
// Import the reusable TrackCard or create a specific one
// For now, let's create a specific card for favorites

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Track> _favoriteTracks = [];
  List<Track> _filteredTracks = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFavoriteTracks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavoriteTracks() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tracks = await TrackService.getFavoriteTracks();
      if (mounted) {
        setState(() {
          _favoriteTracks = tracks;
          _filteredTracks = tracks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading favorite tracks: $e");
      }
      if (mounted) {
        setState(() {
          _error = "Failed to load saved tracks. Please try again.";
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTracks = _favoriteTracks;
      } else {
        _filteredTracks = _favoriteTracks.where((track) {
          return track.name.toLowerCase().contains(query.toLowerCase()) ||
                 track.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _filteredTracks = _favoriteTracks;
    });
  }

  // Method to remove a favorite and refresh the list
  Future<void> _removeFavorite(int trackId) async {
    final success = await TrackService.removeFavoriteTrack(trackId);
    if (success) {
      // Refresh the list after successful removal
      _loadFavoriteTracks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from saved tracks.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove track.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Saved Tracks',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(
                              context,
                              small: 24,
                              medium: 28,
                              large: 32,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SearchBarWidget(
                    controller: _searchController,
                    hintText: 'Search saved tracks...',
                    onChanged: _onSearchChanged,
                    onClear: _clearSearch,
                  ),
                  Expanded(
                    child:
                        _isLoading
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
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
                                    onPressed: _loadFavoriteTracks,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF4B8EF6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                            : _favoriteTracks.isEmpty
                            ? Center(
                              child: Text(
                                'No saved tracks yet.\nUse the bookmark icon to save tracks.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getFontSize(
                                    context,
                                    small: 16,
                                    medium: 18,
                                    large: 20,
                                  ),
                                  color: Colors.white,
                                ),
                              ),
                            )
                            : RefreshIndicator(
                              onRefresh: _loadFavoriteTracks,
                              color: Colors.white,
                              backgroundColor: const Color(0xFF4B8EF6),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredTracks.length,
                                itemBuilder: (context, index) {
                                  final track = _filteredTracks[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: InkWell(
                                      onTap:
                                          () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => LanguageListPage(
                                                    trackId: track.id,
                                                  ),
                                            ),
                                          ),
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 48,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF4B8EF6,
                                                    ).withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.school,
                                                    color: Color(0xFF4B8EF6),
                                                    size: 24,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        track.name,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        track.description,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                        maxLines: 2,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.bookmark,
                                                    color: Color(0xFF4B8EF6),
                                                  ),
                                                  onPressed:
                                                      () => _removeFavorite(
                                                        track.id,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (context) =>
                                                                  LanguageListPage(
                                                                    trackId:
                                                                        track
                                                                            .id,
                                                                  ),
                                                        ),
                                                      ),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        const Color(0xFF4B8EF6),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 8,
                                                        ),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text('Explore'),
                                                      SizedBox(width: 4),
                                                      Icon(
                                                        Icons.arrow_forward,
                                                        size: 16,
                                                      ),
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
