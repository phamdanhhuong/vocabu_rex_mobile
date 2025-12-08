import 'package:flutter/material.dart';

/// Wrapper widget để tạo fade animation và đảm bảo minimum loading time
class SmoothLoadingWrapper extends StatefulWidget {
  final Widget loadingWidget;
  final Widget contentWidget;
  final bool isLoading;
  final Duration minimumLoadingDuration;
  final Duration fadeDuration;

  const SmoothLoadingWrapper({
    super.key,
    required this.loadingWidget,
    required this.contentWidget,
    required this.isLoading,
    this.minimumLoadingDuration = const Duration(milliseconds: 800),
    this.fadeDuration = const Duration(milliseconds: 400),
  });

  @override
  State<SmoothLoadingWrapper> createState() => _SmoothLoadingWrapperState();
}

class _SmoothLoadingWrapperState extends State<SmoothLoadingWrapper> {
  bool _showLoading = true;
  bool _hasDataLoaded = false;
  DateTime? _loadingStartTime;

  @override
  void initState() {
    super.initState();
    if (widget.isLoading) {
      _loadingStartTime = DateTime.now();
    }
  }

  @override
  void didUpdateWidget(SmoothLoadingWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Khi bắt đầu loading
    if (widget.isLoading && !oldWidget.isLoading) {
      _loadingStartTime = DateTime.now();
      setState(() {
        _showLoading = true;
        _hasDataLoaded = false;
      });
    }

    // Khi data đã load xong
    if (!widget.isLoading && oldWidget.isLoading) {
      _hasDataLoaded = true;
      _handleLoadingComplete();
    }
  }

  void _handleLoadingComplete() async {
    if (_loadingStartTime == null) {
      setState(() => _showLoading = false);
      return;
    }

    final elapsed = DateTime.now().difference(_loadingStartTime!);
    final remaining = widget.minimumLoadingDuration - elapsed;

    // Nếu chưa đủ minimum time, đợi thêm
    if (remaining.inMilliseconds > 0) {
      await Future.delayed(remaining);
    }

    // Sau đó mới fade out
    if (mounted) {
      setState(() => _showLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.fadeDuration,
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: _showLoading
          ? KeyedSubtree(
              key: const ValueKey('loading'),
              child: widget.loadingWidget,
            )
          : KeyedSubtree(
              key: const ValueKey('content'),
              child: widget.contentWidget,
            ),
    );
  }
}
