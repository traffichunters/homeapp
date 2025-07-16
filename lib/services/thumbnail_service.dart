import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class ThumbnailService {
  static const int thumbnailSize = 150;
  
  /// Generate thumbnail for a document based on its file type
  static Future<Widget> generateThumbnail(String filePath, String fileType) async {
    try {
      // For images, try to load the actual image
      if (_isImageFile(fileType)) {
        final file = File(filePath);
        if (await file.exists()) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              file,
              width: thumbnailSize.toDouble(),
              height: thumbnailSize.toDouble(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildFileTypeIcon(fileType);
              },
            ),
          );
        }
      }
      
      // For other file types, return an icon-based thumbnail
      return _buildFileTypeIcon(fileType);
    } catch (e) {
      // If anything goes wrong, return a default icon
      return _buildFileTypeIcon(fileType);
    }
  }
  
  /// Generate a smaller thumbnail for list views
  static Widget generateListThumbnail(String filePath, String fileType) {
    const double listThumbnailSize = 48;
    
    if (_isImageFile(fileType)) {
      final file = File(filePath);
      return FutureBuilder<bool>(
        future: file.exists(),
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(
                file,
                width: listThumbnailSize,
                height: listThumbnailSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFileTypeIcon(fileType, size: listThumbnailSize);
                },
              ),
            );
          } else {
            return _buildFileTypeIcon(fileType, size: listThumbnailSize);
          }
        },
      );
    }
    
    return _buildFileTypeIcon(fileType, size: listThumbnailSize);
  }
  
  /// Build an icon-based thumbnail for non-image files
  static Widget _buildFileTypeIcon(String fileType, {double size = 150}) {
    IconData icon;
    Color backgroundColor;
    Color iconColor;
    
    switch (fileType.toLowerCase()) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        backgroundColor = Colors.red.shade50;
        iconColor = Colors.red.shade700;
        break;
      case 'doc':
      case 'docx':
        icon = Icons.description;
        backgroundColor = Colors.blue.shade50;
        iconColor = Colors.blue.shade700;
        break;
      case 'xls':
      case 'xlsx':
        icon = Icons.table_chart;
        backgroundColor = Colors.green.shade50;
        iconColor = Colors.green.shade700;
        break;
      case 'ppt':
      case 'pptx':
        icon = Icons.slideshow;
        backgroundColor = Colors.orange.shade50;
        iconColor = Colors.orange.shade700;
        break;
      case 'txt':
        icon = Icons.text_snippet;
        backgroundColor = Colors.grey.shade50;
        iconColor = Colors.grey.shade700;
        break;
      case 'zip':
      case 'rar':
      case '7z':
        icon = Icons.archive;
        backgroundColor = Colors.purple.shade50;
        iconColor = Colors.purple.shade700;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        icon = Icons.image;
        backgroundColor = Colors.teal.shade50;
        iconColor = Colors.teal.shade700;
        break;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
        icon = Icons.video_file;
        backgroundColor = Colors.indigo.shade50;
        iconColor = Colors.indigo.shade700;
        break;
      case 'mp3':
      case 'wav':
      case 'flac':
        icon = Icons.audio_file;
        backgroundColor = Colors.pink.shade50;
        iconColor = Colors.pink.shade700;
        break;
      default:
        icon = Icons.attach_file;
        backgroundColor = Colors.grey.shade100;
        iconColor = Colors.grey.shade600;
    }
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: size * 0.4,
          ),
          const SizedBox(height: 4),
          Text(
            fileType.toUpperCase(),
            style: TextStyle(
              color: iconColor,
              fontSize: size * 0.08,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Check if a file type is an image
  static bool _isImageFile(String fileType) {
    const imageExtensions = [
      'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'
    ];
    return imageExtensions.contains(fileType.toLowerCase());
  }
  
  /// Get file extension from file path
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase().replaceFirst('.', '');
  }
  
  /// Generate a placeholder thumbnail for loading states
  static Widget buildLoadingThumbnail({double size = 48}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.4,
          height: size * 0.4,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}