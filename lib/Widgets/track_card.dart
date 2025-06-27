import 'package:flutter/material.dart';
import '../models/track.dart';

class TrackCard extends StatelessWidget {
  final Track track;
  final bool isBookmarked;
  final Function(int trackId) onBookmarkToggle;
  final VoidCallback onExplore;

  const TrackCard({
    super.key,
    required this.track,
    required this.isBookmarked,
    required this.onBookmarkToggle,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider trackImage;
    if (track.imageUrl.startsWith('http')) {
      trackImage = NetworkImage(track.imageUrl);
    } else {
      trackImage = AssetImage(
        track.imageUrl.isEmpty
            ? 'Assets/Images/Flutter_Logo.png'
            : track.imageUrl,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image(
                  image: trackImage,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? Colors.blueAccent : Colors.white,
                  ),
                  onPressed: () => onBookmarkToggle(track.id),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  track.description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onExplore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 36),
                  ),
                  child: const Text("Explore"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
