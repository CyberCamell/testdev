import 'package:flutter/material.dart';
import '../Services/track_service.dart';
import '../models/language.dart';
import '../utils/responsive_helper.dart';
import '../Widgets/base_screen.dart';
import '../Widgets/search_bar_widget.dart';
import 'package:flutter/foundation.dart';
import 'favorite_languages_page.dart';
import 'language_detail_page.dart';

class LanguageListPage extends StatefulWidget {
  final int trackId;

  const LanguageListPage({
    super.key, 
    required this.trackId,
  });

  @override
  State<LanguageListPage> createState() => _LanguageListPageState();
}

class _LanguageListPageState extends State<LanguageListPage> {
  List<Language> _languages = [];
  List<Language> _filteredLanguages = [];
  Set<int> _favoriteLanguageIds = {};
  bool _isLoading = true;
  String? _error;
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

    if (kDebugMode) {
      print("Loading languages for track ${widget.trackId}");
    }

    try {
      final languages = await TrackService.getTrackLanguages(widget.trackId);
      final favorites = await TrackService.getFavoriteLanguages();

      if (kDebugMode) {
        print("Received ${languages.length} languages and ${favorites.length} favorites");
      }

      if (mounted) {
        setState(() {
          _languages = languages;
          _filteredLanguages = languages;
          _favoriteLanguageIds = favorites.map((e) => e.id).toSet();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in _loadData: $e");
      }
      if (mounted) {
        setState(() {
          _error = 'Failed to load languages. Please check your connection.';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLanguages = _languages;
      } else {
        _filteredLanguages = _languages.where((language) {
          return language.name.toLowerCase().contains(query.toLowerCase()) ||
                 language.code.toLowerCase().contains(query.toLowerCase()) ||
                 (language.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _filteredLanguages = _languages;
    });
  }

  Future<void> _toggleFavorite(Language language) async {
    final isCurrentlyFavorite = _favoriteLanguageIds.contains(language.id);

    // Optimistically update UI
    if (mounted) {
      setState(() {
        if (isCurrentlyFavorite) {
          _favoriteLanguageIds.remove(language.id);
        } else {
          _favoriteLanguageIds.add(language.id);
        }
      });
    }

    // Call the service
    bool success;
    if (isCurrentlyFavorite) {
      success = await TrackService.removeFavoriteLanguage(language.id);
    } else {
      success = await TrackService.addFavoriteLanguage(language.id);
    }

    // If the API call failed, revert the UI change and show message
    if (!success && mounted) {
      setState(() {
        if (isCurrentlyFavorite) {
          _favoriteLanguageIds.add(language.id); // Add back if remove failed
        } else {
          _favoriteLanguageIds.remove(language.id); // Remove if add failed
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update favorite status. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCurrentlyFavorite ? 'Removed from favorites' : 'Added to favorites',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _selectLanguage(Language language) {
    // TODO: Implement language selection and track start
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected ${language.name} for track ${widget.trackId}'),
      ),
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
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Select Language',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, small: 24, medium: 28, large: 32),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.star, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FavoriteLanguagesPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SearchBarWidget(
                    controller: _searchController,
                    hintText: 'Search languages...',
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
                            : _languages.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No languages available.',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _filteredLanguages.length,
                                    itemBuilder: (context, index) {
                                      final language = _filteredLanguages[index];
                                      final isFavorite = _favoriteLanguageIds.contains(language.id);
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: InkWell(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => LanguageDetailPage(languageId: language.id),
                                            ),
                                          ),
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
                                                      child: language.flagUrl != null
                                                          ? ClipRRect(
                                                              borderRadius: BorderRadius.circular(12),
                                                              child: Image.network(
                                                                language.flagUrl!,
                                                                width: 48,
                                                                height: 48,
                                                                fit: BoxFit.cover,
                                                                errorBuilder: (context, error, stackTrace) {
                                                                  return const Icon(
                                                                    Icons.language,
                                                                    color: Color(0xFF4B8EF6),
                                                                    size: 24,
                                                                  );
                                                                },
                                                              ),
                                                            )
                                                          : const Icon(
                                                              Icons.language,
                                                              color: Color(0xFF4B8EF6),
                                                              size: 24,
                                                            ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            language.name,
                                                            style: const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            language.code.toUpperCase(),
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.grey[600],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        isFavorite ? Icons.star : Icons.star_border,
                                                        color: isFavorite ? const Color(0xFF4B8EF6) : Colors.grey,
                                                      ),
                                                      onPressed: () => _toggleFavorite(language),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () => Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => LanguageDetailPage(languageId: language.id),
                                                        ),
                                                      ),
                                                      style: TextButton.styleFrom(
                                                        foregroundColor: const Color(0xFF4B8EF6),
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                      ),
                                                      child: const Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Text('View Details'),
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