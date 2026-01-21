import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_native_image_v2/flutter_native_image.dart';
import 'package:image/image.dart' as img;
import 'package:exif/exif.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  static ImageUtils instance = ImageUtils();

  /// Flips an image vertically (for selfie correction)
  Future<File> flipSelfieImage(File imagePath) async {
    try {
      final originalFile = imagePath;
      Uint8List imageBytes = await originalFile.readAsBytes();

      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      final fixedImage = img.flipVertical(originalImage);
      final fixedFile =
          await originalFile.writeAsBytes(img.encodeJpg(fixedImage));

      return fixedFile;
    } catch (e) {
      throw Exception('Error flipping image: $e');
    }
  }

  /// Fixes image rotation based on EXIF data
  Future<File> fixRotationImage(String imagePath) async {
    try {
      final originalFile = File(imagePath);
      Uint8List imageBytes = await originalFile.readAsBytes();

      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      final height = originalImage.height;
      final width = originalImage.width;

      // If image is already portrait, return as is
      if (height >= width) {
        return originalFile;
      }

      // Read EXIF data
      final exifData = await readExifFromBytes(imageBytes);

      img.Image fixedImage;

      // Only rotate if landscape
      if (height < width) {
        final orientation = exifData['Image Orientation']?.printable ?? '';

        if (orientation.contains('Horizontal')) {
          fixedImage = img.copyRotate(originalImage, angle: 90);
        } else if (orientation.contains('180')) {
          fixedImage = img.copyRotate(originalImage, angle: -90);
        } else {
          fixedImage = originalImage; // No rotation needed
        }
      } else {
        fixedImage = originalImage;
      }

      final fixedFile =
          await originalFile.writeAsBytes(img.encodeJpg(fixedImage));

      return fixedFile;
    } catch (e) {
      throw Exception('Error fixing image rotation: $e');
    }
  }

  /// Crops an image to specified dimensions
  Future<File> cropImage(
    File file,
    int originX,
    int originY,
    int width,
    int height,
  ) async {
    try {
      File croppedFile = await FlutterNativeImage.cropImage(
        file.path,
        originX,
        originY,
        width,
        height,
      );
      return croppedFile;
    } catch (e) {
      throw Exception('Error cropping image: $e');
    }
  }

  /// Compresses an image file
  Future<File> compressImage(File file, {int quality = 85}) async {
    try {
      File compressedFile = await FlutterNativeImage.compressImage(
        file.path,
        quality: quality,
      );
      return compressedFile;
    } catch (e) {
      throw Exception('Error compressing image: $e');
    }
  }

  /// Gets bytes from an asset image with specified width
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    try {
      ByteData data = await rootBundle.load(path);
      ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: width,
      );
      ui.FrameInfo fi = await codec.getNextFrame();
      final byteData =
          await fi.image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      throw Exception('Error getting bytes from asset: $e');
    }
  }

  /// Saves an image to temporary directory
  Future<String> saveTemporaryImage({
    required Uint8List imageFile,
    required String fileName,
  }) async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/$fileName';
      File image = File(tempPath);

      // Delete if already exists
      bool isExist = await image.exists();
      if (isExist) await image.delete();

      // Write new file
      await File(tempPath).writeAsBytes(imageFile);
      return tempPath;
    } catch (e) {
      throw Exception('Error saving temporary image: $e');
    }
  }

  /// Deletes a temporary image file
  Future<void> deleteTemporaryImage({required String fileName}) async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/$fileName';
      File image = File(tempPath);

      bool isExist = await image.exists();
      if (isExist) {
        await image.delete();
      }
    } catch (e) {
      // Log error but don't throw - deletion failure shouldn't break the app
      print('Warning: Failed to delete temporary image: $e');
    }
  }

  /// Gets image dimensions without loading full image
  Future<Map<String, int>> getImageDimensions(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      final imageProperties =
          await FlutterNativeImage.getImageProperties(imageFile.path);

      return {
        'width': imageProperties.width ?? 0,
        'height': imageProperties.height ?? 0,
      };
    } catch (e) {
      throw Exception('Error getting image dimensions: $e');
    }
  }

  /// Resizes an image to target dimensions
  Future<File> resizeImage(
    String imagePath, {
    int? targetWidth,
    int? targetHeight,
    int quality = 85,
  }) async {
    try {
      File resizedFile = await FlutterNativeImage.compressImage(
        imagePath,
        quality: quality,
        targetWidth: targetWidth ?? 0,
        targetHeight: targetHeight ?? 0,
      );
      return resizedFile;
    } catch (e) {
      throw Exception('Error resizing image: $e');
    }
  }
}
