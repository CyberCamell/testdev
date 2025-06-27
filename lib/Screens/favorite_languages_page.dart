import 'package:flutter/material.dart';
import '../Services/track_service.dart';
import '../models/language.dart';
import '../utils/responsive_helper.dart';
import '../Widgets/base_screen.dart';
import '../Widgets/search_bar_widget.dart';
import 'package:flutter/foundation.dart';
import 'language_detail_page.dart';

class FavoriteLanguagesPage extends StatefulWidget {
  const FavoriteLanguagesPage({super.key});

  @override
  State<FavoriteLanguagesPage> createState() => _FavoriteLanguagesPageState();
}

class _FavoriteLanguagesPageState extends State<FavoriteLanguagesPage> {
  List<Language> _favoriteLanguages = [];
  List<Language> _filteredLanguages = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final favorites = await TrackService.getFavoriteLanguages();
      
      if (kDebugMode) {
        print("Loaded ${favorites.length} favorite languages");
      }

      if (mounted) {
        setState(() {
          _favoriteLanguages = favorites;
          _filteredLanguages = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading favorite languages: $e");
      }
      if (mounted) {
        setState(() {
          _error = 'Failed to load favorite languages. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLanguages = _favoriteLanguages;
      } else {
        _filteredLanguages = _favoriteLanguages.where((language) {
          return language.name.toLowerCase().contains(query.toLowerCase()) ||
                 language.code.toLowerCase().contains(query.toLowerCase()) ||
                 (language.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _filteredLanguages = _favoriteLanguages;
    });
  }

  Future<void> _removeFavorite(Language language) async {
    // Optimistically update UI
    setState(() {
      _favoriteLanguages.removeWhere((l) => l.id == language.id);
    });

    // Call the service
    final success = await TrackService.removeFavoriteLanguage(language.id);

    // If the API call failed, revert the UI change and show message
    if (!success && mounted) {
      setState(() {
        _favoriteLanguages.add(language);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to remove from favorites. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from favorites'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
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
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Favorite Languages',
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
                    hintText: 'Search favorite languages...',
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
                                      onPressed: _loadFavorites,
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
                            : _favoriteLanguages.isEmpty
                                ? Center(
                                    child: Text(
                                      'No favorite languages yet.\nUse the star icon to add languages to favorites.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.getFontSize(context, small: 16, medium: 18, large: 20),
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _filteredLanguages.length,
                                    itemBuilder: (context, index) {
                                      final language = _filteredLanguages[index];
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
                                                      icon: const Icon(
                                                        Icons.star,
                                                        color: Color(0xFF4B8EF6),
                                                      ),
                                                      onPressed: () => _removeFavorite(language),
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