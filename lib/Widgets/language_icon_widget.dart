import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../Services/http_client.dart';

class LanguageIconWidget extends StatelessWidget {
  final String? iconUrl;
  final double size;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? fallbackIconColor;

  const LanguageIconWidget({
    super.key,
    this.iconUrl,
    this.size = 48,
    this.borderRadius,
    this.backgroundColor,
    this.fallbackIconColor,
  });

  @override
  Widget build(BuildContext context) {
    if (iconUrl == null || iconUrl!.isEmpty) {
      return _buildFallbackIcon();
    }

    return FutureBuilder<Uint8List?>(
      future: _loadImageFromUrl(iconUrl!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIcon();
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return _buildImageIcon(snapshot.data!);
        }
        
        return _buildFallbackIcon();
      },
    );
  }

  Widget _buildImageIcon(Uint8List imageBytes) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: Image.memory(
          imageBytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackIcon();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingIcon() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF4B8EF6).withOpacity(0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.code,
        color: fallbackIconColor ?? const Color(0xFF4B8EF6),
        size: size * 0.5,
      ),
    );
  }

  Future<Uint8List?> _loadImageFromUrl(String imageUrl) async {
    try {
      final httpClient = CustomHttpClient.getClient();
      final response = await httpClient.get(Uri.parse(imageUrl));
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      print('Error loading language icon: $e');
      return null;
    }
  }
} 