import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../Services/http_client.dart';

class UserAvatarWidget extends StatelessWidget {
  final String? profilePictureUrl;
  final double radius;
  final Color? backgroundColor;
  final Widget? fallbackWidget;
  final VoidCallback? onTap;

  const UserAvatarWidget({
    super.key,
    this.profilePictureUrl,
    this.radius = 50,
    this.backgroundColor,
    this.fallbackWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (profilePictureUrl == null || profilePictureUrl!.isEmpty) {
      return _buildFallbackAvatar();
    }

    return FutureBuilder<Uint8List?>(
      future: _loadImageFromUrl(profilePictureUrl!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingAvatar();
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return _buildImageAvatar(snapshot.data!);
        }
        
        return _buildFallbackAvatar();
      },
    );
  }

  Widget _buildImageAvatar(Uint8List imageBytes) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(imageBytes),
        backgroundColor: backgroundColor ?? Colors.grey[300],
      ),
    );
  }

  Widget _buildLoadingAvatar() {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[300],
        child: SizedBox(
          width: radius * 0.6,
          height: radius * 0.6,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return GestureDetector(
      onTap: onTap,
      child: fallbackWidget ?? CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[300],
        child: Icon(
          Icons.person,
          size: radius * 0.8,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Future<Uint8List?> _loadImageFromUrl(String imageUrl) async {
    try {
      // Ensure we have a full URL
      String fullUrl = imageUrl;
      if (!fullUrl.startsWith('http')) {
        fullUrl = 'https://api.devguide.help$fullUrl';
      }
      
      final httpClient = CustomHttpClient.getClient();
      final response = await httpClient.get(Uri.parse(fullUrl));
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      print('Error loading profile picture: $e');
      return null;
    }
  }
} 