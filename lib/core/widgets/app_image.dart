import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Displays local assets or cached HTTP(S) images through one consistent API.
class AppImage extends StatelessWidget {
  const AppImage(
    this.source, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.placeholder,
    this.errorWidget,
    this.color,
    this.filterQuality = FilterQuality.low,
  });

  final String source;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Alignment alignment;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? color;
  final FilterQuality filterQuality;

  bool get _isNetworkImage {
    final uri = Uri.tryParse(source);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Widget get _fallback =>
      errorWidget ?? const ColoredBox(color: Color(0xFFEDEDED));

  bool get _isSvg => source.toLowerCase().endsWith('.svg');

  File get _localFile {
    final uri = Uri.tryParse(source);
    return uri?.scheme == 'file' ? File.fromUri(uri!) : File(source);
  }

  bool get _isLocalFile => !_isNetworkImage && _localFile.existsSync();

  @override
  Widget build(BuildContext context) {
    if (source.isEmpty) return _fallback;

    if (_isNetworkImage) {
      return CachedNetworkImage(
        imageUrl: source,
        width: width,
        height: height,
        fit: fit,
        filterQuality: filterQuality,
        alignment: alignment,
        placeholder: (_, __) => placeholder ?? _fallback,
        errorWidget: (_, __, ___) => _fallback,
      );
    }

    if (_isLocalFile) {
      return Image.file(
        _localFile,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        color: color,
        filterQuality: filterQuality,
        errorBuilder: (_, __, ___) => _fallback,
      );
    }

    if (_isSvg) {
      return SvgPicture.asset(
        source,
        width: width,
        height: height,
        fit: fit ?? BoxFit.contain,
        alignment: alignment,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color!, BlendMode.srcIn),
        placeholderBuilder: (_) => _fallback,
      );
    }

    return Image.asset(
      source,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      filterQuality: filterQuality,
      errorBuilder: (_, __, ___) => _fallback,
    );
  }
}
